// Shift Leds

`define N_LEDS 4
`define NB_SEL 2
`define NB_COUNT 32
`define NB_SW 4
`define NB_BTN 4

module shiftleds
    #(
        parameter  N_LEDS    =  `N_LEDS    ,
        parameter  NB_SEL    =  `NB_SEL    ,
        parameter  NB_COUNT  =  `NB_COUNT  ,
        parameter  NB_BTN    =  `NB_BTN ,
        parameter  NB_SW     =  `NB_SW  
        
    )
    (
        output  [N_LEDS - 1 : 0] o_led_r ,
        output  [N_LEDS - 1 : 0] o_led_b ,
        output  [N_LEDS - 1 : 0] o_led_g ,
        output  [NB_BTN  - 1 : 0] o_led ,
        input   [NB_SW  - 1 : 0] i_sw ,
        input   [NB_BTN  - 1 : 0] i_btn ,
        input                    clock ,
        input                    ck_rst
    );

    // Velocidades de shifteo de los LEDs
    localparam R0       = (2**(NB_COUNT-10))-1  ;
    localparam R1       = (2**(NB_COUNT-9)) -1  ;
    localparam R2       = (2**(NB_COUNT-8)) -1  ;
    localparam R3       = (2**(NB_COUNT-7)) -1  ;

    // Selectores de velocidades 00;01;10;11 para los i_sw
    localparam SEL0     = `NB_SEL'h0 ;
    localparam SEL1     = `NB_SEL'h1 ;
    localparam SEL2     = `NB_SEL'h2 ;
    localparam SEL3     = `NB_SEL'h3 ;


    // Vars
    wire [NB_COUNT - 1 : 0] ref_limit ;
    reg [NB_COUNT  - 1 : 0] counter   ;
    reg [N_LEDS    - 1 : 0] shiftreg  ;
    reg [N_LEDS    - 1 : 0] flash     ;
    reg [N_LEDS    - 1 : 0] selector  ;
    reg                     sel_SR_FS ;
    reg                     sel_SR_FS_led ;// Led de ShitfReg/Flash
    reg [2:0]      sel_color ;
    reg [2:0]      sel_color_led ;// Led de color elegido
    wire                    init      ;
    wire                    reset     ;

    assign reset     =  ~ck_rst; // 1'b1 sin apretar
    assign init      =  i_sw[0];
    assign ref_limit = (i_sw[(NB_SW-1)-1 -: NB_SEL]==SEL0) ? R0 :
                       (i_sw[(NB_SW-1)-1 -: NB_SEL]==SEL1) ? R1 :
                       (i_sw[(NB_SW-1)-1 -: NB_SEL]==SEL2) ? R2 : R3;

    always@(posedge clock or posedge reset) begin
        // Pongo el reset con prioridad 
        if(reset) begin
            // Resets de elementos
            // Counter = 0
            // shiftreg = 0001
            // flash = 0
            counter  <= {NB_COUNT{1'b0}};
            shiftreg <= {{N_LEDS-1{1'b0}},{1'b1}};
            flash    <= {N_LEDS{1'b0}};
        end
        else if(init) begin

            if(counter>=ref_limit)begin
                counter  <= {NB_COUNT{1'b0}};
                // Con i_sw elijo desplazamiento
                //  0'b0 => 1,2,4,8
                //  1'b0 => 8,4,2,1
                if (i_sw[3] == 1'b0)
                    shiftreg <= {shiftreg[N_LEDS-2 -: N_LEDS-1],shiftreg[N_LEDS-1]};
                else
                    shiftreg <= {shiftreg[0],shiftreg[N_LEDS-1 -: N_LEDS-1]};
                flash <= ~flash;
            end
            else begin
                counter  <= counter + {{NB_COUNT-1{1'b0}},{1'b1}};
                shiftreg <= shiftreg;
                flash    <= flash;
            end
        end
        else begin
            counter  <= counter;
            shiftreg <= shiftreg;
            flash    <= flash;
        end // if (init)
    end // always@ (posedge clock or posedge reset)

    //************************************************************

    // Boton de selector de ShiftReg vs Flash
    always@(posedge clock or posedge reset) begin
        if(reset) begin
            sel_SR_FS <= 1'b0; // Reseteo a ShiftReg
            sel_SR_FS_led <= 1'b0;
        end
        else begin
            sel_SR_FS <= i_btn[0];
            sel_SR_FS_led <= (i_btn[0] && (!sel_SR_FS)) ?   !sel_SR_FS_led :
                                                            sel_SR_FS_led  ;
        end
    end // always@ (posedge clock or posedge reset)

    //************************************************************

    // Boton de prendido de un led de color
    always@(posedge clock or posedge reset) begin
        if(reset) begin
            sel_color_led[2:0] <= 3'b001; // Reseteo para prender solo el r
        end
        else begin
            sel_color[2:0] <= i_btn[3:1];

            sel_color_led[2:0] <=   (i_btn[1] && (!sel_color[0])) ? 3'b001 :
                                    (i_btn[2] && (!sel_color[1])) ? 3'b010 :
                                    (i_btn[3] && (!sel_color[2])) ? 3'b100 : 
                                    sel_color_led[2:0];
        end
    end // always@ (posedge clock or posedge reset)


    //************************************************************
        
        assign o_led_r = (sel_color_led[0]) ? 
                            ((sel_SR_FS_led) ? flash : shiftreg) :
                            4'b0;
        assign o_led_g = (sel_color_led[1]) ? 
                            ((sel_SR_FS_led) ? flash : shiftreg) :
                            4'b0;
        assign o_led_b = (sel_color_led[2]) ? 
                            ((sel_SR_FS_led) ? flash : shiftreg) :
                            4'b0;
        assign o_led = {sel_color_led,sel_SR_FS_led};
endmodule // shiftleds

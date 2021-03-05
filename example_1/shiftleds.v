// Definition of global parameters
// used with C-like syntax and a `
`define N_LEDS 4 	// Number of RGB LEDS to use
`define NB_SEL 2 	//
`define NB_COUNT 32 // Number of bits of counter
`define NB_SW 4 	// Number of switches usage
`define NB_BTN 4 	// Number of buttons

module shiftleds
	// Inicialize global parameters of module with #() before IO assignments
    #(
        parameter  N_LEDS    =  `N_LEDS    ,
        parameter  NB_SEL    =  `NB_SEL    ,
        parameter  NB_COUNT  =  `NB_COUNT  ,
        parameter  NB_BTN    =  `NB_BTN ,
        parameter  NB_SW     =  `NB_SW
    )
	// Assign input/output buses with their respective sizes
    (
        output  [N_LEDS - 1 : 0] o_led_r , // R-color of all LEDS
        output  [N_LEDS - 1 : 0] o_led_b , // B-color of all LEDS
        output  [N_LEDS - 1 : 0] o_led_g , // G-color of all LEDS
        output  [NB_BTN - 1 : 0] o_led   , // Single-terminal LEDS

        input   [NB_SW  - 1 : 0] i_sw    , // Input switches
        input   [NB_BTN - 1 : 0] i_btn   , // input buttons
        input                    clock   , // clock signal
        input                    ck_rst    // reset signal
    );

    // Select shift-speed. Rn will be the amount of clocks to wait until the
	// next generation of a pulse
    localparam R0 = (2**(NB_COUNT-10))-1 ;
    localparam R1 = (2**(NB_COUNT-9)) -1 ;
    localparam R2 = (2**(NB_COUNT-8)) -1 ;
    localparam R3 = (2**(NB_COUNT-7)) -1 ;

    // Speed selector options. This will be linked to switch-values
    localparam SEL0     = `NB_SEL'h0 ; // ex 2'h0 will be 4b'0000
    localparam SEL1     = `NB_SEL'h1 ;
    localparam SEL2     = `NB_SEL'h2 ;
    localparam SEL3     = `NB_SEL'h3 ;


    // Different variables wires/registers to be used
	wire  [NB_COUNT-1:0]  ref_limit      ; // Selected limit (speed)
	reg   [NB_COUNT-1:0]  counter        ; // counter real value
	reg   [N_LEDS-1:0]    shiftreg       ; // shitfreg output (will run LEDS)
	reg   [N_LEDS-1:0]    flash          ; // this will flash leds (i.e. turn all on)
	reg                   sel_SR_FS      ; // select SR=shiftregister or FS=flash mode
	reg                   sel_SR_FS_led  ; // state of LED assosiated to mode-selector
	reg   [3:1]           sel_color      ; // which LED color is turned on
	// sel_color will be which color is chosed to be turned on:
	// 		sel_color[1] is 1'b1 if R
	// 		sel_color[2] is 1'b1 if b
	// 		sel_color[3] is 1'b1 if G
	reg   [3:1]           sel_color_led  ; // LED associated to the button pres

	wire                  init           ; // global enable signal
	wire                  reset          ; // global reset signal

	// CLOCK signal is normal open, so I need to invert it to detect rising
	// edges (or posedges)
    assign reset     =  ~ck_rst;
    assign init      =  i_sw[0]; // First switch will be the enable

	// Select the speed of the SR with i_sw[1:3]
    assign ref_limit = (i_sw[(NB_SW-1)-1 -: NB_SEL]==SEL0) ? R0 :
                       (i_sw[(NB_SW-1)-1 -: NB_SEL]==SEL1) ? R1 :
                       (i_sw[(NB_SW-1)-1 -: NB_SEL]==SEL2) ? R2 : R3;


    //************************************************************
	// This always loop will handle the main logic of the system
	// It will drive the shift=reg, toggle the flash state
    always@(posedge clock or posedge reset) begin
        // RESET signal is chosen to have the greatest priority
        if(reset) begin
            // Inicialize all relevant values
            // Counter = 32'b0 (ex)
            // shiftreg = 4'b0001
            // flash = 4'b0
			//
			// I use <= to have a non-obstructive flow. Everything is
			// connected together and runs "simultaniously"
			//
			// Verilog expansions: {4{1'b0}} == 4'b0000
            counter  <= {NB_COUNT{1'b0}};
            shiftreg <= {{N_LEDS-1{1'b0}},{1'b1}}; // ex 4'b0001
            flash    <= {N_LEDS{1'b0}};
        end
		// Then I check enable signal
        else if(init) begin
            if(counter>=ref_limit)begin
				// Every time the counter reaches the limit it gets reset
				// and then effectibly shift the output and toggle the
				// flash-ed
                counter  <= {NB_COUNT{1'b0}};

                // I will use i_sw[3] to select the shitf direction
                //  0'b0 => 1,2,4,8
                //  1'b0 => 8,4,2,1
                if (i_sw[3] == 1'b0)
					// Abuse Verilog expansions to shift the output state
					// accordingly
                    shiftreg <= {shiftreg[N_LEDS-2 -: N_LEDS-1],shiftreg[N_LEDS-1]};
                else
                    shiftreg <= {shiftreg[0],shiftreg[N_LEDS-1 -: N_LEDS-1]};

				// Toggle the flash state
                flash <= ~flash;
            end
            else begin
                counter  <= counter + {{NB_COUNT-1{1'b0}},{1'b1}};
                shiftreg <= shiftreg;
                flash    <= flash;
            end
        end
        else begin
			// If not init, everything stays the same.
            counter  <= counter;
            shiftreg <= shiftreg;
            flash    <= flash;
        end // if (init)
    end // always@ (posedge clock or posedge reset)


    //************************************************************
	// This handle the mode-selection.
	// It checks the state of the i_btn[0] and and set the according
	// state LED on/off
    always@(posedge clock or posedge reset) begin
        if(reset) begin
			// The reset state is to use the SR to drive the LEDs
			// and to have the state LED off.
            sel_SR_FS <= 1'b0;
            sel_SR_FS_led <= 1'b0;
        end
        else begin
			// i need to generate a buffer register to check for a rising edge
			// on the button press.
			// button_edge = button_state[now] AND ( NOT button_state[now-1])
            sel_SR_FS <= i_btn[0];
            sel_SR_FS_led <= (i_btn[0] && (!sel_SR_FS)) ? !sel_SR_FS_led :
                                                          sel_SR_FS_led  ;

			/*   AWESOME EPIC DRAWING OF AWESOMENESS
			*              _________________     __
			*             |      ______     |___|  )______ sel_SR_FS_led
			* sel_SR_FS___|______|D  Q|_______o_|__)
			*                    |    |           AND
			*              clk___|____|
			*/
        end
    end // always@ (posedge clock or posedge reset)

    //************************************************************
    // This will handle all the color-selection buttons
    always@(posedge clock or posedge reset) begin
        if(reset) begin
			// Reset state is R color
            sel_color_led <= 3'b001; // Reseteo para prender solo el r
        end
        else begin
			// Same thing, I need to infer a register to check against
            sel_color <= i_btn[3:1];
			// Depending on which button is pressed I HARDCODE the led color
			// state.
			// I don't need to worry about many button presses this way, it
			// always will send the correct output color
            sel_color_led <=   (i_btn[1] && (!sel_color[1])) ? 3'b001 :
                               (i_btn[2] && (!sel_color[2])) ? 3'b010 :
                               (i_btn[3] && (!sel_color[3])) ? 3'b100 :
                               sel_color_led;
        end
    end // always@ (posedge clock or posedge reset)


    //************************************************************
	// OUTPUT assignments.
	// I check if the color is ON. If it is, I check which mode should be
	// acting, if the shifting or the flash

	assign o_led_r = (sel_color_led[0]) ?
						((sel_SR_FS_led) ? flash : shiftreg) :
						4'b0;
	assign o_led_g = (sel_color_led[1]) ?
						((sel_SR_FS_led) ? flash : shiftreg) :
						4'b0;
	assign o_led_b = (sel_color_led[2]) ?
						((sel_SR_FS_led) ? flash : shiftreg) :
						4'b0;

	// this is the "button pressed output LEDS"
	assign o_led = {sel_color_led,sel_SR_FS_led};
endmodule // shiftleds

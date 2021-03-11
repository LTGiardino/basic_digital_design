module top_full_design
    #(
        parameter NB_ADDR = 10,
        parameter NB_DATA = 8
    )
    (
        output [NB_DATA - 1 : 0] o_log_data_from_ram, // Data extraction
        output o_log_ram_full, // RAM FULL flag

        input [2:0] i_enable,
            //i_enable[0]: enable signal generator and filter
            //i_enable[1]: enable FSM (logging)
            //i_enable[2]: enable ReadCounter (reading from RAM)
        input [1:0] i_sel, // Buttons to select signal generator
        input i_reset,
        input clock
    );

wire [NB_DATA - 1 : 0] gen_signals [3:0];
wire [NB_DATA - 1 : 0] mux_o_signal;
wire [NB_DATA - 1 : 0] filtered_signal;

wire i_reset_neg;
assign i_reset_neg = ~i_reset;

reg [1:0] i_sel_prevstate;
reg [1:0] i_sel_picker;



// Create all four signal generators with the specified hex data file
//
// NOTE: Here signal_generator only has a reset input.
// It works both as a reset signal AND the enable one.
// b/c reset freezes the counter to 0 forever (i.e. disabling it)
signal_generator
    #(
        .MEM_INIT_FILE ("signals/mem17khz.hex")
    )
    u_signal_generator_0
    (
        .i_clock(clock),
        .i_reset(i_reset_neg || ~i_enable[0]),
        .o_signal(gen_signals[0])
    );

signal_generator
    #(
        .MEM_INIT_FILE ("signals/mem4p25khz.hex")
    )
    u_signal_generator_1
    (
        .i_clock(clock),
        .i_reset(i_reset_neg || ~i_enable[0]),
        .o_signal(gen_signals[1])
    );

signal_generator
    #(
        .MEM_INIT_FILE ("signals/mem5p666khz.hex")
    )
    u_signal_generator_2
    (
        .i_clock(clock),
        .i_reset(i_reset_neg || ~i_enable[0]),
        .o_signal(gen_signals[2])
    );

signal_generator
    #(
        .MEM_INIT_FILE ("signals/mem8p5khz.hex")
    )
    u_signal_generator_3
    (
        .i_clock(clock),
        .i_reset(i_reset_neg || ~i_enable[0]),
        .o_signal(gen_signals[3])
    );

filtro_fir
    u_filtro_fir
    (
        .clk (clock),
        .i_srst (i_reset_neg),
        .i_en (i_enable[0]),
        .i_data (mux_o_signal),
        .o_data (filtered_signal)
    );

// Inicialize the BRAM to log data
fsmRam
    #(
        .NB_ADDR (NB_ADDR),
        .NB_DATA (NB_DATA)
    )
    u_fsmRam
    (
        .o_log_data_from_ram(o_log_data_from_ram),
        .o_log_ram_full (o_log_ram_full),
        .i_data(filtered_signal),
        .i_enable (i_enable),
        .i_reset (i_reset),
        .clock (clock)
    );

always @ (posedge clock or posedge i_reset) begin // signal selector
    if (i_reset_neg == 1'b1) begin
        // If reset is on then pick signal 0 and start anew
        i_sel_prevstate <= 2'b00;
        i_sel_picker    <= 2'b00;
    end else begin
        // Whenever a button is pressed, I toggle that bit on the mux selector input
        // To find a rising edge I need to compare against a previous state of i_sel
        // so I need to store it on a reg
        i_sel_prevstate <= i_sel;
        i_sel_picker[0] <= (i_sel[0] && (!i_sel_prevstate[0])) ? ~i_sel_picker[0]:
                                                                  i_sel_picker[0]; 

        i_sel_picker[1] <= (i_sel[1] && (!i_sel_prevstate[1])) ? ~i_sel_picker[1]:
                                                                  i_sel_picker[1]; 
    end // reset
end // signal selector

// Really multiplex the signals
assign mux_o_signal =  (i_sel_picker == 2'b00) ? gen_signals[0] :
                       (i_sel_picker == 2'b01) ? gen_signals[1] :
                       (i_sel_picker == 2'b10) ? gen_signals[2] :
                                                 gen_signals[3] ;

endmodule 


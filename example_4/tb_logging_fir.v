`timescale 1ns/100ps
module tb_logging_fir ();

parameter NB_DATA = 8;

reg [2:0] i_enable;
reg [1:0] i_sel;
reg i_reset;
reg clock;

wire [NB_DATA - 1 : 0] o_log_data_from_ram;
wire o_log_ram_full;

initial begin
    i_enable = 3'b000;
    i_reset  = 1'b0;
    clock    = 1'b1;
    i_sel    = 2'b00;

    #2000  i_reset  = 1'b1;

    #1000 i_enable = 3'b001;  // ENABLE SIGNALS &  FILTER
    #1000 i_enable = 3'b011;  // ENABLE LOGGING IN BRAM
    #20000 i_enable = 3'b101; // ENABLE DATA UNLOADING
    #1000 i_enable = 3'b000;  // STOP EVERYTHING

    #10000 i_sel = 2'b01;
    #100   i_sel = 2'b00;

    #1000 i_enable = 3'b001;
    #1000 i_enable = 3'b011;
    #10000 i_enable = 3'b101;
    #1000 i_enable = 3'b000;
 
    #10000 i_sel = 2'b01;
    #100   i_sel = 2'b00;

    #1000 i_enable = 3'b001;
    #1000 i_enable = 3'b011;
    #10000 i_enable = 3'b101;
    #1000 i_enable = 3'b000;

    #10000 i_sel = 2'b10;
    #100   i_sel = 2'b00;

    #1000 i_enable = 3'b001;
    #1000 i_enable = 3'b011;
    #10000 i_enable = 3'b101;

    #5000 $finish;
end

always #5 clock = ~clock;

top_full_design
    #(
        .NB_ADDR (10),
        .NB_DATA (8)
    )
    u_design
    (
        .o_log_data_from_ram(o_log_data_from_ram),
        .o_log_ram_full(o_log_ram_full),
        .i_enable(i_enable),
        .i_reset(i_reset),
        .i_sel(i_sel),
        .clock(clock)
    );

endmodule

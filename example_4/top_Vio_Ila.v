`timescale 1ns / 1ps

module top_Vio_Ila
    #(
        parameter NB_DATA = 8
    )
    (
        input clock
    );

wire [NB_DATA-1 : 0] o_log_data_from_ram;
wire o_log_ram_full;
reg [2:0] i_enable;
reg [1:0] i_sel;
reg i_reset;

vio
    u_vio
    (
        .clk_0        (clock),
        .probe_in0_0  (o_log_data_from_ram),
        .probe_in1_0  (o_log_ram_full),
        .probe_out0_0 (i_enable),
        .probe_out1_0 (i_reset),
        .probe_out2_0 (i_sel)
    );

ila
    u_ila
    (
        .clk_0    (clock),
        .probe0_0 (o_log_data_from_ram),
        .probe1_0 (o_log_ram_full)
    );

top_full_design
    u_design
    (
        .o_log_data_from_ram  (o_log_data_from_ram),
        .o_log_ram_full       (o_log_ram_full),
        .i_enable             (i_enable),
        .i_sel                (i_sel),
        .i_reset              (i_reset),
        .clock                (clock)
    );

endmodule

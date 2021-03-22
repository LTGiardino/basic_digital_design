`timescale 1ns/1ps

module tb_fir_filter ();

// set Word-width
localparam WW = 16;

// clk, enable and resets
reg tb_clk = 1'b1;
reg tb_en;
reg tb_srst;

// Input Stream
reg [WW-1:0] tb_is_data;
reg tb_is_dv;
wire tb_is_rfd;

// Output Stream
wire [0+WW-1:0] tb_os_data;
wire tb_os_dv;
reg tb_os_rfd;

// Ancilliary Signals
reg aux_tb_en;
reg aux_tb_srst;
reg [WW-1:0] aux_tb_is_data;
reg aux_tb_is_dv;
reg aux_tb_os_rfd;

// Unit Under Test
fir_filter
	#(
		.WW_INPUT (WW),
		.WW_OUTPUT (WW+0)
	)
	dut (
		// clock, reset, enable
		.clk (tb_clk),
		.i_srst (tb_srst),
		.i_en (tb_en),

		// Input Stream(
		.i_is_data (tb_is_data),
		.i_is_dv (tb_is_dv),
		.o_is_rfd (tb_is_rfd),

		// Output Stream
		.o_os_data (tb_os_data),
		.o_os_dv (tb_os_dv),
		.i_os_rfd (tb_os_rfd)
	);

// Clock Period = 40clk
always #20 tb_clk <= ~tb_clk;

always @(posedge tb_clk) begin
	tb_en <= aux_tb_en;
	tb_srst <= aux_tb_srst;
	tb_is_data <= aux_tb_is_data;
	tb_is_dv <= aux_tb_is_dv;
	tb_os_rfd <= aux_tb_os_rfd;
end

// Stimulus
real i;
real aux;
initial begin
	$display("");
	$display("Simulation Started");
	//$dumpfile("./verification/waves.vcd");
	//$dumpvars(0, tb_fir_filter);
	#5
	aux_tb_en <= 1'b1;
	aux_tb_srst <= 1'b1;
	aux_tb_is_data <= 16'b0010_0000_0000_0000;
	aux_tb_is_dv <= 1'b1;
	aux_tb_os_rfd <= 1'b1;
	#40;
	aux_tb_en <= 1'b1;
	aux_tb_srst <= 1'b0;
	#40;
	aux_tb_is_data <= 16'b0000_0000_0000_0000;
	#1000
	aux_tb_is_data <= 16'b0010_0000_0000_0000;
	#40;
	aux_tb_is_data <= 16'b0000_0000_0000_0000;
	#1000
	aux_tb_is_data <= 16'b0010_0000_0000_0000;
	#1000
	aux_tb_is_data <= 16'b0000_0000_0000_0000;
	#1000
	for (i=0;i<4000;i=i+1) begin
		// Generate a sin waveform using verilog (or vivado?) helper function.
		// I generate the signal with a a given frecuency an then scale it to
		// fit the WW.
		// I create a sample every 40clk (i.e. every period) This number can
		// be changed to see aliasing-like effects
		aux <= $sin(2.0*3.1415926*i/25000.0*1000.0)*(2**13);
		aux_tb_is_data <= aux;
		#40;
	end
	$display("Simulation Finished");
	$display("");
	$finish;
end

endmodule //tb_fir_filter

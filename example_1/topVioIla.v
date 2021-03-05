// Top level module to integrate test-bench with other IP cores
// I will be using:
// 		VIO (virtual input/output) to interact with the testbench
// 		ILA (integrated logic analyzer) to see the real FPGA outputs on my
//	 		machine
module top
	#(
		parameter NB_LEDS  = 4 ,
		parameter NB_COUNT = 32,
		parameter NB_SW    = 4
	)
	(
		// I do not need this values as registers, b/c i will be using them with
		// the other IP cores. << This needs to be reflected on the contraint
		// files, there should not be anything assigned to this outputs. Just for
		// the clock signal (which obviously will be the FPGA's internal one)

		// output  [NB_LEDS-1:0]  o_led    ,
		// output  [NB_LEDS-1:0]  o_led_b  ,
		// output  [NB_LEDS-1:0]  o_led_g  ,
		// input   [NB_LEDS-1:0]  i_sw     ,
		// input                  i_reset  ,
		input                  clock
	);

	// All the endpoints will be wires to connect VIO and ILA with the module
	wire [NB_LEDS - 1 : 0] o_led;
	wire [NB_LEDS - 1 : 0] o_led_b;
	wire [NB_LEDS - 1 : 0] o_led_g;
	wire [NB_LEDS - 1 : 0] i_sw;
	wire [NB_LEDS - 1 : 0] i_btn;
	wire 		           i_reset;

	// Instance VIO ip-core
 	vio u_vio (
 		.clk_0        (clock  ) ,
 		.probe_in0_0  (o_led  ) ,
 		.probe_in1_0  (o_led_r) ,
 		.probe_in2_0  (o_led_g) ,
 		.probe_in3_0  (o_led_b) ,
 		.probe_out0_0 (i_reset) ,
		.probe_out1_0 (i_sw   ) ,
		.probe_out2_0 (i_btn  )
	);

	// Instance ILA ip core
	ila u_ila (
		.clk_0    (clock),
		.probe0_0 (o_led)
	);


	// Instance my module to shiftleds
	shiftleds
		#(
			.N_LEDS(NB_LEDS),
			.NB_COUNT(NB_COUNT)
		)
		u_shiftleds (
			.o_led_r (o_led_r) ,
			.o_led_b (o_led_b) ,
			.o_led_g (o_led_g) ,
			.o_led   (o_led  ) ,
			.i_sw    (i_sw   ) ,
			.i_btn   (i_btn  ) ,
			.clock   (clock  ) ,
			.ck_rst  (i_reset)
		);
endmodule // top

// Test-Bench of module:
// ShiftLeds
`define N_LEDS   4
`define NB_SEL   2
`define NB_COUNT 14 // I use a lower count number b/c I really don't need 32bit
`define NB_SW    4
`define NB_BTN   4

// Set the timescale to emulate Artix-7 board
`timescale 1ns/100ps

module tb_shiftleds();
	parameter N_LEDS   = `N_LEDS   ;
	parameter NB_SEL   = `NB_SEL   ;
	parameter NB_COUNT = `NB_COUNT ;
	parameter NB_SW    = `NB_SW    ;
	parameter NB_BTN   = `NB_BTN   ;

	// I select all outputs as wires and all inputs as registers.
	// b/c i need them to be stored somewehere, right?
	wire [NB_BTN-1:0]   o_led    ;
	wire [N_LEDS-1:0]   o_led_r  ;
	wire [N_LEDS-1:0]   o_led_b  ;
	wire [N_LEDS-1:0]   o_led_g  ;
	reg  [NB_SW-1 :0]   i_sw     ;
	reg  [NB_BTN-1:0]   i_btn    ;
	reg                 i_reset  ;
	reg                 clock    ;
	wire [NB_COUNT-1:0] tb_count ;

	// get a scope point to register counter value on the waveform
	assign tb_count = tb_shiftleds.u_shiftleds.counter;

	// Run initial to set everything ONCE at first and that's it
	initial begin
		// inicialize inputs
		i_sw[0]    = 1'b0       ; // i_sw[0] = ENABLE
		clock      = 1'b0       ;
		i_reset    = 1'b0       ; // do not reset yet
		i_sw[2:1]  = `NB_SEL'h0 ; // all other switches on 0
		i_sw[3]    = 1'b0       ;
		i_btn[3:0] = 4'b0000    ; // all buttons not pressed

		// wait 100 clocks and set enable and reset
		#100 i_reset = 1'b1;
		#100 i_sw[0] = 1'b1;

		// Begin pressing buttons for 100 clocks (simulating a push and
		// release of a real button).
		// This should probably be better off written on an external file

		// Change mode. SR -> Flash
		#1000 i_btn[0] = 1'b1;
		#100  i_btn[0] = 1'b0;

		// Enable RED color (this should already be enabled so nothing must
		// happen)
		#1000 i_btn[1] = 1'b1;
		#100  i_btn[1] = 1'b0;

		// Change mode. Flash -> SR
		#1000 i_btn[0] = 1'b1;
		#100  i_btn[0] = 1'b0;

		// Enable GREEN color.
		#1000 i_btn[2] = 1'b1;
		#100  i_btn[2] = 1'b0;

		// Change mode. SR -> Flash
		#1000 i_btn[0] = 1'b1;
		#100  i_btn[0] = 1'b0;

		// Enable BLUE color
		#1000 i_btn[3] = 1'b1;
		#100  i_btn[3] = 1'b0;

		// Change mode. Flash -> SR
		#1000 i_btn[0] = 1'b1;
		#100  i_btn[0] = 1'b0;

		// Wait and finish
		#1000 $finish;
	end

	// Select the clock frecuency 5clocks HIGH 5clocks LOW.
	// each clock is 1ns, so 10ns clock period
	always #5 clock = ~clock;

	// Instance shiftleds module
	shiftleds
		// Set the global vraiables
	  #(
		  .N_LEDS   (N_LEDS  ),
		  .NB_SEL   (NB_SEL  ),
		  .NB_COUNT (NB_COUNT),
		  .NB_SW    (NB_SW   )
	  )
	  // select instance name and connect all end-points to test-bench
	  // registers/wires
	  u_shiftleds
	  (
		  .o_led     (o_led  ),
		  .o_led_r   (o_led_r),
		  .o_led_b   (o_led_b),
		  .o_led_g   (o_led_g),
		  .i_sw      (i_sw   ),
		  .i_btn     (i_btn  ),
		  .ck_rst    (i_reset),
		  .clock     (clock  )
	  );

endmodule // tb_shiftleds

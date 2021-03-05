
//`define NB_LEDS 4

module top 
  #(
    parameter NB_LEDS  = 4 ,
    parameter NB_COUNT = 32,
    parameter NB_SW    = 4
    )
   (
//    output [NB_LEDS - 1 : 0] o_led,
//    output [NB_LEDS - 1 : 0] o_led_b,
//    output [NB_LEDS - 1 : 0] o_led_g,
//    input [NB_LEDS - 1 : 0]  i_sw,
//    input 		     i_reset,
    input 		     clock
    );
    
    wire [NB_LEDS - 1 : 0] o_led;
    wire [NB_LEDS - 1 : 0] o_led_b;
    wire [NB_LEDS - 1 : 0] o_led_g;
    wire [NB_LEDS - 1 : 0] i_sw;
    wire 		           i_reset;
    
   wire 		  connect_count_to_sr;
   wire [NB_LEDS - 1 : 0] connect_sh_to_out;
   
    
   vio
   u_vio
   (.clk_0        (clock),
    .probe_in0_0  (o_led),
    .probe_in1_0  (o_led_b),
    .probe_in2_0  (o_led_g),
    .probe_out0_0 (i_reset),
    .probe_out1_0 (i_sw)
    ); 
    
   ila
   u_ila
   (.clk_0    (clock),
    .probe0_0 (o_led)
    );
    
   count
     #(
       .NB_COUNT (NB_COUNT),
       .NB_SW    (NB_SW)
       )
     u_count(
	     .o_valid (connect_count_to_sr),
	     .i_sw    (i_sw[NB_SW-1:0]    ),
	     .i_reset (~i_reset            ),
	     .clock   (clock              )
	     );

   shiftreg
     #(
       .NB_LEDS(NB_LEDS)
       )
   u_shiftreg(
	      .o_led   (connect_sh_to_out  ),
	      .i_valid (connect_count_to_sr),
	      .i_reset (~i_reset            ),
	      .clock   (clock              )
	      );


   assign o_led    = connect_sh_to_out;
   assign o_led_b  = (i_sw[3]==1'b1) ? connect_sh_to_out : {NB_LEDS{1'b0}};
   assign o_led_g  = (i_sw[3]==1'b0) ? connect_sh_to_out : {NB_LEDS{1'b0}};


   
endmodule // top

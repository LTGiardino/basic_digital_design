
module fir_filter
#(
	parameter WW_INPUT = 8, // Input word-with
	parameter WW_OUTPUT = 8
)
(
	// clk, en, srst
	input clk,
	input i_en,
	input i_srst,
	// Input Stream
	input signed [WW_INPUT-1:0] i_is_data,
	input i_is_dv,
	output o_is_rfd,
	// Output Stream
	output signed [WW_OUTPUT-1:0] o_os_data,
	output o_os_dv,
	input i_os_rfd
);

	// Local Params
	localparam WW_COEFF = 8;

	// Internal Signals
	wire internal_en;
	// This way we can create "matrix" like objects.
	// ex: reg signed [7:0] var [3:0];
	// is going to be understood as 8 buses with a 4bit width (or smth like
	// that)
	reg  signed [WW_INPUT -1:0] register [3:1]; // 3 to 1
	wire signed [WW_COEFF-1:0] coeff [3:0]; // 3 to 0
	wire signed [WW_INPUT+WW_COEFF-1:0] prod [3:0]; // 3 to 0
	wire signed [WW_INPUT+WW_COEFF-1:0] sum [3:1]; // 3 to 1

	// Internal Enable
	assign internal_en = i_os_rfd & i_is_dv & i_en;

	// Coeffs c = [-1 1/2 -1/4 1/8]
	// this coeffs will determine the filter output,
	// what frecuency it effectible filters and misc
	assign coeff[0] = 8'b1000_0000;
	assign coeff[1] = 8'b0100_0000;
	assign coeff[2] = 8'b1110_0000;
	assign coeff[3] = 8'b0001_0000;

	// Shift Register
	always @(posedge clk) begin
		if (i_srst == 1'b1) begin
			// if reset is pressed set to 0's everything
			register[1] <= {WW_INPUT{1'b0}};
			register[2] <= {WW_INPUT{1'b0}};
			register[3] <= {WW_INPUT{1'b0}};
		end else begin
			if (internal_en == 1'b1) begin
				// Else, log make the necesary registers get the new value
				register[1] <= i_is_data;
				register[2] <= register[1];
				register[3] <= register[2];
			end
		end
	end

	// Products
	assign prod[0] = coeff[0] * i_is_data;
	assign prod[1] = coeff[1] * register[1];
	assign prod[2] = coeff[2] * register[2];
	assign prod[3] = coeff[3] * register[3];

	// Adders
	assign sum[1] = prod[0] + prod[1];
	assign sum[2] = sum[1] + prod[2];
	assign sum[3] = sum[2] + prod[3];


	// This will try to mimic this electric diagram:
	//
	// i_is_data ━━━━━┳━━━━▶ ━━━━┳━━━━▶ ━━━━━┳━━━━▶ ━━━━┓
	// (signal)       ┃          ┃           ┃          ┃
	//              ×c_0       ×c_1        ×c_2       ×c_3
	//                ┃          ┃           ┃          ┃
	//                ┗━━ S_1 ━━━┻━━━ S_2 ━━━┻━━━ S_3 ━━┻━━━━━ o_os_data
	//                                                         (filtered)
	//

	// Output
	//
	// This will set the correct output bits as the most significant ones
	// This reads like:
	// 		start at bit number WW_COEFF+WW_INPUT-1 and then take
	// 		WW_OUTPUT bits to the right
	//
	assign o_os_data = sum[3][WW_COEFF+WW_INPUT-1-:WW_OUTPUT];
	assign o_os_dv = 1'b1;
	assign o_is_rfd = 1'b1;

endmodule

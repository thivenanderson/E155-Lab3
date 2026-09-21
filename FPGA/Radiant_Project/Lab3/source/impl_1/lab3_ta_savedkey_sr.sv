//Name: Thiven Anderson
//Email: thanderson@g.hmc.edu
//Date: 9/19/2026
//Description: Keypad saved valid key shift register
module lab3_ta_savedkey_sr(
	input logic clk, reset, enable,
	input logic [1:0] col_decoded,
	input logic [3:0] row_decoded,
	output logic [1:0] saved_col,
	output logic [3:0] saved_row
	);
	always_ff @(posedge clk) begin
		if (!reset) begin
			saved_row <= 4'b0;
			saved_col <= 2'b0;
		end
		else if (enable) begin
			saved_row <= row_decoded;
			saved_col <= col_decoded;
		end
	end
endmodule
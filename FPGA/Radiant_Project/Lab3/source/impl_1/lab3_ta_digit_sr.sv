//Name: Thiven Anderson
//Email: thanderson@g.hmc.edu
//Date: 9/19/2026
//Description: Dual seven segment display shift register

module lab3_ta_digit_sr(
	input logic clk, reset, enable,
	input logic [3:0] digit,
	output logic [3:0] digit1, digit2
	);
	always_ff @(posedge clk) begin
		if (!reset) begin
			digit1 <= 4'b0000;
			digit2 <= 4'b0000;
		end
		else if(enable) begin
		  digit2 <= digit1;
		  digit1 <= digit;
		end
		else begin
		  digit2 <= digit2;
		  digit1 <= digit1;
		end
	end
	endmodule

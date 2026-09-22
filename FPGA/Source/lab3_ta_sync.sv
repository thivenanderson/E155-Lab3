//Name: Thiven Anderson
//Email: thanderson@g.hmc.edu
//Date: 9/19/2026
//Description: Generic two flop synchronizer

module lab3_ta_sync(   
	input logic clk,
	input logic [3:0] d,
	output logic [3:0] q
	);
	logic [3:0] n1;
		always_ff @(posedge clk)
		begin
			  n1 <= d;
			  q <= n1;
		end
		endmodule

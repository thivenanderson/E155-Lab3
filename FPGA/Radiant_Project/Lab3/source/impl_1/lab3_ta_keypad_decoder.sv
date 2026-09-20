//Name: Thiven Anderson
//Email: thanderson@g.hmc.edu
//Date: 9/19/2026
//Description: Keypad "matrix" decoder

module lab3_ta_keypad_decoder(
	input  logic [15:0] keypad,
	output logic [3:0] row_decoded,
	output logic [1:0] col_decoded,
	output logic [3:0] hex_decoded
	);
	
	always_comb begin
			case(keypad)
				16'b0000_0000_0000_0001: begin
					row_decoded = 4'b0001;
					col_decoded = 2'd0;
					hex_decoded = 4'hD;
				end
				16'b0000_0000_0000_0010: begin
					row_decoded = 4'b0001;
					col_decoded = 2'd1;
					hex_decoded = 4'hF;
				end
				16'b0000_0000_0000_0100: begin
					row_decoded = 4'b0001;
					col_decoded = 2'd2;
					hex_decoded = 4'h0;
				end
				16'b0000_0000_0000_1000: begin
					row_decoded = 4'b0001;
					col_decoded = 2'd3;
					hex_decoded = 4'hE;
				end
				16'b0000_0000_0001_0000: begin
					row_decoded = 4'b0010;
					col_decoded = 2'd0;
					hex_decoded = 4'hC;
				end
				16'b0000_0000_0010_0000: begin
					row_decoded = 4'b0010;
					col_decoded = 2'd1;
					hex_decoded = 4'h9;
				end
				16'b0000_0000_0100_0000: begin
					row_decoded = 4'b0010;
					col_decoded = 2'd2;
					hex_decoded = 4'h8;
				end
				16'b0000_0000_1000_0000: begin
					row_decoded = 4'b0010;
					col_decoded = 2'd3;
					hex_decoded = 4'h7;
				end
				16'b0000_0001_0000_0000: begin
					row_decoded = 4'b0100;
					col_decoded = 2'd0;
					hex_decoded = 4'hB;
				end
				16'b0000_0010_0000_0000: begin
					row_decoded = 4'b0100;
					col_decoded = 2'd1;
					hex_decoded = 4'h6;
				end
				16'b0000_0100_0000_0000: begin
					row_decoded = 4'b0100;
					col_decoded = 2'd2;
					hex_decoded = 4'h5;
				end
				16'b0000_1000_0000_0000: begin
					row_decoded = 4'b0100;
					col_decoded = 2'd3;
					hex_decoded = 4'h4;
				end
				16'b0001_0000_0000_0000: begin
					row_decoded = 4'b1000;
					col_decoded = 2'd0;
					hex_decoded = 4'hA;
				end
				16'b0010_0000_0000_0000: begin
					row_decoded = 4'b1000;
					col_decoded = 2'd1;
					hex_decoded = 4'h3;
				end
				16'b0100_0000_0000_0000: begin
					row_decoded = 4'b1000;
					col_decoded = 2'd2;
					hex_decoded = 4'h2;
				end
				16'b1000_0000_0000_0000: begin
					row_decoded = 4'b1000;
					col_decoded = 2'd3;
					hex_decoded = 4'h1;
				end
				default: begin
					row_decoded = 4'b1000;
					col_decoded = 2'd3;
					hex_decoded = 4'h0;	
				end
			endcase
		end
	endmodule

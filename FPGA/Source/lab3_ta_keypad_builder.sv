//Name: Thiven Anderson
//Email: thanderson@g.hmc.edu
//Date: 9/19/2026
//Description: Keypad "matrix" bulder in form of 16 bit logic

module lab3_ta_keypad_builder(
    input  logic        clk,
    input  logic        reset,
    input  logic        scan_tick,
    input  logic [1:0]  row_scan_idx,
    input  logic [3:0]  col_sync,

    output logic [15:0] keypad,
    output logic        scan_done
);

	always_ff @(posedge clk, negedge reset) begin
		if (!reset)
			keypad <= 16'b0;
		else if (scan_tick) begin
			case(row_scan_idx)
				2'd0: keypad[15:12] <= ~col_sync;
				2'd1: keypad[11:8] <= ~col_sync;
				2'd2: keypad[7:4] <= ~col_sync;
				2'd3: keypad[3:0] <= ~col_sync;
			endcase
		end
	end
	assign scan_done = (scan_tick && (row_scan_idx == 2'd3));
endmodule
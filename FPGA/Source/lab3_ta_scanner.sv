//Name: Thiven Anderson
//Email: thanderson@g.hmc.edu
//Date: 9/19/2026
//Description: Keypad row canning module using generic counter and output logic

module lab3_ta_scanner #(
		parameter SCAN_WIDTH = 17,  
		parameter SCAN_MAX_COUNT = 95_999)(
	input logic clk, reset, enable,
	output logic scan_tick,
	output logic [1:0] row_scan_idx,
	output logic [3:0] row_scan
	);
	
	
	logic [SCAN_WIDTH-1:0] scan_counter;
	//instantiate counter module
		lab2_ta_counter #(
    .WIDTH(SCAN_WIDTH),
    .MAX_COUNT(SCAN_MAX_COUNT) 	 	
		)i_SCAN_COUNTER(
        .clk(clk),
		.reset(reset),
		.enable(enable),
		.counter(scan_counter)
    );
	
	//output logic
	
	assign  row_scan[3]= (scan_counter <= SCAN_MAX_COUNT/4);
	assign row_scan[2] = (scan_counter > SCAN_MAX_COUNT/4 && scan_counter<= SCAN_MAX_COUNT/2);
	assign row_scan[1] = (scan_counter > SCAN_MAX_COUNT/2 && scan_counter<= 3*SCAN_MAX_COUNT/4);
	assign row_scan[0] = (scan_counter > 3*SCAN_MAX_COUNT/4);
	assign scan_tick = (scan_counter == SCAN_MAX_COUNT/4 ||scan_counter == SCAN_MAX_COUNT/2 ||scan_counter == 3*SCAN_MAX_COUNT/4 || scan_counter == SCAN_MAX_COUNT);
	always_comb begin
			case(row_scan)
				4'b1000: row_scan_idx = 2'd0;
				4'b0100: row_scan_idx = 2'd1;
				4'b0010: row_scan_idx = 2'd2;
				4'b0001: row_scan_idx = 2'd3;
				default: row_scan_idx = 2'd0;
			endcase
		end
	endmodule
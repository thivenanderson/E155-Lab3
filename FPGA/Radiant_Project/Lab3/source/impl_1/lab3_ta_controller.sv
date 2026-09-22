//Name: Thiven Anderson
//Email: thanderson@g.hmc.edu
//Date: 9/19/2026
//Description: Keypad to dual seven seg display control FSM
module lab3_ta_controller (
    input  logic        clk,
    input  logic        reset,

    input  logic        scan_done,
    input  logic [15:0] keypad,
    input  logic [3:0]  col_sync,
    input  logic        db_done,

    input  logic [3:0]  row_decoded,
    input  logic [1:0]  col_decoded,
	input logic [1:0]  saved_col,

    output logic        scan_enable, scan_reset,
    output logic        db_reset, db_enable,
    output logic        shift_enable,
	output logic save_enable
);
//Define states
typedef enum logic [2:0] {
    SCAN,
    CHECK,
    SAVE,
    SETTLE,
    WAIT,
    PULSE,
    PRESSED
} state_t;

state_t state, next_state;
//State transition timing
	always_ff @(posedge clk, negedge reset) begin
		if (!reset)
			state <= SCAN;
		else
			state <= next_state;
	end
//Next State Logic
	always_comb begin
		next_state = state;

		case (state)

			SCAN: begin
				if (scan_done)
					next_state = CHECK;
				else
					next_state = SCAN;
			end
			CHECK: begin
				if ($onehot(keypad))
					next_state = SAVE;
				else
					next_state = SCAN;
			end
			SAVE: begin
				next_state = SETTLE;
			end
			SETTLE: begin
				next_state = WAIT;
			end
			WAIT: begin
				if (col_sync[saved_col] == 1'b1)
					next_state = SCAN;       // key disappeared
				else if (db_done)
					next_state = PULSE;      // stayed low long enough
				else
					next_state = WAIT;
			end
			PULSE: begin
				next_state = PRESSED;
			end
			PRESSED: begin
				if (col_sync[saved_col] == 0)
					next_state = PRESSED;
				else
					next_state = SCAN;
			end
			default:
				next_state = SCAN;
		endcase
	end
//State control outputs
	always_comb begin
		scan_enable  = 0;
		scan_reset   = 0;
		db_reset     = 0;
		db_enable    = 0;
		shift_enable = 0;
		save_enable  = 0;

		case (state)

			SCAN: begin
				scan_enable  = 1;
				scan_reset   = 1;
				db_reset     = 0;
				db_enable    = 0;
				shift_enable = 0;
				save_enable  = 0;					
			end
			CHECK: begin
				scan_enable  = 0;
				scan_reset   = 0;
				db_reset     = 0;
				db_enable    = 0;
				shift_enable = 0;
				if ($onehot(keypad)) 
					save_enable = 1;
			end
			WAIT: begin
				scan_enable  = 0;
				scan_reset   = 0;
				db_reset     = 1;
				db_enable    = 1;
				shift_enable = 0;
				save_enable  = 0;
			end
			PULSE: begin
				scan_enable  = 0;
				scan_reset   = 0;
				db_reset     = 0;
				db_enable    = 0;
				shift_enable = 1;
				save_enable  = 0;
			end
			PRESSED: begin
				scan_enable  = 0;
				scan_reset   = 0;
				db_reset     = 0;
				db_enable    = 0;
				shift_enable = 0;
				save_enable  = 0;
			end

		endcase
	end
endmodule
		
				
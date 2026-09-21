//Name: Thiven Anderson
//Email: thanderson@g.hmc.edu
//Date: 9/19/2026
//Description: Top level module for lab 3 of E155 that allows a 4x4 keypad to drive a dual seven segment display
module lab3_ta (
	input logic reset, enable,
	input logic [3:0] col_raw,
	output logic [3:0] row_out,
	output logic [1:0] anode,
    output logic [6:0] seg
	);

	logic int_osc;

	logic [3:0] col_sync;

	logic [3:0] row_scan;
	logic [1:0] row_scan_idx;
	logic       scan_tick;
	logic       scan_done;
	logic       scan_enable;
	logic 		scan_reset;

	logic [15:0] keypad;

	logic [3:0] row_decoded;
	logic [1:0] col_decoded;
	logic [3:0] hex_decoded;
	logic [3:0] dig1, dig2;
	logic [3:0] saved_row;
	logic [1:0] saved_col;

	logic db_reset;
	logic db_enable;
	logic db_done;

	logic shift_enable;
	logic save_enable;
	
	localparam DB_WIDTH = 18;
	localparam DB_MAX_COUNT = 239_999;
	localparam HEX_WIDTH = 18;
	localparam HEX_MAX_COUNT = 200_000;
	
	logic [DB_WIDTH-1:0] db_counter;
	logic [HEX_WIDTH-1:0] hex_counter;
	logic dig_s;
	logic [3:0] s;
    // Internal oscillator
    HSOSC #(.CLKHF_DIV(2'b01))
        hf_osc (
            .CLKHFPU(1'b1),
            .CLKHFEN(1'b1),
            .CLKHF(int_osc)
        );
	//Synchronizer
	lab3_ta_sync i_SYNC(
			.clk(int_osc),
			.d(col_raw),
			.q(col_sync)
			);
	//Scanner
	logic scan_reset_master;
	assign scan_reset_master = scan_reset & reset;
	lab3_ta_scanner i_SCANNER(
			.clk(int_osc),
			.reset(scan_reset_master),
			.enable(scan_enable),
			.scan_tick(scan_tick),
			.row_scan_idx(row_scan_idx),
			.row_scan(row_scan)
			);
	//Keypad builder
	lab3_ta_keypad_builder i_KEYPAD_BUILDER (
			.clk(int_osc),
			.reset(reset),
			.scan_tick(scan_tick),
			.row_scan_idx(row_scan_idx),
			.col_sync(col_sync),
			.keypad(keypad),
			.scan_done(scan_done)
			);
	//Keypad decoder
	lab3_ta_keypad_decoder i_KEYPAD_DECODER(
			.keypad(keypad),
			.row_decoded(row_decoded),
			.col_decoded(col_decoded),
			.hex_decoded(hex_decoded)
			);
	//Debouncer
		//instantiate counter module
	lab2_ta_counter #(
    .WIDTH(DB_WIDTH),
    .MAX_COUNT(DB_MAX_COUNT) 	 	
		)i_DB_COUNTER(
        .clk(int_osc),
		.reset(db_reset),
		.enable(db_enable),
		.counter(db_counter)
    );
	
	assign db_done = (db_counter == DB_MAX_COUNT);
	//Controller
	lab3_ta_controller i_CONTROLLER (
		.clk(int_osc),
		.reset(reset),
		.scan_done(scan_done),
		.keypad(keypad),
		.col_sync(col_sync),
		.db_done(db_done),
		.row_decoded(row_decoded),
		.col_decoded(col_decoded),
		.saved_col(saved_col),
		.scan_enable(scan_enable),
		.scan_reset(scan_reset),
		.db_reset(db_reset),
		.db_enable(db_enable),
		.shift_enable(shift_enable),
		.save_enable(save_enable)
	);
	//Shift registers
	//Hex display
	lab3_ta_digit_sr i_DIGIT_SR(
		.clk(int_osc),
		.reset(reset),
		.enable(shift_enable),
		.digit(hex_decoded),
		.digit1(dig1),
		.digit2(dig2)
		);
	//Saved key
	lab3_ta_savedkey_sr i_SAVEDKEY_SR(
		.clk(int_osc),
		.reset(reset),
		.enable(save_enable),
		.col_decoded(col_decoded),
		.row_decoded(row_decoded),
		.saved_col(saved_col),
		.saved_row(saved_row)
		);
	//Dual display mux logic
	//generic counter
	lab2_ta_counter #(
    .WIDTH(HEX_WIDTH),
    .MAX_COUNT(HEX_MAX_COUNT) 	 	
		)i_HEX_COUNTER(
        .clk(int_osc),
		.reset(reset),
		.enable(enable),
		.counter(hex_counter)
    );
	//time mux assign logic
	assign dig_s = (hex_counter >= HEX_MAX_COUNT/2);
	assign s = dig_s ? dig2 : dig1;
	assign anode = dig_s ? 2'b01 : 2'b10;
		// 7-segment decoder
    lab1_ta_hex_seg_decoder i_HEX_DECODER (
        .s(s),
        .seg(seg)
    );
	//Row out logic
	assign row_out = scan_enable ? row_scan : saved_row;
endmodule

	
	
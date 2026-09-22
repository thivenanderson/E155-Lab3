// ============================================================
// Rate / clock-enable generator
// Generates a one-system-clock-wide tick at approximately TICK_HZ.
// ============================================================
module rate_tick #(
    parameter integer CLK_HZ  = 20_000_000,
    parameter integer TICK_HZ = 200
)(
    input  logic clk,
    input  logic reset_n,
    output logic tick
);

    localparam integer DIV = CLK_HZ / TICK_HZ;
    localparam integer WIDTH = $clog2(DIV);

    logic [WIDTH-1:0] count;

    always_ff @(posedge clk) begin
        if (!reset_n) begin
            count <= '0;
            tick  <= 1'b0;
        end
        else begin
            tick <= 1'b0;

            if (count == DIV-1) begin
                count <= '0;
                tick  <= 1'b1;
            end
            else begin
                count <= count + 1'b1;
            end
        end
    end

endmodule


// ============================================================
// 4x4 keypad scanner
//
// col_n : active-low column drive
// row_n : active-low row inputs
//
// A column remains selected for an entire scan interval, so the
// row signals have several milliseconds to settle before sampling.
//
// Once a key is detected:
//   SCAN -> WAIT_RELEASE
//
// WAIT_RELEASE continues scanning every column. A new key cannot
// register until one complete 4-column sweep contains no presses.
// ============================================================
module keypad_scanner_4x4 (
    input  logic       clk,
    input  logic       reset_n,
    input  logic       scan_tick,

    input  logic [3:0] row_n,
    output logic [3:0] col_n,

    output logic       key_valid,
    output logic [3:0] key_code
);

    typedef enum logic {
        SCAN,
        WAIT_RELEASE
    } state_t;

    state_t state;

    logic [1:0] col_idx;

    // Synchronize external keypad row signals into FPGA clock domain.
    logic [3:0] row_sync1;
    logic [3:0] row_sync2;

    logic       release_sweep_active;
    logic       release_sweep_any;

    // --------------------------------------------------------
    // Input synchronizer
    // --------------------------------------------------------
    always_ff @(posedge clk) begin
        if (!reset_n) begin
            row_sync1 <= 4'b1111;
            row_sync2 <= 4'b1111;
        end
        else begin
            row_sync1 <= row_n;
            row_sync2 <= row_sync1;
        end
    end

    // --------------------------------------------------------
    // Drive exactly one column low
    // --------------------------------------------------------
    always_comb begin
        col_n = 4'b1111;

        case (col_idx)
            2'd0: col_n = 4'b1110;
            2'd1: col_n = 4'b1101;
            2'd2: col_n = 4'b1011;
            2'd3: col_n = 4'b0111;
            default: col_n = 4'b1111;
        endcase
    end

    // --------------------------------------------------------
    // Key lookup
    //
    // Example hexadecimal keypad layout:
    //
    //        COL0 COL1 COL2 COL3
    // ROW0     1    2    3    A
    // ROW1     4    5    6    B
    // ROW2     7    8    9    C
    // ROW3     E    0    F    D
    //
    // Change this function if the physical keypad is wired
    // differently.
    // --------------------------------------------------------
    function automatic logic [3:0] decode_key(
        input logic [1:0] column,
        input logic [1:0] row
    );
        begin
            case ({row, column})
                4'b0000: decode_key = 4'h1;
                4'b0001: decode_key = 4'h2;
                4'b0010: decode_key = 4'h3;
                4'b0011: decode_key = 4'hA;

                4'b0100: decode_key = 4'h4;
                4'b0101: decode_key = 4'h5;
                4'b0110: decode_key = 4'h6;
                4'b0111: decode_key = 4'hB;

                4'b1000: decode_key = 4'h7;
                4'b1001: decode_key = 4'h8;
                4'b1010: decode_key = 4'h9;
                4'b1011: decode_key = 4'hC;

                4'b1100: decode_key = 4'hE;
                4'b1101: decode_key = 4'h0;
                4'b1110: decode_key = 4'hF;
                4'b1111: decode_key = 4'hD;

                default: decode_key = 4'h0;
            endcase
        end
    endfunction

    // --------------------------------------------------------
    // Scanner / debounce FSM
    // --------------------------------------------------------
    always_ff @(posedge clk) begin
        if (!reset_n) begin
            state                <= SCAN;
            col_idx              <= 2'd0;
            key_code             <= 4'h0;
            key_valid            <= 1'b0;
            release_sweep_active <= 1'b0;
            release_sweep_any    <= 1'b0;
        end
        else begin
            // key_valid is a one-clock pulse
            key_valid <= 1'b0;

            if (scan_tick) begin

                case (state)

                    // ----------------------------------------
                    // Normal scanning
                    // ----------------------------------------
                    SCAN: begin
                        if (row_sync2 != 4'b1111) begin

                            // If multiple rows are active,
                            // choose the first one by priority.
                            if (!row_sync2[0])
                                key_code <= decode_key(col_idx, 2'd0);
                            else if (!row_sync2[1])
                                key_code <= decode_key(col_idx, 2'd1);
                            else if (!row_sync2[2])
                                key_code <= decode_key(col_idx, 2'd2);
                            else
                                key_code <= decode_key(col_idx, 2'd3);

                            key_valid <= 1'b1;
                            state     <= WAIT_RELEASE;

                            // Do not accept a partial sweep as
                            // evidence of full release.
                            release_sweep_active <= 1'b0;
                            release_sweep_any    <= 1'b0;
                        end

                        col_idx <= col_idx + 2'd1;
                    end

                    // ----------------------------------------
                    // Ignore all keys until a COMPLETE sweep
                    // sees every row inactive.
                    // ----------------------------------------
                    WAIT_RELEASE: begin

                        // Start release checking at column 0 so
                        // the release decision always represents
                        // a full four-column sweep.
                        if (col_idx == 2'd0) begin
                            release_sweep_active <= 1'b1;
                            release_sweep_any    <=
                                (row_sync2 != 4'b1111);
                        end
                        else if (release_sweep_active) begin
                            if (row_sync2 != 4'b1111)
                                release_sweep_any <= 1'b1;
                        end

                        // Column 3 finishes a complete sweep.
                        if ((col_idx == 2'd3) &&
                            release_sweep_active) begin

                            // Include column 3 in the decision.
                            if (!release_sweep_any &&
                                (row_sync2 == 4'b1111)) begin
                                state <= SCAN;
                            end

                            release_sweep_active <= 1'b0;
                            release_sweep_any    <= 1'b0;
                        end

                        col_idx <= col_idx + 2'd1;
                    end

                    default: begin
                        state <= SCAN;
                    end

                endcase
            end
        end
    end

endmodule


// ============================================================
// Hex-to-seven-segment decoder
//
// Active-low segment outputs for a common-anode display.
// seg_n = {a,b,c,d,e,f,g}
// ============================================================
module hex7seg (
    input  logic [3:0] hex,
    output logic [6:0] seg_n
);

    always_comb begin
        case (hex)
            4'h0: seg_n = 7'b0000001;
            4'h1: seg_n = 7'b1001111;
            4'h2: seg_n = 7'b0010010;
            4'h3: seg_n = 7'b0000110;
            4'h4: seg_n = 7'b1001100;
            4'h5: seg_n = 7'b0100100;
            4'h6: seg_n = 7'b0100000;
            4'h7: seg_n = 7'b0001111;
            4'h8: seg_n = 7'b0000000;
            4'h9: seg_n = 7'b0000100;
            4'hA: seg_n = 7'b0001000;
            4'hB: seg_n = 7'b1100000;
            4'hC: seg_n = 7'b0110001;
            4'hD: seg_n = 7'b1000010;
            4'hE: seg_n = 7'b0110000;
            4'hF: seg_n = 7'b0111000;
            default: seg_n = 7'b1111111;
        endcase
    end

endmodule


// ============================================================
// Dual seven-segment display multiplexer
//
// digit_n[0] = right / most-recent digit
// digit_n[1] = left  / older digit
//
// Active-low digit enables assumed.
//
// Each digit is active for exactly one refresh interval, giving
// a 50% duty cycle and balanced brightness.
// ============================================================
module dual7seg_mux (
    input  logic       clk,
    input  logic       reset_n,
    input  logic       refresh_tick,

    input  logic [3:0] older_digit,
    input  logic [3:0] recent_digit,

    output logic [6:0] seg_n,
    output logic [1:0] digit_n
);

    logic digit_sel;
    logic [3:0] selected_hex;

    always_ff @(posedge clk) begin
        if (!reset_n)
            digit_sel <= 1'b0;
        else if (refresh_tick)
            digit_sel <= ~digit_sel;
    end

    // Right digit = most recent
    // Left digit  = older
    always_comb begin
        if (digit_sel == 1'b0) begin
            selected_hex = recent_digit;
            digit_n      = 2'b10;
        end
        else begin
            selected_hex = older_digit;
            digit_n      = 2'b01;
        end
    end

    hex7seg decoder (
        .hex   (selected_hex),
        .seg_n (seg_n)
    );

endmodule


// ============================================================
// Top level
//
// Uses the iCE40 high-frequency internal oscillator.
//
// CLKHF_DIV = "0b01" is commonly used to divide the native
// HFOSC frequency. Adjust CLK_HZ below to match the oscillator
// frequency used in the actual design / board configuration.
// ============================================================
module keypad_display_top (
    input  logic       reset_n,

    input  logic [3:0] keypad_row_n,
    output logic [3:0] keypad_col_n,

    output logic [6:0] seg_n,
    output logic [1:0] digit_n
);

    // Approximate system-clock rate assumed by the tick dividers.
    localparam integer CLK_HZ = 24_000_000;

    logic clk;

    logic scan_tick;
    logic refresh_tick;

    logic       key_valid;
    logic [3:0] key_code;

    logic [3:0] older_digit;
    logic [3:0] recent_digit;

    // --------------------------------------------------------
    // iCE40 UP5K internal high-frequency oscillator
    // --------------------------------------------------------
	HSOSC #(
		.CLKHF_DIV(2'b01)
	) hfosc_inst (
		.CLKHFPU(1'b1),
		.CLKHFEN(1'b1),
		.CLKHF  (clk)
	);

    // --------------------------------------------------------
    // Keypad scan rate
    //
    // 200 column samples / second:
    //     5 ms per column
    //     20 ms per complete keypad sweep
    // --------------------------------------------------------
    rate_tick #(
        .CLK_HZ (CLK_HZ),
        .TICK_HZ(200)
    ) scan_rate (
        .clk     (clk),
        .reset_n (reset_n),
        .tick    (scan_tick)
    );

    // --------------------------------------------------------
    // Display refresh
    //
    // Toggle digit at 1 kHz.
    // Each individual digit is therefore refreshed at 500 Hz,
    // comfortably above the visible-flicker range.
    // --------------------------------------------------------
    rate_tick #(
        .CLK_HZ (CLK_HZ),
        .TICK_HZ(1000)
    ) display_rate (
        .clk     (clk),
        .reset_n (reset_n),
        .tick    (refresh_tick)
    );

    // --------------------------------------------------------
    // Keypad scanner
    // --------------------------------------------------------
    keypad_scanner_4x4 keypad_scanner (
        .clk       (clk),
        .reset_n   (reset_n),
        .scan_tick (scan_tick),

        .row_n     (keypad_row_n),
        .col_n     (keypad_col_n),

        .key_valid (key_valid),
        .key_code  (key_code)
    );

    // --------------------------------------------------------
    // Two-key history
    //
    // Example:
    //   first press 5 -> [0][5]
    //   next press A  -> [5][A]
    // --------------------------------------------------------
    always_ff @(posedge clk) begin
        if (!reset_n) begin
            older_digit  <= 4'h0;
            recent_digit <= 4'h0;
        end
        else if (key_valid) begin
            older_digit  <= recent_digit;
            recent_digit <= key_code;
        end
    end

    // --------------------------------------------------------
    // Seven-segment multiplexer
    // --------------------------------------------------------
    dual7seg_mux display_mux (
        .clk          (clk),
        .reset_n      (reset_n),
        .refresh_tick (refresh_tick),

        .older_digit  (older_digit),
        .recent_digit (recent_digit),

        .seg_n        (seg_n),
        .digit_n      (digit_n)
    );

endmodule
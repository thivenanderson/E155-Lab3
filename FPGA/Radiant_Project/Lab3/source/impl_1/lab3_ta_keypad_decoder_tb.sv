`timescale 1 ns/1 ns

module lab3_ta_keypad_decoder_tb();

    logic [15:0] keypad;
    logic [3:0] row_decoded;
    logic [1:0] col_decoded;
    logic [3:0] hex_decoded;

    lab3_ta_keypad_decoder dut (
        .keypad(keypad),
        .row_decoded(row_decoded),
        .col_decoded(col_decoded),
        .hex_decoded(hex_decoded)
    );


    task automatic check_decode(
        input logic [15:0] test_keypad,
        input logic [3:0]  expected_row,
        input logic [1:0]  expected_col,
        input logic [3:0]  expected_hex
    );
    begin

        keypad = test_keypad;
        #1;

        assert(row_decoded == expected_row &&
               col_decoded == expected_col &&
               hex_decoded == expected_hex)

            $display("Passed keypad %b -> row %b, col %0d, hex %h",
                     keypad, row_decoded, col_decoded, hex_decoded);

        else
            $error("FAILED keypad %b: got row %b col %0d hex %h",
                   keypad, row_decoded, col_decoded, hex_decoded);

    end
    endtask


    initial begin

        // row_decoded = 1000 : physical keypad row 0
        check_decode(16'b1000_0000_0000_0000, 4'b1000, 2'd3, 4'h1);
        check_decode(16'b0100_0000_0000_0000, 4'b1000, 2'd2, 4'h2);
        check_decode(16'b0010_0000_0000_0000, 4'b1000, 2'd1, 4'h3);
        check_decode(16'b0001_0000_0000_0000, 4'b1000, 2'd0, 4'hA);

        // row_decoded = 0100
        check_decode(16'b0000_1000_0000_0000, 4'b0100, 2'd3, 4'h4);
        check_decode(16'b0000_0100_0000_0000, 4'b0100, 2'd2, 4'h5);
        check_decode(16'b0000_0010_0000_0000, 4'b0100, 2'd1, 4'h6);
        check_decode(16'b0000_0001_0000_0000, 4'b0100, 2'd0, 4'hB);

        // row_decoded = 0010
        check_decode(16'b0000_0000_1000_0000, 4'b0010, 2'd3, 4'h7);
        check_decode(16'b0000_0000_0100_0000, 4'b0010, 2'd2, 4'h8);
        check_decode(16'b0000_0000_0010_0000, 4'b0010, 2'd1, 4'h9);
        check_decode(16'b0000_0000_0001_0000, 4'b0010, 2'd0, 4'hC);

        // row_decoded = 0001
        check_decode(16'b0000_0000_0000_1000, 4'b0001, 2'd3, 4'hE);
        check_decode(16'b0000_0000_0000_0100, 4'b0001, 2'd2, 4'h0);
        check_decode(16'b0000_0000_0000_0010, 4'b0001, 2'd1, 4'hF);
        check_decode(16'b0000_0000_0000_0001, 4'b0001, 2'd0, 4'hD);


        // Test default case with no key pressed
        keypad = 16'b0;
        #1;

        assert(row_decoded == 4'b1000 &&
               col_decoded == 2'd3 &&
               hex_decoded == 4'h0)

            $display("Passed decoder default case.");

        else
            $error("FAILED decoder default case.");


        $display("Keypad decoder testbench complete.");
        $stop;

    end

endmodule
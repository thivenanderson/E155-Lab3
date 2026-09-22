`timescale 1 ns/1 ns

module lab3_ta_savedkey_sr_tb();

    logic clk;
    logic reset;
    logic enable;
    logic [3:0] saved_row;
	logic [1:0] saved_col;
	logic [3:0] row_decoded;
	logic [1:0] col_decoded;
    logic [3:0] digit1, digit2;

    lab3_ta_savedkey_sr dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
	    .col_decoded(col_decoded),
        .row_decoded(row_decoded),
	    .saved_col(saved_col),
	    .saved_row(saved_row)
    );

    // 10 ns clock period
    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    initial begin

        reset  = 0;
        enable = 0;
        col_decoded  = 2'b0;
		row_decoded = 4'b0;

        // Test reset
        repeat (2) @(posedge clk);
        #1;

        assert(saved_row == 4'b0 && saved_col == 2'b0)
            $display("Passed reset test at time %0t.", $time);
        else
            $error("FAILED reset test at time %0t.", $time);


        // Release reset
        @(negedge clk);
        reset = 1;


        // Load first keypress: A
        col_decoded  = 2'b0;
		row_decoded = 4'b1000;
        enable = 1;

        @(posedge clk);
        #1;

        assert(saved_row == 4'b1000 && saved_col == 2'b0)
            $display("Passed first key load at time %0t.", $time);
        else
            $error("FAILED first key load at time %0t.", $time);


        // Load second key: 6
        col_decoded  = 2'b01;
		row_decoded = 4'b0100;

        @(posedge clk);
        #1;

        assert(saved_row == 4'b0100 && saved_col == 2'b01)
            $display("Passed second saved kye shift at time %0t.", $time);
        else
            $error("FAILED second saved key shift at time %0t.", $time);


        // Disable and make sure values hold
        enable = 0;
        col_decoded  = 2'b10;
		row_decoded = 4'b0001;

        repeat (3) @(posedge clk);
        #1;

        assert(saved_row == 4'b0100 && saved_col == 2'b01)
            $display("Passed enable hold test at time %0t.", $time);
        else
            $error("FAILED enable hold test at time %0t.", $time);


        // Enable again and load 0
        enable = 1;

        @(posedge clk);
        #1;

        assert(saved_row == 4'b0001 && saved_col == 2'b10)
            $display("Passed third digit shift at time %0t.", $time);
        else
            $error("FAILED third digit shift at time %0t.", $time);


        $display("Digit shift register testbench complete.");
        $stop;

    end

endmodule
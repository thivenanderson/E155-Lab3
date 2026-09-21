`timescale 1 ns/1 ns

module lab3_ta_keypad_builder_tb();

    logic clk;
    logic reset;
    logic scan_tick;
    logic [1:0] row_scan_idx;
    logic [3:0] col_sync;

    logic [15:0] keypad;
    logic scan_done;

    lab3_ta_keypad_builder dut (
        .clk(clk),
        .reset(reset),
        .scan_tick(scan_tick),
        .row_scan_idx(row_scan_idx),
        .col_sync(col_sync),
        .keypad(keypad),
        .scan_done(scan_done)
    );

    // 10 ns clock period
    always begin
        clk = 0; #5;
        clk = 1; #5;
    end


    initial begin

        reset        = 0;
        scan_tick    = 0;
        row_scan_idx = 0;
        col_sync     = 4'b1111;

        // Test reset
        repeat (2) @(posedge clk);
        #1;

        assert(keypad == 16'b0)
            $display("Passed keypad reset.");
        else
            $error("FAILED keypad reset.");


        @(negedge clk);
        reset = 1;

		//-------------------------------------------------
		//We will store a unique column input in each row to tell if the correct nibble was sent
		//to the correct part of 'keypad' 
		//We will set all column inputs on negedge of clock to mimic asynchronous button presses
        // ------------------------------------------------
        // Row 0
        // col_sync = 0111 -> stored value = 1000
        // ------------------------------------------------
        row_scan_idx = 2'd0;
        col_sync     = 4'b0111;
        scan_tick    = 1;

        @(posedge clk);
        #1;

        assert(keypad == 16'b1000_0000_0000_0000)
            $display("Passed row 0 capture.");
        else
            $error("FAILED row 0 capture.");

        assert(scan_done == 0)
            $display("Passed scan_done low on row 0.");
        else
            $error("FAILED: scan_done high on row 0.");

        scan_tick = 0;


        // ------------------------------------------------
        // Row 1
        // col_sync = 1011 -> stored value = 0100
        // ------------------------------------------------
        @(negedge clk);
        row_scan_idx = 2'd1;
        col_sync     = 4'b1011;
        scan_tick    = 1;

        @(posedge clk);
        #1;

        assert(keypad == 16'b1000_0100_0000_0000)
            $display("Passed row 1 capture.");
        else
            $error("FAILED row 1 capture.");

        assert(scan_done == 0)
            $display("Passed scan_done low on row 1.");
        else
            $error("FAILED: scan_done high on row 1.");

        scan_tick = 0;


        // ------------------------------------------------
        // Row 2
        // col_sync = 1101 -> stored value = 0010
        // ------------------------------------------------
        @(negedge clk);
        row_scan_idx = 2'd2;
        col_sync     = 4'b1101;
        scan_tick    = 1;

        @(posedge clk);
        #1;

        assert(keypad == 16'b1000_0100_0010_0000)
            $display("Passed row 2 capture.");
        else
            $error("FAILED row 2 capture.");

        assert(scan_done == 0)
            $display("Passed scan_done low on row 2.");
        else
            $error("FAILED: scan_done high on row 2.");

        scan_tick = 0;


        // ------------------------------------------------
        // Row 3
        // col_sync = 1110 -> stored value = 0001
        // ------------------------------------------------
        @(negedge clk);
        row_scan_idx = 2'd3;
        col_sync     = 4'b1110;
        scan_tick    = 1;

        // scan_done is combinational
        #1;
        assert(scan_done == 1)
            $display("Passed scan_done assertion.");
        else
            $error("FAILED scan_done assertion.");

        @(posedge clk);
        #1;

        assert(keypad == 16'b1000_0100_0010_0001)
            $display("Passed complete keypad build.");
        else
            $error("FAILED complete keypad build.");

        scan_tick = 0;
        #1;

        assert(scan_done == 0)
            $display("Passed scan_done deassertion.");
        else
            $error("FAILED scan_done deassertion.");


        // ------------------------------------------------
        // Make sure keypad DOES NOT update without scan_tick
        // ------------------------------------------------
        @(negedge clk);
        row_scan_idx = 2'd0;
        col_sync     = 4'b1110;
        scan_tick    = 0;

        @(posedge clk);
        #1;

        assert(keypad == 16'b1000_0100_0010_0001)
            $display("Passed no-update-without-tick test.");
        else
            $error("FAILED: keypad changed without scan_tick.");


        $display("Keypad builder testbench complete.");
        $stop;

    end

endmodule
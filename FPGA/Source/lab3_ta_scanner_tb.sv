`timescale 1 ns/1 ns
module lab3_ta_scanner_tb ();
    logic [3:0] scanner;
    logic clk;
	logic reset;
	logic enable;
	logic scan_tick;
	logic [1:0] scan_idx;

	
	
	    lab3_ta_scanner #(.SCAN_WIDTH(4), .SCAN_MAX_COUNT(11)) dut (
        .clk(clk),
		.reset(reset),
		.enable(enable),
		.scan_tick(scan_tick),
		.row_scan_idx(scan_idx),
		.row_scan(scanner)
	);
	
 // generate clock
    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    // apply stimuli and check outputs
    initial begin

        reset  = 0;
        enable = 1;

        repeat (2) @(posedge clk);

        // release reset away from active clock edge
        @(negedge clk);
        reset = 1;

        // counter = 0
        #1;
        assert (scanner == 4'b1000 &&
                scan_idx == 2'd0 &&
                scan_tick == 0)
            $display("Passed row 0 start at time: %0t.", $time);
        else
            $error("FAILED row 0 start at time: %0t.", $time);


        // counter = 1
        @(posedge clk); #1;
        assert (scan_tick == 0)
            $display("Passed no tick at count 1.");
        else
            $error("FAILED: scan_tick high too early.");


        // counter = 2 -> first scan tick
        @(posedge clk); #1;
        assert (scanner == 4'b1000 &&
                scan_idx == 2'd0 &&
                scan_tick == 1)
            $display("Passed row 0 scan tick at time: %0t.", $time);
        else
            $error("FAILED row 0 scan tick at time: %0t.", $time);


        // counter = 3 -> row 1
        @(posedge clk); #1;
        assert (scanner == 4'b0100 &&
                scan_idx == 2'd1 &&
                scan_tick == 0)
            $display("Passed row 1 start at time: %0t.", $time);
        else
            $error("FAILED row 1 start at time: %0t.", $time);


        // counter = 5 -> second scan tick
        repeat (2) @(posedge clk);
        #1;
        assert (scanner == 4'b0100 &&
                scan_idx == 2'd1 &&
                scan_tick == 1)
            $display("Passed row 1 scan tick at time: %0t.", $time);
        else
            $error("FAILED row 1 scan tick at time: %0t.", $time);


        // counter = 6 -> row 2
        @(posedge clk); #1;
        assert (scanner == 4'b0010 &&
                scan_idx == 2'd2 &&
                scan_tick == 0)
            $display("Passed row 2 start at time: %0t.", $time);
        else
            $error("FAILED row 2 start at time: %0t.", $time);


        // counter = 8 -> third scan tick
        repeat (2) @(posedge clk);
        #1;
        assert (scanner == 4'b0010 &&
                scan_idx == 2'd2 &&
                scan_tick == 1)
            $display("Passed row 2 scan tick at time: %0t.", $time);
        else
            $error("FAILED row 2 scan tick at time: %0t.", $time);


        // counter = 9 -> row 3
        @(posedge clk); #1;
        assert (scanner == 4'b0001 &&
                scan_idx == 2'd3 &&
                scan_tick == 0)
            $display("Passed row 3 start at time: %0t.", $time);
        else
            $error("FAILED row 3 start at time: %0t.", $time);


        // counter = 11 -> fourth scan tick
        repeat (2) @(posedge clk);
        #1;
        assert (scanner == 4'b0001 &&
                scan_idx == 2'd3 &&
                scan_tick == 1)
            $display("Passed row 3 scan tick at time: %0t.", $time);
        else
            $error("FAILED row 3 scan tick at time: %0t.", $time);


        // next clock -> counter wraps to 0 / row 0
        @(posedge clk); #1;
        assert (scanner == 4'b1000 &&
                scan_idx == 2'd0 &&
                scan_tick == 0)
            $display("Passed scanner wraparound at time: %0t.", $time);
        else
            $error("FAILED scanner wraparound at time: %0t.", $time);


        // Test enable freeze
        enable = 0;

        repeat (3) @(posedge clk);
        #1;

        assert (scanner == 4'b1000 &&
                scan_idx == 2'd0 &&
                scan_tick == 0)
            $display("Passed scanner enable freeze at time: %0t.", $time);
        else
            $error("FAILED scanner enable freeze at time: %0t.", $time);


        $display("Scanner testbench complete.");
        $stop;

    end

endmodule
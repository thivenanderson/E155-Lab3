`timescale 1 ns/1 ns

module lab3_ta_top_tb();

    logic reset;
    logic enable;

    logic [3:0] col_raw;
    logic [3:0] row_out;
    logic [1:0] anode;
    logic [6:0] seg;

    // One bit for each physical keypad key.
    //'pressed' keypad map:
    // [15:12] = row 0 = 1 2 3 A
    // [11:8]  = row 1 = 4 5 6 B
    // [7:4]   = row 2 = 7 8 9 C
    // [3:0]   = row 3 = E 0 F D
    //
	//logic to simulate keypad presses
    logic [15:0] pressed;


    // Using small counter with parameterized values so the top-level simulation
    // does not require hundreds of thousands of clock cycles.
    lab3_ta #(
        .DB_WIDTH(4),
        .DB_MAX_COUNT(9),

        .HEX_WIDTH(4),
        .HEX_MAX_COUNT(9),

        .SCAN_WIDTH(4),
        .SCAN_MAX_COUNT(11)
    ) dut (
        .reset(reset),
        .enable(enable),
        .col_raw(col_raw),
        .row_out(row_out),
        .anode(anode),
        .seg(seg)
    );



    // For a raw column input
    //     unpressed = 1111
    //
    // If a key is pressed AND its row is being driven,
    // its corresponding column is pulled low.

	//logic to impliment above statement
    always_comb begin

        col_raw = 4'b1111;

        // row 0 driven
        if (row_out[3])
            col_raw = col_raw & ~pressed[15:12];

        // row 1 driven
        if (row_out[2])
            col_raw = col_raw & ~pressed[11:8];

        // row 2 driven
        if (row_out[1])
            col_raw = col_raw & ~pressed[7:4];

        // row 3 driven
        if (row_out[0])
            col_raw = col_raw & ~pressed[3:0];

    end



    // Helper task: wait for shift register to update.
	//Shift register has already been tested


    task automatic wait_for_digits(
        input logic [3:0] expected_dig2,
        input logic [3:0] expected_dig1
    );

        integer cycles;

        begin

            cycles = 0;

            while ((dut.dig1 !== expected_dig1 ||
                    dut.dig2 !== expected_dig2) &&
                    cycles < 300) begin

                @(posedge dut.int_osc);
                cycles = cycles + 1;

            end

            #1;

            assert(dut.dig1 == expected_dig1 &&
                   dut.dig2 == expected_dig2)

                $display(
                    "Passed digits: newest=%h previous=%h at time %0t.",
                    dut.dig1, dut.dig2, $time
                );

            else
                $error(
                    "FAILED digits: expected %h %h, got %h %h.",
                    expected_dig1, expected_dig2,
                    dut.dig1, dut.dig2
                );

        end

    endtask



    // Helper task: simulate a bouncing key press

    // Includes:
    //   - transitions away from clock edges
    //   - a transition exactly on a system-clock edge
    //   - final stable press

    task automatic bounce_press(
        input integer key_bit
    );

        begin

            // asynchronous assertion
            #7;
            pressed[key_bit] = 1'b1;

            // bounce open
            #3;
            pressed[key_bit] = 1'b0;

            // exactly on a rising clock edge
            @(posedge dut.int_osc);
            pressed[key_bit] = 1'b1;

            // bounce open again
            #2;
            pressed[key_bit] = 1'b0;

            // asynchronous final stable press
            #5;
            pressed[key_bit] = 1'b1;

        end

    endtask



    // Now we initialize


    initial begin

        reset   = 0;
        enable  = 1;
        pressed = 16'b0;



        // First test asynch reset
		$display("RESET TEST START: at %0t", $time);

        #2;

        assert(dut.dig1 == 4'h0 &&
               dut.dig2 == 4'h0 &&
               dut.saved_row == 4'b0000)
            $display("Passed top-level asynchronous reset.");
        else
            $error("FAILED top-level asynchronous reset.");

		$display("RESET TEST END: at %0t", $time);
        // release reset asynchronously
        #3;
        reset = 1;

        // Allow synchronizer to initialize
        repeat (3) @(posedge dut.int_osc);


		
        // Test 1: Press '1' with simulated bounce
        //
        // key 1 = pressed[15]
		$display("TEST 1 START: at %0t", $time);
		//simulate a bounced press of the key that should ouput 1
        bounce_press(15);


        // Wait until controller has recognized a valid one-hot key
        wait(dut.save_enable == 1'b1);


        // CHECK -> SAVE:
        // saved key register captures row 0 / column 3
        @(posedge dut.int_osc);
        #1;

        assert(dut.saved_row == 4'b1000 &&
               dut.saved_col == 2'd3 &&
               row_out == 4'b1000 &&
               dut.db_enable == 0)

            $display("Passed CHECK -> SAVE / saved-row selection.");

        else
            $error("FAILED CHECK -> SAVE behavior.");


        // SAVE -> SETTLE:
        // first synchronizer stage has now seen the selected row
        @(posedge dut.int_osc);
        #1;

        assert(dut.i_SYNC.n1 == 4'b0111 &&
               dut.db_enable == 0)

            $display("Passed SAVE -> SETTLE synchronizer stage 1.");

        else
            $error("FAILED synchronizer stage 1 timing.");


        // SETTLE -> WAIT:
        // second synchronizer stage now contains valid columns
        @(posedge dut.int_osc);
        #1;

        assert(dut.col_sync == 4'b0111 &&
               dut.db_enable == 1)

            $display("Passed SETTLE -> WAIT synchronizer stage 2.");

        else
            $error("FAILED synchronizer stage 2 timing.");


        // Eventually key 1 should register exactly once
        wait_for_digits(4'h0, 4'h1);


        // Hold the key for a while
        // It should not register repeatedly
        repeat (30) @(posedge dut.int_osc);
        #1;

        assert(dut.dig1 == 4'h1 &&
               dut.dig2 == 4'h0)

            $display("Passed long-hold single-registration test.");

        else
            $error("FAILED long-hold test.");


        // release key 1 asynchronously
		$display("TEST 1 END: at %0t", $time);
        #3;
        pressed[15] = 0;

        wait(dut.scan_enable == 1'b1);

		

        // Test 2: Shift register update with a second key press
        //
        // key 5 = row 1, col 1 = pressed[10]
        // Should produce 1, 5
		$display("TEST 2 START:  at %0t", $time);
        #4;
        pressed[10] = 1;

        wait_for_digits(4'h1, 4'h5);

        #6;
        pressed[10] = 0;

        wait(dut.scan_enable == 1'b1);

		$display("TEST 2 END:  at %0t", $time);
		
        // Test 3: Reject multi key press while key held
        //
        // Press 2 first.
        // While 2 remains held, press 9.
        // Display must remain 5, 2.
		$display("TEST 3 START:  at %0t", $time);
        #3;
        pressed[14] = 1;       // key 2

        wait_for_digits(4'h5, 4'h2);


        // Additional key while first key still held
        #7;
        pressed[5] = 1;        // key 9

        repeat (25) @(posedge dut.int_osc);
        #1;

        assert(dut.dig1 == 4'h2 &&
               dut.dig2 == 4'h5)

            $display("Passed first-key priority test.");

        else
            $error("FAILED first-key priority test.");


        // Release original key while 9 remains held.
        // Now 9 should become the valid remaining key.
        #3;
        pressed[14] = 0;

        wait_for_digits(4'h2, 4'h9);
        
		assert(dut.dig1 == 4'h9 &&
               dut.dig2 == 4'h2)

            $display("Passed multi-key roll off test #1.");

        else
            $error("FAILED multi-key roll off test #1.");
        // release 9
        #4;
        pressed[5] = 0;

        wait(dut.scan_enable == 1'b1);


		$display("TEST 3 END:  at %0t", $time);
        // Test 4: Reject multi key press while in SCAN
        //
        // 3 and C are asserted together.
        // System should hold the display.

		$display("TEST 4 START:  at %0t", $time);
        #6;

        pressed[13] = 1;       // key 3
        pressed[4]  = 1;       // key C


        // Give scanner enough time to encounter multiple complete scans
        repeat (60) @(posedge dut.int_osc);
        #1;

        assert(dut.dig1 == 4'h9 &&
               dut.dig2 == 4'h2)

            $display("Passed simultaneous multi-key hold test.");

        else
            $error("FAILED simultaneous multi-key hold test.");

		$display("TEST 4 END:  at %0t", $time);

        // Test 5: Multi key roll off 
        //
        // Release 3, keep C held.
        // C should now register.
		$display("TEST 5 START:  at %0t", $time);
        #3;
        pressed[13] = 0;

        wait_for_digits(4'h9, 4'hC);
		
		assert(dut.dig1 == 4'hC &&
               dut.dig2 == 4'h9)

            $display("Passed multi-key roll off test #2.");

        else
            $error("FAILED multi-key roll off test #2.");
		
        #4;
        pressed[4] = 0;


		$display("TEST 5 END:  at %0t", $time);
        // Finally test we are outputing correct digit to correct half of display
        //
        // Newest/Left half = C
        // Previous/Right half = 9

		$display("OUTPUT TEST START:  at %0t", $time);
        wait(anode == 2'b10);
        #1;

        assert(seg == 7'b1000110)
            $display("Passed newest-digit display connection.");
        else
            $error("FAILED newest-digit display connection.");


        wait(anode == 2'b01);
        #1;

        assert(seg == 7'b0011000)
            $display("Passed previous-digit display connection.");
        else
            $error("FAILED previous-digit display connection.");

		$display("OUTPUT TEST END:  at %0t", $time);
        $display("TOP LEVEL TESTBENCH COMPLETE.");
		
        $stop;
		
    end

endmodule
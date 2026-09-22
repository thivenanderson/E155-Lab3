`timescale 1 ns/1 ns

module lab3_ta_controller_tb();

    logic clk;
    logic reset;

    logic scan_done;
    logic [15:0] keypad;
    logic [3:0] col_sync;
    logic db_done;



    logic [1:0] saved_col;

    logic scan_enable;
    logic scan_reset;
    logic db_reset;
    logic db_enable;
    logic shift_enable;
    logic save_enable;


    lab3_ta_controller dut (
        .clk(clk),
        .reset(reset),

        .scan_done(scan_done),
        .keypad(keypad),
        .col_sync(col_sync),
        .db_done(db_done),
        .saved_col(saved_col),

        .scan_enable(scan_enable),
        .scan_reset(scan_reset),
        .db_reset(db_reset),
        .db_enable(db_enable),
        .shift_enable(shift_enable),
        .save_enable(save_enable)
    );


    // 10 ns clock period
    always begin
        clk = 0; #5;
        clk = 1; #5;
    end


    initial begin

        // ---------------------------------------------------------
        // Initial values
        // ---------------------------------------------------------

        reset       = 1;
        scan_done   = 0;
        keypad      = 16'b0;
        col_sync    = 4'b1111;
        db_done     = 0;


        saved_col   = 2'd0;


        // =========================================================
        // TEST ASYNCHRONOUS RESET
        // =========================================================

        #2;
        reset = 0;       // not on a clock edge

        #1;

        assert(scan_enable  == 1 &&
               scan_reset   == 1 &&
               db_enable    == 0 &&
               shift_enable == 0 &&
               save_enable  == 0)
            $display("Passed asynchronous reset -> SCAN.");
        else
            $error("FAILED asynchronous reset -> SCAN.");


        // Release reset away from positive edge
        @(negedge clk);
        reset = 1;


        // =========================================================
        // MULTIPLE KEYS
        //
        // SCAN -> CHECK -> SCAN
        // Must not save anything.
        // =========================================================

        keypad    = 16'b1100_0000_0000_0000;
        scan_done = 1;

        @(posedge clk);
        #1;

        // Now in CHECK
        assert(scan_enable == 0 &&
               save_enable == 0)
            $display("Passed multi-key SCAN -> CHECK.");
        else
            $error("FAILED multi-key CHECK behavior.");


        @(negedge clk);
        scan_done = 0;

        @(posedge clk);
        #1;

        // Invalid multi-key condition returns to SCAN
        assert(scan_enable == 1 &&
               scan_reset  == 1 &&
               save_enable == 0)
            $display("Passed multi-key rejection.");
        else
            $error("FAILED multi-key rejection.");


        // =========================================================
        // VALID KEY
        //
        // SCAN -> CHECK
        // save_enable should assert during CHECK.
        // =========================================================

        @(negedge clk);

        keypad      = 16'b0100_0000_0000_0000;


        // Physical saved key column is low while pressed
        col_sync    = 4'b1011;

        scan_done   = 1;


        @(posedge clk);
        #1;

        // State is now CHECK.
        // Valid one-hot key should generate save pulse.
        assert(scan_enable == 0 &&
               save_enable == 1)
            $display("Passed valid-key CHECK/save_enable.");
        else
            $error("FAILED valid-key CHECK/save_enable.");


        @(negedge clk);

        scan_done = 0;

        // Mimic output of saved-key register after save edge.
        saved_col = 2'd2;


        // =========================================================
        // CHECK -> SAVE
        // =========================================================

        @(posedge clk);
        #1;

        assert(save_enable == 0 &&
               scan_enable == 0 &&
               db_enable == 0)
            $display("Passed CHECK -> SAVE.");
        else
            $error("FAILED CHECK -> SAVE.");


        // =========================================================
        // SAVE -> SETTLE
        // =========================================================

        @(posedge clk);
        #1;

        assert(db_enable == 0 &&
               shift_enable == 0)
            $display("Passed SAVE -> SETTLE.");
        else
            $error("FAILED SAVE -> SETTLE.");


        // =========================================================
        // SETTLE -> WAIT
        // =========================================================

        @(posedge clk);
        #1;

        assert(db_reset  == 1 &&
               db_enable == 1 &&
               shift_enable == 0)
            $display("Passed entry into WAIT.");
        else
            $error("FAILED entry into WAIT.");


        // =========================================================
        // EXTRA KEY WHILE ORIGINAL KEY IS HELD
        //
        // saved_col = 2, so bit 2 must stay LOW.
        // Another column can also go low and should be ignored.
        // =========================================================

        @(negedge clk);

        col_sync = 4'b0011;
        //               ^
        // saved bit 2 still low


        @(posedge clk);
        #1;

        assert(db_enable == 1 &&
               shift_enable == 0 &&
               scan_enable == 0)
            $display("Passed additional-key ignore during WAIT.");
        else
            $error("FAILED additional-key behavior during WAIT.");


        // =========================================================
        // COMPLETE DEBOUNCE
        //
        // WAIT -> PULSE
        // =========================================================

        @(negedge clk);

        db_done = 1;


        @(posedge clk);
        #1;

        assert(shift_enable == 1 &&
               db_enable == 0)
            $display("Passed WAIT -> PULSE.");
        else
            $error("FAILED WAIT -> PULSE.");


        // =========================================================
        // PULSE -> PRESSED
        //
        // shift_enable must last exactly one clock.
        // =========================================================

        @(negedge clk);
        db_done = 0;


        @(posedge clk);
        #1;

        assert(shift_enable == 0 &&
               scan_enable == 0)
            $display("Passed one-cycle shift pulse.");
        else
            $error("FAILED one-cycle shift pulse.");


        // =========================================================
        // HOLD KEY
        //
        // Should remain PRESSED and never register again.
        // =========================================================

        repeat (3) begin

            @(posedge clk);
            #1;

            assert(shift_enable == 0 &&
                   scan_enable == 0)
                $display("Passed held-key behavior at time %0t.", $time);
            else
                $error("FAILED held-key behavior at time %0t.", $time);

        end


        // =========================================================
        // RELEASE ORIGINAL KEY
        //
        // saved_col = 2 -> set bit 2 back HIGH.
        // PRESSED -> SCAN
        // =========================================================

        @(negedge clk);

        col_sync = 4'b1111;


        @(posedge clk);
        #1;

        assert(scan_enable  == 1 &&
               scan_reset   == 1 &&
               shift_enable == 0)
            $display("Passed release -> SCAN.");
        else
            $error("FAILED release -> SCAN.");


        // =========================================================
        // FINAL ASYNCHRONOUS RESET TEST FROM NON-SCAN STATE
        // =========================================================

        @(negedge clk);

        keypad    = 16'b1000_0000_0000_0000;
        scan_done = 1;


        // Enter CHECK
        @(posedge clk);
        #1;

        assert(scan_enable == 0)
            $display("Entered CHECK for async-reset test.");
        else
            $error("FAILED to enter CHECK.");


        // Assert reset BETWEEN clock edges
        #2;
        reset = 0;

        #1;

        // Must return to SCAN without waiting for posedge
        assert(scan_enable  == 1 &&
               scan_reset   == 1 &&
               shift_enable == 0 &&
               save_enable  == 0)
            $display("Passed asynchronous reset during operation.");
        else
            $error("FAILED asynchronous reset during operation.");


        $display("Controller testbench complete.");
        $stop;

    end

endmodule
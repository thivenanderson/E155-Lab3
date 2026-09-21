`timescale 1 ns/1 ns

module lab3_ta_sync_tb();

    logic clk;
    logic [3:0] d;
    logic [3:0] q;

    lab3_ta_sync dut (
        .clk(clk),
        .d(d),
        .q(q)
    );

    // 10 ns clock period
    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    initial begin

        // Give known starting value
        d = 4'b1111;

        // Allow pipeline to fill
        repeat (2) @(posedge clk);
        #1;

        assert(q == 4'b1111)
            $display("Passed initial synchronization at time %0t.", $time);
        else
            $error("FAILED initial synchronization at time %0t.", $time);


        // Change asynchronously away from clock edge
        @(negedge clk);
        #2;
        d = 4'b0111;

        // First rising edge:
        // n1 gets 0111, q should still have old value
        @(posedge clk);
        #1;

        assert(q == 4'b1111)
            $display("Passed first-stage delay at time %0t.", $time);
        else
            $error("FAILED: q changed too early at time %0t.", $time);


        // Second rising edge:
        // q should now get 0111
        @(posedge clk);
        #1;

        assert(q == 4'b0111)
            $display("Passed second-stage synchronization at time %0t.", $time);
        else
            $error("FAILED synchronization at time %0t.", $time);


        // Try another pattern
        @(negedge clk);
        #2;
        d = 4'b1010;

        @(posedge clk);
        #1;
        assert(q == 4'b0111)
            $display("Passed second input first-stage delay.");

        @(posedge clk);
        #1;
        assert(q == 4'b1010)
            $display("Passed second input synchronization.");
        else
            $error("FAILED second input synchronization.");


        $display("Synchronizer testbench complete.");
        $stop;

    end

endmodule
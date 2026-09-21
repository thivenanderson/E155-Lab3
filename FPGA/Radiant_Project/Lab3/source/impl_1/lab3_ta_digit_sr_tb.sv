`timescale 1 ns/1 ns

module lab3_ta_digit_sr_tb();

    logic clk;
    logic reset;
    logic enable;
    logic [3:0] digit;
    logic [3:0] digit1, digit2;

    lab3_ta_digit_sr dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .digit(digit),
        .digit1(digit1),
        .digit2(digit2)
    );

    // 10 ns clock period
    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    initial begin

        reset  = 0;
        enable = 0;
        digit  = 4'h0;

        // Test reset
        repeat (2) @(posedge clk);
        #1;

        assert(digit1 == 4'h0 && digit2 == 4'h0)
            $display("Passed reset test at time %0t.", $time);
        else
            $error("FAILED reset test at time %0t.", $time);


        // Release reset
        @(negedge clk);
        reset = 1;


        // Load first digit: A
        digit  = 4'hA;
        enable = 1;

        @(posedge clk);
        #1;

        assert(digit1 == 4'hA && digit2 == 4'h0)
            $display("Passed first digit load at time %0t.", $time);
        else
            $error("FAILED first digit load at time %0t.", $time);


        // Load second digit: 5
        digit = 4'h5;

        @(posedge clk);
        #1;

        assert(digit1 == 4'h5 && digit2 == 4'hA)
            $display("Passed second digit shift at time %0t.", $time);
        else
            $error("FAILED second digit shift at time %0t.", $time);


        // Disable and make sure values hold
        enable = 0;
        digit  = 4'hC;

        repeat (3) @(posedge clk);
        #1;

        assert(digit1 == 4'h5 && digit2 == 4'hA)
            $display("Passed enable hold test at time %0t.", $time);
        else
            $error("FAILED enable hold test at time %0t.", $time);


        // Enable again and load C
        enable = 1;

        @(posedge clk);
        #1;

        assert(digit1 == 4'hC && digit2 == 4'h5)
            $display("Passed third digit shift at time %0t.", $time);
        else
            $error("FAILED third digit shift at time %0t.", $time);


        $display("Digit shift register testbench complete.");
        $stop;

    end

endmodule
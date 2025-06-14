`timescale 1ns / 1ps

module testbench;

    // Inputs
    reg clk;
    reg rst;
    reg we;
    reg [9:0] index;
    reg [31:0] a_data;
    reg [31:0] b_data;
    reg [31:0] n;

    // Outputs
    wire done;

    // Instantiate the top module
    top uut (
        .clk(clk),
        .rst(rst),
        .we(we),
        .index(index),
        .a_data(a_data),
        .b_data(b_data),
        .n(n),
        .done(done)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // Test sequence
    initial begin
        // Initialize inputs
        rst = 1;
        we = 0;
        index = 0;
        a_data = 0;
        b_data = 0;
        n = 15; // Test with 16 elements
        #20;

        // Release reset
        rst = 0;
        we = 1; // Enable write
        #10; // Wait for a clock cycle

        a_data = 10; b_data = 2; index = 0; #10;
        a_data = 20; b_data = 3; index = 1; #10;
        a_data = 30; b_data = 4; index = 2; #10;
        a_data = 40; b_data = 5; index = 3; #10;
        a_data = 50; b_data = 6; index = 4; #10;
        a_data = 60; b_data = 7; index = 5; #10;
        a_data = 70; b_data = 8; index = 6; #10;
        a_data = 80; b_data = 9; index = 7; #10;
        a_data = 90; b_data = 10; index = 8; #10;
        a_data = 100; b_data = 11; index = 9; #10;
        a_data = 110; b_data = 12; index = 10; #10;
        a_data = 120; b_data = 13; index = 11; #10;
        a_data = 130; b_data = 14; index = 12; #10;
        a_data = 140; b_data = 15; index = 13; #10;
        a_data = 150; b_data = 16; index = 14; #10;

        // Wait for computation to complete
        wait(done);

        // Finish simulation
        $finish;
    end

endmodule
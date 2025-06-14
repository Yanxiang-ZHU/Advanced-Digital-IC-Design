`timescale 1ns / 1ps

module testbench;

    // Inputs
    reg clk;
    reg rst;
    reg we;
    reg category;
    reg [9:0] index;
    reg [31:0] a_data;
    reg [31:0] b_data;
    reg [31:0] c_data_in;
    reg [31:0] n;

    // Outputs
    wire [31:0] c_data_out;
    wire done;

    // Instantiate the top module
    top uut (
        .clk(clk),
        .rst(rst),
        .we(we),
        .category(category),
        .index(index),
        .a_data(a_data),
        .b_data(b_data),
        .n(n),
        .c_data_out(c_data_out),
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
        category = 0;
        index = 0;
        a_data = 0;
        b_data = 0;
        c_data_in = 0;
        n = 16; // Test with 16 elements
        #20;

        // Release reset
        rst = 0;
        we = 1; // Enable write
        #10; // Wait for a clock cycle
        
        // Load a_data
        category = 0; // Indicate a_data
        a_data = 10; index = 0; #10; // a[0] = 10
        a_data = 20; index = 1; #10; // a[1] = 20
        a_data = 30; index = 2; #10; // a[2] = 30
        a_data = 40; index = 3; #10; // a[3] = 40
        a_data = 50; index = 4; #10; // a[4] = 50
        a_data = 60; index = 5; #10; // a[5] = 60
        a_data = 70; index = 6; #10; // a[6] = 70
        a_data = 80; index = 7; #10; // a[7] = 80
        a_data = 90; index = 8; #10; // a[8] = 90
        a_data = 100; index = 9; #10; // a[9] = 100
        a_data = 110; index = 10; #10; // a[10] = 110
        a_data = 120; index = 11; #10; // a[11] = 120
        a_data = 130; index = 12; #10; // a[12] = 130
        a_data = 140; index = 13; #10; // a[13] = 140
        a_data = 150; index = 14; #10; // a[14] = 150
        a_data = 160; index = 15; #10; // a[15] = 160

        // Load b_data
        category = 1; // Indicate b_data
        b_data = 2; index = 0; #10; // b[0] = 2
        b_data = 3; index = 1; #10; // b[1] = 3
        b_data = 4; index = 2; #10; // b[2] = 4
        b_data = 5; index = 3; #10; // b[3] = 5
        b_data = 6; index = 4; #10; // b[4] = 6
        b_data = 7; index = 5; #10; // b[5] = 7
        b_data = 8; index = 6; #10; // b[6] = 8
        b_data = 9; index = 7; #10; // b[7] = 9
        b_data = 10; index = 8; #10; // b[8] = 10
        b_data = 11; index = 9; #10; // b[9] = 11
        b_data = 12; index = 10; #10; // b[10] = 12
        b_data = 13; index = 11; #10; // b[11] = 13
        b_data = 14; index = 12; #10; // b[12] = 14
        b_data = 15; index = 13; #10; // b[13] = 15
        b_data = 16; index = 14; #10; // b[14] = 16
        b_data = 17; index = 15; #10; // b[15] = 17

        // Wait for computation to complete
        wait(done);

        // Finish simulation
        $finish;
    end

endmodule
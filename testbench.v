`timescale 1ns / 1ps

module testbench;

    // Inputs
    reg clk;
    reg rst;
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
        .a_data(a_data),
        .b_data(b_data),
        .c_data_in(c_data_in),
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
        a_data = 0;
        b_data = 0;
        c_data_in = 0;
        n = 4; // Test with 4 elements
        #20;

        // Release reset
        rst = 0;

        // Test case 1: Provide input data
        #10;
        a_data = 10; b_data = 2; c_data_in = 0; #10; // a[0]=10, b[0]=2
        a_data = 20; b_data = 3; c_data_in = 0; #10; // a[1]=20, b[1]=3
        a_data = 30; b_data = 4; c_data_in = 0; #10; // a[2]=30, b[2]=4
        a_data = 40; b_data = 5; c_data_in = 0; #10; // a[3]=40, b[3]=5

        // Wait for computation to complete
        wait(done);

        // Check results
        $display("Test completed. Output data:");
        $display("c[0] = %d", c_data_out); // Expected: (10 + 2*2) * (10 + 5*2)
        $display("c[1] = %d", c_data_out); // Expected: (20 + 2*3) * (20 + 5*3)
        $display("c[2] = %d", c_data_out); // Expected: (30 + 2*4) * (30 + 5*4)
        $display("c[3] = %d", c_data_out); // Expected: (40 + 2*5) * (40 + 5*5)

        // Finish simulation
        $finish;
    end

endmodule
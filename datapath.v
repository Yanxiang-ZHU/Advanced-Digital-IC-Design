module datapath (
    input wire clk,
    input wire rst,
    input wire load_a_en,
    input wire load_b_en,
    input wire load_c_en,
    input wire store_c_en,
    input wire mul_en,
    input wire add_en,
    input wire [1:0] mul_sel,  // 00:IDLE, 01:b[i]*2，10:b[i]*5，11:c[i]*(a[i]+5b[i])
    input wire [1:0] add_sel,  // 00:IDLE, 01:a[i]+b2，10:a[i]+b5
    input wire [31:0] a_data,
    input wire [31:0] b_data,
    input wire [31:0] c_data_in,
    output wire [31:0] c_data_out
);

reg [31:0] R1, R2, R3, R4, R5, R6, R7, R8, R9, R10;

// Load
always @(posedge clk) begin
    if (rst) begin
        R1 <= 0; R2 <= 0; R8 <= 0;
    end else begin
        if (load_a_en) R1 <= a_data; // a[i] -> R1
        if (load_b_en) R2 <= b_data; // b[i] -> R2
        if (load_c_en) R8 <= c_data_in; // c[i] -> R8
    end
end

// Mul
always @(posedge clk) begin
    if (mul_en) begin
        case (mul_sel)
            2'b01: R3 <= R2 * 2;      // b[i] * 2
            2'b10: R7 <= R6 * 5;      // b[i] * 5
            2'b11: R10 <= R8 * R9;    // c[i] * (a[i] + 5 * b[i])
            default: ;
        endcase
    end
end

always @(posedge clk) begin
    if (add_en) begin
        case (add_sel)
            2'b01: R4 <= R1 + R3;      // a[i] + (b[i] * 2)
            2'b10: R9 <= R5 + R7;      // a[i] + (b[i] * 5)
            default: ;
        endcase
    end
end

// Output
assign c_data_out = (store_c_en) ? ( (mul_sel == 2'b11) ? R10 : R4 ) : 32'bz; // Tri-state

endmodule

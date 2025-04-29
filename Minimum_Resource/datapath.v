module datapath (
    input wire clk,
    input wire rst,
    input wire category,
    input wire [9:0] index,
    input wire [9:0] index_loop,
    input wire load_a_en,
    input wire load_b_en,
    input wire load_c_en,
    input wire store_ab,
    input wire store_c_en,
    input wire mul_en,
    input wire add_en,
    input wire [1:0] mul_sel,  // 00:IDLE, 01:b[i]*2，10:b[i]*5，11:c[i]*(a[i]+5b[i])
    input wire [1:0] add_sel,  // 00:IDLE, 01:a[i]+b2，10:a[i]+b5
    input wire [31:0] a_data,
    input wire [31:0] b_data,
    output wire [31:0] c_data_out
);

reg [31:0] R1, R2, R3, R4, R7, R8, R9, R10;

reg [9:0] addr;
reg [31:0] din;
wire [31:0] dout;
sram #(.SIZE(300), .DATA_WIDTH(32)) SRAM (
    .clk(clk),
    .we(store_c_en || store_ab),
    .addr(addr),
    .din(din),
    .dout(dout)
);

// Data Storage
always @(*) begin
    if (store_ab) begin
        addr = category * 100 + index;
        din = (category == 0) ? a_data : b_data;
    end else if (store_c_en) begin
        addr = 200 + index_loop;
        din = (mul_sel == 2'b11) ? R10 : R4;
    end
end

// Load
always @(*) begin
    if (rst) begin
        R1 <= 0; R2 <= 0; R3 <= 0; R4 <= 0;
        R7 <= 0; R8 <= 0; R9 <= 0; R10 <= 0;
    end else begin
        if (load_a_en) begin addr = index_loop; R1 = dout; end // a[i] -> R1
        if (load_b_en) begin addr = 100 + index_loop; R2 = dout; end // b[i] -> R2
        if (load_c_en) begin addr = 200 + index_loop; R8 = dout; end // c[i] -> R8
    end
end

// Mul
always @(posedge clk) begin
    if (mul_en) begin
        case (mul_sel)
            2'b01: R3 <= R2 * 2;      // b[i] * 2
            2'b10: R7 <= R2 * 5;      // b[i] * 5
            2'b11: R10 <= R8 * R9;    // c[i] * (a[i] + 5 * b[i])
            default: ;
        endcase
    end
end

always @(posedge clk) begin
    if (add_en) begin
        case (add_sel)
            2'b01: R4 <= R1 + R3;      // a[i] + (b[i] * 2)
            2'b10: R9 <= R1 + R7;      // a[i] + (b[i] * 5)
            default: ;
        endcase
    end
end

// Output
assign c_data_out = (store_c_en) ? ( (mul_sel == 2'b11) ? R10 : R4 ) : 32'bz; // Tri-state

endmodule

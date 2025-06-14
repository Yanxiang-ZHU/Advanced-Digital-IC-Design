module datapath (
    input wire clk,
    input wire rst,
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
    input wire multi
);

reg [31:0] R1, R2, R3, R4, R7, R8, R9, R10;
reg [31:0] RR1, RR2, RR3, RR4, RR7, RR8, RR9, RR10;

reg [9:0] addr1;
reg [9:0] addr2;
reg [31:0] din1;
reg [31:0] din2;
wire [31:0] dout1;
wire [31:0] dout2;
sram #(.SIZE(300), .DATA_WIDTH(32)) SRAM (
    .clk(clk),
    .we(store_c_en || store_ab),
    .addr1(addr1),
    .addr2(addr2),
    .din1(din1),
    .din2(din2),
    .dout1(dout1),
    .dout2(dout2)
);

// Data Storage
always @(*) begin
    if (store_ab) begin
        addr1 = index;
        addr2 = 100 + index;
        din1 = a_data;
        din2 = b_data;
    end else if (store_c_en) begin
        addr1 = 200 + index_loop;
        din1 = (mul_sel == 2'b11) ? R10 : R4;
        if (multi) begin
            addr2 = 201 + index_loop;
            din2 = (mul_sel == 2'b11) ? RR10 : RR4;
        end
    end
end

// Load
always @(*) begin
    if (rst) begin
        R1 <= 0; R2 <= 0; R3 <= 0; R4 <= 0;
        R7 <= 0; R8 <= 0; R9 <= 0; R10 <= 0;
        RR1 <= 0; RR2 <= 0; RR3 <= 0; RR4 <= 0;
        RR7 <= 0; RR8 <= 0; RR9 <= 0; RR10 <= 0;
    end else begin
        if (load_a_en) begin
            addr1 = index_loop; 
            R1 = dout1; 
            if (multi) begin
                addr2 = index_loop + 1;
                RR1 = dout2;
            end
        end // a[i] -> R1, a[i+1] -> RR1

        if (load_b_en) begin
            addr1 = 100 + index_loop; 
            R2 = dout1;
            if (multi) begin
                addr2 = 100 + index_loop + 1;
                RR2 = dout2;
            end
        end // b[i] -> R2, b[i+1] -> RR2

        if (load_c_en) begin
            addr1 = 200 + index_loop; 
            R8 = dout1;
            if (multi) begin
                addr2 = 200 + index_loop + 1;
                RR8 = dout2;
            end
        end // c[i] -> R8, c[i+1] -> RR8
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
        if (multi) begin
            case (mul_sel)
                2'b01: RR3 <= RR2 * 2;      // b[i+1] * 2
                2'b10: RR7 <= RR2 * 5;      // b[i+1] * 5
                2'b11: RR10 <= RR8 * RR9;   // c[i+1] * (a[i+1] + 5 * b[i+1])
                default: ;
            endcase
        end
    end
end

always @(posedge clk) begin
    if (add_en) begin
        case (add_sel)
            2'b01: R4 <= R1 + R3;      // a[i] + (b[i] * 2)
            2'b10: R9 <= R1 + R7;      // a[i] + (b[i] * 5)
            default: ;
        endcase
        if (multi) begin
            case (add_sel)
                2'b01: RR4 <= RR1 + RR3;      // a[i+1] + (b[i+1] * 2)
                2'b10: RR9 <= RR1 + RR7;      // a[i+1] + (b[i+1] * 5)
                default: ;
            endcase
        end
    end
end

endmodule

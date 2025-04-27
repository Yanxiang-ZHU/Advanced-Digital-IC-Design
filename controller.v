module controller (
    input wire clk,
    input wire rst,
    input wire [31:0] n,
    output reg load_a_en,
    output reg load_b_en,
    output reg load_c_en,
    output reg store_c_en,
    output reg mul_en,
    output reg add_en,
    output reg [1:0] mul_sel,
    output reg [1:0] add_sel,
    output reg done
);

reg [3:0] state;
reg [31:0] i;

localparam S0=0, S1=1, S2=2, S3=3, S4=4, S5=5, S6=6, S7=7, S8=8, FINISH=9;

always @(posedge clk) begin
    if (rst) begin
        state <= S0;
        i <= 0;
        done <= 0;
    end else begin
        case(state)
            S0: begin
                load_a_en <= 1;
                load_b_en <= 1;
                load_c_en <= 0;
                mul_en <= 0;
                add_en <= 0;
                store_c_en <= 0;
                state <= S1;
            end
            S1: begin
                load_a_en <= 0;
                load_b_en <= 0;
                mul_en <= 1;
                mul_sel <= 2'b01; // b*2
                state <= S2;
            end
            S2: begin
                mul_en <= 0;
                add_en <= 1;
                add_sel <= 2'b01; // a+b2
                state <= S3;
            end
            S3: begin
                add_en <= 0;
                mul_en <= 1;
                mul_sel <= 2'b11; // c[i] * (a[i] + 5 * b[i])
                state <= S4;
            end
            S4: begin
                mul_en <= 0;
                store_c_en <= 1;
                if (i == n-1) begin
                    state <= FINISH;
                end else begin
                    i <= i + 1;
                    state <= S0;
                end
            end
            S5: begin
                load_a_en <= 0;
                load_b_en <= 0;
                load_c_en <= 0;
                mul_en <= 1;
                mul_sel <= 2'b10; // b*5
                state <= S6;
            end
            S6: begin
                mul_en <= 0;
                add_en <= 1;
                add_sel <= 2'b10; // a+b5
                state <= S7;
            end
            S7: begin
                add_en <= 0;
                mul_en <= 1;
                mul_sel <= 2'b11; // c*(a+5b)
                state <= S8;
            end
            S8: begin
                mul_en <= 0;
                store_c_en <= 1;
                if (i + 1 < n) begin
                    i <= i + 2;
                    state <= S0;
                end else if (i < n) begin
                    i <= i + 1;
                    state <= S0;
                end else begin
                    state <= FINISH;
                end
            end
            FINISH: begin
                store_c_en <= 0;
                done <= 1;
            end
            default: state <= S0;
        endcase
    end
end

endmodule

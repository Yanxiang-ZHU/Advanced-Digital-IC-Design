module controller (
    input wire clk,
    input wire rst,
    input wire we,
    input wire [31:0] n,
    output reg load_a_en,
    output reg load_b_en,
    output reg load_c_en,
    output reg store_ab,
    output reg store_c_en,
    output reg mul_en,
    output reg add_en,
    output reg [1:0] mul_sel,
    output reg [1:0] add_sel,
    output reg [9:0] index_loop, 
    output reg done
);

reg [3:0] state;
reg [31:0] j;
reg second_loop;

localparam S0=0, S1=1, S2=2, S3=3, S4=4, S5=5, S6=6, S7=7, S8=8, S9=9, FINISH=10;

always @(posedge clk) begin
    if (rst) begin
        state <= S0;
        index_loop <= 0;
        j <= 0;
        done <= 0;
        second_loop <= 0;
    end else begin
        case(state)
            S0: begin
                store_ab <= 1;
                if (we) begin
                    if (j == 2*n) begin
                        state <= S1;
                    end else begin
                        j <= j + 1;
                    end
                end
            end
            S1: begin
                if (store_c_en) index_loop <= index_loop + 1;
                store_ab <= 0;
                load_b_en <= 1;
                load_c_en <= 0;
                mul_en <= 0;
                add_en <= 0;
                store_c_en <= 0;
                state <= S2;
            end
            S2: begin
                load_a_en <= 1;
                load_b_en <= 0;
                load_c_en <= 0;
                mul_en <= 1;
                mul_sel <= 2'b01; // b*2
                state <= S3;
            end
            S3: begin
                load_a_en <= 0;
                mul_en <= 0;
                add_en <= 1;
                add_sel <= 2'b01; // a+2*b
                state <= S4;
            end
            S4: begin
                add_en <= 0;
                store_c_en <= 1;
                if (index_loop == n-1) begin
                    state <= S5;
                end else begin
                    state <= S1;
                end
            end
            S5: begin
                if (index_loop == n-1 && !second_loop) index_loop <= 0;
                else index_loop <= index_loop + 1;
                store_c_en <= 0;
                load_b_en <= 1;
                state <= S6;
            end
            S6: begin
                load_a_en <= 1;
                load_b_en <= 0;
                mul_en <= 1;
                mul_sel <= 2'b10; // b*5
                state <= S7;
            end
            S7: begin
                load_a_en <= 0;
                load_c_en <= 1;
                mul_en <= 0;
                add_en <= 1;
                add_sel <= 2'b10; // a+b*5
                state <= S8;
            end
            S8: begin
                load_c_en <= 0;
                add_en <= 0;
                mul_en <= 1;
                mul_sel <= 2'b11; // c*(a+5b)
                state <= S9;
            end
            S9: begin
                mul_en <= 0;
                store_c_en <= 1;
                if (index_loop < n) begin
                    state <= S5;
                    second_loop <= 1;
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

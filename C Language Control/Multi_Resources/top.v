module top (
    input wire clk,
    input wire rst,
    input wire we,
    input wire [9:0] index,
    input wire [31:0] a_data,
    input wire [31:0] b_data,
    input wire [31:0] n,
    output wire done
);

wire store_ab;
wire [9:0] index_loop;
wire load_a_en, load_b_en, load_c_en, store_c_en, mul_en, add_en;
wire [1:0] mul_sel, add_sel;
wire multi;

datapath u_datapath (
    .clk(clk), 
    .rst(rst),
    .index(index),
    .index_loop(index_loop),
    .load_a_en(load_a_en),
    .load_b_en(load_b_en),
    .load_c_en(load_c_en),
    .store_ab(store_ab),
    .store_c_en(store_c_en),
    .mul_en(mul_en),
    .add_en(add_en),
    .mul_sel(mul_sel),
    .add_sel(add_sel),
    .a_data(a_data),
    .b_data(b_data),
    .multi(multi)
);

controller u_controller (
    .clk(clk), 
    .rst(rst),
    .we(we),
    .n(n),
    .load_a_en(load_a_en),
    .load_b_en(load_b_en),
    .load_c_en(load_c_en),
    .store_ab(store_ab),
    .store_c_en(store_c_en),
    .mul_en(mul_en),
    .add_en(add_en),
    .mul_sel(mul_sel),
    .add_sel(add_sel),
    .index_loop(index_loop),
    .multi(multi),
    .done(done)
);

endmodule

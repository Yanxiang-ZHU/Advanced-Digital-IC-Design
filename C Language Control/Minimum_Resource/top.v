module top (
    input wire clk,
    input wire rst,
    input wire we,
    input wire category,
    input wire [9:0] index,
    input wire [31:0] a_data,
    input wire [31:0] b_data,
    input wire [31:0] n,
    output wire [31:0] c_data_out,
    output wire done
);

wire store_ab;
wire [9:0] index_loop;
wire load_a_en, load_b_en, load_c_en, store_c_en, mul_en, add_en;
wire [1:0] mul_sel, add_sel;

datapath u_datapath (
    .clk(clk), 
    .rst(rst),
    .category(category),
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
    .c_data_out(c_data_out)
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
    .done(done)
);

endmodule

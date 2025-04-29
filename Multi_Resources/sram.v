module sram #(
    parameter SIZE = 300,
    parameter DATA_WIDTH = 32
)(
    input wire clk,
    input wire we,
    input wire [9:0] addr1,
    input wire [9:0] addr2,
    input wire [DATA_WIDTH-1:0] din1,
    input wire [DATA_WIDTH-1:0] din2,
    output wire [DATA_WIDTH-1:0] dout1,
    output wire [DATA_WIDTH-1:0] dout2
);


reg [DATA_WIDTH-1:0] SRAM [0:SIZE-1];

always @(posedge clk) begin
    if (we) begin
        SRAM[addr1] <= din1;
        SRAM[addr2] <= din2;
    end
end

assign dout1 = SRAM[addr1][DATA_WIDTH:0];
assign dout2 = SRAM[addr2][DATA_WIDTH:0];

endmodule
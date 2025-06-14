module sram #(
    parameter SIZE = 300,
    parameter DATA_WIDTH = 32
)(
    input wire clk,
    input wire we,
    input wire [9:0] addr,
    input wire [DATA_WIDTH-1:0] din,
    output wire [DATA_WIDTH-1:0] dout
);


reg [DATA_WIDTH-1:0] SRAM [0:SIZE-1];

always @(posedge clk) begin
    if (we) begin
        SRAM[addr] <= din;
    end
end

assign dout = SRAM[addr][DATA_WIDTH:0];

endmodule
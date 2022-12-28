module rom_rd #(
    parameter DATA_WIDTH = 24,
    parameter ADDR_WIDTH = 16
)( 
    input wire clk,
    input wire rst_n,
    // FSM interface
    input wire rom_rd_en_i,
    input wire rom_rd_done_i,
    // ROM interface
    output wire rom_en_o,
    output reg [ADDR_WIDTH-1:0] rom_addr_o,
    input wire [DATA_WIDTH-1:0] rom_din_i,
    // DS interface
    output wire [DATA_WIDTH-1:0] rom_dout_o,
    output wire rom_dout_valid_o
);

    always @(posedge clk) begin
        if (~rst_n) begin
            rom_addr_o <= 0;
        end
        else begin
            if (rom_rd_done_i) begin
                rom_addr_o <= 0;
            end
            else if (rom_rd_en_i) begin
                rom_addr_o <= rom_addr_o + 1;
            end
        end
    end
    
    // reading the data from block rom requires 1clk delay 
    reg rom_dout_valid_q;
    reg rom_dout_valid_q2;
    always @(posedge clk) begin
        rom_dout_valid_q <= rom_rd_en_i;
        rom_dout_valid_q2 <= rom_dout_valid_q;
    end

    assign rom_en_o = rom_rd_en_i;
    assign rom_dout_o = rom_din_i;
    assign rom_dout_valid_o = rom_dout_valid_q2;

endmodule


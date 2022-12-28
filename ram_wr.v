module ram_wr #(
    parameter DATA_WIDTH = 24
)(
    input wire clk,
    input wire rst_n,
    // FSM interface
    input wire us_run_i,
    // US interface
    input wire us_done_i,
    input wire us_data_valid_i,
    input wire [DATA_WIDTH-1:0] us_data_i,
    // RAM interface
    output wire [31:0] ram_addr_o,
    output wire [31:0] ram_dout_o,
    output wire ram_en_o,
    output wire [3:0] ram_wr_en_o
);
    
    reg [31:0] ram_addr;
    //reg ram_en;
    
    always @(posedge clk) begin
        if (~rst_n) begin
            ram_addr <= 0;
        end
        else begin
            if (us_done_i) begin
                ram_addr <= 0;
            end
            else if (us_run_i && us_data_valid_i) begin
                // word vs byte
                ram_addr <= ram_addr + 4;
            end
        end
    end
    
    assign ram_addr_o = ram_addr;
    assign ram_dout_o = {8'h0, us_data_i};
    assign ram_en_o = us_data_valid_i;
    assign ram_wr_en_o = (us_data_valid_i) ? 4'b1111 : 4'b0000;
    

endmodule

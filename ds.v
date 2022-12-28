module ds #(
    parameter DATA_WIDTH = 24
)(
    input wire clk,
    input wire rst_n,
    // FSM interface
    // input wire ds_run_i,
    output wire ds_done_o,
    // ROM_RD interface
    input wire rd_data_valid_i,
    input wire [DATA_WIDTH-1:0] rd_data_i,
    // US interface
    output wire ds_data_valid_o,
    output wire [DATA_WIDTH-1:0] ds_data_o
);

    // reg [7:0] x_pos, y_pos;
    reg [7:0] row_cnt, col_cnt;
    
    always @(posedge clk) begin
        if (~rst_n) begin
            row_cnt <= 0;
            col_cnt <= 0;
        end
        else begin
            if (ds_done_o) begin
                row_cnt <= 0;
                col_cnt <= 0;
            end
            else if (rd_data_valid_i) begin
                row_cnt <= row_cnt + 1;
                if (row_cnt == 255) begin
                    col_cnt <= col_cnt + 1;
                end
            end
        end
    end
    
    reg [DATA_WIDTH-1:0] ds_data;
    reg ds_data_valid;
    always @(posedge clk) begin
        if (rd_data_valid_i) begin
            ds_data_valid <= 0;
            if ((row_cnt[0] == 0) && (col_cnt[0] == 0)) begin
                ds_data <= rd_data_i;
                ds_data_valid <= 1;
            end
        end
    end
    
    assign ds_data_o = ds_data;
    assign ds_data_valid_o = ds_data_valid;
    
    assign ds_done_o = ((row_cnt == 255) && (col_cnt == 255)) ? 1 : 0;
    
    

endmodule

module us #(
    parameter DATA_WIDTH = 24
)(
    input wire clk,
    input wire rst_n,
    // FSM interface
    input wire us_run_i,
    output wire us_done_o,
    // RAM_WR interface
    output wire us_data_valid_o,
    output wire [DATA_WIDTH-1:0] us_data_o,
    // DS interface
    input wire ds_data_valid_i,
    input wire [DATA_WIDTH-1:0] ds_data_i
);
reg [DATA_WIDTH-1:0] buffer_1 [0:127];
reg [DATA_WIDTH-1:0] buffer_2 [0:127];
reg [DATA_WIDTH-1:0] buffer_temp [0:127];
reg [DATA_WIDTH-1:0] buf_row_avg[0:127];
reg [DATA_WIDTH-1:0] buf_col_avg[0:127];
reg [DATA_WIDTH-1:0] buf_cross_avg[0:127];
reg [DATA_WIDTH-1:0] buf_row_data;
reg [DATA_WIDTH-1:0] buf_col_data;
reg [DATA_WIDTH-1:0] buf_cross_data;
reg [6:0] buf_1_addr = 0;
reg [6:0] buf_2_addr = 0;
reg buf_rd_en = 0;
reg buf_rd_en_row = 0;
reg buf_rd_en_col = 0;
reg buf_rd_en_cross = 0;
reg [6:0] buf_col_addr;
reg [6:0] buf_row_addr;
reg [6:0] buf_cross_addr;






//buffer 
always @(posedge clk) begin
    if((ds_data_valid_i) && (buf_1_addr < 127)) begin
        buffer_1[buf_1_addr] <= ds_data_i;
        end
        else if((ds_data_valid_i) && (buf_1_addr == 127)) begin
             buffer_2[buf_2_addr] <= ds_data_i;
             end
        if(buf_rd_en_row)begin
            buf_row_data  <= buf_row_avg[buf_row_addr];
            end
            if(buf_rd_en_col)begin
             buf_col_data <= buf_col_avg[buf_col_addr];
             end
             if(buf_rd_en_col)begin
              buf_cross_data <= buf_cross_avg[buf_cross_addr];
              end
    end

integer i, j, k;

//buffer acc
always @(posedge clk) begin
    if((buf_1_addr == 127) && (buf_2_addr == 127)) begin
    for(i=0;i<127;i = i+1)begin
        buf_row_avg[i] = buffer_1[i]/2 + buffer_1[i+1]/2;
        buf_row_avg[127] = buffer_1[127];
        end
        for(j=0;j<128;j = j+1)begin
            buf_col_avg[j] = buffer_1[j]/2 + buffer_2[j]/2;
             end
             for(k=0;k<127;k = k+1)begin
                  buf_cross_avg[k] = buffer_1[k]/4 + buffer_1[k+1]/4
                 + buffer_2[k]/4 + buffer_2[k+1]/4;
                     buf_cross_avg[127] = buf_col_avg[127];
                     end
                    buf_rd_en =1;
                   
   end
   end
   
integer p;
always @(posedge clk) begin
    if(buf_rd_en)begin
        
            
      for(p=0;p<128;p=p+1)begin
            buffer_1[p] <= buffer_2[p];
            
        end
        buf_2_addr = 0;
     end
  end

//buffer address

always @(posedge clk) begin
    if (~rst_n) begin
        buf_1_addr <= 0;
        buf_2_addr <= 0;
    end
   else begin
   if (us_run_i) begin
        if((ds_data_valid_i) && (buf_1_addr < 127)) begin
            buf_1_addr <= buf_1_addr + 1;
            end
          else if((buf_1_addr == 127) && (ds_data_valid_i)) begin
                 buf_2_addr <= buf_2_addr + 1;
                
                 
             end
        end
    end
end


    

//row & column counter
reg [7:0] row_cnt = 0, col_cnt = 0;
always @(posedge clk) begin
    if (~rst_n) begin
        row_cnt <= 0;
        col_cnt <= 0;
    end
    else begin
        if (us_done_o) begin
             row_cnt <= 0;
             col_cnt <= 0;
        end
        else if (us_run_i) begin
            row_cnt <= row_cnt + 1;
                if (row_cnt == 255) begin
                    col_cnt <= col_cnt + 1;
                end
            end
        end
    end
    
//us data
reg [DATA_WIDTH-1:0] us_data;
always @(posedge clk) begin
   if((us_run_i) && (buf_rd_en)) begin
      if((row_cnt[0] == 0) && (col_cnt[0] == 0)) begin
         us_data <= ds_data_i;
      end
      else if ((row_cnt[0] == 1) && (col_cnt[0] == 0)) begin
      
         us_data = buf_row_data;
        
      end
      else if ((row_cnt[0] == 0) && (col_cnt[0] == 1)) begin
      
         us_data = buf_col_data;
         
      end
      else if ((row_cnt[0] == 1) && (col_cnt[0] == 1)) begin
       
         us_data = buf_cross_data;
         
      end
        end
       end


//buffer read address

always @(posedge clk) begin
    if(~rst_n) begin
        buf_col_addr <= 0;
         buf_row_addr <= 0;
          buf_cross_addr <= 0;
    end
    else begin
        if(us_run_i) begin
            if(col_cnt[0] == 0) begin
                if(row_cnt[0] == 1) begin
                    buf_row_addr <= buf_row_addr + 1;
                end
            end
            else if (col_cnt[0] == 1) begin
                if(row_cnt[0] == 0) begin
                    buf_col_addr <= buf_col_addr +1;
                    end
                    else if(row_cnt[0]==1) begin
                        buf_cross_addr = buf_cross_addr +1;
                        end
                end
            end
        end
    end
    
    


reg us_data_valid;
always @(posedge clk) begin
    if(us_done_o) begin
        us_data_valid <= 0;
    end
    else begin
    if(buf_rd_en)
        us_data_valid <= us_run_i;
    end
end

always @(posedge clk) begin
        if (us_run_i) begin
            if((col_cnt == 0) && (row_cnt == 1)) begin
                buf_rd_en_row = 1;
            end
            else if ((col_cnt[0] == 0) && (row_cnt == 255)) begin
                buf_rd_en_col = 1;
                buf_rd_en_row = 0;
            end
             else if ((col_cnt[0] == 1) && (row_cnt == 0)) begin
                buf_rd_en_cross = 1;
            end
            else if((col_cnt[0] == 1) && (row_cnt ==255)) begin
                    buf_rd_en_row =1;
                    buf_rd_en_col = 0;
                     buf_rd_en_cross = 0;
                    end
     
      /*  if(buf_rd_en)begin
            us_done = 0;
            end
            else begin
            us_done = 1;            
            end
            */
            
        end
    end


    assign us_data_o = us_data;
    assign us_data_valid_o = us_data_valid;

    assign us_done_o = ((row_cnt == 255) && (col_cnt == 255)) ? 1 : 0;
      

endmodule
module fsm(
    input wire clk,
    input wire rst_n,
    // TOP interface
    input wire start_i,
    output wire run_o, // 
    output wire done_o, // 
    output wire done_led_o, // 
    
    // ROM_RD interface
    input wire rom_rd_valid_i, //?
    output wire rom_rd_done_o, //?
    output wire ds_run_o,
    // DS interface
    input wire ds_done_i,
    // US interface
    output wire us_run_o,
    input wire us_done_i
    
);

/*
 / You have to wait enough time after finish up-sample
 / For example, you can wait around 1 sec by counting 33333300
*/
      
 
    localparam ST_IDLE = 0, ST_DS = 1, ST_US = 2; 
    reg [1:0] cstate, nstate;
    reg button_rst_q;
    reg ds_run_i = 0;
    reg us_run_i = 0;
    reg run = 0;
    reg [26:0] done_o_delay=0;
    reg done_o_reg = 0;
    
     assign ds_run_o = ds_run_i;
     assign us_run_o = us_run_i;
     assign done_o = done_o_reg;
     assign done_led_o = run;
     assign run_o = run;
     
     
     always@(posedge clk) begin  
     if(us_done_i) begin
     done_o_reg = 1;
     done_o_delay = 1; end
     
     else if(done_o_reg) begin
      done_o_delay <= done_o_delay + 1;
       if(done_o_delay < 33333300)
         done_o_reg <= 1;
       else
        done_o_reg <= 0;
         end
      end
     
     
     
    
    
    always @(posedge clk) begin
     button_rst_q<=rst_n; end
    
    //part1
    always@(posedge clk or negedge rst_n) begin
     if(!rst_n) 
      cstate <= ST_IDLE;
     else
      cstate <= nstate;
    end
    
    //part2
    always@(*) 
     case(cstate)
      ST_IDLE : if(start_i) nstate = ST_DS; else nstate = ST_IDLE;
      ST_DS : nstate = ST_US; 
      ST_US : if(us_done_i) nstate = ST_IDLE; else nstate = ST_US; 
      default: nstate = ST_IDLE;
     endcase
    
   
    //part3 determine output
   
    always @(posedge clk) begin
     case(cstate) 
      ST_IDLE : run = 0;
      ST_DS : begin run = 1; end
      ST_US : begin ds_run_i = 1'b1; us_run_i = 1'b1; run = 1; end
      default : run = 0;
      endcase 
     end
     
     
   
endmodule
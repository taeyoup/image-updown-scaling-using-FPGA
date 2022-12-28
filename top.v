module top #(
    parameter DATA_WIDTH = 24,
    parameter ADDR_WIDTH = 16
)(
    input wire clk,
    input wire rst_n,
    input wire start_i,
    output wire run_o,
    output wire done_o,
    output wire done_led_o,
    // RAM interface
    output wire [31:0] ram_addr_o,
    output wire [31:0] ram_dout_o,
    output wire ram_en_o,
    output wire [3:0] ram_wr_en_o
);
    
    wire rom_en_w;
    wire [ADDR_WIDTH-1:0] rom_addr_w;
    wire [DATA_WIDTH-1:0] rom_dout_w;
    wire [DATA_WIDTH-1:0] test_rom_dout_w;
    wire rom_rd_done_w;
    wire ds_done_w;
    wire us_done_w;
    wire ds_run_w;
    wire us_run_w;
    wire rd_data_valid_w;
    wire ds_data_valid_w;
    wire us_data_valid_w;
    wire [DATA_WIDTH-1:0] rd_data_w;
    wire [DATA_WIDTH-1:0] ds_data_w;
    wire [DATA_WIDTH-1:0] us_data_w;
    
    // --------------------------------------
    // Do not modify it!!
    // --------------------------------------
    blk_rom rom_inst(
        .clka(clk),    
        .ena(rom_en_w),      
        .addra(rom_addr_w),  
        .douta(rom_dout_w)  
    );
    
    // --------------------------------------
    // Do not modify it!!
    // --------------------------------------
    rom_rd #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) rom_rd_inst(
        .clk(clk),
        .rst_n(rst_n),
        // FSM interface
        .rom_rd_en_i(ds_run_w),
        .rom_rd_done_i(rom_rd_done_w),
        // Rom interface
        .rom_en_o(rom_en_w),
        .rom_addr_o(rom_addr_w),
        .rom_din_i(rom_dout_w),
        // DS interface
        .rom_dout_o(rd_data_w),
        .rom_dout_valid_o(rd_data_valid_w)
    );
    
    // --------------------------------------
    // Design your own logic
    // You can modify input & output ports
    // You can make it!! :)
    // --------------------------------------
    fsm fsm_inst(
        .clk(clk),
        .rst_n(rst_n),
        // TOP interface
        .start_i(start_i),
        .run_o(run_o),
        .done_o(done_o),
        .done_led_o(done_led_o),
        // ROM_RD interface
        .rom_rd_valid_i(rd_data_valid_w),
        .rom_rd_done_o(rom_rd_done_w),
        .ds_run_o(ds_run_w),
        // DS interface
        .ds_done_i(ds_done_w),
        // US interface
        .us_run_o(us_run_w),
        .us_done_i(us_done_w)
    );
    
    // --------------------------------------
    // Design your own logic
    // You can modify input & output ports
    // You can make it!! :)
    // --------------------------------------
    ds #(
        .DATA_WIDTH(DATA_WIDTH)
    ) ds_inst(
        .clk(clk),
        .rst_n(rst_n),
        // FSM interface
        .ds_done_o(ds_done_w),
        // ROM_RD interface
        .rd_data_valid_i(rd_data_valid_w),
        .rd_data_i(rd_data_w),
        // US interface
        .ds_data_valid_o(ds_data_valid_w),
        .ds_data_o(ds_data_w)
    );
    
    // --------------------------------------
    // Design your own logic
    // You can modify input & output ports
    // You can make it!! :)
    // --------------------------------------
    us #(
        .DATA_WIDTH(DATA_WIDTH)
    ) us_inst(
        .clk(clk),
        .rst_n(rst_n),
        // FSM interface
        .us_run_i(us_run_w),
        .us_done_o(us_done_w),
        // RAM_WR interface
        .us_data_valid_o(us_data_valid_w),
        .us_data_o(us_data_w),
        // DS interface
        .ds_data_valid_i(ds_data_valid_w),
        .ds_data_i(ds_data_w)
    );
    
    // --------------------------------------
    // Do not modify RAM interface signals,
    // but you can modify others.
    // --------------------------------------
    ram_wr #(
        .DATA_WIDTH(DATA_WIDTH)
    ) ram_wr_inst(
        .clk(clk),
        .rst_n(rst_n),
        // FSM interface
        .us_run_i(us_run_w),
        // US interface
        .us_done_i(us_done_w),
        .us_data_valid_i(us_data_valid_w),
        .us_data_i(us_data_w),
        // RAM interface
        .ram_addr_o(ram_addr_o),
        .ram_dout_o(ram_dout_o),
        .ram_en_o(ram_en_o),
        .ram_wr_en_o(ram_wr_en_o)
    );
    
    
endmodule

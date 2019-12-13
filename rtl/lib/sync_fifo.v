////////////////////////////////////////////////////////////////////////////////
// Company     :
//
// Filename    : sync_fifo.v
// Description : 
//
// Author      : 
// Created On  : 10-6-2015
// History     : Initial 	
//
////////////////////////////////////////////////////////////////////////////////
module sync_fifo
    (
     rst_n,
     // write
     wclk,
     wfifo_i,  // request write to fifo
     wdata_i,
     wfull_o,
     // read
     rclk, 
     rfifo_i,
     rempty_o,
     rdata_o  // request read from fifo
     );
//------------------------------------------------------------------------------
//parameter
parameter ADD_W = 3;
parameter DATA_W = 36;
//------------------------------------------------------------------------------
// Port declarations
input                   rst_n;
input                   wclk;
input                   wfifo_i;
input [DATA_W-1:0]      wdata_i;
output                  wfull_o;
// read
input                   rclk;
input                   rfifo_i;
output [DATA_W-1:0]     rdata_o;
output                  rempty_o;
//------------------------------------------------------------------------------
//internal signal
wire  [ADD_W:0]         rptr;
wire  [ADD_W:0]         wptr;
wire                    ren;
wire                    wen;
wire  [ADD_W-1:0]       waddr;
wire  [ADD_W-1:0]       raddr;
wire  [DATA_W-1:0]      rdata_o;
wire  [DATA_W-1:0]      ff_rdata;
wire  [DATA_W-1:0]      nxt_rdata;
//------------------------------------------------------------------------------
//Read control
sync_fiford_ctrl    #(.AW(ADD_W))  sync_fiford_ctrl_00
    (
    .rclk     (rclk),
    .rst_n    (rst_n),
    // input interface
    .rfifo_i  (rfifo_i), 
    .wptr_i   (wptr), 
    // output interface
    .ren_o    (ren),
    .rempty_o (rempty_o),
    .raddr_o  (raddr),
    .rptr_o   (rptr)
     );
//------------------------------------------------------------------------------
//Write control
sync_fifowr_ctrl   #(.AW(ADD_W))   sync_fifowr_ctrl_00
    (
    .wclk    (wclk),
    .rst_n   (rst_n),
    // input interface
    .wfifo_i (wfifo_i),
    .rptr_i  (rptr),
    // output interface
    .wen_o   (wen),
    .wfull_o (wfull_o),
    .waddr_o (waddr),
    .wptr_o  (wptr)
     );
/*
//------------------------------------------------------------------------------
//SRAM
model_alt_ram_dual_clk  #(.AW(ADD_W),
                          .DW(DATA_W),
                          .DEPTH(DEPTH))  model_alt_ram_dual_clk_00
    (
    //Read
    .rclk    (rclk),
    .raddr_i (raddr),
    .rdata_o (rdata_o),
    //Write
    .wclk    (wclk),
    .wen_i   (wen),
    .wdata_i (wdata_i),
    .waddr_i (waddr)
    );

*/

//------------------------------------------------------------------------------
//Register MEM
regfile8xnb   #(.AW(ADD_W),
                .DW(DATA_W))    regfile8xnb_00
    (
    .clk     (wclk),
    .rst_n   (rst_n),	
    //-----------------------------
    //Write
    .wen_i   (wen),//Write enable
    .waddr_i (waddr),//write address
    .wdata_i (wdata_i),//write data
    .clr_i   (1'b0),
    //-----------------------------
    //Read
    .raddr_i (raddr),//Read address
    .rdata_o (ff_rdata)//Read data
    );
//------------------------------------------------------------------------------
//Latch output data
/*
assign nxt_rdata = ren ? ff_rdata : rdata_o;
always@(posedge rclk or negedge rst_n)
    begin
    if (!rst_n)
        rdata_o <= {DATA_W{1'b0}};
    else
        rdata_o <= nxt_rdata;
    end
*/
 assign rdata_o = ff_rdata;
endmodule 


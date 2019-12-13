//////////////////////////////////////////////////////////////////////////////////
//
// Company     : XnonymouX
//
// Filename        : sync_fiford_ctrl.v
// Description     : Control reading FIFO 
//					
//
// Author          : Duong Nguyen
// Created On      : 9/9/2015
// History (Date, Changed By)
//
//////////////////////////////////////////////////////////////////////////////////
module sync_fiford_ctrl
    (
    rclk,
    rst_n,

    //--------------------------------------
    // input interface
    rfifo_i,  // request read fifo
    wptr_i, 
    //--------------------------------------
    // output interface
    ren_o,
    rempty_o,
    raddr_o, // reading address
    rptr_o
    );

//-----------------------------------------------------------------------------
//parameter
parameter AW = 3;

//-----------------------------------------------------------------------------
// Port declarations
input               rclk;
input               rst_n;
//--------------------------------------
// input interface
input               rfifo_i;
input   [AW:0]      wptr_i;
//--------------------------------------
// output interface
output              ren_o;
output              rempty_o;
output  [AW-1:0]    raddr_o;
output  [AW:0]      rptr_o;
//-----------------------------------------------------------------------------
//internal signal
wire [AW:0]         nxt_rptr;
reg  [AW:0]         rptr;
wire                ren;
wire                nxt_rempty;
reg                 rempty;
//------------------------------------------------------------------------------
//Latch read pointer
assign ren = rfifo_i & (~rempty);
assign nxt_rptr = ren ? (rptr + 1'b1) : rptr;
always @ (posedge rclk or negedge rst_n)
    begin
    if(!rst_n)
        rptr <= {(AW+1){1'b0}};
    else
        rptr <= nxt_rptr;
    end
assign raddr_o = rptr[AW-1:0];
assign ren_o = ren;
assign rptr_o = rptr;
//------------------------------------------------------------------------------
//Empty detection
assign nxt_rempty = (nxt_rptr == wptr_i);
always @ (posedge rclk or negedge rst_n)
    begin
    if(!rst_n)
        rempty <= 1'b1;
    else
        rempty <= nxt_rempty;
    end
assign rempty_o = rempty;
 
endmodule 


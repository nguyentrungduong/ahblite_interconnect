//////////////////////////////////////////////////////////////////////////////////
//
// Company     : XnonymouX
//
// Filename        : sync_fifowr_ctrl.v
// Description     : Control writing FIFO. 
//					
//
// Author          : Duong Nguyen
// Created On      : 9/9/2015
// History (Date, Changed By)
//
//////////////////////////////////////////////////////////////////////////////////
module sync_fifowr_ctrl
    (
    wclk,
    rst_n,

    //--------------------------------------
    // input interface
    wfifo_i,
    rptr_i,
    //--------------------------------------
    // output interface
    wen_o,
    wfull_o,
    waddr_o,
    wptr_o
     );

//-----------------------------------------------------------------------------
//parameter
parameter AW = 3;

//-----------------------------------------------------------------------------
// Port declarations
input               wclk;
input               rst_n;
//--------------------------------------
// input interface
input               wfifo_i;
input   [AW:0]      rptr_i;
//--------------------------------------
// output interface
output              wen_o;
output              wfull_o;
output  [AW-1:0]    waddr_o;
output  [AW:0]      wptr_o;
//-----------------------------------------------------------------------------
//internal signal
wire [AW:0]         nxt_wptr;
reg  [AW:0]         wptr;
wire                wen;
wire                nxt_wfull;
reg                 wfull;
//------------------------------------------------------------------------------
//Latch read pointer
assign wen = wfifo_i & (~wfull);
assign nxt_wptr = wen ? (wptr + 1'b1) : wptr;
always @ (posedge wclk or negedge rst_n)
    begin
    if(!rst_n)
        wptr <= {(AW+1){1'b0}};
    else
        wptr <= nxt_wptr;
    end
assign waddr_o = wptr[AW-1:0];
assign wen_o = wen;
assign wptr_o = wptr;
//------------------------------------------------------------------------------
//Empty detection
assign nxt_wfull = ({~nxt_wptr[AW],wptr[AW-1:0]} == rptr_i);
always@(posedge wclk or negedge rst_n)
    begin
    if(!rst_n)
        wfull <= 1'b0;
    else
        wfull <= nxt_wfull;
    end
assign wfull_o = wfull;
 
endmodule 


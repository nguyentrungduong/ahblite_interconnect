////////////////////////////////////////////////////////////////////////////////
// Company     : XnonymouX
//
// Filename    : mux3
// Description : 3:1 parallel mux.
//
// Author      : Duong Nguyen
// Created On  : 10-6-2015
// History     : Initial 	
//
////////////////////////////////////////////////////////////////////////////////

module mux3
    (
    sel0,
    in0,
    //-------------------
    sel1,
    in1,
    //-------------------
    sel2,
    in2,
    //-------------------
    out
    );

//------------------------------------------------------------------------------
//Parameters
parameter DW = 1'b1;
//------------------------------------------------------------------------------
// Port declarations
input               sel0;
input [DW-1:0]	    in0;
//
input               sel1;
input [DW-1:0]	    in1;
//
input               sel2;
input [DW-1:0]	    in2;
//
output [DW-1:0]	    out;
//------------------------------------------------------------------------------
//internal signal

//------------------------------------------------------------------------------
//Logic
assign out = ({DW{sel0}} & in0) |
             ({DW{sel1}} & in1) |
             ({DW{sel2}} & in2);

endmodule 

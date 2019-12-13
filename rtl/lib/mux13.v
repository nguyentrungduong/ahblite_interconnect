////////////////////////////////////////////////////////////////////////////////
// Company     : XnonymouX
//
// Filename    : mux13.v
// Description : 13:1 parallel mux.
//
// Author      : Duong Nguyen
// Created On  : 10-6-2015
// History     : Initial 	
//
////////////////////////////////////////////////////////////////////////////////

module mux13
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
    sel3,
    in3,
    //-------------------
    sel4,
    in4,
    //-------------------
    sel5,
    in5,
    //-------------------
    sel6,
    in6,
    //-------------------
    sel7,
    in7,
    //-------------------
    sel8,
    in8,
    //-------------------
    sel9,
    in9,
    //-------------------
    sel10,
    in10,
    //-------------------
    sel11,
    in11,
    //-------------------
    sel12,
    in12,
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
input               sel3;
input [DW-1:0]	    in3;
//
input               sel4;
input [DW-1:0]	    in4;
//
input               sel5;
input [DW-1:0]	    in5;
//
input               sel6;
input [DW-1:0]	    in6;
//
input               sel7;
input [DW-1:0]	    in7;
//
input               sel8;
input [DW-1:0]	    in8;
//
input               sel9;
input [DW-1:0]	    in9;
//
input               sel10;
input [DW-1:0]	    in10;
//
input               sel11;
input [DW-1:0]	    in11;
//
input               sel12;
input [DW-1:0]	    in12;
//
output [DW-1:0]	    out;
//------------------------------------------------------------------------------
//internal signal
wire [DW-1:0]       out0_5;
wire [DW-1:0]       out6_12;
//------------------------------------------------------------------------------
//Mux 6:1
mux6   #(.DW(DW))   mux0_5
    (
    .sel0  (sel0),
    .in0   (in0),
    //-------------------
    .sel1  (sel1),
    .in1   (in1),
    //-------------------
    .sel2  (sel2),
    .in2   (in2),
    //-------------------
    .sel3  (sel3),
    .in3   (in3),
    //-------------------
    .sel4  (sel4),
    .in4   (in4),
    //-------------------
    .sel5  (sel5),
    .in5   (in5),
    //-------------------
    .out   (out0_5)
    );
//------------------------------------------------------------------------------
//Mux 7:1
mux7   #(.DW(DW))   mux6_12
    (
    .sel0  (sel6),
    .in0   (in6),
    //-------------------
    .sel1  (sel7),
    .in1   (in7),
    //-------------------
    .sel2  (sel8),
    .in2   (in8),
    //-------------------
    .sel3  (sel9),
    .in3   (in9),
    //-------------------
    .sel4  (sel10),
    .in4   (in10),
    //-------------------
    .sel5  (sel11),
    .in5   (in11),
    //-------------------
    .sel6  (sel12),
    .in6   (in12),
    //-------------------
    .out   (out6_12)
    );
//------------------------------------------------------------------------------
//Mux 2:1
assign out = out0_5 | out6_12;

endmodule 


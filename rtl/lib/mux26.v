////////////////////////////////////////////////////////////////////////////////
// Company     : XnonymouX
//
// Filename    : mux26.v
// Description : 26:1 parallel mux.
//
// Author      : Duong Nguyen
// Created On  : 10-6-2015
// History     : Initial 	
//
////////////////////////////////////////////////////////////////////////////////

module mux26
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
    sel13,
    in13,
    //-------------------
    sel14,
    in14,
    //-------------------
    sel15,
    in15,
    //-------------------
    sel16,
    in16,
    //-------------------
    sel17,
    in17,
    //-------------------
    sel18,
    in18,
    //-------------------
    sel19,
    in19,
    //-------------------
    sel20,
    in20,
    //-------------------
    sel21,
    in21,
    //-------------------
    sel22,
    in22,
    //-------------------
    sel23,
    in23,
    //-------------------
    sel24,
    in24,
    //-------------------
    sel25,
    in25,
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
input               sel13;
input [DW-1:0]	    in13;
//
input               sel14;
input [DW-1:0]	    in14;
//
input               sel15;
input [DW-1:0]	    in15;
//
input               sel16;
input [DW-1:0]	    in16;
//
input               sel17;
input [DW-1:0]	    in17;
//
input               sel18;
input [DW-1:0]	    in18;
//
input               sel19;
input [DW-1:0]	    in19;
//
input               sel20;
input [DW-1:0]	    in20;
//
input               sel21;
input [DW-1:0]	    in21;
//
input               sel22;
input [DW-1:0]	    in22;
//
input               sel23;
input [DW-1:0]	    in23;
//
input               sel24;
input [DW-1:0]	    in24;
//
input               sel25;
input [DW-1:0]	    in25;
//
output [DW-1:0]	    out;
//------------------------------------------------------------------------------
//internal signal
wire [DW-1:0]       out0_12;
wire [DW-1:0]       out13_25;
//------------------------------------------------------------------------------
//Mux 13:1
mux13   #(.DW(DW))   mux0_12
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
    .sel6  (sel6),
    .in6   (in6),
    //-------------------
    .sel7  (sel7),
    .in7   (in7),
    //-------------------
    .sel8  (sel8),
    .in8   (in8),
    //-------------------
    .sel9  (sel9),
    .in9   (in9),
    //-------------------
    .sel10  (sel10),
    .in10   (in10),
    //-------------------
    .sel11  (sel11),
    .in11   (in11),
    //-------------------
    .sel12  (sel12),
    .in12   (in12),
    //-------------------
    .out   (out0_12)
    );
//------------------------------------------------------------------------------
//Mux 13:1
mux13   #(.DW(DW))   mux13_25
    (
    .sel0  (sel13),
    .in0   (in13),
    //-------------------
    .sel1  (sel14),
    .in1   (in14),
    //-------------------
    .sel2  (sel15),
    .in2   (in15),
    //-------------------
    .sel3  (sel16),
    .in3   (in16),
    //-------------------
    .sel4  (sel17),
    .in4   (in17),
    //-------------------
    .sel5  (sel18),
    .in5   (in18),
    //-------------------
    .sel6  (sel19),
    .in6   (in19),
    //-------------------
    .sel7  (sel20),
    .in7   (in20),
    //-------------------
    .sel8  (sel21),
    .in8   (in21),
    //-------------------
    .sel9  (sel22),
    .in9   (in23),
    //-------------------
    .sel10  (sel23),
    .in10   (in23),
    //-------------------
    .sel11  (sel24),
    .in11   (in24),
    //-------------------
    .sel12  (sel25),
    .in12   (in25),
    //-------------------
    .out   (out13_25)
    );
//------------------------------------------------------------------------------
//Mux 2:1
assign out = out0_12 | out13_25;

endmodule 

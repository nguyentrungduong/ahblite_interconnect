////////////////////////////////////////////////////////////////////////////////
// Company     : Xnonymous
//
// Filename    : ahblite_m_port.v
// Description : AHB Lite master port which connects to AHB lite master
//
// Author      : Duong Nguyen
// Created On  : 
// History     : Initial 	
//
////////////////////////////////////////////////////////////////////////////////

module ahblite_m_port
    (
    clk          ,
    rst          ,//synchronous reset, active-high
    //---------------------------------
    //AHB slave interface
    haddr_i      ,
    hwrite_i     ,
    htrans_i     ,
    hsize_i      ,
    hburst_i     ,
    hwdata_i     ,
    hmastlock_i  ,
    hprot_i      ,
    hreadyout_o  ,
    hresp_o      ,
    hrdata_o     ,
    //---------------------------------
    //Internal slave port interface
    s_grant_i    ,//grant signals from requested slaves
    s_req_o      ,//request slave signals
    s_addr_base_i,//from top module
    s_haddr_o    ,
    s_hwrite_o   ,
    s_htrans_o   ,
    s_hsize_o    ,
    s_hburst_o   ,
    s_hwdata_o   ,
    s_hready_i   ,//hready in from slaves
    s_hreadyout_o,//output from hready mux
    s_hmastlock_o,
    s_hprot_o    ,
    s_hresp_i    ,
    s_hrdata_i   
    );

//------------------------------------------------------------------------------
//parameter
parameter AHB_AW  = 32;
parameter AHB_DW  = 32;
parameter SLV_NUM = 8;//NUmber of slave


//------------------------------------------------------------------------------
// Port declarations
input logic                              clk;
input logic                              rst;
//---------------------------------
//AHB slave interface
input logic [AHB_AW-1:0]                 haddr_i;
input logic                              hwrite_i;
input logic [1:0]                        htrans_i;
input logic [2:0]                        hsize_i;
input logic [2:0]                        hburst_i;
input logic [3:0]                        hprot_i;
input logic [AHB_DW-1:0]                 hwdata_i;
input logic                              hmastlock_i;
output logic                             hreadyout_o;
output logic                             hresp_o;
output logic [AHB_DW-1:0]                hrdata_o;
//---------------------------------
//Internal slave port interface
input logic [SLV_NUM-1:0]                s_grant_i;//grant signals from requested slaves
output logic [SLV_NUM-1:0]               s_req_o;//request slave signals
input  logic [SLV_NUM-1:0][AHB_AW-1:0]   s_addr_base_i;//from top module
output logic [AHB_AW-1:0]                s_haddr_o;
output logic                             s_hwrite_o;
output logic [1:0]                       s_htrans_o;
output logic [2:0]                       s_hsize_o;
output logic [2:0]                       s_hburst_o;
output logic [AHB_DW-1:0]                s_hwdata_o;
input logic  [SLV_NUM-1:0]               s_hready_i;//hready in from all slaves
output logic                             s_hreadyout_o;//output from hready mux
output logic                             s_hmastlock_o;
output logic [3:0]                       s_hprot_o;
input logic  [SLV_NUM-1:0]               s_hresp_i;
input logic [SLV_NUM-1:0][AHB_DW-1:0]    s_hrdata_i;

//------------------------------------------------------------------------------
//internal signal
logic                                    s0_addr_dec; 
logic                                    s1_addr_dec; 
logic                                    s2_addr_dec; 
logic                                    s3_addr_dec; 
logic                                    s4_addr_dec; 
logic                                    s5_addr_dec; 
logic                                    s6_addr_dec; 
logic                                    s7_addr_dec;
logic                                    non_seq;
logic [SLV_NUM-1:0]                      s_req;
logic [1:0]                              nxt_trans;
logic [2:0]                              nxt_size;
logic                                    nxt_write;
logic [2:0]                              nxt_burst;
logic                                    clr_vld;

logic [SLV_NUM-1:0]                      nxt_req;
logic [SLV_NUM-1:0]                      req;

logic [AHB_AW-1:0]                       nxt_haddr;
logic                                    nxt_hwrite;
logic [1:0]                              nxt_htrans;
logic [2:0]                              nxt_hsize;
logic [2:0]                              nxt_hburst;
logic                                    nxt_hmastlock;
logic [3:0]                              nxt_hprot;
logic [AHB_DW-1:0]                       nxt_hwdata;


//------------------------------------------------------------------------------
//Decode and latch request signals, request is triggered at each
//NONSEQ transaction
assign s0_addr_dec = (haddr_i[31:16] == s_addr_base_i[0][31:16]); 
assign s1_addr_dec = (haddr_i[31:16] == s_addr_base_i[1][31:16]); 
assign s2_addr_dec = (haddr_i[31:16] == s_addr_base_i[2][31:16]); 
assign s3_addr_dec = (haddr_i[31:16] == s_addr_base_i[3][31:16]); 
assign s4_addr_dec = (haddr_i[31:16] == s_addr_base_i[4][31:16]); 
assign s5_addr_dec = (haddr_i[31:16] == s_addr_base_i[5][31:16]); 
assign s6_addr_dec = (haddr_i[31:16] == s_addr_base_i[6][31:16]); 
assign s7_addr_dec = (haddr_i[31:16] == s_addr_base_i[7][31:16]);

assign non_seq = (htrans_i == 2'b10) & hreadyout_o; //NONSEQ type

assign s_req[0] = s0_addr_dec & non_seq;
assign s_req[1] = s1_addr_dec & non_seq;
assign s_req[2] = s2_addr_dec & non_seq;
assign s_req[3] = s3_addr_dec & non_seq;
assign s_req[4] = s4_addr_dec & non_seq;
assign s_req[5] = s5_addr_dec & non_seq;
assign s_req[6] = s6_addr_dec & non_seq;
assign s_req[7] = s7_addr_dec & non_seq;

assign nxt_req[0] = s_grant_i[0] ? 1'b0 : 
                    s_req[0]     ? 1'b1 : req[0];

assign nxt_req[1] = s_grant_i[1] ? 1'b0 : 
                    s_req[1]     ? 1'b1 : req[1];

assign nxt_req[2] = s_grant_i[2] ? 1'b0 : 
                    s_req[2]     ? 1'b1 : req[2];

assign nxt_req[3] = s_grant_i[3] ? 1'b0 : 
                    s_req[3]     ? 1'b1 : req[3];

assign nxt_req[4] = s_grant_i[4] ? 1'b0 : 
                    s_req[4]     ? 1'b1 : req[4];

assign nxt_req[5] = s_grant_i[5] ? 1'b0 : 
                    s_req[5]     ? 1'b1 : req[5];

assign nxt_req[6] = s_grant_i[6] ? 1'b0 : 
                    s_req[6]     ? 1'b1 : req[6];

assign nxt_req[7] = s_grant_i[7] ? 1'b0 : 
                    s_req[7]     ? 1'b1 : req[7];


dff_rst  #(8)  dff_req  (clk,rst,nxt_req,req);

assign s_req_o = req | s_req;

//------------------------------------------------------------------------------
//hresp mux
mux8  #(.DW(1))  mux8_hresp
    (
    .in0(s_hresp_i[0]), .sel0(s_grant_i[0]),
    .in1(s_hresp_i[1]), .sel1(s_grant_i[1]),
    .in2(s_hresp_i[2]), .sel2(s_grant_i[2]),
    .in3(s_hresp_i[3]), .sel3(s_grant_i[3]),
    .in4(s_hresp_i[4]), .sel4(s_grant_i[4]),
    .in5(s_hresp_i[5]), .sel5(s_grant_i[5]),
    .in6(s_hresp_i[6]), .sel6(s_grant_i[6]),
    .in7(s_hresp_i[7]), .sel7(s_grant_i[7]),
    .out(hresp_o)
    );
//------------------------------------------------------------------------------
//hreadyout_o mux

assign hreadyout_o = //(|req)       ? 1'b0          :
                     s_grant_i[0] ? s_hready_i[0] :
                     s_grant_i[1] ? s_hready_i[1] :
                     s_grant_i[2] ? s_hready_i[2] :
                     s_grant_i[3] ? s_hready_i[3] :
                     s_grant_i[4] ? s_hready_i[4] :
                     s_grant_i[5] ? s_hready_i[5] :
                     s_grant_i[6] ? s_hready_i[6] :
                     s_grant_i[7] ? s_hready_i[7] : 
                     (|req)       ? 1'b0          : 1'b1;
                     
//------------------------------------------------------------------------------
//hrdata mux
mux8  #(.DW(32))  mux8_hrdata
    (
    .in0(s_hrdata_i[0]), .sel0(s_grant_i[0]),
    .in1(s_hrdata_i[1]), .sel1(s_grant_i[1]),
    .in2(s_hrdata_i[2]), .sel2(s_grant_i[2]),
    .in3(s_hrdata_i[3]), .sel3(s_grant_i[3]),
    .in4(s_hrdata_i[4]), .sel4(s_grant_i[4]),
    .in5(s_hrdata_i[5]), .sel5(s_grant_i[5]),
    .in6(s_hrdata_i[6]), .sel6(s_grant_i[6]),
    .in7(s_hrdata_i[7]), .sel7(s_grant_i[7]),
    .out(hrdata_o)
    );
//------------------------------------------------------------------------------
//Latch input controls and address

//haddr[31:0]
assign nxt_haddr = hreadyout_o ? haddr_i : s_haddr_o;
 
dff_rst  #(32)  dff_haddr (clk,rst,nxt_haddr,s_haddr_o);

//hwrite
assign nxt_hwrite = hreadyout_o ? hwrite_i : s_hwrite_o;
 
dff_rst  #(1)  dff_hwrite (clk,rst,nxt_hwrite,s_hwrite_o);

//htrans[1:0]
assign nxt_htrans = hreadyout_o ? htrans_i : s_htrans_o;
 
dff_rst  #(2) dff_htrans (clk,rst,nxt_htrans,s_htrans_o);

//hsize[2:0]
assign nxt_hsize = hreadyout_o ? hsize_i : s_hsize_o;
 
dff_rst  #(3) dff_hsize (clk,rst,nxt_hsize,s_hsize_o);

//hburst[2:0]
assign nxt_hburst = hreadyout_o ? hburst_i : s_hburst_o;
 
dff_rst  #(3) dff_hburst (clk,rst,nxt_hburst,s_hburst_o);

//hmastlock
assign nxt_hmastlock = hreadyout_o ? hmastlock_i : s_hmastlock_o;
 
dff_rst  #(1) dff_hmastlock (clk,rst,nxt_hmastlock,s_hmastlock_o);

//hprot[3:0]
assign nxt_hprot = hreadyout_o ? hprot_i : s_hprot_o;
 
dff_rst  #(4) dff_hprot (clk,rst,nxt_hprot,s_hprot_o);

//hwdata[31:0]
assign nxt_hwdata = hreadyout_o ? hwdata_i : s_hwdata_o;
 
dff_rst  #(32) dff_hwdata (clk,rst,nxt_hwdata,s_hwdata_o);


//Routing hready back again to slave
assign s_hreadyout_o = hreadyout_o;


endmodule 


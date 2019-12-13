////////////////////////////////////////////////////////////////////////////////
// Company     : XnonymousX
//
// Filename    : ahblite_interconnect.sv
// Description : AHB Lite master port which connects to AHB lite master
//
// Author      : Duong Nguyen
// Created On  : 
// History     : Initial 	
//
////////////////////////////////////////////////////////////////////////////////

module ahblite_interconnect
    (
    clk        ,
    rst        ,//synchronous reset, active-high
    //---------------------------------
    //AHB slave, master port
    haddr_i    ,
    hwrite_i   ,
    htrans_i   ,
    hsize_i    ,
    hburst_i   ,
    hwdata_i   ,
    hmastlock_i,
    hprot_i    ,
    hreadyout_o,
    hresp_o    ,
    hrdata_o   ,
    //---------------------------------
    //AHB master, slave port
    hsel_o     ,
    haddr_o    ,
    hwrite_o   ,
    htrans_o   ,
    hsize_o    ,
    hburst_o   ,
    hwdata_o   ,
    hready_o   ,
    hmastlock_o,
    hprot_o    ,
    hreadyout_i,
    hresp_i    ,
    hrdata_i
    );

////////////////////////////////////////////////////////////////////////////////
//parameter
parameter AHB_AW  = 32;
parameter AHB_DW  = 32;
parameter SLV_NUM = 8;//NUmber of slave
parameter MST_NUM = 4;//NUmber of master


parameter OFFSET_7 = 32'h0007_0000;
parameter OFFSET_6 = 32'h0006_0000;
parameter OFFSET_5 = 32'h0005_0000;
parameter OFFSET_4 = 32'h0004_0000;
parameter OFFSET_3 = 32'h0003_0000;
parameter OFFSET_2 = 32'h0002_0000;
parameter OFFSET_1 = 32'h0001_0000;
parameter OFFSET_0 = 32'h0000_0000;
////////////////////////////////////////////////////////////////////////////////
// Port declarations
input logic                              clk;
input logic                              rst;
//---------------------------------
//AHB slave, master port
input logic [MST_NUM-1:0][AHB_AW-1:0]    haddr_i;
input logic [MST_NUM-1:0]                hwrite_i;
input logic [MST_NUM-1:0][1:0]           htrans_i;
input logic [MST_NUM-1:0][2:0]           hsize_i;
input logic [MST_NUM-1:0][2:0]           hburst_i;
input logic [MST_NUM-1:0][3:0]           hprot_i;
input logic [MST_NUM-1:0][AHB_DW-1:0]    hwdata_i;
input logic [MST_NUM-1:0]                hmastlock_i;
output logic [MST_NUM-1:0]               hreadyout_o;
output logic [MST_NUM-1:0]               hresp_o;
output logic [MST_NUM-1:0][AHB_DW-1:0]   hrdata_o;
//---------------------------------
//AHB master, slave port
output logic [SLV_NUM-1:0]               hsel_o;
output logic [SLV_NUM-1:0][AHB_AW-1:0]   haddr_o;
output logic [SLV_NUM-1:0]               hwrite_o;
output logic [SLV_NUM-1:0][1:0]          htrans_o;
output logic [SLV_NUM-1:0][2:0]          hsize_o;
output logic [SLV_NUM-1:0][2:0]          hburst_o;
output logic [SLV_NUM-1:0][3:0]          hprot_o;
output logic [SLV_NUM-1:0][AHB_DW-1:0]   hwdata_o;
output logic [SLV_NUM-1:0]               hready_o;
output logic [SLV_NUM-1:0]               hmastlock_o;
input logic [SLV_NUM-1:0]                hreadyout_i;
input logic [SLV_NUM-1:0]                hresp_i;
input logic [SLV_NUM-1:0][AHB_DW-1:0]    hrdata_i;



//------------------------------------------------------------------------------
//internal signal
logic [MST_NUM-1:0][SLV_NUM-1:0]                m_grant;
logic [MST_NUM-1:0][SLV_NUM-1:0]                m_req;
logic [MST_NUM-1:0][AHB_AW-1:0]                 m_haddr;
logic [MST_NUM-1:0]                             m_hwrite;
logic [MST_NUM-1:0][1:0]                        m_htrans;
logic [MST_NUM-1:0][2:0]                        m_hsize;
logic [MST_NUM-1:0][2:0]                        m_hburst;
logic [MST_NUM-1:0][AHB_AW-1:0]                 m_hwdata;
logic [MST_NUM-1:0][SLV_NUM-1:0]                m_hready;
logic [MST_NUM-1:0]                             m_hreadyout;
logic [MST_NUM-1:0]                             m_hmastlock;
logic [MST_NUM-1:0][3:0]                        m_hprot;
logic [MST_NUM-1:0][SLV_NUM-1:0]                m_hresp;
logic [MST_NUM-1:0][SLV_NUM-1:0][AHB_AW-1:0]    m_hrdata;
wire  [SLV_NUM-1:0][AHB_AW-1:0]                 m_addr_base;//from top module

logic [SLV_NUM-1:0][MST_NUM-1:0]                s_grant;
logic [SLV_NUM-1:0][MST_NUM-1:0]                s_req;
logic [SLV_NUM-1:0][MST_NUM-1:0][AHB_AW-1:0]    s_haddr;
logic [SLV_NUM-1:0][MST_NUM-1:0]                s_hwrite;
logic [SLV_NUM-1:0][MST_NUM-1:0][1:0]           s_htrans;
logic [SLV_NUM-1:0][MST_NUM-1:0][2:0]           s_hsize;
logic [SLV_NUM-1:0][MST_NUM-1:0][2:0]           s_hburst;
logic [SLV_NUM-1:0][MST_NUM-1:0][AHB_DW-1:0]    s_hwdata;
logic [SLV_NUM-1:0]                             s_hready;
logic [SLV_NUM-1:0][MST_NUM-1:0]                s_hreadyout;
logic [SLV_NUM-1:0][MST_NUM-1:0]                s_hmastlock;
logic [SLV_NUM-1:0]                             s_hresp;
logic [SLV_NUM-1:0][AHB_DW-1:0]                 s_hrdata;
logic [SLV_NUM-1:0][MST_NUM-1:0][3:0]           s_hprot;

//------------------------------------------------------------------------------
//Master port generation

assign m_addr_base = {OFFSET_7,
                      OFFSET_6,
                      OFFSET_5,
                      OFFSET_4,
                      OFFSET_3,
                      OFFSET_2,
                      OFFSET_1,
                      OFFSET_0};
 
genvar k;
generate
    for(k=0; k<MST_NUM; k=k+1)
        begin : ahblite_m_port_label
        //
        ahblite_m_port   #(.AHB_AW(AHB_AW),
                           .AHB_DW(AHB_DW),
                           .SLV_NUM(SLV_NUM))   ahblite_m_port_inst
            (
            .clk           (clk)           ,
            .rst           (rst)           ,//synchronous reset, active-high
            //---------------------------------
            //AHB slave interface
            .haddr_i       (haddr_i[k])    ,
            .hwrite_i      (hwrite_i[k])   ,
            .htrans_i      (htrans_i[k])   ,
            .hsize_i       (hsize_i[k])    ,
            .hburst_i      (hburst_i[k])   ,
            .hwdata_i      (hwdata_i[k])   ,
            .hmastlock_i   (hmastlock_i[k]),
            .hprot_i       (hprot_i[k])    ,
            .hreadyout_o   (hreadyout_o[k]),
            .hresp_o       (hresp_o[k])    ,
            .hrdata_o      (hrdata_o[k])   ,
            //---------------------------------
            //Internal slave port interface
            .s_grant_i     (m_grant[k])    ,//grant signals from requested slaves
            .s_req_o       (m_req[k])      ,//request slave signals
            .s_addr_base_i (m_addr_base)   ,//Slave offset
            .s_haddr_o     (m_haddr[k])    ,
            .s_hwrite_o    (m_hwrite[k])   ,
            .s_htrans_o    (m_htrans[k])   ,
            .s_hsize_o     (m_hsize[k])    ,
            .s_hburst_o    (m_hburst[k])   ,
            .s_hwdata_o    (m_hwdata[k])   ,
            .s_hready_i    (m_hready[k])   ,//hready in from slaves
            .s_hreadyout_o (m_hreadyout[k]),//output from hready mux
            .s_hmastlock_o (m_hmastlock[k]),
            .s_hprot_o     (m_hprot[k])    ,
            .s_hresp_i     (m_hresp[k])    ,
            .s_hrdata_i    (m_hrdata[k])   
            );
        assign m_grant[k] = {s_grant[7][k],s_grant[6][k],s_grant[5][k],s_grant[4][k],
                             s_grant[3][k],s_grant[2][k],s_grant[1][k],s_grant[0][k]};

        assign m_hready[k] = {s_hready[7],s_hready[6],s_hready[5],s_hready[4],
                              s_hready[3],s_hready[2],s_hready[1],s_hready[0]};   

        assign m_hresp[k] = {s_hresp[7],s_hresp[6],s_hresp[5],s_hresp[4],
                             s_hresp[3],s_hresp[2],s_hresp[1],s_hresp[0]};

        assign m_hrdata[k] = {s_hrdata[7],s_hrdata[6],s_hrdata[5],s_hrdata[4],
                              s_hrdata[3],s_hrdata[2],s_hrdata[1],s_hrdata[0]};

        end
endgenerate
//------------------------------------------------------------------------------
//Slave port generation

genvar k1;
generate
    for(k1=0; k1<SLV_NUM; k1=k1+1)
        begin : ahblite_s_port_label
        //
        ahblite_s_port   #(.AHB_AW(AHB_AW),
                           .AHB_DW(AHB_DW),
                           .MST_NUM(MST_NUM))   ahblite_s_port_inst
            (
            .clk           (clk)            ,
            .rst           (rst)            ,//synchronous reset, active-high
            //---------------------------------
            //AHB slave port interface
            .hsel_o        (hsel_o[k1])     ,
            .haddr_o       (haddr_o[k1])    ,
            .hwrite_o      (hwrite_o[k1])   ,
            .htrans_o      (htrans_o[k1])   ,
            .hsize_o       (hsize_o[k1])    ,
            .hburst_o      (hburst_o[k1])   ,
            .hwdata_o      (hwdata_o[k1])   ,
            .hready_o      (hready_o[k1])   ,
            .hmastlock_o   (hmastlock_o[k1]), 
            .hprot_o       (hprot_o[k1])    ,
            .hreadyout_i   (hreadyout_i[k1]),
            .hresp_i       (hresp_i[k1])    ,
            .hrdata_i      (hrdata_i[k1])   ,
            //---------------------------------
            //Internal slave port interface
            .s_grant_o     (s_grant[k1])    ,//grant signals from requested slaves
            .s_req_i       (s_req[k1])      ,//request slave signals
            .s_haddr_i     (s_haddr[k1])    ,
            .s_hwrite_i    (s_hwrite[k1])   ,
            .s_htrans_i    (s_htrans[k1])   ,
            .s_hsize_i     (s_hsize[k1])    ,
            .s_hburst_i    (s_hburst[k1])   ,
            .s_hwdata_i    (s_hwdata[k1])   ,
            .s_hready_o    (s_hready[k1])   ,//hready to master port
            .s_hreadyout_i (s_hreadyout[k1]),
            .s_hmastlock_i (s_hmastlock[k1]),
            .s_hprot_i     (s_hprot[k1])    ,
            .s_hresp_o     (s_hresp[k1])    , 
            .s_hrdata_o    (s_hrdata[k1])
            );
        assign s_req[k1]    = {m_req[3][k1],m_req[2][k1],m_req[1][k1],m_req[0][k1]};

        assign s_haddr[k1]  = {m_haddr[3],m_haddr[2],m_haddr[1],m_haddr[0]};

        assign s_hwrite[k1] = {m_hwrite[3],m_hwrite[2],m_hwrite[1],m_hwrite[0]};

        assign s_htrans[k1] = {m_htrans[3],m_htrans[2],m_htrans[1],m_htrans[0]};

        assign s_hsize[k1]  = {m_hsize[3],m_hsize[2],m_hsize[1],m_hsize[0]};

        assign s_hburst[k1] = {m_hburst[3],m_hburst[2],m_hburst[1],m_hburst[0]};

        assign s_hwdata[k1] = {m_hwdata[3],m_hwdata[2],m_hwdata[1],m_hwdata[0]};

        assign s_hreadyout[k1] = {m_hreadyout[3],m_hreadyout[2],m_hreadyout[1],
                                 m_hreadyout[0]};

        assign s_hmastlock[k1] = {m_hmastlock[3],m_hmastlock[2],m_hmastlock[1],
                                 m_hmastlock[0]};

        assign s_hprot[k1] = {m_hprot[3],m_hprot[2],m_hprot[1],m_hprot[0]};

        end
endgenerate


endmodule 


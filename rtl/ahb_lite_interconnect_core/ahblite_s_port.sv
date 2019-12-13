////////////////////////////////////////////////////////////////////////////////
// Company     : XnonymouX
//
// Filename    : ahblite_s_port.sv
// Description : AHB Lite slave port which connects to AHB lite slave
//
// Author      : Duong Nguyen
// Created On  : 
// History     : Initial 	
//
////////////////////////////////////////////////////////////////////////////////

module ahblite_s_port
    (
    clk          ,
    rst          ,//synchronous reset, active-high
    //---------------------------------
    //AHB slave port interface
    hsel_o       ,
    haddr_o      ,
    hwrite_o     ,
    htrans_o     ,
    hsize_o      ,
    hburst_o     ,
    hwdata_o     ,
    hready_o     ,
    hmastlock_o  ,
    hprot_o      ,
    hreadyout_i  ,
    hresp_i      ,
    hrdata_i     ,
    //---------------------------------
    //Internal slave port interface
    s_grant_o    ,//grant signals from requested slaves
    s_req_i      ,//request slave signals
    s_haddr_i    ,
    s_hwrite_i   ,
    s_htrans_i   ,
    s_hsize_i    ,
    s_hburst_i   ,
    s_hwdata_i   ,
    s_hready_o   ,//hready to master port
    s_hreadyout_i,
    s_hmastlock_i,
    s_hprot_i    ,
    s_hresp_o    ,
    s_hrdata_o   
    );

////////////////////////////////////////////////////////////////////////////////
//parameter
parameter AHB_AW  = 32;
parameter AHB_DW  = 32;
parameter MST_NUM = 4;//NUmber of master

parameter IDLE    = 2'b00;
parameter ARB     = 2'b01;
parameter ACCESS  = 2'b10;


////////////////////////////////////////////////////////////////////////////////
// Port declarations
input logic                              clk;
input logic                              rst;
//---------------------------------
//AHB master interface
output logic                             hsel_o;
output logic [AHB_AW-1:0]                haddr_o;
output logic                             hwrite_o;
output logic [1:0]                       htrans_o;
output logic [2:0]                       hsize_o;
output logic [2:0]                       hburst_o;
output logic [3:0]                       hprot_o;
output logic [AHB_DW-1:0]                hwdata_o;
output logic                             hready_o;
output logic                             hmastlock_o;
input logic                              hreadyout_i;
input logic                              hresp_i;
input logic [AHB_DW-1:0]                 hrdata_i;
//---------------------------------
//Internal slave port interface
output logic [MST_NUM-1:0]               s_grant_o;//grant signals from requested slaves
input logic [MST_NUM-1:0]                s_req_i;//request slave signals
input logic [MST_NUM-1:0][AHB_AW-1:0]    s_haddr_i;
input logic [MST_NUM-1:0]                s_hwrite_i;
input logic [MST_NUM-1:0][1:0]           s_htrans_i;
input logic [MST_NUM-1:0][2:0]           s_hsize_i;
input logic [MST_NUM-1:0][2:0]           s_hburst_i;
input logic [MST_NUM-1:0][AHB_DW-1:0]    s_hwdata_i;
output logic                             s_hready_o;//hready to master port
input logic [MST_NUM-1:0]                s_hreadyout_i;//from from all master port
input logic [MST_NUM-1:0]                s_hmastlock_i;
input logic [MST_NUM-1:0][3:0]           s_hprot_i;
output logic                             s_hresp_o;
output logic [AHB_DW-1:0]                s_hrdata_o;  


//------------------------------------------------------------------------------
//internal signal
logic [MST_NUM-1:0]                      grant;
logic [2:0]                              burst_type;
logic                                    single;
logic                                    wrap4;
logic                                    incr4;
logic                                    incr8;
logic                                    wrap8;
logic                                    incr16;
logic                                    wrap16;

logic [4:0]                              burst_len;
logic                                    clr_burst_cnt;
logic [4:0]                              nxt_burst_cnt;
logic [4:0]                              burst_cnt;

logic                                    has_req;
logic                                    idle_to_arb;
logic                                    access_to_idle;
logic                                    access_to_arb;
logic                                    st_idle;
logic                                    st_access;
logic                                    st_arb;
logic                                    en_arb;

logic [1:0]                              cur_mst_tmp;
logic [1:0]                              cur_mst;
logic [1:0]                              nxt_cur_mst;
logic                                    nxt_gen_hready;
logic                                    burst_cnt_eq_len;
logic [1:0]                              nxt_state;
logic [1:0]                              state;
logic                                    slv_hready;
logic [1:0]                              mux_htrans;
logic [2:0]                              mux_hsize;
logic                                    mux_hwrite;
logic                                    mux_latch_hwrite;
logic [AHB_AW-1:0]                       mux_haddr;

//------------------------------------------------------------------------------
//Burst counter
mux4  #(.DW(3))  mux4_burst_type
    (
    .in0(s_hburst_i[0]), .sel0(grant[0]),
    .in1(s_hburst_i[1]), .sel1(grant[1]),
    .in2(s_hburst_i[2]), .sel2(grant[2]),
    .in3(s_hburst_i[3]), .sel3(grant[3]),
    .out (burst_type)
    );

 
assign single = (burst_type == 3'b000);
assign wrap4  = (burst_type == 3'b010);
assign incr4  = (burst_type == 3'b011);
assign wrap8  = (burst_type == 3'b100);
assign incr8  = (burst_type == 3'b101);
assign wrap16 = (burst_type == 3'b110);
assign incr16 = (burst_type == 3'b111);


mux4  #(.DW(5))  mux4_burst_len
    (
    .in0(5'd1) , .sel0(single)         ,
    .in1(5'd4) , .sel1(wrap4 | incr4)  ,
    .in2(5'd8) , .sel2(wrap8 | incr8)  ,
    .in3(5'd16), .sel3(wrap16 | incr16),
    .out (burst_len)
    );

//assign clr_burst_cnt = burst_cnt_eq_len & hreadyout_i;
assign clr_burst_cnt = burst_cnt_eq_len & slv_hready;
assign nxt_burst_cnt = clr_burst_cnt ? 5'd0 :
                       (slv_hready & st_access) ? (burst_cnt + 1'b1) : burst_cnt; 

//Burst counter FF
dff_rst  #(5)  dff_burst_cnt  (clk,rst,nxt_burst_cnt,burst_cnt);

//assign burst_cnt_eq_len = (burst_cnt == burst_len);
assign burst_cnt_eq_len = (burst_cnt == burst_len);

//------------------------------------------------------------------------------
//Arbitration control state machine
assign has_req = |s_req_i;
assign idle_to_arb = has_req & st_idle;
assign access_to_idle = clr_burst_cnt & (~has_req) & st_access;
assign access_to_arb = clr_burst_cnt & has_req & st_access; 

always_comb
    begin
    case (state)
    	IDLE :
            begin
    	    nxt_state = idle_to_arb ? ARB : IDLE;
    	    end	
    	ARB :
    	    begin
    	    nxt_state = ACCESS;
    	    end
    	ACCESS :
    	    begin
    	    nxt_state = access_to_idle ? IDLE : 
                        access_to_arb  ? ARB  : ACCESS;
    	    end	
    	default :
    	    begin
    	    nxt_state = IDLE;
    	    end	
    endcase
    end

dff_rst  #(2)  dff_arb_state  (clk,rst,nxt_state,state);

assign st_idle   = (state == IDLE);
assign st_access = (state == ACCESS);
assign st_arb    = (state == ARB);


//For debug
//logic       st_access_1;
//dff_rst #(1) dff_st_access (clk,rst,st_access,st_access_1);


//------------------------------------------------------------------------------
//Current accessed master
assign en_arb = st_arb;

always_comb
    begin
    case (cur_mst)
    	2'd0 :
            begin
    	    cur_mst_tmp = s_req_i[1] ? 2'd1 :
                          s_req_i[2] ? 2'd2 :
                          s_req_i[3] ? 2'd3 : 2'd0;
    	    end	
    	2'd1 :
            begin
    	    cur_mst_tmp = s_req_i[2] ? 2'd2 :
                          s_req_i[3] ? 2'd3 :
                          s_req_i[0] ? 2'd0 : 2'd1;
    	    end	
    	2'd2 :
            begin
    	    cur_mst_tmp = s_req_i[3] ? 2'd3 :
                          s_req_i[0] ? 2'd0 :
                          s_req_i[1] ? 2'd1 : 2'd2;
    	    end	
    	2'd3 :
            begin
    	    cur_mst_tmp = s_req_i[0] ? 2'd0 :
                          s_req_i[1] ? 2'd1 :
                          s_req_i[2] ? 2'd2 : 2'd3;
    	    end	
    	default :
    	    begin
    	    cur_mst_tmp = 2'd0;
    	    end	
    endcase
    end


assign nxt_cur_mst = en_arb ? cur_mst_tmp : cur_mst;  

dff_rst  #(2)  dff_cur_master  (clk,rst,nxt_cur_mst,cur_mst);

assign grant[0] = (cur_mst == 2'd0) & st_access;
assign grant[1] = (cur_mst == 2'd1) & st_access;
assign grant[2] = (cur_mst == 2'd2) & st_access;
assign grant[3] = (cur_mst == 2'd3) & st_access;
//------------------------------------------------------------------------------
//pipeline st_arb
logic    st_arb_1;

dff_rst  #(1)  dff_st_arb_1 (clk,rst,st_arb,st_arb_1);

//------------------------------------------------------------------------------
//Read address generation

logic [31:0]    nxt_gen_haddr;
logic [31:0]    gen_haddr;
logic [31:0]    gen_haddr1;


assign nxt_gen_haddr = (~hready_o) ? 32'd0          :
                       hready_o    ? (gen_haddr1 + 32'd4) : gen_haddr1;

dff_rst #(32) dff_gen_haddr (clk,rst,nxt_gen_haddr,gen_haddr);

assign gen_haddr1 = st_arb_1 ? mux_haddr : gen_haddr;

//------------------------------------------------------------------------------
//Generate hready

//assign s_hready_o = (hreadyout_i & st_access);//Route to master ports
logic hready_1;

assign hready_o = hreadyout_i & st_access;//HREADY to slave

dff_rst #(1) dff_s_hready (clk,rst,hready_o,hready_1);

//assign s_hready_o = mux_hwrite ? hready_o : hready_1;
 
assign s_hready_o = mux_hwrite ? hready_o : (hready_o & (~st_arb_1));

//------------------------------------------------------------------------------
//haddr_o mux
mux4  #(.DW(AHB_AW))  mux4_haddr
    (
    .in0(s_haddr_i[0]), .sel0(grant[0]),
    .in1(s_haddr_i[1]), .sel1(grant[1]),
    .in2(s_haddr_i[2]), .sel2(grant[2]),
    .in3(s_haddr_i[3]), .sel3(grant[3]),
    .out(mux_haddr)
    );

//assign haddr_o = mux_haddr;
assign haddr_o = gen_haddr1;


//------------------------------------------------------------------------------
//hwrite mux
mux4  #(.DW(1))  mux4_hwrite
    (
    .in0(s_hwrite_i[0]), .sel0(grant[0]),
    .in1(s_hwrite_i[1]), .sel1(grant[1]),
    .in2(s_hwrite_i[2]), .sel2(grant[2]),
    .in3(s_hwrite_i[3]), .sel3(grant[3]),
    .out(mux_hwrite)
    );

assign hwrite_o = mux_hwrite;
//------------------------------------------------------------------------------
//htrans mux
mux4  #(.DW(2))  mux4_htrans
    (
    .in0(s_htrans_i[0]), .sel0(grant[0]),
    .in1(s_htrans_i[1]), .sel1(grant[1]),
    .in2(s_htrans_i[2]), .sel2(grant[2]),
    .in3(s_htrans_i[3]), .sel3(grant[3]),
    .out(mux_htrans)
    );

assign htrans_o = mux_htrans;
//------------------------------------------------------------------------------
//hsize mux
mux4  #(.DW(3))  mux4_hsize
    (
    .in0(s_hsize_i[0]), .sel0(grant[0]),
    .in1(s_hsize_i[1]), .sel1(grant[1]),
    .in2(s_hsize_i[2]), .sel2(grant[2]),
    .in3(s_hsize_i[3]), .sel3(grant[3]),
    .out(mux_hsize)
    );

assign hsize_o = mux_hsize;
//------------------------------------------------------------------------------
//hburst mux
assign hburst_o = burst_type;

//------------------------------------------------------------------------------
//hwdata mux
mux4  #(.DW(AHB_DW))  mux4_hwdata
    (
    .in0(s_hwdata_i[0]), .sel0(grant[0]),
    .in1(s_hwdata_i[1]), .sel1(grant[1]),
    .in2(s_hwdata_i[2]), .sel2(grant[2]),
    .in3(s_hwdata_i[3]), .sel3(grant[3]),
    .out(hwdata_o)
    );
//------------------------------------------------------------------------------
//hready mux
mux4  #(.DW(1))  mux4_hready
    (
    .in0(s_hreadyout_i[0]), .sel0(grant[0]),
    .in1(s_hreadyout_i[1]), .sel1(grant[1]),
    .in2(s_hreadyout_i[2]), .sel2(grant[2]),
    .in3(s_hreadyout_i[3]), .sel3(grant[3]),
    .out(slv_hready)
    );

//assign hready_o = slv_hready;//HREADY to slave 


//------------------------------------------------------------------------------
//hmastlock mux
mux4  #(.DW(1))  mux4_hmastlock
    (
    .in0(s_hmastlock_i[0]), .sel0(grant[0]),
    .in1(s_hmastlock_i[1]), .sel1(grant[1]),
    .in2(s_hmastlock_i[2]), .sel2(grant[2]),
    .in3(s_hmastlock_i[3]), .sel3(grant[3]),
    .out(hmastlock_o)
    );
//------------------------------------------------------------------------------
//hprot mux
mux4  #(.DW(4))  mux4_hprot
    (
    .in0(s_hprot_i[0]), .sel0(grant[0]),
    .in1(s_hprot_i[1]), .sel1(grant[1]),
    .in2(s_hprot_i[2]), .sel2(grant[2]),
    .in3(s_hprot_i[3]), .sel3(grant[3]),
    .out(hprot_o)
    );

//------------------------------------------------------------------------------
//Output to master port
assign s_grant_o  = grant;
assign s_hresp_o  = hresp_i;
assign s_hrdata_o = hrdata_i;  
//------------------------------------------------------------------------------
//HSEL
assign hsel_o = st_arb | st_access;

endmodule 


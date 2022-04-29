`timescale 1ns/100ps

module ddr4_test();

  parameter N_WRITE_STREAMS   = 'd144;
  parameter N_READ_STREAMS    = 'd12;
  parameter READ_BURST_LEN    = 'd1280;
  parameter WRITE_STREAM_MAXSIZE  = 'd230400;
  parameter WRITE_BURST_LEN     = 'd64;

  reg clk;
  reg clk_slow;
  reg reset;
  reg en;
 
  //axi write
  /// adress channel
  wire AWREADY;
  wire [31:0] AWADDR;
  wire [3:0]  AWID;
  wire [7:0]  AWLEN;
  wire [2:0]  AWSIZE;
  wire [1:0]  AWBURST;
  wire [1:0]  AWLOCK;
  wire [3:0]  AWCACHE;
  wire [2:0]  AWPROT;
  wire        AWVALID;
 
  /// data channel
  wire WREADY;
  wire [3:0]  WID;
  wire [511:0] WDATA;
  wire [63:0]  WSTRB;
  wire        WLAST;
  wire        WVALID;
 
  /// responce channel
  wire [3:0] BID;
  wire [1:0] BRESP;
  wire       BVALID;
  wire      BREADY;

  wire        ARREADY;
  wire[31:0] ARADDR;
  wire [3:0] ARID;
  wire [7:0] ARLEN;
  wire       ARVALID;
  wire [2:0] ARSIZE;
  wire [1:0] ARBURST;
  wire [1:0] ARLOCK;
  wire [3:0] ARCACHE;
  wire [2:0] ARPROT;
 
  /// data channel
  wire RREADY;
  wire [3:0]  RID;
  wire [511:0] RDATA;
  wire [1:0]  RRESP;
  wire        RLAST;
  wire        RVALID;

  wire [31:0]wr_addr;
  wire [31:0]rd_addr;

  assign AWADDR[31] = 1'b0;
  assign ARADDR[31] = 1'b0;

  initial begin
    en = 1'b0;
    reset = 1'b0;
    repeat(2) @(posedge clk);
    reset = 1'b1;
    repeat(5) @(posedge clk);
    reset = 1'b0;
    repeat(5) @(posedge clk);
    en = 1'b1;

    $display ("\n",$time,  ,"   AXI-DDR4 TEST STARTED   \n");
    repeat(3_000_000) @(posedge clk);
    if(ext_memory_test_blk.mon_streams_blk.error_detect)
      $display ("\n",$time,  ,"   ERROR. TEST FAILED   \n");
    else
      $display ("\n",$time,  ,"   SUCCESS. TEST FINISHED   \n");
    $finish;
  end

  initial begin
    clk <= 1'b0;
    forever #(1.500) clk = ~clk;
  end

  initial begin
    clk_slow <= 1'b0;
    forever #(4.000) clk_slow = ~clk_slow;
  end

ext_memory_test #(
  .N_WRITE_STREAMS(N_WRITE_STREAMS),
  .N_READ_STREAMS(N_READ_STREAMS),
  .READ_BURST_LEN(READ_BURST_LEN),
  .WRITE_STREAM_MAXSIZE(WRITE_STREAM_MAXSIZE),
  .WRITE_BURST_LEN(WRITE_BURST_LEN))
ext_memory_test_blk(
  .aclk_slow(clk),
  .aresetn_slow(~reset),
  .aclk_fast(clk),
  .aresetn_fast(~reset),
  .en(en),
  //axi write
  /// adress channel

  .m_axi_awready(AWREADY),
  .m_axi_awaddr(AWADDR),
  .m_axi_awid(AWID),
  .m_axi_awlen(AWLEN),
  .m_axi_awsize(AWSIZE),
  .m_axi_awburst(AWBURST),
  .m_axi_awlock(AWLOCK),
  .m_axi_awcache(AWCACHE),
  .m_axi_awprot(AWPROT),
  .m_axi_awvalid(AWVALID),
 
  /// data channel
  .m_axi_wready(WREADY),
  .m_axi_wdata(WDATA),
  .m_axi_wstrb(WSTRB),
  .m_axi_wlast(WLAST),
  .m_axi_wvalid(WVALID),
 
  /// responce channel
  .m_axi_bid(BID),
  .m_axi_bresp(BRESP),
  .m_axi_bvalid(BVALID),
  .m_axi_bready(BREADY),

  //axi read 
  /// address channel
  .m_axi_arready(ARREADY),
  .m_axi_araddr(ARADDR),
  .m_axi_arid(ARID),
  .m_axi_arlen(ARLEN),
  .m_axi_arvalid(ARVALID),
  .m_axi_arsize(ARSIZE),
  .m_axi_arburst(ARBURST),
  .m_axi_arlock(ARLOCK),
  .m_axi_arcache(ARCACHE),
  .m_axi_arprot(ARPROT),
 
  /// data channel
  .m_axi_rready(RREADY),
  .m_axi_rid(RID),
  .m_axi_rdata(RDATA),
  .m_axi_rresp(RRESP),
  .m_axi_rlast(RLAST),
  .m_axi_rvalid(RVALID)
  );

axi_target_bfm axi_target_bfm_blk(
  .en(en),
  .clk(clk),
  .reset(reset),
  /*
  .AWREADY(AWREADY),
  .AWADDR(AWADDR),
  .AWID(AWID),
  .AWLEN(AWLEN),
  //.AWSIZE(AWSIZE),
  //.AWBURST(AWBURST),
  //.AWLOCK(AWLOCK),
  //.AWCACHE(AWCACHE),
  //.AWPROT(AWPROT),
  .AWVALID(AWVALID),
 
  /// data channel
  .WREADY(WREADY),
  .WID(4'h0),
  .WDATA(WDATA),
  .WSTRB(WSTRB),
  .WLAST(WLAST),
  .WVALID(WVALID),
 
  /// responce channel
  .BID(BID),
  .BRESP(BRESP),
  .BVALID(BVALID),
  .BREADY(BREADY),
*/
  .ARREADY(ARREADY),
  .ARADDR(ARADDR),
  .ARID(ARID),
  .ARLEN(ARLEN),
  .ARVALID(ARVALID),
  .RREADY(RREADY),
  .RID(RID),
  .RDATA(RDATA),
  .RRESP(RRESP),
  .RLAST(RLAST),
  .RVALID(RVALID)

  );


axi_mem_target axi_mem_target_blk(
  .clk(clk),
  .reset(~reset),
  .AWREADY(AWREADY),
  .AWADDR(AWADDR),
  .AWID(AWID),
  .AWLEN(AWLEN),
  //.AWSIZE(AWSIZE),
  //.AWBURST(AWBURST),
  //.AWLOCK(AWLOCK),
  //.AWCACHE(AWCACHE),
  //.AWPROT(AWPROT),
  .AWVALID(AWVALID),
 
  /// data channel
  .WREADY(WREADY),
  .WID(4'h0),
  .WDATA(WDATA),
  .WSTRB(WSTRB),
  .WLAST(WLAST),
  .WVALID(WVALID),
 
  /// responce channel
  .BID(BID),
  .BRESP(BRESP),
  .BVALID(BVALID),
  .BREADY(BREADY)
/*
  .ARREADY(ARREADY),
  .ARADDR(ARADDR),
  .ARID(ARID),
  .ARLEN(ARLEN),
  .ARVALID(ARVALID),
  .RREADY(RREADY),
  .RID(RID),
  .RDATA(RDATA),
  .RRESP(RRESP),
  .RLAST(RLAST),
  .RVALID(RVALID)
  */
  );

/*
ddr4_0 ddr4_blk (
  .c0_init_calib_complete(c0_init_calib_complete),    // wire c0_init_calib_complete
  .dbg_clk(dbg_clk),                                  // wire dbg_clk
  .c0_sys_clk_p(c0_sys_clk_p),                        // wire c0_sys_clk_p
  .c0_sys_clk_n(c0_sys_clk_n),                        // wire c0_sys_clk_n
  .dbg_bus(dbg_bus),                                  // wire [511 : 0] dbg_bus
  .c0_ddr4_adr(c0_ddr4_adr),                          // wire [16 : 0] c0_ddr4_adr
  .c0_ddr4_ba(c0_ddr4_ba),                            // wire [1 : 0] c0_ddr4_ba
  .c0_ddr4_cke(c0_ddr4_cke),                          // wire [0 : 0] c0_ddr4_cke
  .c0_ddr4_cs_n(c0_ddr4_cs_n),                        // wire [0 : 0] c0_ddr4_cs_n
  .c0_ddr4_dm_dbi_n(c0_ddr4_dm_dbi_n),                // inout wire [0 : 0] c0_ddr4_dm_dbi_n
  .c0_ddr4_dq(c0_ddr4_dq),                            // inout wire [7 : 0] c0_ddr4_dq
  .c0_ddr4_dqs_c(c0_ddr4_dqs_c),                      // inout wire [0 : 0] c0_ddr4_dqs_c
  .c0_ddr4_dqs_t(c0_ddr4_dqs_t),                      // inout wire [0 : 0] c0_ddr4_dqs_t
  .c0_ddr4_odt(c0_ddr4_odt),                          // wire [0 : 0] c0_ddr4_odt
  .c0_ddr4_bg(c0_ddr4_bg),                            // wire [0 : 0] c0_ddr4_bg
  .c0_ddr4_reset_n(c0_ddr4_reset_n),                  // wire c0_ddr4_reset_n
  .c0_ddr4_act_n(c0_ddr4_act_n),                      // wire c0_ddr4_act_n
  .c0_ddr4_ck_c(c0_ddr4_ck_c),                        // wire [0 : 0] c0_ddr4_ck_c
  .c0_ddr4_ck_t(c0_ddr4_ck_t),                        // wire [0 : 0] c0_ddr4_ck_t
  .c0_ddr4_ui_clk(c0_ddr4_ui_clk),                    // wire c0_ddr4_ui_clk
  .c0_ddr4_ui_clk_sync_rst(c0_ddr4_ui_clk_sync_rst),  // wire c0_ddr4_ui_clk_sync_rst
  
  .c0_ddr4_aresetn(aresetn),                  // wire c0_ddr4_aresetn
  .c0_ddr4_s_axi_awid(AWID),            // wire [3 : 0] c0_ddr4_s_axi_awid
  .c0_ddr4_s_axi_awaddr(AWADDR),        // wire [27 : 0] c0_ddr4_s_axi_awaddr
  .c0_ddr4_s_axi_awlen(AWLEN),          // wire [7 : 0] c0_ddr4_s_axi_awlen
  .c0_ddr4_s_axi_awsize(AWSIZE),        // wire [2 : 0] c0_ddr4_s_axi_awsize
  .c0_ddr4_s_axi_awburst(AWBURST),      // wire [1 : 0] c0_ddr4_s_axi_awburst
  .c0_ddr4_s_axi_awlock(AWLOCK),        // wire [0 : 0] c0_ddr4_s_axi_awlock
  .c0_ddr4_s_axi_awcache(AWCACHE),      // wire [3 : 0] c0_ddr4_s_axi_awcache
  .c0_ddr4_s_axi_awprot(AWPROT),        // wire [2 : 0] c0_ddr4_s_axi_awprot
  .c0_ddr4_s_axi_awqos(4'h0),          // wire [3 : 0] c0_ddr4_s_axi_awqos
  .c0_ddr4_s_axi_awvalid(AWVALID),      // wire c0_ddr4_s_axi_awvalid
  .c0_ddr4_s_axi_awready(AWREADY),      // wire c0_ddr4_s_axi_awready
  .c0_ddr4_s_axi_wdata(WDATA),          // wire [63 : 0] c0_ddr4_s_axi_wdata
  .c0_ddr4_s_axi_wstrb(WSTRB),          // wire [7 : 0] c0_ddr4_s_axi_wstrb
  .c0_ddr4_s_axi_wlast(WLAST),          // wire c0_ddr4_s_axi_wlast
  .c0_ddr4_s_axi_wvalid(WVALID),        // wire c0_ddr4_s_axi_wvalid
  .c0_ddr4_s_axi_wready(WREADY),        // wire c0_ddr4_s_axi_wready
  .c0_ddr4_s_axi_bready(BREADY),        // wire c0_ddr4_s_axi_bready
  .c0_ddr4_s_axi_bid(BID),              // wire [3 : 0] c0_ddr4_s_axi_bid
  .c0_ddr4_s_axi_bresp(BRESP),          // wire [1 : 0] c0_ddr4_s_axi_bresp
  .c0_ddr4_s_axi_bvalid(BVALID),        // wire c0_ddr4_s_axi_bvalid
  .c0_ddr4_s_axi_arid(ARID),            // wire [3 : 0] c0_ddr4_s_axi_arid
  .c0_ddr4_s_axi_araddr(ARADDR),        // wire [27 : 0] c0_ddr4_s_axi_araddr
  .c0_ddr4_s_axi_arlen(ARLEN),          // wire [7 : 0] c0_ddr4_s_axi_arlen
  .c0_ddr4_s_axi_arsize(ARSIZE),        // wire [2 : 0] c0_ddr4_s_axi_arsize
  .c0_ddr4_s_axi_arburst(ARBURST),      // wire [1 : 0] c0_ddr4_s_axi_arburst
  .c0_ddr4_s_axi_arlock(ARLOCK),        // wire [0 : 0] c0_ddr4_s_axi_arlock
  .c0_ddr4_s_axi_arcache(ARCACHE),      // wire [3 : 0] c0_ddr4_s_axi_arcache
  .c0_ddr4_s_axi_arprot(ARPROT),        // wire [2 : 0] c0_ddr4_s_axi_arprot
  .c0_ddr4_s_axi_arqos(4'h0),          // wire [3 : 0] c0_ddr4_s_axi_arqos
  .c0_ddr4_s_axi_arvalid(AWVALID),      // wire c0_ddr4_s_axi_arvalid
  .c0_ddr4_s_axi_arready(ARREADY),      // wire c0_ddr4_s_axi_arready
  .c0_ddr4_s_axi_rready(RREADY),        // wire c0_ddr4_s_axi_rready
  .c0_ddr4_s_axi_rlast(RLAST),          // wire c0_ddr4_s_axi_rlast
  .c0_ddr4_s_axi_rvalid(RVALID),        // wire c0_ddr4_s_axi_rvalid
  .c0_ddr4_s_axi_rresp(RRESP),          // wire [1 : 0] c0_ddr4_s_axi_rresp
  .c0_ddr4_s_axi_rid(RID),              // wire [3 : 0] c0_ddr4_s_axi_rid
  .c0_ddr4_s_axi_rdata(RDATA),          // wire [63 : 0] c0_ddr4_s_axi_rdata
  .sys_rst(sys_rst)                                  // wire sys_rst
);
*/

endmodule 

module ext_memory_test(
	input aclk_slow,
	input aresetn_slow,
	input aclk_fast,
	input aresetn_fast,
	input en,
	//axi write
	/// adress channel

	input m_axi_awready,
	output [30:0] m_axi_awaddr,
	output [3:0]  m_axi_awid,
	output [7:0]  m_axi_awlen,
	output [2:0]  m_axi_awsize,
	output [1:0]  m_axi_awburst,
	output [1:0]  m_axi_awlock,
	output [3:0]  m_axi_awcache,
	output [2:0]  m_axi_awprot,
	output        m_axi_awvalid,
 
	/// data channel
	input m_axi_wready,
	output [511:0] m_axi_wdata,
	output [63:0]  m_axi_wstrb,
	output        m_axi_wlast,
	output        m_axi_wvalid,
 
	/// responce channel
	input [3:0] m_axi_bid,
	input [1:0] m_axi_bresp,
	input       m_axi_bvalid,
	output      m_axi_bready,

	//axi read 
	/// address channel
	input        m_axi_arready,
	output[30:0] m_axi_araddr,
	output [3:0] m_axi_arid,
	output [7:0] m_axi_arlen,
	output       m_axi_arvalid,
	output [2:0] m_axi_arsize,
	output [1:0] m_axi_arburst,
	output [1:0] m_axi_arlock,
	output [3:0] m_axi_arcache,
	output [2:0] m_axi_arprot,
 
	/// data channel
	output m_axi_rready,
	input [3:0]  m_axi_rid,
	input [511:0] m_axi_rdata,
	input [1:0]  m_axi_rresp,
	input        m_axi_rlast,
	input        m_axi_rvalid
	);

	parameter N_WRITE_STREAMS		= 'd144;
	parameter N_READ_STREAMS		= 'd12;
	parameter READ_BURST_LEN		= 'd1280;
	parameter WRITE_STREAM_MAXSIZE	= 'd230400;
	parameter WRITE_BURST_LEN 		= 'd64;

	wire [31:0]wr_addr;
	wire [31:0]rd_addr;

	wire wr_en;
	wire rd_en;
	wire wr_finish;
	wire rd_finish;

	wire [7:0]wr_iter_num;
	wire [7:0]wr_stream_num;
	wire [3:0]wr_burst_length;
	wire [7:0]rd_burst_length;

	wire adr_neg;
	wire [2:0]wr_sm;
	wire [2:0]wr_sm_ns;

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

	//axi read 
	/// address channel
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

main_machine #(
	.N_WRITE_STREAMS(N_WRITE_STREAMS),
	.N_READ_STREAMS(N_READ_STREAMS),
	.READ_BURST_LEN(READ_BURST_LEN),
	.WRITE_STREAM_MAXSIZE(WRITE_STREAM_MAXSIZE),
	.WRITE_BURST_LEN(WRITE_BURST_LEN))
main_machine_blk(
	.clk(aclk_slow),
	.reset(~aresetn_slow),
	.en(en),
	.wlast(WLAST),

	.wr_iter_num(wr_iter_num),
	.wr_stream_num(wr_stream_num),
	.wr_burst_length(wr_burst_length),
	.wr_en(wr_en),
	.wr_finish(wr_finish),
	.wr_addr(wr_addr),

	.adr_neg(adr_neg),
	.wr_sm(wr_sm),
	.wr_sm_ns(wr_sm_ns),

	.rd_en(rd_en),
	.rd_finish(rd_finish),
	.rd_burst_length(rd_burst_length),
	.rd_addr(rd_addr)
);
	//axi write
	/// adress channel

	assign AWREADY = m_axi_awready;
	assign m_axi_awaddr = AWADDR;
	assign m_axi_awid = AWID;
	assign m_axi_awlen = AWLEN;
	assign m_axi_awsize = AWSIZE;
	assign m_axi_awburst = AWBURST;
	assign m_axi_awlock = AWLOCK;
	assign m_axi_awcache = AWCACHE;
	assign m_axi_awprot = AWPROT;
	assign m_axi_awvalid = AWVALID;
 
	/// data channel
	assign WREADY = m_axi_wready;
	assign m_axi_wdata = WDATA;
	assign m_axi_wstrb = WSTRB;
	assign m_axi_wlast = WLAST;
	assign m_axi_wvalid = WVALID;
 
	/// responce channel
	assign BID = m_axi_bid;
	assign BRESP = m_axi_bresp;
	assign BVALID = m_axi_bvalid;
	assign m_axi_bready = BREADY;

	//axi read 
	/// address channel
	assign ARREADY = m_axi_arready;
	assign m_axi_araddr = ARADDR;
	assign m_axi_arid = ARID;
	assign m_axi_arlen = ARLEN;
	assign m_axi_arvalid = ARVALID;
	assign m_axi_arsize = ARSIZE;
	assign m_axi_arburst = ARBURST;
	assign m_axi_arlock = ARLOCK;
	assign m_axi_arcache = ARCACHE;
	assign m_axi_arprot = ARPROT;
 
	/// data channel
	assign m_axi_rready = RREADY;
	assign RID = m_axi_rid;
	assign RDATA = m_axi_rdata;
	assign RRESP = m_axi_rresp;
	assign RLAST = m_axi_rlast;
	assign RVALID = m_axi_rvalid;

write_stream_gen write_stream_gen_blk(
	.clk(aclk_slow),
	.reset(~aresetn_slow),
	.en(wr_en),
	.finish(wr_finish),
	.addr(wr_addr),

	.iter_num(wr_iter_num),
	.stream_num(wr_stream_num),
	.burst_length({4'h0, wr_burst_length}),

	.adr_neg(adr_neg),
	.wr_sm(wr_sm),
	.wr_sm_ns(wr_sm_ns),
 
	//axi write
	/// adress channel
	.AWREADY(AWREADY),
	.AWADDR(AWADDR),
	.AWID(AWID),
	.AWLEN(AWLEN),
	.AWSIZE(AWSIZE),
	.AWBURST(AWBURST),
	.AWLOCK(AWLOCK),
	.AWCACHE(AWCACHE),
	.AWPROT(AWPROT),
	.AWVALID(AWVALID),
 
	/// data channel
	.WREADY(WREADY),
	.WID(WID),
	.WDATA(WDATA),
	.WSTRB(WSTRB),
	.WLAST(WLAST),
	.WVALID(WVALID),
 
	/// responce channel
	.BID(BID),
	.BRESP(BRESP),
	.BVALID(BVALID),
	.BREADY(BREADY)
);

read_stream #(
	.READ_BURST_LEN(READ_BURST_LEN))
read_stream_blk(
	.clk(aclk_slow),
	.reset(~aresetn_slow),
	.en(rd_en),
	.finish(rd_finish),
	.addr(rd_addr),
	.burst_length(rd_burst_length),

	//axi read 
	/// address channel
	.ARREADY(ARREADY),
	.ARADDR(ARADDR),
	.ARID(ARID),
	.ARLEN(ARLEN),
	.ARVALID(ARVALID),
	.ARSIZE(ARSIZE),
	.ARBURST(ARBURST),
	.ARLOCK(ARLOCK),
	.ARCACHE(ARCACHE),
	.ARPROT(ARPROT),
 
	/// data channel
	.RREADY(RREADY),
	.RID(RID),
	.RDATA(RDATA),
	.RRESP(RRESP),
	.RLAST(RLAST),
	.RVALID(RVALID)
);

  mon_streams mon_streams_blk(
    .clk(aclk_slow),
    .reset(~aresetn_slow),

    .ARADDR(ARADDR),
    .ARID(ARID),
    .ARREADY(ARREADY),
    .ARVALID(ARVALID),
  
    .RID(RID),
    .RDATA(RDATA),
    .RREADY(RREADY),
    .RLAST(RLAST),
    .RVALID(RVALID),
    .RRESP(RRESP),
    .BRESP(BRESP),

    .error_detect()
  );

  speed_tester speed_tester_blk(
    .clk(aclk_slow),
    .reset(~aresetn_slow),

    .WREADY(WREADY),
    .WVALID(WVALID),

    .RREADY(RREADY),
    .RVALID(RVALID)
  );

endmodule

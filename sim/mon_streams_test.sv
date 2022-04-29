`timescale 1ns/100ps

module mon_streams_test();

  parameter WRITE_STREAM_MAXSIZE	= 'd230400;
  parameter STREAM_ADDR_OFFSET = $clog2(WRITE_STREAM_MAXSIZE);
	parameter STREAM_ADDR_SHIFT = 2;
  parameter READ_BURST_LEN = 'd1280;

  reg clk;
  reg reset;

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

  wire       ARREADY;
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
  wire error_detect;

  reg en;
  wire rd_finish;
  reg [31:0]rd_addr;
  reg [7:0]rd_burst_length;
  reg [7:0]stream_num;
  int i;

  initial begin
    en = 1'b0;
    reset = 1'b0;
    repeat(2) @(posedge clk);
    reset = 1'b1;
    repeat(5) @(posedge clk);
    reset = 1'b0;
    repeat(5) @(posedge clk);
    en = 1'b1;
    rd_addr = 32'h0;
    stream_num = 8'h0;
    rd_burst_length = 8'h14;

    $display ("\n",$time,  ,"   AXI MON STREAMS TEST STARTED   \n");

    for(i = 0; i < 10000; )
    begin
      
      //if(ARREADY && ARVALID && (rd_addr < 32'h0003_8400))
      if(ARREADY && ARVALID && (rd_addr[17:0] == 18'h38000))
      begin
        if(stream_num < 11)
          stream_num = stream_num + 8'h01;
        else
          stream_num = 8'h0;
        i = i + 1;
        rd_addr = stream_num << (STREAM_ADDR_SHIFT + STREAM_ADDR_OFFSET);
      end
      else if(ARREADY && ARVALID)
      begin
        rd_addr = rd_addr + rd_burst_length * 64;
        i = i + 1;
      end
      else
        wait(ARREADY && ARVALID);

      if(rd_addr[17:0] == 18'h38000)
        rd_burst_length = 8'h10;
      else if((i + 1) % 4 == 0)
        rd_burst_length = 8'h04;
      else
        rd_burst_length = 8'h14;
      repeat(1) @(posedge clk);
    end

    if(error_detect)
      $display ("\n",$time,  ,"   ERROR. AXI MON STREAMS TEST FINISHED   \n");
    else
      $display ("\n",$time,  ,"   SUCCESS. AXI MON STREAMS TEST FINISHED   \n");
    repeat(300) @(posedge clk);
    $finish;
  end

  initial begin
    clk <= 1'b0;
    forever #(1.500) clk = ~clk;
  end

read_stream #(
	.READ_BURST_LEN(READ_BURST_LEN))
read_stream_blk(
	.clk(clk),
	.reset(reset),
	.en(en),
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

axi_target_bfm axi_target_bfm_blk(
  .en(en),
  .clk(clk),
  .reset(reset),
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

  mon_streams mon_streams_blk(
    .clk(clk),
    .reset(reset),

    .ARADDR(ARADDR),
    .ARREADY(ARREADY),
    .ARVALID(ARVALID),
    .ARID(ARID),
  
    .RDATA(RDATA),
    .RREADY(RREADY),
    .RLAST(RLAST),
    .RVALID(RVALID),
    .RRESP(RRESP),
    .RID(RID),

    .error_detect(error_detect)
  );




endmodule 

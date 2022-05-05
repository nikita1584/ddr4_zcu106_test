module write_stream_gen(
	input clk,
	input reset,
	input en,
	output finish,
	output adr_neg,
	output [2:0]wr_sm,
	output [2:0]wr_sm_ns,
	input [31:0]addr,

	input [7:0]iter_num,
	input [7:0]stream_num,
	input [7:0]burst_length,

	//axi write
	/// adress channel
	input AWREADY,
	output [31:0] AWADDR,
	output [3:0]  AWID,
	output [7:0]  AWLEN,
	output [2:0]  AWSIZE,
	output [1:0]  AWBURST,
	output [1:0]  AWLOCK,
	output [3:0]  AWCACHE,
	output [2:0]  AWPROT,
	output        AWVALID,
 
	/// data channel
	input WREADY,
	output [3:0]  WID,
	output [511:0] WDATA,
	output [63:0]  WSTRB,
	output        WLAST,
	output        WVALID,
 
	/// responce channel
	input [3:0] BID,
	input [1:0] BRESP,
	input       BVALID,
	output      BREADY
	);

	localparam [3:0]
		S_IDLE = 8'h01,
		S_ADDR = 8'h02,
		S_DATA = 8'h03,
		S_CONF = 8'h04;

	(* mark_debug = "true" *)reg [2:0]wr_sm;
	(* mark_debug = "true" *)reg [2:0]wr_sm_ns;
	(* mark_debug = "true" *)reg [7:0]data_cnt;
	(* mark_debug = "true" *)reg [15:0]counter;
	(* mark_debug = "true" *)reg [3:0]wid_r;
	(* mark_debug = "true" *)reg [3:0]awid_r;
	(* mark_debug = "true" *)reg [7:0]bvalid_timout_cnt;
	(* mark_debug = "true" *)reg bvalid_timout;
	reg [7:0]burst_length_reg;

	always @(posedge clk)
	begin
		if(reset || (BREADY & BVALID))
			bvalid_timout <= 1'b0;
		else if(bvalid_timout > 8'h20)
			bvalid_timout <= 1'b1;
	end

	always @(posedge clk)
	begin
		if(reset || (BREADY & BVALID))
			bvalid_timout_cnt <= 1'b0;
		else if(BREADY & ~BVALID)
			bvalid_timout_cnt <= bvalid_timout_cnt + 8'h01;
	end

	always @(posedge clk)
	begin
		if(reset)
			burst_length_reg <= 8'h0;
		else if(AWVALID && AWREADY) 
			burst_length_reg <= burst_length;
	end

	assign AWLOCK = 2'b00;
	assign AWBURST = 2'b01;
	assign AWCACHE = 4'b0000;
	assign AWLEN = burst_length - 8'h01;//transfer count from 1 to 256
	assign AWSIZE = 5'b00110; //bytes in one burst, 110 == 64 bytes
	assign AWPROT = 3'b000;
	assign BREADY = (wr_sm == S_CONF);
	assign AWADDR = addr;
	assign WID = wid_r;
	assign AWID = awid_r;
	assign AWVALID = (wr_sm == S_ADDR);
	assign WVALID = wr_sm == S_DATA;
	assign WSTRB = 64'hFFFF_FFFF_FFFF_FFFF;
	assign WLAST = WREADY && WVALID && (wr_sm == S_DATA) & (data_cnt == (burst_length_reg - 8'h01));
	assign WDATA = {stream_num, iter_num, counter+16'h0F, stream_num, iter_num, counter+16'h0E,
					stream_num, iter_num, counter+16'h0D, stream_num, iter_num, counter+16'h0C,
					stream_num, iter_num, counter+16'h0B, stream_num, iter_num, counter+16'h0A,
					stream_num, iter_num, counter+16'h09, stream_num, iter_num, counter+16'h08,
					stream_num, iter_num, counter+16'h07, stream_num, iter_num, counter+16'h06,
					stream_num, iter_num, counter+16'h05, stream_num, iter_num, counter+16'h04,
					stream_num, iter_num, counter+16'h03, stream_num, iter_num, counter+16'h02,
					stream_num, iter_num, counter+16'h01, stream_num, iter_num, counter+16'h00};

	assign finish = (wr_sm == S_CONF) && BREADY && BVALID;
	assign adr_neg = AWVALID && AWREADY;

	always @(posedge clk)
	begin
		if(reset)
			awid_r <= 4'h0;
		else if(BREADY && BVALID)
			awid_r <= awid_r + 4'h1;
	end

	always @(posedge clk)
	begin
		if(reset)
			wid_r <= 4'h0;
		else if(wr_sm == S_ADDR && wr_sm_ns == BVALID)
			wid_r <= awid_r;
	end

	always @(posedge clk)
	if(reset)
		wr_sm <= S_IDLE;
	else
		wr_sm <= wr_sm_ns;

	always @(*)
	begin
		wr_sm_ns = wr_sm;
		case (wr_sm)
			S_IDLE:
				if(en)
					wr_sm_ns = S_ADDR;
			S_ADDR:
				if(AWREADY && AWVALID)
					wr_sm_ns = S_DATA;
			S_DATA:
				if(WLAST && WREADY && WVALID)
					wr_sm_ns = S_CONF;
			S_CONF:
				if(BREADY && BVALID && en)
					wr_sm_ns = S_ADDR;
				else if(BREADY & BVALID & ~en)
					wr_sm_ns = S_IDLE;
		endcase
	end

	always @(posedge clk)
	begin
		if(wr_sm == S_IDLE | wr_sm == S_CONF)
			data_cnt <= 'd0;
		else if((wr_sm == S_DATA) && WREADY && WVALID)
			data_cnt <= data_cnt + 'd1;
	end

	always @(posedge clk)
	begin
		if(reset || ~en)
			counter <= 'd0;
		else if((wr_sm == S_DATA) && WREADY && WVALID)
			counter <= counter + 'h10;
	end

endmodule 

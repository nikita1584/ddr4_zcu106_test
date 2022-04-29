module axi_target_bfm(

// global
	input clk,
	input reset,
	input en,

//axi write channel

	/// address channel
	output AWREADY,

	input [31:0] AWADDR,
	input [3:0]  AWID,
	input [7:0]  AWLEN,
	input		AWVALID,

	/// data channel
	output	   WREADY,

	input [3:0]  WID,
	input [511:0] WDATA,
	input [64:0]  WSTRB,
	input		WLAST,
	input		WVALID,

	/// responce channel
	output [3:0] BID,
	output [1:0] BRESP,
	output	   BVALID,

	input		BREADY,

	//axi read channel
	/// address channel
	output	   ARREADY,

	input [31:0] ARADDR,
	input [3:0]  ARID,
	input [7:0]  ARLEN,
	input		ARVALID,

	/// data channel
	input RREADY,

	output [3:0]  RID,
	output [511:0] RDATA,
	output [1:0]  RRESP,
	output		RLAST,
	output		RVALID
);

	localparam [3:0]
		S_IDLE 		= 8'h01,
		S_ADDR		= 8'h02,
		S_WAIT_DATA = 8'h03,
		S_SEND_DATA = 8'h04;

	reg rand_bit;
	reg rand_bit_data;
	reg [3:0]rd_sm_adr;
	reg [3:0]rd_sm_adr_ns;

	reg [3:0]rd_sm_data;
	reg [3:0]rd_sm_data_ns;

	reg [3:0]count_adr;
	reg [3:0]count_data;
	reg [7:0]adr_delay;
	reg [3:0]adr_delay_cnt;
	reg [3:0]rid;
	reg [511:0]rdata;
	reg [7:0]stream_num;
	reg [7:0]iter_num;
	reg [15:0]stream_cnt;
	reg [7:0]start_data;
	reg [7:0]rlast_counter[0:15];
	reg [15:0]rdata_cnt;
	wire new_stream;
	integer i;

	assign new_stream = RREADY && RVALID && RLAST && (stream_cnt == 16'hE0F0);

	assign ARREADY = (rd_sm_adr == S_ADDR) && (count_data < 'd14) && (adr_delay == 0) && rand_bit;

	assign RVALID = (rd_sm_data == S_SEND_DATA) && rand_bit_data && (count_data > 0);
	assign RLAST = RVALID && (rlast_counter[RID] == 4'h0);
	assign RRESP = 2'b00;
	assign RID = rid;

	assign RDATA = {stream_num, iter_num, stream_cnt+16'h0F, stream_num, iter_num, stream_cnt+16'h0E,
					stream_num, iter_num, stream_cnt+16'h0D, stream_num, iter_num, stream_cnt+16'h0C,
					stream_num, iter_num, stream_cnt+16'h0B, stream_num, iter_num, stream_cnt+16'h0A,
					stream_num, iter_num, stream_cnt+16'h09, stream_num, iter_num, stream_cnt+16'h08,
					stream_num, iter_num, stream_cnt+16'h07, stream_num, iter_num, stream_cnt+16'h06,
					stream_num, iter_num, stream_cnt+16'h05, stream_num, iter_num, stream_cnt+16'h04,
					stream_num, iter_num, stream_cnt+16'h03, stream_num, iter_num, stream_cnt+16'h02,
					stream_num, iter_num, stream_cnt+16'h01, stream_num, iter_num, stream_cnt+16'h00};

	always @(posedge clk)
	begin
		if(reset)
			rdata_cnt <= 0;
		else if(RREADY && RVALID)
			rdata_cnt <= rdata_cnt + 1;
	end

	always @(posedge clk)
		rand_bit = $random;

	always @(posedge clk)
		rand_bit_data <= ($random % 10) == 0;

	always @(posedge clk)
	begin
		if(reset)
			for(i = 0; i < 16; i = i + 1)
				rlast_counter[i] <= 4'h0;
		else if(ARREADY && ARVALID)
			rlast_counter[ARID] <= ARLEN;

		if(RREADY && RVALID && (rlast_counter[RID] != 0))
			rlast_counter[RID] <= rlast_counter[RID] - 1;
	end
/*
	always @(posedge clk)
	begin
		if(reset)
			count_adr <= 4'h0;
		else if(ARREADY && ARVALID)
			count_adr <= count_adr + 4'h1;
		else if(RREADY && RVALID && RLAST)
			//
		else if((rd_sm_adr == S_IDLE) && (rd_sm_adr_ns == S_ADDR))
			count_adr <= $random;
	end
*/
	always @(posedge clk)
	begin
		if(reset)
			count_data <= 4'h0;
		else if(ARREADY && ARVALID && RLAST)
			count_data <= count_data;
		else if(ARREADY && ARVALID)
			count_data <= count_data + 4'h1;
		else if(RLAST)
			count_data <= count_data - 4'h1;
	end

	always @(posedge clk)
	begin
		if(reset)
			start_data <= 8'h0;
		else if(rd_sm_adr == S_WAIT_DATA && start_data != 8'h4)
			start_data <= start_data + 8'h01;
	end

	always @(posedge clk)
	begin
		if(reset || new_stream)
			stream_cnt <= 16'h0;
		else if(RREADY && RVALID)
			stream_cnt <= stream_cnt + 16'h10;
	end

	always @(posedge clk)
	begin
		if(reset)
			iter_num <= 8'h0;
	end

	always @(posedge clk)
	begin
		if(reset || (new_stream && (stream_num  == 'd11)))
			stream_num <= 8'h0;
		else if(new_stream)
			stream_num <= stream_num + 8'h01;
	end

	always @(posedge clk)
	begin
		if(reset)
			adr_delay <= 4'h0;
		else if(ARREADY && ARVALID)
			adr_delay <= $random % 100;
		else
			adr_delay <= adr_delay - 8'h01;
	end

	always @(posedge clk)
	begin
		if(reset)
			rid <= 4'h0;
		else if(RVALID && RREADY && RLAST)
			rid <= rid + 4'h1;
	end

	always @(posedge clk)
	begin
		if(reset)
			adr_delay_cnt <= 4'b0;
		else if(ARREADY && ARVALID)
			adr_delay_cnt <= adr_delay_cnt - 4'h1;
	end

	always @(posedge clk)
	if(reset)
		rd_sm_adr <= S_IDLE;
	else
		rd_sm_adr <= rd_sm_adr_ns;

	always @(*)
	begin
		rd_sm_adr_ns = rd_sm_adr;
		case (rd_sm_adr)
			S_IDLE:
				if(en)
					rd_sm_adr_ns = S_ADDR;
			S_ADDR:
				if(ARREADY && ARVALID && (count_data > 4))
					rd_sm_adr_ns = S_WAIT_DATA;
			S_WAIT_DATA:
				if(count_data < 3)
					rd_sm_adr_ns = S_IDLE;
		endcase
	end

	always @(posedge clk)
	if(reset)
		rd_sm_data <= S_IDLE;
	else
		rd_sm_data <= rd_sm_data_ns;

	always @(*)
	begin
		rd_sm_data_ns = rd_sm_data;
		case (rd_sm_data)
			S_IDLE:
				rd_sm_data_ns <= S_ADDR;
			S_ADDR:
				if((start_data == 8'h4) && (count_data > 0))
					rd_sm_data_ns <= S_SEND_DATA;
			S_SEND_DATA:
				if(count_data == 0)
					rd_sm_data_ns <= S_ADDR;
		endcase
	end

endmodule

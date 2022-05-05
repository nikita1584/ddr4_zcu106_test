module mon_streams(
	input clk,
	input reset,

	input[31:0] ARADDR,
	input [3:0]	ARID,
	input		ARREADY,
	input		ARVALID,
	
	input [3:0]	RID,
	input[511:0]RDATA,	
	input		RREADY,
	input       RLAST,
	input       RVALID,
	input [1:0] RRESP,
	input [1:0] BRESP,

	output		error_detect
);

	parameter WRITE_STREAM_MAXSIZE	= 'd230400;
	parameter STREAM_ADDR_OFFSET = $clog2(WRITE_STREAM_MAXSIZE);
	parameter STREAM_ADDR_SHIFT = 2;

	(* mark_debug = "true" *)reg [31:0]addr[0:15];
	reg [3:0]arid;
	reg [3:0]rid;
	reg finish_addr;
	reg [3:0]finish_arid;
	integer i;

	//(* mark_debug = "true" *)reg [15:0]stream_cnt[0:15];
	(* mark_debug = "true" *)reg [15:0]stream_cnt;
	(* mark_debug = "true" *)reg error_detect;
	(* mark_debug = "true" *)wire data_equal;
	(* mark_debug = "true" *)wire new_stream_num;
	(* mark_debug = "true" *)wire [7:0]stream_num;
	(* mark_debug = "true" *)wire [511:0]data_ok;
	(* mark_debug = "true" *)wire [7:0]iter_num;

	assign stream_num = addr[RID][STREAM_ADDR_SHIFT + STREAM_ADDR_OFFSET + 7:
		STREAM_ADDR_SHIFT + STREAM_ADDR_OFFSET];

	assign new_stream_num = (stream_cnt == 16'hE0F0) && RREADY && RVALID && RLAST;
	assign iter_num = RDATA[55:48];

	assign data_ok = {stream_num, iter_num, stream_cnt+16'h0F, stream_num, iter_num, stream_cnt+16'h0E,
					stream_num, iter_num, stream_cnt+16'h0D, stream_num, iter_num, stream_cnt+16'h0C,
					stream_num, iter_num, stream_cnt+16'h0B, stream_num, iter_num, stream_cnt+16'h0A,
					stream_num, iter_num, stream_cnt+16'h09, stream_num, iter_num, stream_cnt+16'h08,
					stream_num, iter_num, stream_cnt+16'h07, stream_num, iter_num, stream_cnt+16'h06,
					stream_num, iter_num, stream_cnt+16'h05, stream_num, iter_num, stream_cnt+16'h04,
					stream_num, iter_num, stream_cnt+16'h03, stream_num, iter_num, stream_cnt+16'h02,
					stream_num, iter_num, stream_cnt+16'h01, stream_num, iter_num, stream_cnt+16'h00};

	assign data_equal = RDATA == data_ok;

	always @(posedge clk)
	begin
		if(reset)
			arid <= 4'h0;
		else if(ARREADY && ARVALID)
			arid <= ARID;
	end

	always @(posedge clk)
	begin
		if(reset)
		begin
			finish_addr <= 1'b0;
			finish_arid <= 4'h0;
		end
		else if(ARADDR[17:0] == 18'h37F00 && ARREADY && ARVALID)
		begin
			finish_arid <= ARID;
			finish_addr <= 1'b1;
		end
		else if(ARADDR[17:0] == 18'h00000 && ARREADY && ARVALID)
			finish_addr <= 1'b0;
	end

	always @(posedge clk)
	begin
		if(reset)
		begin
			for(i = 0; i < 16; i = i + 1)
				addr[i] <= 32'h0;
		end
		else if(ARREADY && ARVALID)
			addr[ARID] <= ARADDR;
	end

	always @(posedge clk)
	begin
		if(reset)
			rid <= 4'h0;
		else if(RVALID && RREADY)
			rid <= RID;
	end

	always @(posedge clk)
	begin
		if(reset)
			stream_cnt <= 16'h0;
		else if(new_stream_num)// && ARREADY && ARVALID)
			stream_cnt <= 16'h0;
		else if(RREADY && RVALID)
			stream_cnt <= stream_cnt + 16'h0010;
	end

	always @(posedge clk)
	begin
		if(reset)
			error_detect <= 1'b0;
		else if((RDATA != data_ok && RREADY && RVALID) || (RRESP != 2'b00) || (BRESP != 2'b00))
			error_detect <= 1'b1;
	end

endmodule

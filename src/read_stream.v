module read_stream(
	input clk,
	input reset,
	input en,
	output finish,
	input [31:0]addr,
	input [7:0]burst_length,

	//axi read 
	/// address channel
	input        ARREADY,
	output[31:0] ARADDR,
	output [3:0] ARID,
	output [7:0] ARLEN,
	output       ARVALID,
	output [2:0] ARSIZE,
	output [1:0] ARBURST,
	output [1:0] ARLOCK,
	output [3:0] ARCACHE,
	output [2:0] ARPROT,
 
	/// data channel
	output RREADY,
	input [3:0]  RID,
	input [511:0] RDATA,
	input [1:0]  RRESP,
	input        RLAST,
	input        RVALID
);

	parameter READ_BURST_LEN = 'd1280;

	localparam [3:0]
		S_IDLE = 8'h01,
		S_ADDR = 8'h02,
		S_DATA = 8'h03,
		S_CONF = 8'h04;

	(* mark_debug = "true" *)reg [3:0]rd_sm;
	(* mark_debug = "true" *)reg [3:0]rd_sm_ns;
	reg [3:0]arid_r;

	//assign finish = (rd_sm == S_DATA) && RLAST && RVALID && RREADY;
	assign finish = ARVALID && ARREADY; //(rd_sm == S_ADDR) && 

	assign ARLOCK = 2'b00;
	assign ARBURST = 2'b01;
	assign ARCACHE = 4'b0000;
	assign ARSIZE = 5'b00110;
	assign ARPROT = 3'b000;
	assign ARADDR = addr;
	assign ARLEN = burst_length - 8'h01;
	assign ARID = arid_r;
	assign ARVALID = en;//rd_sm == S_ADDR;
	assign RREADY = rd_sm != S_IDLE;//rd_sm == S_DATA;

	always @(posedge clk)
	begin
		if(reset)
			arid_r <= 4'h0;
		else if(ARREADY && ARVALID)
			arid_r <= arid_r + 4'h1;
	end

	always @(posedge clk)
	if(reset)
		rd_sm <= S_IDLE;
	else
		rd_sm <= rd_sm_ns;

	always @(*)
	begin
		rd_sm_ns = rd_sm;
		case (rd_sm)
			S_IDLE:
				if(en)
					rd_sm_ns = S_ADDR;
			S_ADDR:
				if(ARREADY && ARVALID)
					rd_sm_ns = S_DATA;
			S_DATA:
				if(RREADY && RVALID && RLAST && en)
					rd_sm_ns = S_ADDR;
				else if(RREADY & RVALID & RLAST & ~en)
					rd_sm_ns = S_IDLE;
		endcase
	end

endmodule

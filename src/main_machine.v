module main_machine(
	input clk,
	input reset,
	input en,
	input wlast,

	output [7:0]wr_iter_num,
	output [7:0]wr_stream_num,
	output [3:0]wr_burst_length,
	output [31:0]wr_addr,
	input wr_finish,
	output wr_en,

	input adr_neg,
	input [2:0]wr_sm,
	input [2:0]wr_sm_ns,

	output [31:0]rd_addr,
	output [7:0]rd_burst_length,
	input rd_finish,
	output rd_en
);

	parameter N_WRITE_STREAMS		= 'd144;
	parameter N_READ_STREAMS		= 'd12;
	parameter READ_BURST_LEN		= 'd1280;
	parameter WRITE_STREAM_MAXSIZE	= 'd230400;
	parameter WRITE_BURST_LEN 		= 'd64;

	parameter STREAM_ADDR_OFFSET = $clog2(WRITE_STREAM_MAXSIZE);
	parameter STREAM_ADDR_SHIFT = 2;

	localparam [3:0]
		S_IDLE_WR	= 8'h01,
		S_DIR_WR	= 8'h02,
		S_INC_STR_WR= 8'h03,
		S_RAND_WR	= 8'h04;

	localparam [3:0]
		S_IDLE_RD	= 8'h01,
		S_DIR_RD	= 8'h02,
		S_INC_STR_RD= 8'h03;

	(* mark_debug = "true" *)reg [7:0]wr_iter_num;
	(* mark_debug = "true" *)reg [7:0]wr_iter_num_d;
	(* mark_debug = "true" *)reg [7:0]wr_stream_num;
	(* mark_debug = "true" *)reg [7:0]wr_stream_num_d;
	(* mark_debug = "true" *)reg [3:0]wr_burst_length;
	(* mark_debug = "true" *)reg [11:0]wr_64b_counter;
	(* mark_debug = "true" *)wire [11:0]wr_boundary_4k;
	//(* mark_debug = "true" *)wire [15:0]wr_boundary_4k;
	(* mark_debug = "true" *)wire [15:0]stream_size;
	(* mark_debug = "true" *)reg dir_wr_end;
	(* mark_debug = "true" *)wire [31:0]random;
	//reg [31:0]wr_addr;
	//230400 == 28800*8
	//'d28800 == 'h7080 dwords

	(* mark_debug = "true" *)reg [3:0]main_wr_sm_ns;
	(* mark_debug = "true" *)reg [3:0]main_wr_sm;
	(* mark_debug = "true" *)reg [3:0]main_rd_sm_ns;
	(* mark_debug = "true" *)reg [3:0]main_rd_sm;

	(* mark_debug = "true" *)reg rd_en;
	(* mark_debug = "true" *)wire steam_rd_end;
	(* mark_debug = "true" *)reg [7:0]rd_stream_num;
	(* mark_debug = "true" *)reg [7:0]rd_stream_num_d;
	
	(* mark_debug = "true" *)reg [15:0]rd_64b_counter;
	(* mark_debug = "true" *)wire [15:0]rd_boundary_4k;
	(* mark_debug = "true" *)reg [7:0]rd_burst_length;

	//reg [15:0]wr_boundary_4k_reg;
	//reg [15:0]wr_burst_length_4k_reg;
	//reg adr_neg_d;

	assign wr_en = (main_wr_sm != S_IDLE_WR) && (main_wr_sm != S_INC_STR_WR)
		&& (main_wr_sm_ns != S_INC_STR_WR)
	`ifdef SIM
		&& (wr_iter_num < 1)
	`endif
		;

	//always @(posedge clk)
	//	wr_boundary_4k_reg <= 16'h040 * ((wr_64b_counter) / 16'h040 + 16'h0001);

	//always @(posedge clk)
	//	wr_burst_length_4k_reg <= wr_boundary_4k % wr_64b_counter;

	//always @(posedge clk)
	//	adr_neg_d <= adr_neg;

	assign steam_wr_end = wr_64b_counter == stream_size;
	assign stream_size = WRITE_STREAM_MAXSIZE / 64; // size in 64 bytes (512/8)
	assign wr_boundary_4k = 16'h040 * ((wr_64b_counter) / 16'h040 + 16'h0001);

	assign wr_addr = ((wr_64b_counter * 8) << 3) | (wr_stream_num << (STREAM_ADDR_SHIFT + STREAM_ADDR_OFFSET));
	//-----------------------------------------------------------
	always @(posedge clk)
	begin
		if(reset)
			wr_stream_num <= 8'h0;
		else if((main_wr_sm == S_INC_STR_WR) && (wr_iter_num == 8'h0))
			wr_stream_num <= wr_stream_num + 8'h01;
		else if((main_wr_sm == S_INC_STR_WR) && (wr_iter_num != wr_iter_num_d))
			wr_stream_num <= random[6:0] + random[3:0] + 1;
		wr_stream_num_d <= wr_stream_num;
	end
	//-----------------------------------------------------------
	always @(posedge clk)
	begin
		if(reset)
			dir_wr_end <= 1'b0;
		else if((main_wr_sm == S_INC_STR_WR) && (main_wr_sm_ns == S_RAND_WR))
			dir_wr_end <= 1'b1;
	end
	//-----------------------------------------------------------
	// count of burst transmissions
	always @(posedge clk)
	begin
		//ok!
		if(reset)
			wr_burst_length <= 8'h01;
		else if(wr_finish && ((wr_boundary_4k - wr_64b_counter) <= (WRITE_BURST_LEN / 8)) && (wr_64b_counter > 0))
			//wr_burst_length <= wr_boundary_4k % wr_64b_counter;
			wr_burst_length <= wr_boundary_4k - wr_64b_counter;
		else if(wr_finish && ((stream_size - wr_64b_counter) <= (WRITE_BURST_LEN / 8)) && (wr_64b_counter != stream_size))
			wr_burst_length <= stream_size - wr_64b_counter;
		else if(wr_finish)// | ((main_wr_sm == S_IDLE_WR) && (main_wr_sm_ns == S_DIR_WR)))
			wr_burst_length <= random[2:0] + 'd1;//1 - 8
			//wr_burst_length <= (random[2:0] + 'd1)*(WRITE_BURST_LEN / 8);//8 - 64
		/*
		if(reset)
			wr_burst_length <= 8'h0;
		else if(adr_neg_d && ((wr_boundary_4k_reg - wr_64b_counter) <= (WRITE_BURST_LEN / 8)) && (wr_64b_counter > 0))
			wr_burst_length <= wr_burst_length_4k_reg;
		else if(adr_neg_d && ((stream_size - wr_64b_counter) <= (WRITE_BURST_LEN / 8)) && (wr_64b_counter != stream_size))
			wr_burst_length <= stream_size - wr_64b_counter;
		else if(adr_neg_d | ((main_wr_sm == S_IDLE_WR) && (main_wr_sm_ns == S_DIR_WR)))
			wr_burst_length <= random[2:0] + 'd1;//1 - 8
			//wr_burst_length <= (random[2:0] + 'd1)*(WRITE_BURST_LEN / 8);//8 - 64
		*/
	end
	//-----------------------------------------------------------
	always @(posedge clk)
	begin
		if(reset)
			wr_64b_counter <= 12'h00;
		//else if(main_wr_sm_ns == S_INC_STR_WR)//(stream_num != stream_num_d)
		else if((main_wr_sm == S_INC_STR_WR) || steam_wr_end)//(stream_num != stream_num_d)
			wr_64b_counter <= 12'h00;
		else if(wlast)//
			wr_64b_counter <= wr_64b_counter + wr_burst_length;
	end
	//-----------------------------------------------------------
	/*
	always @(posedge clk)
	begin
		if(reset || (wr_stream_num != wr_stream_num_d))
			wr_addr <= 32'h0;
		else if(wr_finish)
			wr_addr <= (wr_addr + wr_burst_length) |
				(wr_stream_num << (STREAM_ADDR_SHIFT + STREAM_ADDR_OFFSET));
	end
	*/
	//-----------------------------------------------------------
	always @(posedge clk)
	begin
		if(reset)
			wr_iter_num <= 8'h00;
		else if((main_wr_sm == S_INC_STR_WR) && (wr_stream_num == N_WRITE_STREAMS - 1))
			wr_iter_num <= wr_iter_num + 8'h01;
		wr_iter_num_d <= wr_iter_num;
	end
	//-----------------------------------------------------------
	always @(posedge clk)
	if(reset)
		main_wr_sm <= S_IDLE_WR;
	else
		main_wr_sm <= main_wr_sm_ns;

	always @(*)
	begin
		main_wr_sm_ns = main_wr_sm;
		case (main_wr_sm)
			S_IDLE_WR:
				if(en)
					main_wr_sm_ns = S_DIR_WR;
			S_DIR_WR:
				if(steam_wr_end)
					main_wr_sm_ns = S_INC_STR_WR;
			S_INC_STR_WR:
			//	if(stream_num == 16'd143)
			//		main_wr_sm_ns = S_RAND_WR;
			//	else
					main_wr_sm_ns = S_DIR_WR;
			//S_RAND_WR:
			//	main_wr_sm_ns = S_RAND_WR;
		endcase
	end

	//----------------------READ---------------------------------
	assign steam_rd_end = (rd_64b_counter == (stream_size - (READ_BURST_LEN / 64))) && rd_finish;
	assign rd_addr = ((rd_64b_counter * 8) << 3) | (rd_stream_num << (STREAM_ADDR_SHIFT + STREAM_ADDR_OFFSET));
	assign rd_boundary_4k = 16'h040 * ((rd_64b_counter + rd_burst_length) / 16'h040 + 16'h0001);
	//-----------------------------------------------------------
	
	always @(posedge clk)
	begin
		if(reset || (rd_stream_num != rd_stream_num_d) || (rd_boundary_4k - rd_64b_counter == 'h040))
			rd_burst_length <= READ_BURST_LEN / 64;
		else if(rd_finish && ((rd_boundary_4k - rd_64b_counter - READ_BURST_LEN / 64) <= (READ_BURST_LEN / 64)) && (rd_64b_counter > 0))
			rd_burst_length <= rd_boundary_4k - rd_64b_counter - READ_BURST_LEN / 64;
	end
	
	//-----------------------------------------------------------
	always @(posedge clk)
	begin
		if(reset)// || (wr_iter_num != wr_iter_num_d))
			rd_stream_num <= 8'h0;
		else if(steam_rd_end && (rd_stream_num < N_READ_STREAMS - 1))
			rd_stream_num <= rd_stream_num + 8'h01;
		else if(steam_rd_end && (rd_stream_num >= N_READ_STREAMS - 1))
			rd_stream_num <= 8'h0;
		rd_stream_num_d <= rd_stream_num;
	end
	//-----------------------------------------------------------
	always @(posedge clk)
	begin
		if(reset)
			rd_64b_counter <= 12'h00;
		else if((main_rd_sm == S_INC_STR_RD) || steam_rd_end)
			rd_64b_counter <= 12'h00;
		else if(rd_finish)
			rd_64b_counter <= rd_64b_counter + rd_burst_length;
	end
	//-----------------------------------------------------------
	always @(posedge clk)
	begin
		if(reset)
			rd_en <= 1'b0;
		else if(wr_iter_num != wr_iter_num_d)
			rd_en <= 1'b1;
	end
	//-----------------------------------------------------------
	always @(posedge clk)
	if(reset)
		main_rd_sm <= S_IDLE_RD;
	else
		main_rd_sm <= main_rd_sm_ns;

	always @(*)
	begin
		main_rd_sm_ns = main_rd_sm;
		case (main_rd_sm)
			S_IDLE_RD:
				if(rd_en)
					main_rd_sm_ns = S_DIR_RD;
			S_DIR_RD:
				if(steam_rd_end)
					main_rd_sm_ns = S_INC_STR_RD;
			S_INC_STR_RD:
					main_rd_sm_ns = S_DIR_RD;
		endcase
	end

	prbs_gen prbs_gen_blk (
		.clk(clk),
		.reset_n(~reset),

		.mode(3'h6),
		.width(3'h0),
		.pat(32'h0),
		.inv(1'b0),
		.set_err(1'b0),
		.load(1'b0), 
		.din(31'b0),

		.dout(random)
	);		

endmodule

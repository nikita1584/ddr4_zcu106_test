module speed_tester(
	input clk,
	input reset,

	input		WREADY,
	input       WVALID,

	input		RREADY,
	input       RVALID
	);
	
	(* mark_debug = "true" *)reg [31:0] sec_cnt;
	(* mark_debug = "true" *)reg [31:0] wr_cnt;
	(* mark_debug = "true" *)reg [31:0] rd_cnt;
	(* mark_debug = "true" *)reg [31:0] wr_speed;
	(* mark_debug = "true" *)reg [31:0] rd_speed;

	(* mark_debug = "true" *)wire sec_tick;

	assign sec_tick = sec_cnt == 32'd300_120_000;

	always @(posedge clk)
	begin
		if(reset || (sec_cnt == 32'd300_120_000))
			sec_cnt <= 32'h0;
		else
			sec_cnt <= sec_cnt + 32'h01;
	end

	always @(posedge clk)
	begin
		if(reset || sec_tick)
			wr_cnt <= 32'h0;
		else if(WREADY && WVALID)
			wr_cnt <= wr_cnt + 32'h01;
	end

	always @(posedge clk)
	begin
		if(reset || sec_tick)
			rd_cnt <= 32'h0;
		else if(RREADY && RVALID)
			rd_cnt <= rd_cnt + 32'h01;
	end

	always @(posedge clk)
	begin
		if(reset)
			wr_speed <= 32'h0;
		else if(sec_tick)
			wr_speed <= wr_cnt * 8;
	end

	always @(posedge clk)
	begin
		if(reset)
			rd_speed <= 32'h0;
		else if(sec_tick)
			rd_speed <= rd_cnt * 8;
	end

endmodule

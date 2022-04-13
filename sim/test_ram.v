module  test_ram ( data_in_a, wraddress_a, wrclock_a, wren_a, wr_be_a,
                   data_out_a, rdaddress_a, rdclock_a, rden_a,
                   data_in_b, wraddress_b, wrclock_b, wren_b, wr_be_b,
                   data_out_b, rdaddress_b, rdclock_b, rden_b);

	parameter lpm_width = 1;
	parameter lpm_n_bytes = 1;
	parameter lpm_widthad = 1;
	parameter lpm_outdata_a = "REGISTERED";
	parameter lpm_outdata_b = "REGISTERED";

	parameter lpm_numwords = 1<< lpm_widthad;

	input  [lpm_width-1:0] data_in_a;
	input  [lpm_n_bytes-1:0] wr_be_a;
	input  [lpm_widthad-1:0] rdaddress_a, wraddress_a;
	input  rdclock_a, wrclock_a, rden_a, wren_a;
	output [lpm_width-1:0] data_out_a;

    input  [lpm_width-1:0] data_in_b;
	input  [lpm_n_bytes-1:0] wr_be_b;
	input  [lpm_widthad-1:0] rdaddress_b, wraddress_b;
	input  rdclock_b, wrclock_b, rden_b, wren_b;
	output [lpm_width-1:0] data_out_b;

///////////////////////////////////////////////////////////////////////////////////////

reg  [lpm_width-1:0] q_reg_a;
wire [lpm_width-1:0] q_unreg_a;
reg  [lpm_width-1:0] data_out_a;

reg  [lpm_width-1:0] q_reg_b;
wire [lpm_width-1:0] q_unreg_b;
reg  [lpm_width-1:0] data_out_b;

////////////////////////////////////////////

reg[lpm_width-1:0] memory [0:lpm_numwords-1];

////////////////////////////////////////////

integer i;
reg [63:0] data_tmp_a,data_mem_a;
always @(wr_be_a or wraddress_a or data_in_a) begin
  data_mem_a = memory[wraddress_a]; 
    data_tmp_a[7:0] = wr_be_a[0] ? data_in_a[7:0] : data_mem_a[7:0];
	data_tmp_a[15:8] = wr_be_a[1] ? data_in_a[15:8] : data_mem_a[15:8];
	data_tmp_a[23:16] = wr_be_a[2] ? data_in_a[23:16] : data_mem_a[23:16];
	data_tmp_a[31:24] = wr_be_a[3] ? data_in_a[31:24] : data_mem_a[31:24];
	data_tmp_a[39:32] = wr_be_a[4] ? data_in_a[39:32] : data_mem_a[39:32];
	data_tmp_a[47:40] = wr_be_a[5] ? data_in_a[47:40] : data_mem_a[47:40];
	data_tmp_a[55:48] = wr_be_a[6] ? data_in_a[55:48] : data_mem_a[55:48];
	data_tmp_a[63:56] = wr_be_a[7] ? data_in_a[63:56] : data_mem_a[63:56];
end

always @(posedge wrclock_a)
if (wren_a) memory [wraddress_a] <= data_tmp_a;

always @(posedge rdclock_a) 
if (rden_a) q_reg_a <= memory [rdaddress_a];

assign q_unreg_a = memory[rdaddress_a];

always @(rdaddress_a or q_reg_a or q_unreg_a)
  if(lpm_outdata_a=="REGISTERED") data_out_a = q_reg_a;
  else data_out_a = q_unreg_a;

//////////////////////////////////////////////

integer j;
reg [63:0] data_tmp_b,data_mem_b;
always @(wr_be_b or wraddress_b or data_in_b) begin
  data_mem_b = memory[wraddress_b]; 
  data_tmp_b[7:0] = wr_be_b[0] ? data_in_b[7:0] : data_mem_b[7:0];
	data_tmp_b[15:8] = wr_be_b[1] ? data_in_b[15:8] : data_mem_b[15:8];
	data_tmp_b[23:16] = wr_be_b[2] ? data_in_b[23:16] : data_mem_b[23:16];
	data_tmp_b[31:24] = wr_be_b[3] ? data_in_b[31:24] : data_mem_b[31:24];
	data_tmp_b[39:32] = wr_be_b[4] ? data_in_b[39:32] : data_mem_b[39:32];
	data_tmp_b[47:40] = wr_be_b[5] ? data_in_b[47:40] : data_mem_b[47:40];
	data_tmp_b[55:48] = wr_be_b[6] ? data_in_b[55:48] : data_mem_b[55:48];
	data_tmp_b[63:55] = wr_be_b[7] ? data_in_b[63:55] : data_mem_b[63:55];

end

always @(posedge wrclock_b)
if (wren_b) memory [wraddress_b] <= data_tmp_b;

always @(posedge rdclock_b) 
if (rden_b) q_reg_b <= memory [rdaddress_b];

assign q_unreg_b = memory[rdaddress_b];

always @(rdaddress_b or q_reg_b or q_unreg_b)
  if(lpm_outdata_b=="REGISTERED") data_out_b = q_reg_b;
  else data_out_b = q_unreg_b;

//////////////////////////////////////////////

/*
always @(posedge wrclock_a or posedge wrclock_b)
if (wren_a | wren_b) $display ($time, "\n   !!! WARNING: TEST MEMORY SIMULTANEOUS WRITE ACCESS !!! \n");

always @(posedge wrclock_a or posedge rdclock_b)
if (wren_a | rden_b) $display ($time, "\n   !!! WARNING: TEST MEMORY SIMULTANEOUS READ/WRITE ACCESS !!! \n");

always @(posedge rdclock_a or posedge wrclock_b)
if (rden_a | wren_b) $display ($time, "\n   !!! WARNING: TEST MEMORY SIMULTANEOUS READ/WRITE ACCESS !!! \n");

always @(posedge rdclock_a or posedge rdclock_b)
if (rden_a | rden_b) $display ($time, "\n   !!! WARNING: TEST MEMORY SIMULTANEOUS READ ACCESS !!! \n");
*/
//////////////////////////////////////////////

endmodule

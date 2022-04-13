/*
axi_mem_target inst_name (.clk(),.reset(),

	                    .AWREADY(),
	                    .AWADDR(),.AWID(),.AWLEN(),.AWVALID(),
	                    .WREADY(),
	                    .WID(),.WDATA(),.WSTRB(),.WLAST(),.WVALID(),
	                    .BID(),.BRESP(),.BVALID(),
	                    .BREADY(),
	                    .ARREADY(),
	                    .ARADDR(),.ARID(),.ARLEN(),.ARVALID(),
	                    .RREADY(),
	                    .RID(),.RDATA(),.RRESP(),.RLAST(),.RVALID(),

	                    .mem_wr_clk(),.mem_wr_adr(),.mem_wr_en(),.mem_data_in(),.mem_be(),
						.mem_rd_clk(),.mem_rd_adr(),.mem_rd_en(),.mem_data_out()
	                    );
*/

module axi_mem_target (clk,reset,

	                    AWREADY,
	                    AWADDR,AWID,AWLEN,AWVALID,
	                    WREADY,
	                    WID,WDATA,WSTRB,WLAST,WVALID,
	                    BID,BRESP,BVALID,
	                    BREADY,
	                    ARREADY,
	                    ARADDR,ARID,ARLEN,ARVALID,
	                    RREADY,
	                    RID,RDATA,RRESP,RLAST,RVALID,

	                    mem_wr_clk,mem_wr_adr,mem_wr_en,mem_data_in,mem_be,
						mem_rd_clk,mem_rd_adr,mem_rd_en,mem_data_out
	                    );

parameter response_mode = "min";
   
// global
	input clk,reset;

//axi write channel

	/// address channel
	output AWREADY;

	input [31:0] AWADDR;
	input [3:0]  AWID;
	input [7:0]  AWLEN;
	input        AWVALID;

	/// data channel
	output       WREADY;

	input [3:0]  WID;
	input [511:0] WDATA;
	input [64:0]  WSTRB;
	input        WLAST;
	input        WVALID;

	/// responce channel
	output [3:0] BID;
	output [1:0] BRESP;
	output       BVALID;

	input        BREADY;


//axi read channel
	/// address channel
	output       ARREADY;

	input [31:0] ARADDR;
	input [3:0]  ARID;
	input [7:0]  ARLEN;
	input        ARVALID;

	/// data channel
	input RREADY;

	output [3:0]  RID;
	output [511:0] RDATA;
	output [1:0]  RRESP;
	output        RLAST;
	output        RVALID;


// memory 
	input mem_wr_clk;
	input [31:0] mem_wr_adr;
	input mem_wr_en;
	input [63:0] mem_data_in;
	input [7:0] mem_be;
	input mem_rd_clk;
	input [31:0] mem_rd_adr;
	input mem_rd_en;
	output [63:0] mem_data_out;

////////////////////////////////////////////////////

	reg AWREADY,WREADY;
	reg ARREADY;
	reg [3:0] BID;
	reg [1:0] BRESP;
	reg       BVALID;
	reg[3:0]  RID;
	reg[511:0] RDATA;
	reg[1:0]  RRESP;
	reg       RLAST;
	reg       RVALID;

	reg R_dscrp_read,R_dscrp_write,R_data_access;
	reg T_dscrp_read,T_dscrp_write,T_data_access;

///////////////////////////////////////////////////////////////// 
  /*
  OK
   wire 	Hit_RD = (ARVALID & ARADDR[31:16]==16'h00c1 |
                      AWVALID & AWADDR[31:16]==16'h00c1); // R.descriptor

   wire 	Hit_DR = AWVALID & AWADDR[31:20]==12'h00d;//12'h00d; // R.data


   wire 	Hit_TD = (ARVALID & ARADDR[31:16]==16'h00a1 |
                      AWVALID & AWADDR[31:16]==16'h00a1); // T.descriptor

   wire 	Hit_DT = ARVALID & ARADDR[31:20]==12'h00b; // T.data
*/

   wire 	Hit_RD = ARVALID; // R.descriptor

   wire 	Hit_DR = AWVALID;//12'h00d; // R.data


   wire 	Hit_TD = ARVALID; // T.descriptor

   wire 	Hit_DT = ARVALID; // T.data

   /*
  OK
   wire     Wrong_Hit = (ARVALID | AWVALID) & (!Hit_RD & !Hit_DR & !Hit_TD & !Hit_DT)
                        `ifdef DMA_in_descriptor_read_error
                         | ARVALID & ARADDR[31:0]==32'h00a10030 // DMA_in dscrp read error
						`endif
                        `ifdef DMA_in_data_write_error						
						 | AWVALID & AWADDR[31:0]==32'h00b60020 // DMA_in data write error
						`endif
						`ifdef DMA_out_descriptor_read_error
                         | ARVALID & ARADDR[31:0]==32'h00a10030 // DMA_out dscrp read error
						`endif
						`ifdef DMA_out_data_read_error
                         | ARVALID & ARADDR[31:0]==32'h00b71fa0 // DMA_out data read error
						`endif 
                         ;
	*/
	wire     Wrong_Hit = 1'b0;

/*					 
	wire     Wrong_Hit = (ARVALID | AWVALID) & (!Hit_RD & !Hit_DR & !Hit_TD & !Hit_DT)
                        
                         | ARVALID & ARADDR[31:0]==32'h00a10030 // DMA_out dscrp read error
						 
                         ;	
*/						 
////////////////////////////////////////////////////

reg [7:0] l_be;
reg [31:0] l_wr_adr;
reg l_wr_en;
reg [511:0] l_data_in;
reg [31:0] l_rd_adr;
reg l_rd_en;
wire [511:0] l_data_out;

defparam t_ram.lpm_width = 512,
         t_ram.lpm_n_bytes = 8,  
		 t_ram.lpm_widthad = 21,  
		 t_ram.lpm_outdata_a = "UNREGISTERED",
		 t_ram.lpm_outdata_b = "UNREGISTERED";
 
test_ram t_ram (.data_in_a(mem_data_in), .wraddress_a(mem_wr_adr[23:3]), 
                .wrclock_a(mem_wr_clk), .wren_a(mem_wr_en), .wr_be_a(mem_be),
	            .data_out_a(mem_data_out), .rdaddress_a(mem_rd_adr[23:3]), 
	            .rdclock_a(mem_rd_clk), .rden_a(mem_rd_en),
	            
	            .data_in_b(l_data_in), .wraddress_b(l_wr_adr[23:3]), //23:3
	            .wrclock_b(clk), .wren_b(l_wr_en), .wr_be_b(l_be),
	            .data_out_b(l_data_out), .rdaddress_b(l_rd_adr[23:3]), //23:3
	            .rdclock_b(clk), .rden_b(l_rd_en)
	            );

////////////////////////////////////////////////////////////////

reg [2:0] sm;
parameter sm0 = 3'b000,
          sm1 = 3'b001,
		  sm2 = 3'b010,
		  sm3 = 3'b011,
		  sm4 = 3'b100,
		  sm5 = 3'b101,
		  sm6 = 3'b110,
		  sm7 = 3'b111;

reg line_end;
reg r_cntr_zero;
wire start = AWVALID | ARVALID;
reg [7:0] l_cntr; 
reg dir;

always @(posedge clk or negedge reset)
if(!reset) sm <= sm0;
else case(sm)
sm0: if(start & response_mode=="random") sm <= sm2;
     else if(start & response_mode=="min") sm <= sm1;
sm1: if(response_mode=="random") sm <= sm4;
     else sm <= sm3;
sm2: if(r_cntr_zero) sm <= sm1;
sm3: if(line_end & (WVALID & WREADY | RVALID & RREADY)) sm <= sm6; 
     //else if(response_mode=="random" & (WVALID | RREADY)) sm <= sm4;
     else if(WVALID & WREADY | RVALID & RREADY) sm <= sm5;
sm5: if(line_end & (WVALID & WREADY | RVALID & RREADY)) sm <= sm6;
     //else if(response_mode=="random" & (WVALID | RREADY)) sm <= sm4;
	 else if(WVALID & WREADY | RVALID & RREADY) sm <= sm3;
sm4: if(r_cntr_zero & (!l_cntr[0])) sm <= sm5;
     else if(r_cntr_zero & (l_cntr[0])) sm <= sm3;
sm6: if(!dir | BREADY) sm <= sm0;// sm <= sm7
sm7: sm <= sm0;
endcase

//////////////////////////////////////////////////////////////////

reg [7:0] randomizer;
reg [4:0] r_cntr;


reg load;
reg stb;

reg Adr_Error;
reg Leng_Error;
reg ID_Error;

always @(posedge clk or negedge reset)
if(!reset) begin
  randomizer <= $urandom%255;
  r_cntr <= 'd0;
  l_cntr <= 'd0;
  Adr_Error <= 0;
  Leng_Error <= 0;
  ID_Error <= 0;
end
else begin
  //randomizer <= {randomizer[3:0],(randomizer[1] ~^ randomizer[4])};
  if(response_mode=="random") randomizer <= $urandom%255;
  else randomizer <= 'd1;
  
  if(sm==sm0 & start | sm==sm1 | sm==sm3 | sm==sm5) r_cntr <= $urandom%31;//randomizer;
  else if(r_cntr!='d0) r_cntr <= r_cntr - 1;

  if(sm==sm1) l_cntr <= dir ? AWLEN : ARLEN;
  else if((sm==sm3 | sm==sm5) & (WVALID & WREADY | RVALID & RREADY) & l_cntr!='d0) l_cntr <= l_cntr - 1;

  if(sm==sm0 & start) Adr_Error <= Wrong_Hit;
  
  if((sm==sm3 | sm==sm5) & WVALID & WREADY & dir & (l_cntr=='d0 & !WLAST |
                                                    l_cntr!='d0 & WLAST)) Leng_Error <= 1;
  else if(sm==sm6) Leng_Error <= 0;
  
  if((sm==sm3 | sm==sm5) & dir & BID!=WID & WVALID) ID_Error <= 1;
  else if(sm==sm6) ID_Error <= 0;
end

always @(*) begin
  r_cntr_zero = (r_cntr=='d0);
  line_end = (l_cntr=='d0);

  load = (sm==sm0) & start;
  stb = ((sm==sm3) | (sm==sm5)) & (WVALID & WREADY | RVALID & RREADY); 
end

///////////////////////////////////////////////////////////////////


always @(*) begin
  AWREADY = (sm==sm1) & dir;
  ARREADY = (sm==sm1) & !dir;
  WREADY = (sm==sm3 | sm==sm5) & dir & randomizer[0];
  RVALID = (sm==sm3 | sm==sm5) & !dir & randomizer[0];
  RLAST  = (sm==sm3 | sm==sm5) & !dir & line_end & randomizer[0]; 
  BVALID = (sm==sm6) & dir;
  BRESP = Adr_Error ? 2'b11 : ((Leng_Error | ID_Error) ? 2'b10 : 2'b00);
  RRESP = Adr_Error ? 2'b11 : 2'b00;
end

///////////////////////////////////////////////////////////////////

   always @(reset)
   if(!reset) 
     begin
	  R_dscrp_read <= 0;
      R_dscrp_write <= 0;
	  R_data_access <= 0;
	  T_dscrp_read <= 0;
      T_dscrp_write <= 0;
	  T_data_access <= 0;
     end 
   
/////////////////////////////////////////////////////////////////////   
/////////////////////////////////////////////////////////////////////
      
     always @(posedge clk or negedge reset)
        if(!reset) begin
        	dir <= 0;
			l_wr_adr <= 32'h00000000;
			l_rd_adr <= 32'h00000000;
			BID <= 'd0;
			RID <= 'd0;
        end
        else begin
         	if(load) begin
         	  dir <= AWVALID;
			  if(AWVALID) l_wr_adr <= AWADDR;
			  if(ARVALID) l_rd_adr <= ARADDR;
			  if(AWVALID) BID <= AWID;
			  if(ARVALID) RID <= ARID;
			end
			else if(stb) begin
			  if(dir) l_wr_adr <= l_wr_adr + 'd64;
			  else l_rd_adr <= l_rd_adr + 'd64;
			end
        end

/////////////////////////////////////////////////////////////////////////
     
      always @(posedge clk) // Receiver Descriptor Access
       if(start & Hit_RD) begin
         if(ARREADY) begin: R_descriptor_reading
     	   R_dscrp_read <= 1;
         end 
     	 else if(AWREADY) begin: R_descriptor_writing
     	   R_dscrp_write <= 1;
         end 
	   end
       else if(RREADY & RVALID & R_dscrp_read) begin
			   $display ("\n ",$time,"   -->    Receive Target Memory: Data read from the descriptor %h_%h, Address of the descriptor %h\n",l_data_out[63:32],l_data_out[31:0],l_rd_adr);

     	       R_dscrp_read <= 0;
            end
       else if(WREADY & WVALID & R_dscrp_write)begin
     	     R_dscrp_write <= 0;
     		 
			 $display ("\n ",$time,"         <--    Receive Target Memory: Data writen to the descriptor %h_%h (WR_be=%h), Address of the descriptor %h\n",WDATA[63:32],WDATA[31:0],WSTRB,l_wr_adr);
             end

////////////////////////////////////

      always @(posedge clk) // Transmitter Descriptor Access
       if(start & Hit_TD) begin
         if(ARREADY) begin: T_descriptor_reading
     	   T_dscrp_read <= 1;
         end 
     	 else if(AWREADY) begin: T_descriptor_writing
     	   T_dscrp_write <= 1;
         end 
	   end
       else if(RREADY & RVALID & T_dscrp_read) begin
			   $display ("\n ",$time,"   -->    Transmit Target Memory: Data read from the descriptor %h_%h, Address of the descriptor %h\n",RDATA[63:32],RDATA[31:0],l_rd_adr);

     	      T_dscrp_read <= 0;
            end
       else if(WREADY & WVALID & T_dscrp_write)begin
     	     T_dscrp_write <= 0;
     		 
			 $display ("\n ",$time,"         <--    Transmit Target Memory: Data writen to the descriptor %h_%h (WR_be=%h), Address of the descriptor %h\n",WDATA[63:32],WDATA[31:0],WSTRB,l_wr_adr);
	    end


//////////////////////////////////////////////////////////////////////////////// 
// Receiver Data Access ////////////////////////////////////////////////////////

  always @(posedge clk) begin
	 if(start & Hit_DR & AWVALID) 
     	   R_data_access <= 1;
     else if(R_data_access & (sm==sm6))  
           R_data_access <= 0;
  end
	  
////////////////////////////////////////////////////////////////////////////////
// Transmit Data Access ////////////////////////////////////////////////////////

always @(posedge clk or negedge reset) 
	 if(start & Hit_DT & ARVALID) 
     	   T_data_access <= 1;
     else if(T_data_access & (sm==sm6))  
           T_data_access <= 0;

////////////////////////////////////////////////////////////////////////////////
 
always @(*) begin
l_be = WSTRB;
RDATA = l_data_out;
l_data_in = WDATA;
l_wr_en = stb & dir;
l_rd_en = stb & !dir;
end 
 	  
////////////////////////////////////////////////////////////////////////////////

endmodule


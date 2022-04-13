module prbs_gen (
//Inputs
clk,
reset_n,

mode,
width,
pat,
inv,
set_err,
load, 
din,

//Outputs
dout

);		


parameter W_8  = 3'h0;
parameter W_10 = 3'h1;
parameter W_16 = 3'h2;
parameter W_20 = 3'h3;
parameter W_32 = 3'h4;

parameter OFF        = 3'h0;
parameter M_PAT      = 3'h1; // Pattern
parameter M_PAT_B    = 3'h2; // Balanced Patter {pat,~pat}
parameter PRBS_7_6   = 3'h3; 
parameter PRBS_15_14 = 3'h4;
parameter PRBS_23_18 = 3'h5;
parameter PRBS_31_28 = 3'h6;



// Port declarations

//Inputs
input clk;
input reset_n;

input [2:0] mode;
input [2:0] width;
input [31:0] pat;
input inv;
input set_err;
input load;
input [30:0] din;

//Outputs
output [31:0] dout;


reg [7:1] prbs_7_6_sh;
reg [15:1] prbs_15_14_sh;
reg [23:1] prbs_23_18_sh;
reg [31:1] prbs_31_28_sh;
reg rst_n_d1;
reg rst_n_d2;
reg rst_n_sync;
reg [7:0] dout_8;
reg [9:0] dout_10;
reg [15:0] dout_16;
reg [19:0] dout_20;
reg [31:0] dout_32;
reg [31:0] dout;
reg set_err_d;
reg pat_ptr;
reg [31:0] dout_int;
wire [31:0] dout_int_p;
wire [31:0] dout_int_p_inv;
wire [31:0] dout_int_p_err;
wire [30:0] din_rev;

always @(posedge clk or negedge reset_n)
   if(~reset_n)
     begin
       rst_n_sync <= 0;
       rst_n_d1 <= 0;
       rst_n_d2 <= 0;
     end
   else
     begin
       rst_n_d1 <= 1;
       rst_n_d2 <= rst_n_d1;
       rst_n_sync <= rst_n_d2;
    end   

always @(posedge clk)
   set_err_d <= set_err;

assign din_rev[0] = din[30];
assign din_rev[1] = din[29];
assign din_rev[2] = din[28];
assign din_rev[3] = din[27];
assign din_rev[4] = din[26];
assign din_rev[5] = din[25];
assign din_rev[6] = din[24];
assign din_rev[7] = din[23];
assign din_rev[8] = din[22];
assign din_rev[9] = din[21];
assign din_rev[10] = din[20];
assign din_rev[11] = din[19];
assign din_rev[12] = din[18];
assign din_rev[13] = din[17];
assign din_rev[14] = din[16];
assign din_rev[15] = din[15];
assign din_rev[16] = din[14];
assign din_rev[17] = din[13];
assign din_rev[18] = din[12];
assign din_rev[19] = din[11];
assign din_rev[20] = din[10];
assign din_rev[21] = din[9];
assign din_rev[22] = din[8];
assign din_rev[23] = din[7];
assign din_rev[24] = din[6];
assign din_rev[25] = din[5];
assign din_rev[26] = din[4];
assign din_rev[27] = din[3];
assign din_rev[28] = din[2];
assign din_rev[29] = din[1];
assign din_rev[30] = din[0];

wire [7:1] prbs_7_6_d32_1;
wire [7:1] prbs_7_6_d32_2;
wire [7:1] prbs_7_6_d32_3;
wire [7:1] prbs_7_6_d32_4;


always @(posedge clk)
  if (~rst_n_sync)
     begin
       prbs_7_6_sh   <= 7'h7f;
       prbs_15_14_sh <= 15'h7fff;
       prbs_23_18_sh <= 23'h7fffff;
       prbs_31_28_sh <= 31'h7fffffff;
     end
  else if(load)
    begin
       prbs_7_6_sh   <=  din_rev[30:24];
       prbs_15_14_sh <=  din_rev[30:16]; 
       prbs_23_18_sh <=  din_rev[30:8];
       prbs_31_28_sh <=  din_rev[30:0];
    end   
 else   
    begin
      case(width)
        W_8: begin
               prbs_7_6_sh   <=   prbs_7__7_6__to_8_lfsr(prbs_7_6_sh);
               prbs_15_14_sh <= prbs_15__15_14__to_8_lfsr(prbs_15_14_sh);
               prbs_23_18_sh <= prbs_23__23_18__to_8_lfsr(prbs_23_18_sh);
               prbs_31_28_sh <= prbs_31__31_28__to_8_lfsr(prbs_31_28_sh);
             end
        W_10: begin
               prbs_7_6_sh   <=   prbs_7__7_6__to_10_lfsr(prbs_7_6_sh);
               prbs_15_14_sh <= prbs_15__15_14__to_10_lfsr(prbs_15_14_sh);
               prbs_23_18_sh <= prbs_23__23_18__to_10_lfsr(prbs_23_18_sh);
               prbs_31_28_sh <= prbs_31__31_28__to_10_lfsr(prbs_31_28_sh);
             end
        W_16: begin
               prbs_7_6_sh   <=   prbs_7__7_6__to_16_lfsr(prbs_7_6_sh);
               prbs_15_14_sh <= prbs_15__15_14__to_16_lfsr(prbs_15_14_sh);
               prbs_23_18_sh <= prbs_23__23_18__to_16_lfsr(prbs_23_18_sh);
               prbs_31_28_sh <= prbs_31__31_28__to_16_lfsr(prbs_31_28_sh);
             end
        W_20: begin
               prbs_7_6_sh   <=   prbs_7__7_6__to_20_lfsr(prbs_7_6_sh);
               prbs_15_14_sh <= prbs_15__15_14__to_20_lfsr(prbs_15_14_sh);
               prbs_23_18_sh <= prbs_23__23_18__to_20_lfsr(prbs_23_18_sh);
               prbs_31_28_sh <= prbs_31__31_28__to_20_lfsr(prbs_31_28_sh);
             end
        W_32: begin
               prbs_7_6_sh   <=   prbs_7__7_6__to_32_lfsr(prbs_7_6_sh);
               prbs_15_14_sh <= prbs_15__15_14__to_32_lfsr(prbs_15_14_sh);
               prbs_23_18_sh <= prbs_23__23_18__to_32_lfsr(prbs_23_18_sh);
               prbs_31_28_sh <= prbs_31__31_28__to_32_lfsr(prbs_31_28_sh);
             end
        default: begin
               prbs_7_6_sh   <=   prbs_7__7_6__to_32_lfsr(prbs_7_6_sh);
               prbs_15_14_sh <= prbs_15__15_14__to_32_lfsr(prbs_15_14_sh);
               prbs_23_18_sh <= prbs_23__23_18__to_32_lfsr(prbs_23_18_sh);
               prbs_31_28_sh <= prbs_31__31_28__to_32_lfsr(prbs_31_28_sh);
             end
       endcase
  end

always @(posedge clk)
  if (~rst_n_sync)
     dout_8 <= 8'h0;
  else
    case(mode)
      PRBS_7_6:   dout_8 <=    prbs_7__7_6__to_8_dout(prbs_7_6_sh);
      PRBS_15_14: dout_8 <= prbs_15__15_14__to_8_dout(prbs_15_14_sh);
      PRBS_23_18: dout_8 <= prbs_23__23_18__to_8_dout(prbs_23_18_sh);
      PRBS_31_28: dout_8 <= prbs_31__31_28__to_8_dout(prbs_31_28_sh);
      default:    dout_8 <= prbs_31__31_28__to_8_dout(prbs_31_28_sh);
    endcase
         
always @(posedge clk)
  if (~rst_n_sync)
     dout_10 <= 10'h0;
  else
    case(mode)
      PRBS_7_6:   dout_10 <=    prbs_7__7_6__to_10_dout(prbs_7_6_sh);
      PRBS_15_14: dout_10 <= prbs_15__15_14__to_10_dout(prbs_15_14_sh);
      PRBS_23_18: dout_10 <= prbs_23__23_18__to_10_dout(prbs_23_18_sh);
      PRBS_31_28: dout_10 <= prbs_31__31_28__to_10_dout(prbs_31_28_sh);
      default:    dout_10 <= prbs_31__31_28__to_10_dout(prbs_31_28_sh);
    endcase
         
always @(posedge clk)
  if (~rst_n_sync)
     dout_16 <= 16'h0;
  else
    case(mode)
      PRBS_7_6:   dout_16 <=    prbs_7__7_6__to_16_dout(prbs_7_6_sh);
      PRBS_15_14: dout_16 <= prbs_15__15_14__to_16_dout(prbs_15_14_sh);
      PRBS_23_18: dout_16 <= prbs_23__23_18__to_16_dout(prbs_23_18_sh);
      PRBS_31_28: dout_16 <= prbs_31__31_28__to_16_dout(prbs_31_28_sh);
      default:    dout_16 <= prbs_31__31_28__to_16_dout(prbs_31_28_sh);
    endcase
         
         
always @(posedge clk)
  if (~rst_n_sync)
     dout_20 <= 20'h0;
  else
    case(mode)
      PRBS_7_6:   dout_20 <=    prbs_7__7_6__to_20_dout(prbs_7_6_sh);
      PRBS_15_14: dout_20 <= prbs_15__15_14__to_20_dout(prbs_15_14_sh);
      PRBS_23_18: dout_20 <= prbs_23__23_18__to_20_dout(prbs_23_18_sh);
      PRBS_31_28: dout_20 <= prbs_31__31_28__to_20_dout(prbs_31_28_sh);
      default:    dout_20 <= prbs_31__31_28__to_20_dout(prbs_31_28_sh);
    endcase
       
always @(posedge clk)
  if (~rst_n_sync)
     dout_32 <= 20'h0;
  else
    case(mode)
      PRBS_7_6:   dout_32 <=    prbs_7__7_6__to_32_dout(prbs_7_6_sh);
      PRBS_15_14: dout_32 <= prbs_15__15_14__to_32_dout(prbs_15_14_sh);
      PRBS_23_18: dout_32 <= prbs_23__23_18__to_32_dout(prbs_23_18_sh);
      PRBS_31_28: dout_32 <= prbs_31__31_28__to_32_dout(prbs_31_28_sh);
      default:    dout_32 <= prbs_31__31_28__to_32_dout(prbs_31_28_sh);
    endcase
       
       
always @(dout_8,dout_10,dout_16,dout_20,dout_32,width)
   case(width)
     W_8:  dout_int = {24'h0,dout_8};
     W_10: dout_int = {22'h0,dout_10};
     W_16: dout_int = {16'h0,dout_16};
     W_20: dout_int = {12'h0,dout_20};
     W_32: dout_int =        dout_32;
     default: dout_int = 32'h0;
   endcase

always @(posedge clk or negedge rst_n_sync)
   if(~rst_n_sync)
       pat_ptr <= 0;
   else
      pat_ptr <= ~pat_ptr;
  

assign dout_int_p  = (mode == M_PAT) ?  pat : 
                    ((mode == M_PAT_B) ? (pat_ptr ? pat : ~pat) : dout_int);

assign dout_int_p_inv = inv ? ~dout_int_p : dout_int_p;

assign dout_int_p_err = (set_err ^ set_err_d) ? {dout_int_p_inv[31:1],~dout_int_p_inv[0]} : dout_int_p_inv;

always @(posedge clk)
   dout <= dout_int_p_err;


function [7:0] prbs_7__7_6__to_8_dout;
input [7:1] x;
begin
   prbs_7__7_6__to_8_dout[0] =x[7];
   prbs_7__7_6__to_8_dout[1] =x[6];
   prbs_7__7_6__to_8_dout[2] =x[5];
   prbs_7__7_6__to_8_dout[3] =x[4];
   prbs_7__7_6__to_8_dout[4] =x[3];
   prbs_7__7_6__to_8_dout[5] =x[2];
   prbs_7__7_6__to_8_dout[6] =x[1];
   prbs_7__7_6__to_8_dout[7] =x[6]^x[7];
end
endfunction




function [7:1] prbs_7__7_6__to_8_lfsr;
input [7:1] x;
begin
   prbs_7__7_6__to_8_lfsr[1] =x[7]^x[5];
   prbs_7__7_6__to_8_lfsr[2] =x[1]^x[6]^x[7];
   prbs_7__7_6__to_8_lfsr[3] =x[2]^x[1];
   prbs_7__7_6__to_8_lfsr[4] =x[2]^x[3];
   prbs_7__7_6__to_8_lfsr[5] =x[3]^x[4];
   prbs_7__7_6__to_8_lfsr[6] =x[4]^x[5];
   prbs_7__7_6__to_8_lfsr[7] =x[6]^x[5];
end
endfunction
function [9:0] prbs_7__7_6__to_10_dout;
input [7:1] x;
begin
   prbs_7__7_6__to_10_dout[0] =x[7];
   prbs_7__7_6__to_10_dout[1] =x[6];
   prbs_7__7_6__to_10_dout[2] =x[5];
   prbs_7__7_6__to_10_dout[3] =x[4];
   prbs_7__7_6__to_10_dout[4] =x[3];
   prbs_7__7_6__to_10_dout[5] =x[2];
   prbs_7__7_6__to_10_dout[6] =x[1];
   prbs_7__7_6__to_10_dout[7] =x[6]^x[7];
   prbs_7__7_6__to_10_dout[8] =x[6]^x[5];
   prbs_7__7_6__to_10_dout[9] =x[4]^x[5];
end
endfunction




function [7:1] prbs_7__7_6__to_10_lfsr;
input [7:1] x;
begin
   prbs_7__7_6__to_10_lfsr[1] =x[3]^x[5];
   prbs_7__7_6__to_10_lfsr[2] =x[6]^x[4];
   prbs_7__7_6__to_10_lfsr[3] =x[7]^x[5];
   prbs_7__7_6__to_10_lfsr[4] =x[1]^x[6]^x[7];
   prbs_7__7_6__to_10_lfsr[5] =x[2]^x[1];
   prbs_7__7_6__to_10_lfsr[6] =x[2]^x[3];
   prbs_7__7_6__to_10_lfsr[7] =x[3]^x[4];
end
endfunction
function [15:0] prbs_7__7_6__to_16_dout;
input [7:1] x;
begin
   prbs_7__7_6__to_16_dout[0] =x[7];
   prbs_7__7_6__to_16_dout[1] =x[6];
   prbs_7__7_6__to_16_dout[2] =x[5];
   prbs_7__7_6__to_16_dout[3] =x[4];
   prbs_7__7_6__to_16_dout[4] =x[3];
   prbs_7__7_6__to_16_dout[5] =x[2];
   prbs_7__7_6__to_16_dout[6] =x[1];
   prbs_7__7_6__to_16_dout[7] =x[6]^x[7];
   prbs_7__7_6__to_16_dout[8] =x[6]^x[5];
   prbs_7__7_6__to_16_dout[9] =x[4]^x[5];
   prbs_7__7_6__to_16_dout[10] =x[3]^x[4];
   prbs_7__7_6__to_16_dout[11] =x[2]^x[3];
   prbs_7__7_6__to_16_dout[12] =x[2]^x[1];
   prbs_7__7_6__to_16_dout[13] =x[1]^x[6]^x[7];
   prbs_7__7_6__to_16_dout[14] =x[7]^x[5];
   prbs_7__7_6__to_16_dout[15] =x[6]^x[4];
end
endfunction




function [7:1] prbs_7__7_6__to_16_lfsr;
input [7:1] x;
begin
   prbs_7__7_6__to_16_lfsr[1] =x[3]^x[6]^x[4]^x[5];
   prbs_7__7_6__to_16_lfsr[2] =x[6]^x[7]^x[4]^x[5];
   prbs_7__7_6__to_16_lfsr[3] =x[1]^x[6]^x[5];
   prbs_7__7_6__to_16_lfsr[4] =x[2]^x[6]^x[7];
   prbs_7__7_6__to_16_lfsr[5] =x[3]^x[1];
   prbs_7__7_6__to_16_lfsr[6] =x[2]^x[4];
   prbs_7__7_6__to_16_lfsr[7] =x[3]^x[5];
end
endfunction
function [19:0] prbs_7__7_6__to_20_dout;
input [7:1] x;
begin
   prbs_7__7_6__to_20_dout[0] =x[7];
   prbs_7__7_6__to_20_dout[1] =x[6];
   prbs_7__7_6__to_20_dout[2] =x[5];
   prbs_7__7_6__to_20_dout[3] =x[4];
   prbs_7__7_6__to_20_dout[4] =x[3];
   prbs_7__7_6__to_20_dout[5] =x[2];
   prbs_7__7_6__to_20_dout[6] =x[1];
   prbs_7__7_6__to_20_dout[7] =x[6]^x[7];
   prbs_7__7_6__to_20_dout[8] =x[6]^x[5];
   prbs_7__7_6__to_20_dout[9] =x[4]^x[5];
   prbs_7__7_6__to_20_dout[10] =x[3]^x[4];
   prbs_7__7_6__to_20_dout[11] =x[2]^x[3];
   prbs_7__7_6__to_20_dout[12] =x[2]^x[1];
   prbs_7__7_6__to_20_dout[13] =x[1]^x[6]^x[7];
   prbs_7__7_6__to_20_dout[14] =x[7]^x[5];
   prbs_7__7_6__to_20_dout[15] =x[6]^x[4];
   prbs_7__7_6__to_20_dout[16] =x[3]^x[5];
   prbs_7__7_6__to_20_dout[17] =x[2]^x[4];
   prbs_7__7_6__to_20_dout[18] =x[3]^x[1];
   prbs_7__7_6__to_20_dout[19] =x[2]^x[6]^x[7];
end
endfunction




function [7:1] prbs_7__7_6__to_20_lfsr;
input [7:1] x;
begin
   prbs_7__7_6__to_20_lfsr[1] =x[2]^x[1]^x[7]^x[5];
   prbs_7__7_6__to_20_lfsr[2] =x[2]^x[3]^x[1]^x[6]^x[7];
   prbs_7__7_6__to_20_lfsr[3] =x[2]^x[3]^x[1]^x[4];
   prbs_7__7_6__to_20_lfsr[4] =x[2]^x[3]^x[4]^x[5];
   prbs_7__7_6__to_20_lfsr[5] =x[3]^x[6]^x[4]^x[5];
   prbs_7__7_6__to_20_lfsr[6] =x[6]^x[7]^x[4]^x[5];
   prbs_7__7_6__to_20_lfsr[7] =x[1]^x[6]^x[5];
end
endfunction
function [31:0] prbs_7__7_6__to_32_dout;
input [7:1] x;
begin
   prbs_7__7_6__to_32_dout[0] =x[7];
   prbs_7__7_6__to_32_dout[1] =x[6];
   prbs_7__7_6__to_32_dout[2] =x[5];
   prbs_7__7_6__to_32_dout[3] =x[4];
   prbs_7__7_6__to_32_dout[4] =x[3];
   prbs_7__7_6__to_32_dout[5] =x[2];
   prbs_7__7_6__to_32_dout[6] =x[1];
   prbs_7__7_6__to_32_dout[7] =x[6]^x[7];
   prbs_7__7_6__to_32_dout[8] =x[6]^x[5];
   prbs_7__7_6__to_32_dout[9] =x[4]^x[5];
   prbs_7__7_6__to_32_dout[10] =x[3]^x[4];
   prbs_7__7_6__to_32_dout[11] =x[2]^x[3];
   prbs_7__7_6__to_32_dout[12] =x[2]^x[1];
   prbs_7__7_6__to_32_dout[13] =x[1]^x[6]^x[7];
   prbs_7__7_6__to_32_dout[14] =x[7]^x[5];
   prbs_7__7_6__to_32_dout[15] =x[6]^x[4];
   prbs_7__7_6__to_32_dout[16] =x[3]^x[5];
   prbs_7__7_6__to_32_dout[17] =x[2]^x[4];
   prbs_7__7_6__to_32_dout[18] =x[3]^x[1];
   prbs_7__7_6__to_32_dout[19] =x[2]^x[6]^x[7];
   prbs_7__7_6__to_32_dout[20] =x[1]^x[6]^x[5];
   prbs_7__7_6__to_32_dout[21] =x[6]^x[7]^x[4]^x[5];
   prbs_7__7_6__to_32_dout[22] =x[3]^x[6]^x[4]^x[5];
   prbs_7__7_6__to_32_dout[23] =x[2]^x[3]^x[4]^x[5];
   prbs_7__7_6__to_32_dout[24] =x[2]^x[3]^x[1]^x[4];
   prbs_7__7_6__to_32_dout[25] =x[2]^x[3]^x[1]^x[6]^x[7];
   prbs_7__7_6__to_32_dout[26] =x[2]^x[1]^x[7]^x[5];
   prbs_7__7_6__to_32_dout[27] =x[1]^x[7]^x[4];
   prbs_7__7_6__to_32_dout[28] =x[3]^x[7];
   prbs_7__7_6__to_32_dout[29] =x[2]^x[6];
   prbs_7__7_6__to_32_dout[30] =x[1]^x[5];
   prbs_7__7_6__to_32_dout[31] =x[6]^x[7]^x[4];
end
endfunction




function [7:1] prbs_7__7_6__to_32_lfsr;
input [7:1] x;
begin
   prbs_7__7_6__to_32_lfsr[1] =x[3]^x[7]^x[4]^x[5];
   prbs_7__7_6__to_32_lfsr[2] =x[1]^x[6]^x[7]^x[4]^x[5];
   prbs_7__7_6__to_32_lfsr[3] =x[2]^x[1]^x[6]^x[5];
   prbs_7__7_6__to_32_lfsr[4] =x[2]^x[3]^x[6]^x[7];
   prbs_7__7_6__to_32_lfsr[5] =x[3]^x[1]^x[4];
   prbs_7__7_6__to_32_lfsr[6] =x[2]^x[4]^x[5];
   prbs_7__7_6__to_32_lfsr[7] =x[3]^x[6]^x[5];
end
endfunction
function [7:0] prbs_15__15_14__to_8_dout;
input [15:1] x;
begin
   prbs_15__15_14__to_8_dout[0] =x[15];
   prbs_15__15_14__to_8_dout[1] =x[14];
   prbs_15__15_14__to_8_dout[2] =x[13];
   prbs_15__15_14__to_8_dout[3] =x[12];
   prbs_15__15_14__to_8_dout[4] =x[11];
   prbs_15__15_14__to_8_dout[5] =x[10];
   prbs_15__15_14__to_8_dout[6] =x[9];
   prbs_15__15_14__to_8_dout[7] =x[8];
end
endfunction




function [15:1] prbs_15__15_14__to_8_lfsr;
input [15:1] x;
begin
   prbs_15__15_14__to_8_lfsr[1] =x[8]^x[7];
   prbs_15__15_14__to_8_lfsr[2] =x[8]^x[9];
   prbs_15__15_14__to_8_lfsr[3] =x[10]^x[9];
   prbs_15__15_14__to_8_lfsr[4] =x[10]^x[11];
   prbs_15__15_14__to_8_lfsr[5] =x[11]^x[12];
   prbs_15__15_14__to_8_lfsr[6] =x[12]^x[13];
   prbs_15__15_14__to_8_lfsr[7] =x[13]^x[14];
   prbs_15__15_14__to_8_lfsr[8] =x[14]^x[15];
   prbs_15__15_14__to_8_lfsr[9] =x[1];
   prbs_15__15_14__to_8_lfsr[10] =x[2];
   prbs_15__15_14__to_8_lfsr[11] =x[3];
   prbs_15__15_14__to_8_lfsr[12] =x[4];
   prbs_15__15_14__to_8_lfsr[13] =x[5];
   prbs_15__15_14__to_8_lfsr[14] =x[6];
   prbs_15__15_14__to_8_lfsr[15] =x[7];
end
endfunction
function [9:0] prbs_15__15_14__to_10_dout;
input [15:1] x;
begin
   prbs_15__15_14__to_10_dout[0] =x[15];
   prbs_15__15_14__to_10_dout[1] =x[14];
   prbs_15__15_14__to_10_dout[2] =x[13];
   prbs_15__15_14__to_10_dout[3] =x[12];
   prbs_15__15_14__to_10_dout[4] =x[11];
   prbs_15__15_14__to_10_dout[5] =x[10];
   prbs_15__15_14__to_10_dout[6] =x[9];
   prbs_15__15_14__to_10_dout[7] =x[8];
   prbs_15__15_14__to_10_dout[8] =x[7];
   prbs_15__15_14__to_10_dout[9] =x[6];
end
endfunction




function [15:1] prbs_15__15_14__to_10_lfsr;
input [15:1] x;
begin
   prbs_15__15_14__to_10_lfsr[1] =x[6]^x[5];
   prbs_15__15_14__to_10_lfsr[2] =x[6]^x[7];
   prbs_15__15_14__to_10_lfsr[3] =x[8]^x[7];
   prbs_15__15_14__to_10_lfsr[4] =x[8]^x[9];
   prbs_15__15_14__to_10_lfsr[5] =x[10]^x[9];
   prbs_15__15_14__to_10_lfsr[6] =x[10]^x[11];
   prbs_15__15_14__to_10_lfsr[7] =x[11]^x[12];
   prbs_15__15_14__to_10_lfsr[8] =x[12]^x[13];
   prbs_15__15_14__to_10_lfsr[9] =x[13]^x[14];
   prbs_15__15_14__to_10_lfsr[10] =x[14]^x[15];
   prbs_15__15_14__to_10_lfsr[11] =x[1];
   prbs_15__15_14__to_10_lfsr[12] =x[2];
   prbs_15__15_14__to_10_lfsr[13] =x[3];
   prbs_15__15_14__to_10_lfsr[14] =x[4];
   prbs_15__15_14__to_10_lfsr[15] =x[5];
end
endfunction
function [15:0] prbs_15__15_14__to_16_dout;
input [15:1] x;
begin
   prbs_15__15_14__to_16_dout[0] =x[15];
   prbs_15__15_14__to_16_dout[1] =x[14];
   prbs_15__15_14__to_16_dout[2] =x[13];
   prbs_15__15_14__to_16_dout[3] =x[12];
   prbs_15__15_14__to_16_dout[4] =x[11];
   prbs_15__15_14__to_16_dout[5] =x[10];
   prbs_15__15_14__to_16_dout[6] =x[9];
   prbs_15__15_14__to_16_dout[7] =x[8];
   prbs_15__15_14__to_16_dout[8] =x[7];
   prbs_15__15_14__to_16_dout[9] =x[6];
   prbs_15__15_14__to_16_dout[10] =x[5];
   prbs_15__15_14__to_16_dout[11] =x[4];
   prbs_15__15_14__to_16_dout[12] =x[3];
   prbs_15__15_14__to_16_dout[13] =x[2];
   prbs_15__15_14__to_16_dout[14] =x[1];
   prbs_15__15_14__to_16_dout[15] =x[14]^x[15];
end
endfunction




function [15:1] prbs_15__15_14__to_16_lfsr;
input [15:1] x;
begin
   prbs_15__15_14__to_16_lfsr[1] =x[13]^x[15];
   prbs_15__15_14__to_16_lfsr[2] =x[1]^x[14]^x[15];
   prbs_15__15_14__to_16_lfsr[3] =x[2]^x[1];
   prbs_15__15_14__to_16_lfsr[4] =x[2]^x[3];
   prbs_15__15_14__to_16_lfsr[5] =x[3]^x[4];
   prbs_15__15_14__to_16_lfsr[6] =x[4]^x[5];
   prbs_15__15_14__to_16_lfsr[7] =x[6]^x[5];
   prbs_15__15_14__to_16_lfsr[8] =x[6]^x[7];
   prbs_15__15_14__to_16_lfsr[9] =x[8]^x[7];
   prbs_15__15_14__to_16_lfsr[10] =x[8]^x[9];
   prbs_15__15_14__to_16_lfsr[11] =x[10]^x[9];
   prbs_15__15_14__to_16_lfsr[12] =x[10]^x[11];
   prbs_15__15_14__to_16_lfsr[13] =x[11]^x[12];
   prbs_15__15_14__to_16_lfsr[14] =x[12]^x[13];
   prbs_15__15_14__to_16_lfsr[15] =x[13]^x[14];
end
endfunction
function [19:0] prbs_15__15_14__to_20_dout;
input [15:1] x;
begin
   prbs_15__15_14__to_20_dout[0] =x[15];
   prbs_15__15_14__to_20_dout[1] =x[14];
   prbs_15__15_14__to_20_dout[2] =x[13];
   prbs_15__15_14__to_20_dout[3] =x[12];
   prbs_15__15_14__to_20_dout[4] =x[11];
   prbs_15__15_14__to_20_dout[5] =x[10];
   prbs_15__15_14__to_20_dout[6] =x[9];
   prbs_15__15_14__to_20_dout[7] =x[8];
   prbs_15__15_14__to_20_dout[8] =x[7];
   prbs_15__15_14__to_20_dout[9] =x[6];
   prbs_15__15_14__to_20_dout[10] =x[5];
   prbs_15__15_14__to_20_dout[11] =x[4];
   prbs_15__15_14__to_20_dout[12] =x[3];
   prbs_15__15_14__to_20_dout[13] =x[2];
   prbs_15__15_14__to_20_dout[14] =x[1];
   prbs_15__15_14__to_20_dout[15] =x[14]^x[15];
   prbs_15__15_14__to_20_dout[16] =x[13]^x[14];
   prbs_15__15_14__to_20_dout[17] =x[12]^x[13];
   prbs_15__15_14__to_20_dout[18] =x[11]^x[12];
   prbs_15__15_14__to_20_dout[19] =x[10]^x[11];
end
endfunction




function [15:1] prbs_15__15_14__to_20_lfsr;
input [15:1] x;
begin
   prbs_15__15_14__to_20_lfsr[1] =x[11]^x[9];
   prbs_15__15_14__to_20_lfsr[2] =x[10]^x[12];
   prbs_15__15_14__to_20_lfsr[3] =x[11]^x[13];
   prbs_15__15_14__to_20_lfsr[4] =x[12]^x[14];
   prbs_15__15_14__to_20_lfsr[5] =x[13]^x[15];
   prbs_15__15_14__to_20_lfsr[6] =x[1]^x[14]^x[15];
   prbs_15__15_14__to_20_lfsr[7] =x[2]^x[1];
   prbs_15__15_14__to_20_lfsr[8] =x[2]^x[3];
   prbs_15__15_14__to_20_lfsr[9] =x[3]^x[4];
   prbs_15__15_14__to_20_lfsr[10] =x[4]^x[5];
   prbs_15__15_14__to_20_lfsr[11] =x[6]^x[5];
   prbs_15__15_14__to_20_lfsr[12] =x[6]^x[7];
   prbs_15__15_14__to_20_lfsr[13] =x[8]^x[7];
   prbs_15__15_14__to_20_lfsr[14] =x[8]^x[9];
   prbs_15__15_14__to_20_lfsr[15] =x[10]^x[9];
end
endfunction
function [31:0] prbs_15__15_14__to_32_dout;
input [15:1] x;
begin
   prbs_15__15_14__to_32_dout[0] =x[15];
   prbs_15__15_14__to_32_dout[1] =x[14];
   prbs_15__15_14__to_32_dout[2] =x[13];
   prbs_15__15_14__to_32_dout[3] =x[12];
   prbs_15__15_14__to_32_dout[4] =x[11];
   prbs_15__15_14__to_32_dout[5] =x[10];
   prbs_15__15_14__to_32_dout[6] =x[9];
   prbs_15__15_14__to_32_dout[7] =x[8];
   prbs_15__15_14__to_32_dout[8] =x[7];
   prbs_15__15_14__to_32_dout[9] =x[6];
   prbs_15__15_14__to_32_dout[10] =x[5];
   prbs_15__15_14__to_32_dout[11] =x[4];
   prbs_15__15_14__to_32_dout[12] =x[3];
   prbs_15__15_14__to_32_dout[13] =x[2];
   prbs_15__15_14__to_32_dout[14] =x[1];
   prbs_15__15_14__to_32_dout[15] =x[14]^x[15];
   prbs_15__15_14__to_32_dout[16] =x[13]^x[14];
   prbs_15__15_14__to_32_dout[17] =x[12]^x[13];
   prbs_15__15_14__to_32_dout[18] =x[11]^x[12];
   prbs_15__15_14__to_32_dout[19] =x[10]^x[11];
   prbs_15__15_14__to_32_dout[20] =x[10]^x[9];
   prbs_15__15_14__to_32_dout[21] =x[8]^x[9];
   prbs_15__15_14__to_32_dout[22] =x[8]^x[7];
   prbs_15__15_14__to_32_dout[23] =x[6]^x[7];
   prbs_15__15_14__to_32_dout[24] =x[6]^x[5];
   prbs_15__15_14__to_32_dout[25] =x[4]^x[5];
   prbs_15__15_14__to_32_dout[26] =x[3]^x[4];
   prbs_15__15_14__to_32_dout[27] =x[2]^x[3];
   prbs_15__15_14__to_32_dout[28] =x[2]^x[1];
   prbs_15__15_14__to_32_dout[29] =x[1]^x[14]^x[15];
   prbs_15__15_14__to_32_dout[30] =x[13]^x[15];
   prbs_15__15_14__to_32_dout[31] =x[12]^x[14];
end
endfunction




function [15:1] prbs_15__15_14__to_32_lfsr;
input [15:1] x;
begin
   prbs_15__15_14__to_32_lfsr[1] =x[11]^x[12]^x[13]^x[14];
   prbs_15__15_14__to_32_lfsr[2] =x[12]^x[13]^x[14]^x[15];
   prbs_15__15_14__to_32_lfsr[3] =x[13]^x[1]^x[14];
   prbs_15__15_14__to_32_lfsr[4] =x[2]^x[14]^x[15];
   prbs_15__15_14__to_32_lfsr[5] =x[3]^x[1];
   prbs_15__15_14__to_32_lfsr[6] =x[2]^x[4];
   prbs_15__15_14__to_32_lfsr[7] =x[3]^x[5];
   prbs_15__15_14__to_32_lfsr[8] =x[6]^x[4];
   prbs_15__15_14__to_32_lfsr[9] =x[7]^x[5];
   prbs_15__15_14__to_32_lfsr[10] =x[8]^x[6];
   prbs_15__15_14__to_32_lfsr[11] =x[9]^x[7];
   prbs_15__15_14__to_32_lfsr[12] =x[10]^x[8];
   prbs_15__15_14__to_32_lfsr[13] =x[11]^x[9];
   prbs_15__15_14__to_32_lfsr[14] =x[10]^x[12];
   prbs_15__15_14__to_32_lfsr[15] =x[11]^x[13];
end
endfunction
function [7:0] prbs_23__23_18__to_8_dout;
input [23:1] x;
begin
   prbs_23__23_18__to_8_dout[0] =x[23];
   prbs_23__23_18__to_8_dout[1] =x[22];
   prbs_23__23_18__to_8_dout[2] =x[21];
   prbs_23__23_18__to_8_dout[3] =x[20];
   prbs_23__23_18__to_8_dout[4] =x[19];
   prbs_23__23_18__to_8_dout[5] =x[18];
   prbs_23__23_18__to_8_dout[6] =x[17];
   prbs_23__23_18__to_8_dout[7] =x[16];
end
endfunction




function [23:1] prbs_23__23_18__to_8_lfsr;
input [23:1] x;
begin
   prbs_23__23_18__to_8_lfsr[1] =x[11]^x[16];
   prbs_23__23_18__to_8_lfsr[2] =x[12]^x[17];
   prbs_23__23_18__to_8_lfsr[3] =x[18]^x[13];
   prbs_23__23_18__to_8_lfsr[4] =x[19]^x[14];
   prbs_23__23_18__to_8_lfsr[5] =x[20]^x[15];
   prbs_23__23_18__to_8_lfsr[6] =x[21]^x[16];
   prbs_23__23_18__to_8_lfsr[7] =x[17]^x[22];
   prbs_23__23_18__to_8_lfsr[8] =x[18]^x[23];
   prbs_23__23_18__to_8_lfsr[9] =x[1];
   prbs_23__23_18__to_8_lfsr[10] =x[2];
   prbs_23__23_18__to_8_lfsr[11] =x[3];
   prbs_23__23_18__to_8_lfsr[12] =x[4];
   prbs_23__23_18__to_8_lfsr[13] =x[5];
   prbs_23__23_18__to_8_lfsr[14] =x[6];
   prbs_23__23_18__to_8_lfsr[15] =x[7];
   prbs_23__23_18__to_8_lfsr[16] =x[8];
   prbs_23__23_18__to_8_lfsr[17] =x[9];
   prbs_23__23_18__to_8_lfsr[18] =x[10];
   prbs_23__23_18__to_8_lfsr[19] =x[11];
   prbs_23__23_18__to_8_lfsr[20] =x[12];
   prbs_23__23_18__to_8_lfsr[21] =x[13];
   prbs_23__23_18__to_8_lfsr[22] =x[14];
   prbs_23__23_18__to_8_lfsr[23] =x[15];
end
endfunction
function [9:0] prbs_23__23_18__to_10_dout;
input [23:1] x;
begin
   prbs_23__23_18__to_10_dout[0] =x[23];
   prbs_23__23_18__to_10_dout[1] =x[22];
   prbs_23__23_18__to_10_dout[2] =x[21];
   prbs_23__23_18__to_10_dout[3] =x[20];
   prbs_23__23_18__to_10_dout[4] =x[19];
   prbs_23__23_18__to_10_dout[5] =x[18];
   prbs_23__23_18__to_10_dout[6] =x[17];
   prbs_23__23_18__to_10_dout[7] =x[16];
   prbs_23__23_18__to_10_dout[8] =x[15];
   prbs_23__23_18__to_10_dout[9] =x[14];
end
endfunction




function [23:1] prbs_23__23_18__to_10_lfsr;
input [23:1] x;
begin
   prbs_23__23_18__to_10_lfsr[1] =x[9]^x[14];
   prbs_23__23_18__to_10_lfsr[2] =x[10]^x[15];
   prbs_23__23_18__to_10_lfsr[3] =x[11]^x[16];
   prbs_23__23_18__to_10_lfsr[4] =x[12]^x[17];
   prbs_23__23_18__to_10_lfsr[5] =x[18]^x[13];
   prbs_23__23_18__to_10_lfsr[6] =x[19]^x[14];
   prbs_23__23_18__to_10_lfsr[7] =x[20]^x[15];
   prbs_23__23_18__to_10_lfsr[8] =x[21]^x[16];
   prbs_23__23_18__to_10_lfsr[9] =x[17]^x[22];
   prbs_23__23_18__to_10_lfsr[10] =x[18]^x[23];
   prbs_23__23_18__to_10_lfsr[11] =x[1];
   prbs_23__23_18__to_10_lfsr[12] =x[2];
   prbs_23__23_18__to_10_lfsr[13] =x[3];
   prbs_23__23_18__to_10_lfsr[14] =x[4];
   prbs_23__23_18__to_10_lfsr[15] =x[5];
   prbs_23__23_18__to_10_lfsr[16] =x[6];
   prbs_23__23_18__to_10_lfsr[17] =x[7];
   prbs_23__23_18__to_10_lfsr[18] =x[8];
   prbs_23__23_18__to_10_lfsr[19] =x[9];
   prbs_23__23_18__to_10_lfsr[20] =x[10];
   prbs_23__23_18__to_10_lfsr[21] =x[11];
   prbs_23__23_18__to_10_lfsr[22] =x[12];
   prbs_23__23_18__to_10_lfsr[23] =x[13];
end
endfunction
function [15:0] prbs_23__23_18__to_16_dout;
input [23:1] x;
begin
   prbs_23__23_18__to_16_dout[0] =x[23];
   prbs_23__23_18__to_16_dout[1] =x[22];
   prbs_23__23_18__to_16_dout[2] =x[21];
   prbs_23__23_18__to_16_dout[3] =x[20];
   prbs_23__23_18__to_16_dout[4] =x[19];
   prbs_23__23_18__to_16_dout[5] =x[18];
   prbs_23__23_18__to_16_dout[6] =x[17];
   prbs_23__23_18__to_16_dout[7] =x[16];
   prbs_23__23_18__to_16_dout[8] =x[15];
   prbs_23__23_18__to_16_dout[9] =x[14];
   prbs_23__23_18__to_16_dout[10] =x[13];
   prbs_23__23_18__to_16_dout[11] =x[12];
   prbs_23__23_18__to_16_dout[12] =x[11];
   prbs_23__23_18__to_16_dout[13] =x[10];
   prbs_23__23_18__to_16_dout[14] =x[9];
   prbs_23__23_18__to_16_dout[15] =x[8];
end
endfunction




function [23:1] prbs_23__23_18__to_16_lfsr;
input [23:1] x;
begin
   prbs_23__23_18__to_16_lfsr[1] =x[3]^x[8];
   prbs_23__23_18__to_16_lfsr[2] =x[9]^x[4];
   prbs_23__23_18__to_16_lfsr[3] =x[10]^x[5];
   prbs_23__23_18__to_16_lfsr[4] =x[11]^x[6];
   prbs_23__23_18__to_16_lfsr[5] =x[12]^x[7];
   prbs_23__23_18__to_16_lfsr[6] =x[8]^x[13];
   prbs_23__23_18__to_16_lfsr[7] =x[9]^x[14];
   prbs_23__23_18__to_16_lfsr[8] =x[10]^x[15];
   prbs_23__23_18__to_16_lfsr[9] =x[11]^x[16];
   prbs_23__23_18__to_16_lfsr[10] =x[12]^x[17];
   prbs_23__23_18__to_16_lfsr[11] =x[18]^x[13];
   prbs_23__23_18__to_16_lfsr[12] =x[19]^x[14];
   prbs_23__23_18__to_16_lfsr[13] =x[20]^x[15];
   prbs_23__23_18__to_16_lfsr[14] =x[21]^x[16];
   prbs_23__23_18__to_16_lfsr[15] =x[17]^x[22];
   prbs_23__23_18__to_16_lfsr[16] =x[18]^x[23];
   prbs_23__23_18__to_16_lfsr[17] =x[1];
   prbs_23__23_18__to_16_lfsr[18] =x[2];
   prbs_23__23_18__to_16_lfsr[19] =x[3];
   prbs_23__23_18__to_16_lfsr[20] =x[4];
   prbs_23__23_18__to_16_lfsr[21] =x[5];
   prbs_23__23_18__to_16_lfsr[22] =x[6];
   prbs_23__23_18__to_16_lfsr[23] =x[7];
end
endfunction
function [19:0] prbs_23__23_18__to_20_dout;
input [23:1] x;
begin
   prbs_23__23_18__to_20_dout[0] =x[23];
   prbs_23__23_18__to_20_dout[1] =x[22];
   prbs_23__23_18__to_20_dout[2] =x[21];
   prbs_23__23_18__to_20_dout[3] =x[20];
   prbs_23__23_18__to_20_dout[4] =x[19];
   prbs_23__23_18__to_20_dout[5] =x[18];
   prbs_23__23_18__to_20_dout[6] =x[17];
   prbs_23__23_18__to_20_dout[7] =x[16];
   prbs_23__23_18__to_20_dout[8] =x[15];
   prbs_23__23_18__to_20_dout[9] =x[14];
   prbs_23__23_18__to_20_dout[10] =x[13];
   prbs_23__23_18__to_20_dout[11] =x[12];
   prbs_23__23_18__to_20_dout[12] =x[11];
   prbs_23__23_18__to_20_dout[13] =x[10];
   prbs_23__23_18__to_20_dout[14] =x[9];
   prbs_23__23_18__to_20_dout[15] =x[8];
   prbs_23__23_18__to_20_dout[16] =x[7];
   prbs_23__23_18__to_20_dout[17] =x[6];
   prbs_23__23_18__to_20_dout[18] =x[5];
   prbs_23__23_18__to_20_dout[19] =x[4];
end
endfunction




function [23:1] prbs_23__23_18__to_20_lfsr;
input [23:1] x;
begin
   prbs_23__23_18__to_20_lfsr[1] =x[17]^x[4]^x[22];
   prbs_23__23_18__to_20_lfsr[2] =x[18]^x[23]^x[5];
   prbs_23__23_18__to_20_lfsr[3] =x[1]^x[6];
   prbs_23__23_18__to_20_lfsr[4] =x[2]^x[7];
   prbs_23__23_18__to_20_lfsr[5] =x[3]^x[8];
   prbs_23__23_18__to_20_lfsr[6] =x[9]^x[4];
   prbs_23__23_18__to_20_lfsr[7] =x[10]^x[5];
   prbs_23__23_18__to_20_lfsr[8] =x[11]^x[6];
   prbs_23__23_18__to_20_lfsr[9] =x[12]^x[7];
   prbs_23__23_18__to_20_lfsr[10] =x[8]^x[13];
   prbs_23__23_18__to_20_lfsr[11] =x[9]^x[14];
   prbs_23__23_18__to_20_lfsr[12] =x[10]^x[15];
   prbs_23__23_18__to_20_lfsr[13] =x[11]^x[16];
   prbs_23__23_18__to_20_lfsr[14] =x[12]^x[17];
   prbs_23__23_18__to_20_lfsr[15] =x[18]^x[13];
   prbs_23__23_18__to_20_lfsr[16] =x[19]^x[14];
   prbs_23__23_18__to_20_lfsr[17] =x[20]^x[15];
   prbs_23__23_18__to_20_lfsr[18] =x[21]^x[16];
   prbs_23__23_18__to_20_lfsr[19] =x[17]^x[22];
   prbs_23__23_18__to_20_lfsr[20] =x[18]^x[23];
   prbs_23__23_18__to_20_lfsr[21] =x[1];
   prbs_23__23_18__to_20_lfsr[22] =x[2];
   prbs_23__23_18__to_20_lfsr[23] =x[3];
end
endfunction
function [31:0] prbs_23__23_18__to_32_dout;
input [23:1] x;
begin
   prbs_23__23_18__to_32_dout[0] =x[23];
   prbs_23__23_18__to_32_dout[1] =x[22];
   prbs_23__23_18__to_32_dout[2] =x[21];
   prbs_23__23_18__to_32_dout[3] =x[20];
   prbs_23__23_18__to_32_dout[4] =x[19];
   prbs_23__23_18__to_32_dout[5] =x[18];
   prbs_23__23_18__to_32_dout[6] =x[17];
   prbs_23__23_18__to_32_dout[7] =x[16];
   prbs_23__23_18__to_32_dout[8] =x[15];
   prbs_23__23_18__to_32_dout[9] =x[14];
   prbs_23__23_18__to_32_dout[10] =x[13];
   prbs_23__23_18__to_32_dout[11] =x[12];
   prbs_23__23_18__to_32_dout[12] =x[11];
   prbs_23__23_18__to_32_dout[13] =x[10];
   prbs_23__23_18__to_32_dout[14] =x[9];
   prbs_23__23_18__to_32_dout[15] =x[8];
   prbs_23__23_18__to_32_dout[16] =x[7];
   prbs_23__23_18__to_32_dout[17] =x[6];
   prbs_23__23_18__to_32_dout[18] =x[5];
   prbs_23__23_18__to_32_dout[19] =x[4];
   prbs_23__23_18__to_32_dout[20] =x[3];
   prbs_23__23_18__to_32_dout[21] =x[2];
   prbs_23__23_18__to_32_dout[22] =x[1];
   prbs_23__23_18__to_32_dout[23] =x[18]^x[23];
   prbs_23__23_18__to_32_dout[24] =x[17]^x[22];
   prbs_23__23_18__to_32_dout[25] =x[21]^x[16];
   prbs_23__23_18__to_32_dout[26] =x[20]^x[15];
   prbs_23__23_18__to_32_dout[27] =x[19]^x[14];
   prbs_23__23_18__to_32_dout[28] =x[18]^x[13];
   prbs_23__23_18__to_32_dout[29] =x[12]^x[17];
   prbs_23__23_18__to_32_dout[30] =x[11]^x[16];
   prbs_23__23_18__to_32_dout[31] =x[10]^x[15];
end
endfunction




function [23:1] prbs_23__23_18__to_32_lfsr;
input [23:1] x;
begin
   prbs_23__23_18__to_32_lfsr[1] =x[15]^x[5];
   prbs_23__23_18__to_32_lfsr[2] =x[6]^x[16];
   prbs_23__23_18__to_32_lfsr[3] =x[7]^x[17];
   prbs_23__23_18__to_32_lfsr[4] =x[18]^x[8];
   prbs_23__23_18__to_32_lfsr[5] =x[19]^x[9];
   prbs_23__23_18__to_32_lfsr[6] =x[10]^x[20];
   prbs_23__23_18__to_32_lfsr[7] =x[11]^x[21];
   prbs_23__23_18__to_32_lfsr[8] =x[12]^x[22];
   prbs_23__23_18__to_32_lfsr[9] =x[13]^x[23];
   prbs_23__23_18__to_32_lfsr[10] =x[19]^x[1]^x[14];
   prbs_23__23_18__to_32_lfsr[11] =x[2]^x[20]^x[15];
   prbs_23__23_18__to_32_lfsr[12] =x[3]^x[21]^x[16];
   prbs_23__23_18__to_32_lfsr[13] =x[17]^x[4]^x[22];
   prbs_23__23_18__to_32_lfsr[14] =x[18]^x[23]^x[5];
   prbs_23__23_18__to_32_lfsr[15] =x[1]^x[6];
   prbs_23__23_18__to_32_lfsr[16] =x[2]^x[7];
   prbs_23__23_18__to_32_lfsr[17] =x[3]^x[8];
   prbs_23__23_18__to_32_lfsr[18] =x[9]^x[4];
   prbs_23__23_18__to_32_lfsr[19] =x[10]^x[5];
   prbs_23__23_18__to_32_lfsr[20] =x[11]^x[6];
   prbs_23__23_18__to_32_lfsr[21] =x[12]^x[7];
   prbs_23__23_18__to_32_lfsr[22] =x[8]^x[13];
   prbs_23__23_18__to_32_lfsr[23] =x[9]^x[14];
end
endfunction
function [7:0] prbs_31__31_28__to_8_dout;
input [31:1] x;
begin
   prbs_31__31_28__to_8_dout[0] =x[31];
   prbs_31__31_28__to_8_dout[1] =x[30];
   prbs_31__31_28__to_8_dout[2] =x[29];
   prbs_31__31_28__to_8_dout[3] =x[28];
   prbs_31__31_28__to_8_dout[4] =x[27];
   prbs_31__31_28__to_8_dout[5] =x[26];
   prbs_31__31_28__to_8_dout[6] =x[25];
   prbs_31__31_28__to_8_dout[7] =x[24];
end
endfunction




function [31:1] prbs_31__31_28__to_8_lfsr;
input [31:1] x;
begin
   prbs_31__31_28__to_8_lfsr[1] =x[24]^x[21];
   prbs_31__31_28__to_8_lfsr[2] =x[25]^x[22];
   prbs_31__31_28__to_8_lfsr[3] =x[26]^x[23];
   prbs_31__31_28__to_8_lfsr[4] =x[24]^x[27];
   prbs_31__31_28__to_8_lfsr[5] =x[25]^x[28];
   prbs_31__31_28__to_8_lfsr[6] =x[26]^x[29];
   prbs_31__31_28__to_8_lfsr[7] =x[30]^x[27];
   prbs_31__31_28__to_8_lfsr[8] =x[31]^x[28];
   prbs_31__31_28__to_8_lfsr[9] =x[1];
   prbs_31__31_28__to_8_lfsr[10] =x[2];
   prbs_31__31_28__to_8_lfsr[11] =x[3];
   prbs_31__31_28__to_8_lfsr[12] =x[4];
   prbs_31__31_28__to_8_lfsr[13] =x[5];
   prbs_31__31_28__to_8_lfsr[14] =x[6];
   prbs_31__31_28__to_8_lfsr[15] =x[7];
   prbs_31__31_28__to_8_lfsr[16] =x[8];
   prbs_31__31_28__to_8_lfsr[17] =x[9];
   prbs_31__31_28__to_8_lfsr[18] =x[10];
   prbs_31__31_28__to_8_lfsr[19] =x[11];
   prbs_31__31_28__to_8_lfsr[20] =x[12];
   prbs_31__31_28__to_8_lfsr[21] =x[13];
   prbs_31__31_28__to_8_lfsr[22] =x[14];
   prbs_31__31_28__to_8_lfsr[23] =x[15];
   prbs_31__31_28__to_8_lfsr[24] =x[16];
   prbs_31__31_28__to_8_lfsr[25] =x[17];
   prbs_31__31_28__to_8_lfsr[26] =x[18];
   prbs_31__31_28__to_8_lfsr[27] =x[19];
   prbs_31__31_28__to_8_lfsr[28] =x[20];
   prbs_31__31_28__to_8_lfsr[29] =x[21];
   prbs_31__31_28__to_8_lfsr[30] =x[22];
   prbs_31__31_28__to_8_lfsr[31] =x[23];
end
endfunction
function [9:0] prbs_31__31_28__to_10_dout;
input [31:1] x;
begin
   prbs_31__31_28__to_10_dout[0] =x[31];
   prbs_31__31_28__to_10_dout[1] =x[30];
   prbs_31__31_28__to_10_dout[2] =x[29];
   prbs_31__31_28__to_10_dout[3] =x[28];
   prbs_31__31_28__to_10_dout[4] =x[27];
   prbs_31__31_28__to_10_dout[5] =x[26];
   prbs_31__31_28__to_10_dout[6] =x[25];
   prbs_31__31_28__to_10_dout[7] =x[24];
   prbs_31__31_28__to_10_dout[8] =x[23];
   prbs_31__31_28__to_10_dout[9] =x[22];
end
endfunction




function [31:1] prbs_31__31_28__to_10_lfsr;
input [31:1] x;
begin
   prbs_31__31_28__to_10_lfsr[1] =x[19]^x[22];
   prbs_31__31_28__to_10_lfsr[2] =x[20]^x[23];
   prbs_31__31_28__to_10_lfsr[3] =x[24]^x[21];
   prbs_31__31_28__to_10_lfsr[4] =x[25]^x[22];
   prbs_31__31_28__to_10_lfsr[5] =x[26]^x[23];
   prbs_31__31_28__to_10_lfsr[6] =x[24]^x[27];
   prbs_31__31_28__to_10_lfsr[7] =x[25]^x[28];
   prbs_31__31_28__to_10_lfsr[8] =x[26]^x[29];
   prbs_31__31_28__to_10_lfsr[9] =x[30]^x[27];
   prbs_31__31_28__to_10_lfsr[10] =x[31]^x[28];
   prbs_31__31_28__to_10_lfsr[11] =x[1];
   prbs_31__31_28__to_10_lfsr[12] =x[2];
   prbs_31__31_28__to_10_lfsr[13] =x[3];
   prbs_31__31_28__to_10_lfsr[14] =x[4];
   prbs_31__31_28__to_10_lfsr[15] =x[5];
   prbs_31__31_28__to_10_lfsr[16] =x[6];
   prbs_31__31_28__to_10_lfsr[17] =x[7];
   prbs_31__31_28__to_10_lfsr[18] =x[8];
   prbs_31__31_28__to_10_lfsr[19] =x[9];
   prbs_31__31_28__to_10_lfsr[20] =x[10];
   prbs_31__31_28__to_10_lfsr[21] =x[11];
   prbs_31__31_28__to_10_lfsr[22] =x[12];
   prbs_31__31_28__to_10_lfsr[23] =x[13];
   prbs_31__31_28__to_10_lfsr[24] =x[14];
   prbs_31__31_28__to_10_lfsr[25] =x[15];
   prbs_31__31_28__to_10_lfsr[26] =x[16];
   prbs_31__31_28__to_10_lfsr[27] =x[17];
   prbs_31__31_28__to_10_lfsr[28] =x[18];
   prbs_31__31_28__to_10_lfsr[29] =x[19];
   prbs_31__31_28__to_10_lfsr[30] =x[20];
   prbs_31__31_28__to_10_lfsr[31] =x[21];
end
endfunction
function [15:0] prbs_31__31_28__to_16_dout;
input [31:1] x;
begin
   prbs_31__31_28__to_16_dout[0] =x[31];
   prbs_31__31_28__to_16_dout[1] =x[30];
   prbs_31__31_28__to_16_dout[2] =x[29];
   prbs_31__31_28__to_16_dout[3] =x[28];
   prbs_31__31_28__to_16_dout[4] =x[27];
   prbs_31__31_28__to_16_dout[5] =x[26];
   prbs_31__31_28__to_16_dout[6] =x[25];
   prbs_31__31_28__to_16_dout[7] =x[24];
   prbs_31__31_28__to_16_dout[8] =x[23];
   prbs_31__31_28__to_16_dout[9] =x[22];
   prbs_31__31_28__to_16_dout[10] =x[21];
   prbs_31__31_28__to_16_dout[11] =x[20];
   prbs_31__31_28__to_16_dout[12] =x[19];
   prbs_31__31_28__to_16_dout[13] =x[18];
   prbs_31__31_28__to_16_dout[14] =x[17];
   prbs_31__31_28__to_16_dout[15] =x[16];
end
endfunction




function [31:1] prbs_31__31_28__to_16_lfsr;
input [31:1] x;
begin
   prbs_31__31_28__to_16_lfsr[1] =x[13]^x[16];
   prbs_31__31_28__to_16_lfsr[2] =x[14]^x[17];
   prbs_31__31_28__to_16_lfsr[3] =x[18]^x[15];
   prbs_31__31_28__to_16_lfsr[4] =x[19]^x[16];
   prbs_31__31_28__to_16_lfsr[5] =x[20]^x[17];
   prbs_31__31_28__to_16_lfsr[6] =x[18]^x[21];
   prbs_31__31_28__to_16_lfsr[7] =x[19]^x[22];
   prbs_31__31_28__to_16_lfsr[8] =x[20]^x[23];
   prbs_31__31_28__to_16_lfsr[9] =x[24]^x[21];
   prbs_31__31_28__to_16_lfsr[10] =x[25]^x[22];
   prbs_31__31_28__to_16_lfsr[11] =x[26]^x[23];
   prbs_31__31_28__to_16_lfsr[12] =x[24]^x[27];
   prbs_31__31_28__to_16_lfsr[13] =x[25]^x[28];
   prbs_31__31_28__to_16_lfsr[14] =x[26]^x[29];
   prbs_31__31_28__to_16_lfsr[15] =x[30]^x[27];
   prbs_31__31_28__to_16_lfsr[16] =x[31]^x[28];
   prbs_31__31_28__to_16_lfsr[17] =x[1];
   prbs_31__31_28__to_16_lfsr[18] =x[2];
   prbs_31__31_28__to_16_lfsr[19] =x[3];
   prbs_31__31_28__to_16_lfsr[20] =x[4];
   prbs_31__31_28__to_16_lfsr[21] =x[5];
   prbs_31__31_28__to_16_lfsr[22] =x[6];
   prbs_31__31_28__to_16_lfsr[23] =x[7];
   prbs_31__31_28__to_16_lfsr[24] =x[8];
   prbs_31__31_28__to_16_lfsr[25] =x[9];
   prbs_31__31_28__to_16_lfsr[26] =x[10];
   prbs_31__31_28__to_16_lfsr[27] =x[11];
   prbs_31__31_28__to_16_lfsr[28] =x[12];
   prbs_31__31_28__to_16_lfsr[29] =x[13];
   prbs_31__31_28__to_16_lfsr[30] =x[14];
   prbs_31__31_28__to_16_lfsr[31] =x[15];
end
endfunction
function [19:0] prbs_31__31_28__to_20_dout;
input [31:1] x;
begin
   prbs_31__31_28__to_20_dout[0] =x[31];
   prbs_31__31_28__to_20_dout[1] =x[30];
   prbs_31__31_28__to_20_dout[2] =x[29];
   prbs_31__31_28__to_20_dout[3] =x[28];
   prbs_31__31_28__to_20_dout[4] =x[27];
   prbs_31__31_28__to_20_dout[5] =x[26];
   prbs_31__31_28__to_20_dout[6] =x[25];
   prbs_31__31_28__to_20_dout[7] =x[24];
   prbs_31__31_28__to_20_dout[8] =x[23];
   prbs_31__31_28__to_20_dout[9] =x[22];
   prbs_31__31_28__to_20_dout[10] =x[21];
   prbs_31__31_28__to_20_dout[11] =x[20];
   prbs_31__31_28__to_20_dout[12] =x[19];
   prbs_31__31_28__to_20_dout[13] =x[18];
   prbs_31__31_28__to_20_dout[14] =x[17];
   prbs_31__31_28__to_20_dout[15] =x[16];
   prbs_31__31_28__to_20_dout[16] =x[15];
   prbs_31__31_28__to_20_dout[17] =x[14];
   prbs_31__31_28__to_20_dout[18] =x[13];
   prbs_31__31_28__to_20_dout[19] =x[12];
end
endfunction




function [31:1] prbs_31__31_28__to_20_lfsr;
input [31:1] x;
begin
   prbs_31__31_28__to_20_lfsr[1] =x[12]^x[9];
   prbs_31__31_28__to_20_lfsr[2] =x[10]^x[13];
   prbs_31__31_28__to_20_lfsr[3] =x[11]^x[14];
   prbs_31__31_28__to_20_lfsr[4] =x[12]^x[15];
   prbs_31__31_28__to_20_lfsr[5] =x[13]^x[16];
   prbs_31__31_28__to_20_lfsr[6] =x[14]^x[17];
   prbs_31__31_28__to_20_lfsr[7] =x[18]^x[15];
   prbs_31__31_28__to_20_lfsr[8] =x[19]^x[16];
   prbs_31__31_28__to_20_lfsr[9] =x[20]^x[17];
   prbs_31__31_28__to_20_lfsr[10] =x[18]^x[21];
   prbs_31__31_28__to_20_lfsr[11] =x[19]^x[22];
   prbs_31__31_28__to_20_lfsr[12] =x[20]^x[23];
   prbs_31__31_28__to_20_lfsr[13] =x[24]^x[21];
   prbs_31__31_28__to_20_lfsr[14] =x[25]^x[22];
   prbs_31__31_28__to_20_lfsr[15] =x[26]^x[23];
   prbs_31__31_28__to_20_lfsr[16] =x[24]^x[27];
   prbs_31__31_28__to_20_lfsr[17] =x[25]^x[28];
   prbs_31__31_28__to_20_lfsr[18] =x[26]^x[29];
   prbs_31__31_28__to_20_lfsr[19] =x[30]^x[27];
   prbs_31__31_28__to_20_lfsr[20] =x[31]^x[28];
   prbs_31__31_28__to_20_lfsr[21] =x[1];
   prbs_31__31_28__to_20_lfsr[22] =x[2];
   prbs_31__31_28__to_20_lfsr[23] =x[3];
   prbs_31__31_28__to_20_lfsr[24] =x[4];
   prbs_31__31_28__to_20_lfsr[25] =x[5];
   prbs_31__31_28__to_20_lfsr[26] =x[6];
   prbs_31__31_28__to_20_lfsr[27] =x[7];
   prbs_31__31_28__to_20_lfsr[28] =x[8];
   prbs_31__31_28__to_20_lfsr[29] =x[9];
   prbs_31__31_28__to_20_lfsr[30] =x[10];
   prbs_31__31_28__to_20_lfsr[31] =x[11];
end
endfunction
function [31:0] prbs_31__31_28__to_32_dout;
input [31:1] x;
begin
   prbs_31__31_28__to_32_dout[0] =x[31];
   prbs_31__31_28__to_32_dout[1] =x[30];
   prbs_31__31_28__to_32_dout[2] =x[29];
   prbs_31__31_28__to_32_dout[3] =x[28];
   prbs_31__31_28__to_32_dout[4] =x[27];
   prbs_31__31_28__to_32_dout[5] =x[26];
   prbs_31__31_28__to_32_dout[6] =x[25];
   prbs_31__31_28__to_32_dout[7] =x[24];
   prbs_31__31_28__to_32_dout[8] =x[23];
   prbs_31__31_28__to_32_dout[9] =x[22];
   prbs_31__31_28__to_32_dout[10] =x[21];
   prbs_31__31_28__to_32_dout[11] =x[20];
   prbs_31__31_28__to_32_dout[12] =x[19];
   prbs_31__31_28__to_32_dout[13] =x[18];
   prbs_31__31_28__to_32_dout[14] =x[17];
   prbs_31__31_28__to_32_dout[15] =x[16];
   prbs_31__31_28__to_32_dout[16] =x[15];
   prbs_31__31_28__to_32_dout[17] =x[14];
   prbs_31__31_28__to_32_dout[18] =x[13];
   prbs_31__31_28__to_32_dout[19] =x[12];
   prbs_31__31_28__to_32_dout[20] =x[11];
   prbs_31__31_28__to_32_dout[21] =x[10];
   prbs_31__31_28__to_32_dout[22] =x[9];
   prbs_31__31_28__to_32_dout[23] =x[8];
   prbs_31__31_28__to_32_dout[24] =x[7];
   prbs_31__31_28__to_32_dout[25] =x[6];
   prbs_31__31_28__to_32_dout[26] =x[5];
   prbs_31__31_28__to_32_dout[27] =x[4];
   prbs_31__31_28__to_32_dout[28] =x[3];
   prbs_31__31_28__to_32_dout[29] =x[2];
   prbs_31__31_28__to_32_dout[30] =x[1];
   prbs_31__31_28__to_32_dout[31] =x[31]^x[28];
end
endfunction




function [31:1] prbs_31__31_28__to_32_lfsr;
input [31:1] x;
begin
   prbs_31__31_28__to_32_lfsr[1] =x[25]^x[31];
   prbs_31__31_28__to_32_lfsr[2] =x[1]^x[29]^x[26];
   prbs_31__31_28__to_32_lfsr[3] =x[2]^x[30]^x[27];
   prbs_31__31_28__to_32_lfsr[4] =x[3]^x[31]^x[28];
   prbs_31__31_28__to_32_lfsr[5] =x[1]^x[4];
   prbs_31__31_28__to_32_lfsr[6] =x[2]^x[5];
   prbs_31__31_28__to_32_lfsr[7] =x[3]^x[6];
   prbs_31__31_28__to_32_lfsr[8] =x[7]^x[4];
   prbs_31__31_28__to_32_lfsr[9] =x[8]^x[5];
   prbs_31__31_28__to_32_lfsr[10] =x[9]^x[6];
   prbs_31__31_28__to_32_lfsr[11] =x[10]^x[7];
   prbs_31__31_28__to_32_lfsr[12] =x[11]^x[8];
   prbs_31__31_28__to_32_lfsr[13] =x[12]^x[9];
   prbs_31__31_28__to_32_lfsr[14] =x[10]^x[13];
   prbs_31__31_28__to_32_lfsr[15] =x[11]^x[14];
   prbs_31__31_28__to_32_lfsr[16] =x[12]^x[15];
   prbs_31__31_28__to_32_lfsr[17] =x[13]^x[16];
   prbs_31__31_28__to_32_lfsr[18] =x[14]^x[17];
   prbs_31__31_28__to_32_lfsr[19] =x[18]^x[15];
   prbs_31__31_28__to_32_lfsr[20] =x[19]^x[16];
   prbs_31__31_28__to_32_lfsr[21] =x[20]^x[17];
   prbs_31__31_28__to_32_lfsr[22] =x[18]^x[21];
   prbs_31__31_28__to_32_lfsr[23] =x[19]^x[22];
   prbs_31__31_28__to_32_lfsr[24] =x[20]^x[23];
   prbs_31__31_28__to_32_lfsr[25] =x[24]^x[21];
   prbs_31__31_28__to_32_lfsr[26] =x[25]^x[22];
   prbs_31__31_28__to_32_lfsr[27] =x[26]^x[23];
   prbs_31__31_28__to_32_lfsr[28] =x[24]^x[27];
   prbs_31__31_28__to_32_lfsr[29] =x[25]^x[28];
   prbs_31__31_28__to_32_lfsr[30] =x[26]^x[29];
   prbs_31__31_28__to_32_lfsr[31] =x[30]^x[27];
end
endfunction


endmodule


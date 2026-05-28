////////////////////////////////////////////////////////
//
//  Module: RegBlk
//  Project: BRIGHTON
//  Description: 
// 
//  Change history: 
//
////////////////////////////////////////////////////////
`timescale 1ns/10ps

`include "defines.inc"

module RegBlk #(
parameter	D_D			= 8,	//Depth
parameter	D_W			= 8		//Width
) (
input wire									I_RSTN				,
input wire									I_CLK				,
input wire									I_CEN				,
input wire									I_WEN				,
input wire [$clog2(D_D)-1:0]				I_ADDR				,
input wire [D_W-1:0]						I_DIN				,
output reg [D_W-1:0]						O_DOUT				,
output wire [`WID_TRIM_BGR			-1:0]	O_TRIM_BGR			,
output wire [`WID_TRIM_BIAS			-1:0]	O_TRIM_BIAS			,
output wire [`WID_TRIM_HS2LS_DT		-1:0]	O_TRIM_HS2LS_DT		,
output wire [`WID_TRIM_TSD_REFH		-1:0]	O_TRIM_TSD_REFH		,
output wire [`WID_TRIM_TSD_REFL		-1:0]	O_TRIM_TSD_REFL		,
output wire [`WID_TRIM_INJ_C		-1:0]	O_TRIM_INJ_C		,
output wire [`WID_TRIM_INJ_R		-1:0]	O_TRIM_INJ_R		,
output wire [`WID_TRIM_ZCD_SEN		-1:0]	O_TRIM_ZCD_SEN		,
output wire [`WID_TRIM_ZCD_REF		-1:0]	O_TRIM_ZCD_REF		,
output wire [`WID_TRIM_OCP_BIAS		-1:0]	O_TRIM_OCP_BIAS		,
output wire [`WID_TRIM_OCP_REF		-1:0]	O_TRIM_OCP_REF		,
output wire [`WID_ENB_COMP         	-1:0]	O_ENB_COMP         	,
output wire [`WID_ENB_SLEEP_DETECT 	-1:0]	O_ENB_SLEEP_DETECT 	,
output wire [`WID_END_SW_GDB		-1:0]	O_END_SW_GDB		,	
output wire [`WID_END_SW_PWMB		-1:0]	O_END_SW_PWMB		,	
output wire [`WID_END_SW_SSB		-1:0]	O_END_SW_SSB		,	
output wire [`WID_END_PROT_GDB		-1:0]	O_END_PROT_GDB		,	
output wire [`WID_SEL_DUTY100		-1:0]	O_SEL_DUTY100		,	
output wire	[`WID_ENB_H2L_DT		-1:0]	O_ENB_H2L_DT		,	
output wire [`WID_TSD_PENB		  	-1:0]	O_TSD_PENB			,

output wire [`WID_TRIM_OSC_C		-1:0]	O_TRIM_OSC_C		,
output wire [`WID_TRIM_OSC_I		-1:0]	O_TRIM_OSC_I		,
output wire [`WID_TRIM_SL_DT		-1:0]	O_TRIM_SL_DT		,
output wire [`WID_ENB_LD_COMPEN 	-1:0]	O_ENB_LD_COMPEN 	,
output wire [`WID_TRIM_TON_DLY		-1:0]	O_TRIM_TON_DLY		,
output wire [`WID_TRIM_SS_BIAS		-1:0]	O_TRIM_SS_BIAS		,

//output wire [`WID_TRIM_AAM_REF		-1:0]	O_TRIM_AAM_REF		,
//output wire [`WID_TRIM_AAM_RSV		-1:0]	O_TRIM_AAM_RSV		,
//output wire [`WID_TRIM_TON_TIME		-1:0]	O_TRIM_TON_TIME		,
//output wire [`WID_TRIM_TON_BIAS		-1:0]	O_TRIM_TON_BIAS		,
//output wire [`WID_TRIM_FSEL			-1:0]	O_TRIM_FSEL			,
//output wire [`WID_ENB_AAM          	-1:0]	O_ENB_AAM          	,
//output wire [`WID_SEL_AAM			-1:0]	O_SEL_AAM			,	
//output wire [`WID_TRIM_SW_SEL		-1:0]	O_TRIM_SW_SEL		,	
//output wire [`WID_TRIM_RSV1	  		-1:0]	O_TRIM_RSV1			,
//output wire [`WID_TRIM_RSV2	  		-1:0]	O_TRIM_RSV2			,
////output wire [`WID_TRIM_RSV3	  		-1:0]	O_TRIM_RSV3			,

output wire [`WID_TEST_EN         	-1:0]	O_TEST_EN         	,
output wire [`WID_TEST_SEL        	-1:0]	O_TEST_SEL          ,
output wire [`WID_TEST_DIGSEL     	-1:0]	O_TEST_DIGSEL       ,
output wire [`WID_TEST_MUX		  	-1:0]	O_TEST_MUX			,
output wire	[`WID_TEST_RON			-1:0]	O_TEST_RON        	,
output wire	[`WID_RON_PFET 			-1:0]	O_RON_PFET        	,
output wire	[`WID_RON_NFET 			-1:0]	O_RON_NFET        	,	
output wire	[`WID_EN_EPROM_PROG		-1:0]	O_EN_EPROM_PROG		,
output wire	[`WID_EN_OSC			-1:0]	O_EN_OSC			,
output wire	[`WID_MREAD_FLAG		-1:0]	O_MREAD_FLAG		
);

reg	[`WID_WREG00	-1:0]	r_WREG00     ;   
reg	[`WID_WREG01	-1:0]	r_WREG01     ;   
reg	[`WID_WREG02	-1:0]	r_WREG02     ;   
reg	[`WID_WREG03	-1:0]	r_WREG03     ;   
reg	[`WID_WREG04	-1:0]	r_WREG04     ;   
reg	[`WID_WREG05	-1:0]	r_WREG05     ;   
reg	[`WID_WREG06	-1:0]	r_WREG06     ;   
reg	[`WID_WREG08	-1:0]	r_WREG08     ;   
reg	[`WID_WREG09	-1:0]	r_WREG09     ;   
reg	[`WID_WREG10	-1:0]	r_WREG10     ;   
//reg	[`WID_WREG11	-1:0]	r_WREG11     ;   
//reg	[`WID_WREG12	-1:0]	r_WREG12     ;
//reg	[`WID_WREG13	-1:0]	r_WREG13     ;
//reg	[`WID_WREG14	-1:0]	r_WREG14     ;
//reg	[`WID_WREG15	-1:0]	r_WREG15     ;
reg	[`WID_WREG16	-1:0]	r_WREG16     ;
reg	[`WID_WREG17	-1:0]	r_WREG17     ;
reg	[`WID_WREG18	-1:0]	r_WREG18     ;
reg	[`WID_WREG19	-1:0]	r_WREG19     ;
reg	[`WID_WREG20	-1:0]	r_WREG20     ;

integer i,b;

always @(posedge I_CLK or negedge I_RSTN)begin
	if(!I_RSTN) begin
		r_WREG00<=`Td `DFT_WREG00;
		r_WREG01<=`Td `DFT_WREG01;
		r_WREG02<=`Td `DFT_WREG02;
		r_WREG03<=`Td `DFT_WREG03;
		r_WREG04<=`Td `DFT_WREG04;
		r_WREG05<=`Td `DFT_WREG05;
		r_WREG06<=`Td `DFT_WREG06;
		r_WREG08<=`Td `DFT_WREG08;
		r_WREG09<=`Td `DFT_WREG09;
		r_WREG10<=`Td `DFT_WREG10;
//		r_WREG11<=`Td `DFT_WREG11;
//		r_WREG12<=`Td `DFT_WREG12;
//		r_WREG13<=`Td `DFT_WREG13;
//		r_WREG14<=`Td `DFT_WREG14;
//		r_WREG15<=`Td `DFT_WREG15;
		r_WREG16<=`Td `DFT_WREG16;
		r_WREG17<=`Td `DFT_WREG17;
		r_WREG18<=`Td `DFT_WREG18;
		r_WREG19<=`Td `DFT_WREG19;
		r_WREG20<=`Td `DFT_WREG20;
	end                   
	else begin
		if(I_CEN==1'b0&&I_WEN==1'b0) begin
			if(I_ADDR	==	`ADD_WREG00) begin r_WREG00<=`Td I_DIN[`WID_WREG00-1:0];end
			else if(I_ADDR==`ADD_WREG01) begin r_WREG01<=`Td I_DIN[`WID_WREG01-1:0];end
			else if(I_ADDR==`ADD_WREG02) begin r_WREG02<=`Td I_DIN[`WID_WREG02-1:0];end
			else if(I_ADDR==`ADD_WREG03) begin r_WREG03<=`Td {I_DIN[7:4],I_DIN[2:0]};end
			else if(I_ADDR==`ADD_WREG04) begin r_WREG04<=`Td I_DIN[`WID_WREG04-1:0];end
			else if(I_ADDR==`ADD_WREG05) begin r_WREG05<=`Td I_DIN[`WID_WREG05-1:0];end
			else if(I_ADDR==`ADD_WREG06) begin r_WREG06<=`Td I_DIN[`WID_WREG06-1:0];end
			else if(I_ADDR==`ADD_WREG08) begin r_WREG08<=`Td {I_DIN[6:4],I_DIN[2:0]};end
			else if(I_ADDR==`ADD_WREG09) begin r_WREG09<=`Td I_DIN[`WID_WREG09-1:0];end
			else if(I_ADDR==`ADD_WREG10) begin r_WREG10<=`Td I_DIN[`WID_WREG10-1:0];end
//			else if(I_ADDR==`ADD_WREG11) begin r_WREG11<=`Td I_DIN[`WID_WREG11-1:0];end
//			else if(I_ADDR==`ADD_WREG12) begin r_WREG12<=`Td I_DIN[`WID_WREG12-1:0];end
//			else if(I_ADDR==`ADD_WREG13) begin r_WREG13<=`Td I_DIN[`WID_WREG13-1:0];end
//			else if(I_ADDR==`ADD_WREG14) begin r_WREG14<=`Td I_DIN[`WID_WREG14-1:0];end
//			else if(I_ADDR==`ADD_WREG15) begin r_WREG15<=`Td I_DIN[`WID_WREG15-1:0];end
			else if(I_ADDR==`ADD_WREG16) begin r_WREG16<=`Td I_DIN[`WID_WREG16-1:0];end
			else if(I_ADDR==`ADD_WREG17) begin r_WREG17<=`Td I_DIN[`WID_WREG17-1:0];end
			else if(I_ADDR==`ADD_WREG18) begin r_WREG18<=`Td I_DIN[`WID_WREG18-1:0];end
			else if(I_ADDR==`ADD_WREG19) begin r_WREG19<=`Td I_DIN[`WID_WREG19-1:0];end
			else if(I_ADDR==`ADD_WREG20) begin r_WREG20<=`Td I_DIN[`WID_WREG20-1:0];end
		end
	end
end

always @(posedge I_CLK or negedge I_RSTN)begin
	if(!I_RSTN) begin
		O_DOUT 		<= `Td 	8'd0;
	end 
	else begin
		if(I_CEN==1'b0 && I_WEN==1'b1) begin
			if(I_ADDR     ==`ADD_WREG00) begin O_DOUT<= `Td r_WREG00;end
			else if(I_ADDR==`ADD_WREG01) begin O_DOUT<= `Td r_WREG01;end
			else if(I_ADDR==`ADD_WREG02) begin O_DOUT<= `Td r_WREG02;end
			else if(I_ADDR==`ADD_WREG03) begin O_DOUT<= `Td {r_WREG03[6:3],1'b0,r_WREG03[2:0]};end
			else if(I_ADDR==`ADD_WREG04) begin O_DOUT<= `Td r_WREG04;end
			else if(I_ADDR==`ADD_WREG05) begin O_DOUT<= `Td r_WREG05;end
			else if(I_ADDR==`ADD_WREG06) begin O_DOUT<= `Td r_WREG06;end
			else if(I_ADDR==`ADD_WREG08) begin O_DOUT<= `Td {1'd0,r_WREG08[5:3],1'b0,r_WREG08[2:0]};end
			else if(I_ADDR==`ADD_WREG09) begin O_DOUT<= `Td {3'd0,r_WREG09};end
			else if(I_ADDR==`ADD_WREG10) begin O_DOUT<= `Td r_WREG10;end
//			else if(I_ADDR==`ADD_WREG11) begin O_DOUT<= `Td r_WREG11;end
//			else if(I_ADDR==`ADD_WREG12) begin O_DOUT<= `Td r_WREG12;end
//			else if(I_ADDR==`ADD_WREG13) begin O_DOUT<= `Td {3'd0,r_WREG13};end
//			else if(I_ADDR==`ADD_WREG14) begin O_DOUT<= `Td r_WREG14;end
//			else if(I_ADDR==`ADD_WREG15) begin O_DOUT<= `Td r_WREG15;end
			else if(I_ADDR==`ADD_WREG16) begin O_DOUT<= `Td r_WREG16;end
			else if(I_ADDR==`ADD_WREG17) begin O_DOUT<= `Td {5'd0,r_WREG17};end
			else if(I_ADDR==`ADD_WREG18) begin O_DOUT<= `Td {7'd0,r_WREG18};end
			else if(I_ADDR==`ADD_WREG19) begin O_DOUT<= `Td {7'd0,r_WREG19};end
			else if(I_ADDR==`ADD_WREG20) begin O_DOUT<= `Td {7'd0,r_WREG20};end
			else 							O_DOUT	<= `Td 8'h00;
		end 
	end
end


assign O_TRIM_BGR			=	r_WREG00[5:0];
assign O_ENB_COMP       	=	r_WREG00[6];
assign O_ENB_SLEEP_DETECT 	=	r_WREG00[7];

assign O_TRIM_BIAS			=	r_WREG01[5:0];
assign O_END_SW_GDB			=	r_WREG01[6];
assign O_END_PROT_GDB		=	r_WREG01[7];

assign O_SEL_DUTY100		=	r_WREG02[0];	
assign O_END_SW_PWMB		=	r_WREG02[1];	
assign O_END_SW_SSB			=	r_WREG02[2];	
assign O_ENB_H2L_DT			=	r_WREG02[3];	
assign O_TRIM_HS2LS_DT		=	r_WREG02[7:4];

assign O_TRIM_TSD_REFH		=	r_WREG03[2:0];
assign O_TRIM_TSD_REFL		=	r_WREG03[5:3];
assign O_TSD_PENB			=	r_WREG03[6];  

assign O_TRIM_INJ_R			=	r_WREG04[3:0];
assign O_TRIM_INJ_C			=	r_WREG04[7:4];

assign O_TRIM_ZCD_SEN		=	r_WREG05[3:0];
assign O_TRIM_ZCD_REF		=	r_WREG05[7:4];

assign O_TRIM_OCP_REF		=	r_WREG06[3:0];
assign O_TRIM_OCP_BIAS		=	r_WREG06[7:4];

assign O_TRIM_OSC_C			=	r_WREG08[2:0];
assign O_TRIM_OSC_I			=	r_WREG08[5:3];

assign O_TRIM_SL_DT			=	r_WREG09[3:0];
assign O_ENB_LD_COMPEN 		=	r_WREG09[4];		

assign O_TRIM_SS_BIAS		=	r_WREG10[7:4];
assign O_TRIM_TON_DLY		=	r_WREG10[3:0];
//
//assign O_TRIM_AAM_RSV		=	r_WREG11[7:4];
//assign O_TRIM_AAM_REF		=	r_WREG11[3:0];
//
//assign O_TRIM_TON_BIAS		=	r_WREG12[7:4];
//assign O_TRIM_TON_TIME		=	r_WREG12[3:0];
//
//assign O_TRIM_SW_SEL		=	r_WREG13[5];	
//assign O_SEL_AAM			=	r_WREG13[4];	
//assign O_ENB_AAM          	=	r_WREG13[3];
//assign O_TRIM_FSEL			=	r_WREG13[1:0];
//
//assign O_TRIM_RSV1			=	r_WREG14;
//assign O_TRIM_RSV2			=	r_WREG15;

assign O_TEST_EN         	=	r_WREG16[7];
assign O_TEST_SEL          	=	r_WREG16[6];
assign O_TEST_DIGSEL       	=	r_WREG16[5:4];
assign O_TEST_MUX			=	r_WREG16[3:0];

assign O_TEST_RON        	=	r_WREG17[2];
assign O_RON_PFET        	=	r_WREG17[1];
assign O_RON_NFET        	=	r_WREG17[0];	

assign O_EN_EPROM_PROG		=	r_WREG18[0];
assign O_EN_OSC				=	r_WREG19[0];
assign O_MREAD_FLAG			=	r_WREG20[0];
endmodule

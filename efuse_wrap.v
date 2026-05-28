////////////////////////////////////////////////////////
//
//  Module: efuse_wrap
//  Project: BRIGHTON
//  Description: 
// 
//  Change history: 
//
////////////////////////////////////////////////////////
`timescale 1ns/10ps

module efuse_wrap #(
parameter DEPTH = 16,
parameter DW	= 8,
parameter AW	= $clog2(DEPTH)
)(
input wire				I_SRAM_STR		,
input wire				I_SRAM_CEN		,
input wire				I_SRAM_WEN		,
input wire  [AW-1:0]	I_SRAM_ADD		,	
input wire  [DW-1:0]	I_SRAM_DIN		,	
output wire [DW-1:0]	O_SRAM_DOUT		,	
output wire				O_SRAM_VALID	,
output wire		 		O_SRAM_PGM_DONE	,
//input wire				I_BURSTREAD		,
input wire				I_MREAD_FLAG	,
input wire				I_CLK			,
input wire				I_RSTB
);

//reg				I_SRAM_CEN_sync_1d;
//reg				I_SRAM_WEN_sync_1d;
//reg [DW-1:0]	I_SRAM_DIN_sync_1d;	
//reg [AW-1:0]	I_SRAM_ADD_sync_1d;	
//
//reg				I_SRAM_CEN_sync_2d;
//reg				I_SRAM_WEN_sync_2d;
//reg [DW-1:0]	I_SRAM_DIN_sync_2d;	
//reg [AW-1:0]	I_SRAM_ADD_sync_2d;	
//
//always @(posedge I_CLK or negedge I_RSTB) begin
//	if(!I_RSTB) begin
//		I_SRAM_CEN_sync_1d	<= `Td 1'b1;
//		I_SRAM_WEN_sync_1d	<= `Td 1'b1;
//		I_SRAM_ADD_sync_1d	<= `Td 'h0;
//		I_SRAM_DIN_sync_1d	<= `Td 'h0;
//		
//		I_SRAM_CEN_sync_2d	<= `Td 1'b1;
//		I_SRAM_WEN_sync_2d	<= `Td 1'b1;
//		I_SRAM_ADD_sync_2d	<= `Td 'h0;
//		I_SRAM_DIN_sync_2d	<= `Td 'h0;
//	end 
//	else begin	//if (I_PMU_SEL==1'b0) begin
//		I_SRAM_CEN_sync_1d	<= `Td I_SRAM_CEN;
//		I_SRAM_WEN_sync_1d	<= `Td I_SRAM_WEN;
//		I_SRAM_ADD_sync_1d	<= `Td I_SRAM_ADD;
//		I_SRAM_DIN_sync_1d	<= `Td I_SRAM_DIN;
//		
//		I_SRAM_CEN_sync_2d	<= `Td I_SRAM_CEN_sync_1d;
//		I_SRAM_WEN_sync_2d	<= `Td I_SRAM_WEN_sync_1d;
//		I_SRAM_ADD_sync_2d	<= `Td I_SRAM_ADD_sync_1d;
//		I_SRAM_DIN_sync_2d	<= `Td I_SRAM_DIN_sync_1d;
//	end
//end

wire			w_CEN	= I_SRAM_CEN;
wire			w_WEN	= I_SRAM_WEN;
wire 			w_mread_flag		= I_MREAD_FLAG;
//wire 			w_burstread			= I_BURSTREAD;

//reg r_i_read	;
//reg	r_i_mread	;	
//reg	r_i_pgm		;
//reg	[AW-1:0]		r_i_addr	;
//reg	[DW-1:0]		r_i_din		;
wire 				w_i_read	;
wire 				w_i_mread	;	
wire 				w_i_pgm		;

wire [AW-1:0]		w_i_addr	;
wire [DW-1:0]		w_i_din		;
wire [DW-1:0]		w_o_dout	;	
wire		 		w_o_valid	;			
wire		 		w_o_pgm_done;

//always @(posedge I_CLK or negedge I_RSTB) begin
//	if(!I_RSTB) begin
//		r_i_read		<=	1'b0;
//		r_i_mread		<=	1'b0;	
//		r_i_pgm			<=	1'b0;
//	end 
//	else begin 
//		if (I_SRAM_CEN_sync_2d	== 1'b0 && 	I_SRAM_WEN_sync_2d	== 1'b0) begin
//			r_i_pgm		<=	1'b1;
//		end
//		else if(!w_mread_flag && (I_SRAM_CEN_sync_2d== 1'b0) && (I_SRAM_WEN_sync_2d	== 1'b1)) begin
//			r_i_read	<=	1'b1;
//		end
//		else if(w_mread_flag && (I_SRAM_CEN_sync_2d== 1'b0) && 	(I_SRAM_WEN_sync_2d	== 1'b1)) begin
//			r_i_mread	<=	1'b1;
//		end
//		else begin 
//			r_i_read	<=	1'b0;
//			r_i_mread	<=	1'b0;	
//			r_i_pgm		<=	1'b0;
//		end
//	end
//end

assign	w_i_read	=	(!w_CEN && w_WEN && !w_mread_flag);
assign	w_i_mread	=	(!w_CEN && w_WEN && w_mread_flag );	
assign	w_i_pgm		=	(!w_CEN && !w_WEN );
assign	w_i_addr	=	I_SRAM_ADD;
assign	w_i_din		=	I_SRAM_DIN;
assign  w_i_str		=	I_SRAM_STR;

eprom_ctrl #(
.DEPTH(DEPTH ),
.DW(DW),
.AW(AW)
) u_eprom_ctrl (
/*input	wire		 */.i_clk  (I_CLK  			),
/*input	wire		 */.i_rstn (I_RSTB 			),
/*input	wire		 */.i_read (w_i_read		),
/*input	wire		 */.i_mread(w_i_mread		),
/*input	wire		 */.i_pgm  (w_i_pgm			),
///*input	wire		 */.i_bread(w_burstread		),	//burst  read
/*input	wire		 */.i_str  (w_i_str			),
/*input	wire [AW-1:0]*/.i_addr (w_i_addr		),
/*input	wire [DW-1:0]*/.i_din  (w_i_din			),
/*output reg [DW-1:0]*/.o_dout (w_o_dout		),	
/*output reg		 */.o_valid(w_o_valid		),
/*output reg		 */.o_pgm_done(w_o_pgm_done	)
);

//////////////////////////////////////////////////////////////////
assign O_SRAM_DOUT	= w_o_dout	;
assign O_SRAM_VALID = w_o_valid	;
assign O_SRAM_PGM_DONE = w_o_pgm_done;




endmodule

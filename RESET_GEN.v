
//------------------------------------------------------------------------------
// Reset Generator
// Author :  (Anapass Inc)
//------------------------------------------------------------------------------

`timescale 1ns/10ps

module RESET_GEN (
	input  wire PORESETn,
	input  wire PMU2RST_REQ_INIT,
	input  wire CLK,
	output wire RESET_SYS,
	output wire RESET_POR
);

	//----------------------------------------------------------------------------
	// Internal signals
	//----------------------------------------------------------------------------
	wire           hwreset_d;
	wire           reset_hw_gf;
	wire           w_reset_sys;
	wire           w_reset_por;

	reg      [31:0] reset_hw_sync;
	wire           reset_wd_te;
	reg      [2:0] reset_wd_delay;
	reg            reset_wd_sync;

	wire reset_hw_te;
	wire reset_hw_src = PORESETn;

	wire reset_hw_src_p;
	wire hwreset_d_p;
	CLK_BUF I_DLY_IBUF (.A(reset_hw_src), .Y(reset_hw_src_p));
	RESET_DELAY_CELL I_HWRST_DLY (.A(reset_hw_src_p), .Y(hwreset_d_p));
	CLK_BUF I_DLY_OBUF (.A(hwreset_d_p), .Y(hwreset_d));


	assign reset_hw_gf = (PORESETn | hwreset_d) ;

	assign reset_hw_te = reset_hw_gf;
	//CLK_MUX I_TMUX_RESET_HW (.A(reset_hw_gf), .B(TEST_RESET), .S(TE), .Y(reset_hw_te));

	always @(negedge reset_hw_te or posedge CLK)
	begin
		if (~reset_hw_te) begin
			reset_hw_sync <= 'd0;
		end
		else begin
			/*
			reset_hw_sync[0] <= 1'b1;
			reset_hw_sync[1] <= reset_hw_sync[0];
			*/
			reset_hw_sync	 <= {reset_hw_sync[30:0],1'b1};
		end
	end

	wire #2 reset_hw_sync_high = (reset_hw_sync[31:0]=={32{1'b1}}) ? 1'b1 : 1'b0;
	wire #2 reset_hw_sync_i = (reset_hw_src==1'b1&&hwreset_d==1'b1&&reset_hw_sync_high==1'b1) ? 1'b1 : 1'b0;

//	assign RESET_TREG = reset_hw_gf ;

	assign #2 w_reset_sys  = reset_hw_sync_i & (~PMU2RST_REQ_INIT);
	assign #2 w_reset_por  = reset_hw_sync_i;

	assign RESET_SYS	=	w_reset_sys;
	assign RESET_POR	=	w_reset_por;
//	CLK_MUX I_TMUX_RESET_SYS 	(.A(w_reset_sys), .B(TEST_RESET), .S(TE), .Y(RESET_SYS));
//	CLK_MUX I_TMUX_RESET_POR_I2C(.A(w_reset_por), .B(TEST_RESET), .S(TE), .Y(RESET_POR));
endmodule

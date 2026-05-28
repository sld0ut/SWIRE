//------------------------------------------------------------------------------
// Clock Divider
//------------------------------------------------------------------------------

`timescale 1ns/10ps

module CLKGEN_DIV (
	input  wire        RESETn, // Reset
	input  wire  [3:0] DIV,    // Dividing factor
	input  wire        EN,     // Clock Enable
	input  wire        TE,     // Scan Test Enable
	input  wire        SE,     // Scan Enable
	input  wire        TEST_CLK,// Scan Clock
	input  wire        CLKIN,  // Clock input
	output wire        CLKOUT  // Clock output
);

	//----------------------------------------------------------------------------
	// Internal signals
	//----------------------------------------------------------------------------
	wire           clock_divided;
	wire           clk_mux_sel;
	wire           gclk;
	reg      [1:0] en_sync;

	wire           cke;
	wire           rst;

	wire           reset_sync_te;

	reg            clk_div;
	reg      [4:0] clk_div_cnt;
	reg            clk_div_phase;


	//----------------------------------------------------------------------------
	//  Synchronization
	//----------------------------------------------------------------------------
	always @(negedge RESETn or posedge CLKIN)
	begin
		if (~RESETn)
			en_sync <= 2'b00;
		else
			en_sync <= {en_sync[0],EN};
	end

	assign cke = en_sync[0] & en_sync[1];
	assign rst = en_sync[0] | en_sync[1];

	CLK_MUX I_TMUX_RESET (.A(rst), .B(RESETn), .S(TE), .Y(reset_sync_te));
	CLK_GATE I_CLK_GATE_DIV (.TE(SE), .EN(cke), .ICLK(CLKIN), .OCLK(gclk));


	//----------------------------------------------------------------------------
	//  Clock Dividing
	//----------------------------------------------------------------------------
	always @(negedge reset_sync_te or posedge gclk)
	begin
		if (~reset_sync_te) begin
			clk_div_cnt <= 0;
			clk_div_phase <= 1'b0;
			clk_div <= 1'b0;
		end
		else begin
			clk_div <= clk_div_phase;
			case (DIV)
				4'b0001 : begin //DIV2
						clk_div_cnt <= 0;
						clk_div_phase <= ~clk_div_phase;
					end
				4'b0010 : begin //DIV3
						if ((clk_div_phase==1'b0&&clk_div_cnt==1) | (clk_div_phase==1'b1&&clk_div_cnt==0)) begin
							clk_div_cnt <= 0;
							clk_div_phase <= ~clk_div_phase;
						end
						else
							clk_div_cnt <= clk_div_cnt + 1;
					end
				4'b0011 : begin //DIV4
						if (clk_div_cnt==1) begin
							clk_div_cnt <= 0;
							clk_div_phase <= ~clk_div_phase;
						end
						else
							clk_div_cnt <= clk_div_cnt + 1;
					end
				4'b0100 : begin //DIV6
						if (clk_div_cnt==2) begin
							clk_div_cnt <= 0;
							clk_div_phase <= ~clk_div_phase;
						end
						else
							clk_div_cnt <= clk_div_cnt + 1;
					end
				4'b0101 : begin //DIV8
						if (clk_div_cnt==3) begin
							clk_div_cnt <= 0;
							clk_div_phase <= ~clk_div_phase;
						end else
							clk_div_cnt <= clk_div_cnt + 1;
					end
				4'b0110 : begin //DIV10
						if (clk_div_cnt==4) begin
							clk_div_cnt <= 0;
							clk_div_phase <= ~clk_div_phase;
						end else
							clk_div_cnt <= clk_div_cnt + 1;
					end
				4'b0111 : begin //DIV12
						if (clk_div_cnt==5) begin
							clk_div_cnt <= 0;
							clk_div_phase <= ~clk_div_phase;
						end else
							clk_div_cnt <= clk_div_cnt + 1;
					end
				4'b1000 : begin //DIV14
						if (clk_div_cnt==6) begin
							clk_div_cnt <= 0;
							clk_div_phase <= ~clk_div_phase;
						end else
							clk_div_cnt <= clk_div_cnt + 1;
					end
				4'b1001 : begin //DIV16
						if (clk_div_cnt==7) begin
							clk_div_cnt <= 0;
							clk_div_phase <= ~clk_div_phase;
						end else
							clk_div_cnt <= clk_div_cnt + 1;
					end
				4'b1010 : begin //DIV18
						if (clk_div_cnt==8) begin
							clk_div_cnt <= 0;
							clk_div_phase <= ~clk_div_phase;
						end else
							clk_div_cnt <= clk_div_cnt + 1;
					end
				4'b1011 : begin //DIV20
						if (clk_div_cnt==9) begin
							clk_div_cnt <= 0;
							clk_div_phase <= ~clk_div_phase;
						end else
							clk_div_cnt <= clk_div_cnt + 1;
					end
				4'b1100 : begin //DIV24
						if (clk_div_cnt==11) begin
							clk_div_cnt <= 0;
							clk_div_phase <= ~clk_div_phase;
						end else
							clk_div_cnt <= clk_div_cnt + 1;
					end
				4'b1101 : begin //DIV32
						if (clk_div_cnt==15) begin
							clk_div_cnt <= 0;
							clk_div_phase <= ~clk_div_phase;
						end else
							clk_div_cnt <= clk_div_cnt + 1;
					end
				4'b1110 : begin //DIV64
						if (clk_div_cnt==31) begin
							clk_div_cnt <= 0;
							clk_div_phase <= ~clk_div_phase;
						end else
							clk_div_cnt <= clk_div_cnt + 1;
					end
				default : begin
						clk_div_cnt <= 0;
						clk_div_phase <= 0;
					end
			endcase
		end
	end

	//----------------------------------------------------------------------------
	//  Clock Muxing
	//----------------------------------------------------------------------------
	assign clock_divided = (DIV==4'b1111) ? 1'b0 : 1'b1;
	assign clk_mux_sel = TE | (~clock_divided);

	wire CLKOUT_PRE;
	CLK_MUX I_CLK_MUX_DIV (.A(clk_div), .B(gclk), .S(clk_mux_sel), .Y(CLKOUT_PRE));
	CLK_MUX I_CLK_OUT (.A(CLKOUT_PRE), .B(TEST_CLK), .S(TE), .Y(CLKOUT));

endmodule

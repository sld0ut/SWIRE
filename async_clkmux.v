// Copyright (C) 2017, Andes Technology Corp. Confidential Proprietary




(* DONT_TOUCH = "yes" *)
module async_clkmux (
	  scan_mode,
	  reset0_n,
	  reset1_n,
	  clk_in0,
	  clk_in1,
	  select,
	  clk_out
);

input	scan_mode;
input	reset0_n;
input	reset1_n;
input	clk_in0;
input	clk_in1;
input	select;
output	clk_out;

reg	select_sync1_clk0;
reg	select_sync2_clk0;
reg	select_sync1_clk1;
reg	select_sync2_clk1;

reg	clk0_dis_sync1;
reg	clk0_dis_sync2;
reg	clk1_dis_sync1;
reg	clk1_dis_sync2;

reg	clk0_en;
reg	clk1_en;

wire	gated_clk0;
wire	gated_clk1;


always @(posedge clk_in0 or negedge reset0_n)
	if (!reset0_n) begin
		select_sync1_clk0 <= 1'b0;
		select_sync2_clk0 <= 1'b0;
	end
	else begin
		select_sync1_clk0 <= ~select;
		select_sync2_clk0 <= select_sync1_clk0;
	end


always @(posedge clk_in0 or negedge reset0_n)
	if (!reset0_n) begin
		clk1_dis_sync1 <= 1'b1;
		clk1_dis_sync2 <= 1'b1;
	end
	else begin
		clk1_dis_sync1 <= ~clk1_en;
		clk1_dis_sync2 <= clk1_dis_sync1;
	end

wire clk_in0_inv;
CLK_MUX I_TMUX_CLK0 (.A(~clk_in0), .B(clk_in0), .S(scan_mode), .Y(clk_in0_inv));
//always @(negedge clk_in0 or negedge reset0_n)
always @(posedge clk_in0_inv or negedge reset0_n)
	if (!reset0_n)
		clk0_en <= 1'b0;
	else
		clk0_en <= select_sync2_clk0 && clk1_dis_sync2;


always @(posedge clk_in1 or negedge reset1_n)
	if (!reset1_n) begin
		select_sync1_clk1 <= 1'b0;
		select_sync2_clk1 <= 1'b0;
	end
	else begin
		select_sync1_clk1 <= select;
		select_sync2_clk1 <= select_sync1_clk1;
	end


always @(posedge clk_in1 or negedge reset1_n)
	if (!reset1_n) begin
		clk0_dis_sync1 <= 1'b1;
		clk0_dis_sync2 <= 1'b1;
	end
	else begin
		clk0_dis_sync1 <= ~clk0_en;
		clk0_dis_sync2 <= clk0_dis_sync1;
	end

wire clk_in1_inv;
CLK_MUX I_TMUX_CLK1 (.A(~clk_in1), .B(clk_in1), .S(scan_mode), .Y(clk_in1_inv));
//always @(negedge clk_in1 or negedge reset1_n)
always @(posedge clk_in1_inv or negedge reset1_n)
	if (!reset1_n)
		clk1_en <= 1'b0;
	else
		clk1_en <= select_sync2_clk1 && clk0_dis_sync2;


assign gated_clk0 = clk_in0 && clk0_en;
assign gated_clk1 = clk_in1 && clk1_en;
CLK_OR u_clk_or( .Y(clk_out), .A(gated_clk0), .B(gated_clk1) );

endmodule

////////////////////////////////////////////////////////
//
//  Module: swire_ctrl
//  Project: BRIGHTON
//  Description: 
// 
//  Change history: 
//
////////////////////////////////////////////////////////
`timescale 1ns/10ps

module swire_ctrl (
	input	wire			i_swire		,
	input	wire			i_sclk		,
	input	wire			i_rstn		,
	input	wire [7:0]		i_rdata		,
	input	wire			i_rvalid	,
	output	reg	 [6:0]		o_pulse		,
	output	reg				o_swire_en	,
	output	reg				o_swire		,
	output	reg				o_pgm_en	,
	output	reg				o_reg_en	,
	output	reg				o_cen		,
	output	reg				o_wen		,
	output	reg				o_str		,		
	output	reg	 [4:0]		o_addr		,
	output	reg	 [7:0]		o_data		,		
	output	reg				o_valid		
);

localparam  DATA1_MIN  = 8'd48;
localparam  DATA1_MAX  = 8'd80;
localparam  HDR_MIN    = 9'd192;
localparam  HDR_MAX    = 9'd320;

//Internal Signal
reg			r_swire_d1	;
reg			r_swire_d2	;
reg			r_swire_d3	;

reg			r_init_done	;
reg	[ 6:0]	r_pulse_cnt	;
reg 		r_stop_en	;
reg [ 5:0]	r_stop_cnt	;
reg 		r_bit_cnt	;

reg [ 2:0]	r_addr_cnt	; 
reg [ 2:0]	r_data_cnt	; 
reg [ 4:0]	r_addr_shift;
reg [ 7:0]	r_data_shift;

//High width counter
reg [ 8:0]	r_high_cnt	;
reg	[ 3:0]	r_tx_cnt	;

wire        w_bit_val = (DATA1_MIN <= r_high_cnt) && (r_high_cnt <= DATA1_MAX);   
wire        w_header  = (HDR_MIN   <= r_high_cnt) && (r_high_cnt <= HDR_MAX  );

always @(posedge i_sclk or negedge i_rstn) begin
	if (~i_rstn) begin
		r_swire_d1 <= 1'b0;
		r_swire_d2 <= 1'b0;
		r_swire_d3 <= 1'b0;
	end else begin
		r_swire_d1 <= i_swire;
		r_swire_d2 <= r_swire_d1;
		r_swire_d3 <= r_swire_d2;
	end
end

wire swire_rise = r_swire_d2 & ~r_swire_d3;
wire swire_fall = ~r_swire_d2 & r_swire_d3;

always @(posedge i_sclk or negedge i_rstn) begin
	if (~i_rstn) r_stop_cnt <= 6'b0;
	else begin
		if (r_swire_d2 & r_init_done) begin
			if(r_stop_cnt < 56)
				r_stop_cnt <= r_stop_cnt + 1'b1;
		end else
				r_stop_cnt <= 6'b0;
	end
end

always @(posedge i_sclk or negedge i_rstn) begin
	 if (~i_rstn) 							r_stop_en <= 1'b0;
else if (~r_init_done)						r_stop_en <= 1'b0;
else if (r_init_done && r_stop_cnt >= 'd50)	r_stop_en <= 1'b1;
end

always @(posedge i_sclk or negedge i_rstn) begin
     if (~i_rstn)				r_high_cnt <= 9'b0;
else if (swire_fall)			r_high_cnt <= 9'b0;
else if (r_swire_d2) begin
	 if (r_high_cnt <= 9'd320)
     	 r_high_cnt <= r_high_cnt + 1'b1;
	 end
end

//--------------------------------------------------
// swire controller FSM
//--------------------------------------------------
localparam 	Wait	= 13'b0_0000_0000_0001,
			Pcnt	= 13'b0_0000_0000_0010,
			Stop	= 13'b0_0000_0000_0100,
			Hold	= 13'b0_0000_0000_1000,
			Head	= 13'b0_0000_0001_0000,
			Mode	= 13'b0_0000_0010_0000,
			Addr	= 13'b0_0000_0100_0000,
			Data	= 13'b0_0000_1000_0000,
			Pstr	= 13'b0_0001_0000_0000,
			Ehdr	= 13'b0_0010_0000_0000,
			Rlow	= 13'b0_0100_0000_0000,
			Rdtx	= 13'b0_1000_0000_0000,
			Done	= 13'b1_0000_0000_0000;

reg [12:0] CurSt_SWIRE_FSM;
reg [12:0] NextSt_SWIRE_FSM;

// State Decoding for Visual Debugging
wire	tWait	= CurSt_SWIRE_FSM[ 0];
wire	tPcnt	= CurSt_SWIRE_FSM[ 1];
wire	tStop	= CurSt_SWIRE_FSM[ 2];
wire	tHold	= CurSt_SWIRE_FSM[ 3];
wire	tHead	= CurSt_SWIRE_FSM[ 4];
wire	tMode	= CurSt_SWIRE_FSM[ 5];
wire	tAddr	= CurSt_SWIRE_FSM[ 6];
wire	tData	= CurSt_SWIRE_FSM[ 7];
wire	tPstr	= CurSt_SWIRE_FSM[ 8];
wire	tEhdr	= CurSt_SWIRE_FSM[ 9];
wire	tRlow	= CurSt_SWIRE_FSM[10];
wire	tRdtx	= CurSt_SWIRE_FSM[11];
wire	tDone	= CurSt_SWIRE_FSM[12];

// synopsys translate_off
reg   [(64*8)-1:0]  MAIN_SWIRE_FSM_STATE;
supply1             vdd;

always @ (*) begin
	case (vdd)
		tWait	: MAIN_SWIRE_FSM_STATE = "Wait";
		tPcnt	: MAIN_SWIRE_FSM_STATE = "Pcnt";
		tStop	: MAIN_SWIRE_FSM_STATE = "Stop";
		tHold	: MAIN_SWIRE_FSM_STATE = "Hold";
		tHead	: MAIN_SWIRE_FSM_STATE = "Head";
		tMode	: MAIN_SWIRE_FSM_STATE = "Mode";
		tAddr	: MAIN_SWIRE_FSM_STATE = "Addr";
		tData	: MAIN_SWIRE_FSM_STATE = "Data";
		tPstr	: MAIN_SWIRE_FSM_STATE = "Pstr";
		tEhdr	: MAIN_SWIRE_FSM_STATE = "Ehdr";
		tRlow	: MAIN_SWIRE_FSM_STATE = "Rlow";
		tRdtx	: MAIN_SWIRE_FSM_STATE = "Rdtx";
		tDone	: MAIN_SWIRE_FSM_STATE = "Done";
		default : MAIN_SWIRE_FSM_STATE = "ERRR";
	endcase
end
// synopsys translate_on

always @ (posedge i_sclk or negedge i_rstn) begin
	if (~i_rstn)	CurSt_SWIRE_FSM <= Wait;
	else			CurSt_SWIRE_FSM <= #1 NextSt_SWIRE_FSM;
end

// Internal FSM Regs
reg r_clr_pcnt	,	r_set_pcnt	;
reg r_clr_pulse	,	r_set_pulse	;
reg	r_clr_sen	,	r_set_sen	;
reg	r_clr_swire	,	r_set_swire	;
reg	r_clr_pgm	,	r_set_pgm	;
reg	r_clr_reg	,	r_set_reg	;
reg	r_clr_cen	,	r_set_cen	;
reg	r_clr_wen	,	r_set_wen	;
reg	r_clr_addr	,	r_set_addr	;
reg	r_clr_data	,	r_set_data	;
reg	r_clr_valid	,	r_set_valid	;
reg	r_clr_str	,	r_set_str	;
reg r_high_swire,	r_clr_init	;

// FSM Main Body
always @(*) begin
	NextSt_SWIRE_FSM = Wait;
	r_clr_pcnt	= 1'b0;	r_set_pcnt	= 1'b0;
	r_clr_pulse	= 1'b0;	r_set_pulse	= 1'b0;
	r_clr_sen	= 1'b0; r_set_sen	= 1'b0;
	r_clr_swire	= 1'b0; r_set_swire	= 1'b0;
	r_clr_pgm	= 1'b0; r_set_pgm	= 1'b0;
	r_clr_reg	= 1'b0; r_set_reg	= 1'b0;
	r_clr_cen	= 1'b0; r_set_cen	= 1'b0;
	r_clr_wen	= 1'b0; r_set_wen	= 1'b0;
	r_clr_addr	= 1'b0; r_set_addr	= 1'b0;
	r_clr_data	= 1'b0; r_set_data	= 1'b0;
	r_clr_valid	= 1'b0; r_set_valid	= 1'b0;
	r_clr_str	= 1'b0; r_set_str	= 1'b0;
	r_high_swire= 1'b0;	r_clr_init	= 1'b0;

	case (CurSt_SWIRE_FSM)
		
		Wait: begin
			if (r_init_done & ~r_stop_en) begin
				r_set_cen	= 1'b1;
				r_set_wen	= 1'b1;
				NextSt_SWIRE_FSM = Pcnt;
			end else begin
				r_clr_pulse	= 1'b1;
				r_clr_pcnt	= 1'b1;
				r_set_cen	= 1'b1;
				r_set_wen	= 1'b1;
				NextSt_SWIRE_FSM = Wait;
			end
		end

		Pcnt: begin
			if (r_stop_en) begin
				if (r_pulse_cnt <= 7'd124) begin
					r_clr_pcnt  = 1'b1;
					r_set_valid = 1'b1;
					r_set_pulse = 1'b1;
					NextSt_SWIRE_FSM = Stop;
				end else if (r_pulse_cnt == 7'd125) begin
					r_clr_cen	= 1'b1;
					r_clr_wen	= 1'b1;
					r_set_pulse	= 1'b1;
					NextSt_SWIRE_FSM = Hold;
				end else if (r_pulse_cnt == 7'd126) begin
					r_clr_cen	= 1'b1;
					r_set_wen	= 1'b1;
					r_set_pulse	= 1'b1;
					NextSt_SWIRE_FSM = Hold;
				end else begin
					r_clr_pulse = 1'b1;	
					r_clr_init	= 1'b1;
					NextSt_SWIRE_FSM = Wait;
				end
			end else begin
				r_set_pcnt = 1'b1;		
				NextSt_SWIRE_FSM = Pcnt;
			end
		end

		Stop: begin
			if (swire_fall) begin
				r_clr_pulse = 1'b1;
				NextSt_SWIRE_FSM = Pcnt;
			end else begin
				r_clr_valid = 1'b1;
			    NextSt_SWIRE_FSM = Stop;
			end
		end

		Hold: begin
			if (swire_fall) 
				NextSt_SWIRE_FSM = Head;
			else begin
				NextSt_SWIRE_FSM = Hold;
			end
		end
		
		Head: begin
			if (swire_fall) begin
				if (w_header)
					NextSt_SWIRE_FSM = Mode;
				else
					NextSt_SWIRE_FSM = Wait;
			end else
				NextSt_SWIRE_FSM = Head;
		end
	
		Mode: begin
			if (swire_fall) begin
				if (r_bit_cnt == 1'b0) begin
					r_set_pgm	= w_bit_val;
					r_clr_pgm	= ~w_bit_val;
					NextSt_SWIRE_FSM = Mode; 
				end else if (r_bit_cnt == 1'b1) begin
					r_set_reg	= w_bit_val;
					r_clr_reg	= ~w_bit_val;
					NextSt_SWIRE_FSM = Addr;
				end else
					NextSt_SWIRE_FSM = Wait;
			end else 
				NextSt_SWIRE_FSM = Mode;
		end

		Addr: begin
			if (swire_fall) begin
				if (r_addr_cnt == 3'd4) begin
					if (~o_cen && ~o_wen) begin
						r_set_addr	= 1'b1;
						NextSt_SWIRE_FSM = Data;
					end else begin
						r_set_valid	= 1'b1;
						r_set_sen	= 1'b1;
						r_set_addr	= 1'b1;
						NextSt_SWIRE_FSM = Rlow;
					end
				end else
					NextSt_SWIRE_FSM = Addr;
			end else 
				NextSt_SWIRE_FSM = Addr;
		end

		Data: begin
			if (swire_fall) begin
				if (r_data_cnt == 3'd7) begin
					if (o_pgm_en) begin
						r_set_valid = 1'b1;						
						r_set_data = 1'b1;
						NextSt_SWIRE_FSM = Pstr;
					end else begin
						r_set_valid = 1'b1;	
						r_set_data = 1'b1;
						NextSt_SWIRE_FSM = Ehdr;
					end
				end else
					NextSt_SWIRE_FSM = Data;
			end else 
				NextSt_SWIRE_FSM = Data;		
		end

		Pstr: begin
			if (swire_fall) begin
				r_set_str	= 1'b1;
				NextSt_SWIRE_FSM = Ehdr;
			end else begin
				r_clr_valid = 1'b1;
				NextSt_SWIRE_FSM = Pstr;
			end
		end

		Ehdr: begin
			if (swire_fall) begin
				if (w_header) begin
					NextSt_SWIRE_FSM = Done;
				end else
					NextSt_SWIRE_FSM = Wait;
			end else begin
				r_clr_valid	= 1'b1;				
				r_clr_str 	= 1'b1;
				NextSt_SWIRE_FSM = Ehdr;
			end
		end
		
		Rlow: begin
			if (i_rvalid) begin
				r_clr_swire = 1'b1;
				NextSt_SWIRE_FSM = Rdtx;
			end else begin
				r_clr_valid = 1'b1;
				NextSt_SWIRE_FSM = Rlow;
			end
		end

		Rdtx: begin
			if (r_tx_cnt == 4'd8) begin
				r_high_swire= 1'b1;
				r_set_swire	= 1'b1;
				NextSt_SWIRE_FSM = Done;
			end else begin
				r_set_swire = 1'b1;				
				NextSt_SWIRE_FSM = Rdtx;
			end
		end

		Done: begin
			r_clr_valid	= 1'b1;
			r_clr_pcnt	= 1'b1;
			r_clr_addr	= 1'b1;
			r_clr_data	= 1'b1;
			r_clr_pgm	= 1'b1;
			r_clr_reg	= 1'b1;
			r_clr_sen	= 1'b1;
			r_set_pulse = 1'b1;
			NextSt_SWIRE_FSM = Wait;
		end

		default: NextSt_SWIRE_FSM = Wait;		
	endcase
end

always @(posedge i_sclk or negedge i_rstn) begin
	 if	(~i_rstn)					r_init_done <= 1'b0;
else if (tStop)						r_init_done <= 1'b0;
else if (tDone)						r_init_done <= 1'b0;
else if (r_clr_init)				r_init_done <= 1'b0;
else if	(swire_fall)				r_init_done <= 1'b1;
end

always @(posedge i_sclk or negedge i_rstn) begin
	 if (~i_rstn)					r_bit_cnt <= 1'b0;
else if (~tMode)     				r_bit_cnt <= 1'b0;
else if (tMode && swire_fall)		r_bit_cnt <= r_bit_cnt + 1'b1;
end

always @(posedge i_sclk or negedge i_rstn) begin
	 if (~i_rstn)					r_addr_cnt <= 3'b0;
else if (r_addr_cnt == 3'd5)		r_addr_cnt <= 3'b0;
else if (tAddr && swire_fall)		r_addr_cnt <= r_addr_cnt + 1'b1;
end

always @(posedge i_sclk or negedge i_rstn) begin
	 if (~i_rstn)					r_addr_shift <= 5'b0;
else if (tAddr && swire_fall)		r_addr_shift <= {r_addr_shift[3:0], w_bit_val};
end

always @(posedge i_sclk or negedge i_rstn) begin
	 if (~i_rstn)					r_data_cnt <= 3'b0;
else if (~tData)					r_data_cnt <= 3'b0;
else if (tData && swire_fall)		r_data_cnt <= r_data_cnt + 1'b1;
end

always @(posedge i_sclk or negedge i_rstn) begin
	 if (~i_rstn)					r_data_shift <= 8'b0;
else if (tData && swire_fall)		r_data_shift <= {r_data_shift[6:0], w_bit_val};
end

always @(posedge i_sclk or negedge i_rstn) begin
	 if (~i_rstn)					r_pulse_cnt <= 7'b0;
else if (r_clr_pcnt)				r_pulse_cnt <= 7'b0;
else if (r_set_pcnt  && swire_rise)	
	 if (r_pulse_cnt < 'd127)		r_pulse_cnt <= r_pulse_cnt + 1'b1;
end

always @(posedge i_sclk or negedge i_rstn) begin
	 if (~i_rstn) 					r_tx_cnt <= 4'b0;
else if (~tRdtx)					r_tx_cnt <= 4'b0;
else if (tRdtx)						r_tx_cnt <= r_tx_cnt + 1'b1;
end

always @(posedge i_sclk or negedge i_rstn) begin
	 if (~i_rstn)		o_pulse		<= 7'b0;
else if (r_clr_pulse)	o_pulse		<= 7'b0;
else if	(r_set_pulse)	o_pulse		<= r_pulse_cnt;
end

always @(posedge i_sclk or negedge i_rstn) begin
	 if (~i_rstn)		o_swire_en	<= 1'b0;
else if (r_clr_sen)		o_swire_en	<= 1'b0;
else if	(r_set_sen)		o_swire_en	<= 1'b1;
end

always @(posedge i_sclk or negedge i_rstn) begin
	 if (~i_rstn)		o_swire		<= 1'b1;
else if (r_high_swire)	o_swire		<= 1'b1;
else if (r_clr_swire)	o_swire		<= 1'b0;
else if	(r_set_swire)	o_swire		<= i_rdata[7 - r_tx_cnt];
end

always @(posedge i_sclk or negedge i_rstn) begin
	 if (~i_rstn)		o_pgm_en	<= 1'b0;
else if (r_clr_pgm)		o_pgm_en	<= 1'b0;
else if	(r_set_pgm)		o_pgm_en	<= 1'b1;
end

always @(posedge i_sclk or negedge i_rstn) begin
	 if (~i_rstn)		o_reg_en	<= 1'b0;
else if (r_clr_reg)		o_reg_en	<= 1'b0;
else if	(r_set_reg)		o_reg_en	<= 1'b1;
end

always @(posedge i_sclk or negedge i_rstn) begin
	 if (~i_rstn)		o_cen		<= 1'b1;
else if (r_clr_cen)		o_cen		<= 1'b0;
else if	(r_set_cen)		o_cen		<= 1'b1;
end

always @(posedge i_sclk or negedge i_rstn) begin
	 if (~i_rstn)		o_wen		<= 1'b1;
else if (r_clr_wen)		o_wen		<= 1'b0;
else if	(r_set_wen)		o_wen		<= 1'b1;
end

always @(posedge i_sclk or negedge i_rstn) begin
	 if (~i_rstn)		o_addr		<= 5'b0;
else if (r_clr_addr)	o_addr		<= 5'b0;
else if (r_set_addr)	o_addr		<= {r_addr_shift[3:0], w_bit_val};
end

always @(posedge i_sclk or negedge i_rstn) begin
	 if (~i_rstn)		o_data		<= 8'b0;
else if (r_clr_data)	o_data		<= 8'b0;
else if (r_set_data)	o_data		<= {r_data_shift[6:0], w_bit_val};
end

always @(posedge i_sclk or negedge i_rstn) begin
	 if (~i_rstn)		o_valid		<= 1'b0;
else if (r_clr_valid)	o_valid		<= 1'b0;
else if (r_set_valid)	o_valid		<= 1'b1;
end

always @(posedge i_sclk or negedge i_rstn) begin
	 if (~i_rstn)		o_str		<= 1'b0;
else if (r_clr_str)		o_str		<= 1'b0;
else if (r_set_str)		o_str		<= 1'b1;
end

endmodule

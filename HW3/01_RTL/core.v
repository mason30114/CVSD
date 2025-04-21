
module core (                       //Don't modify interface
	input         i_clk,
	input         i_rst_n,
	input         i_op_valid,
	input  [ 3:0] i_op_mode,
    output        o_op_ready,
	input         i_in_valid,
	input  [ 7:0] i_in_data,
	output        o_in_ready,
	output        o_out_valid,
	output [13:0] o_out_data
);

parameter [4:0] IDLE = 5'd0, OP_READ = 5'd1, OP_DECODE = 5'd2, MAP_LOAD = 5'd3,                                       
				R_SHIFT = 5'd4, L_SHIFT = 5'd5, U_SHIFT = 5'd6, D_SHIFT = 5'd7,                     
				DEPTH_RED = 5'd8, DEPTH_INC = 5'd9, DISP = 5'd10, CONV_LOAD = 5'd11, CONV_OUT = 5'd12,
				MEDIAN_LOAD = 5'd13, MEDIAN_OUT = 5'd14, SOBEL_LOAD = 5'd15, SOBEL_OUT = 5'd16;
reg [4:0] state, n_state;
wire r_shift_end, l_shift_end, u_shift_end, d_shift_end, depth_red_end, depth_inc_end;
reg map_load_end, disp_end;
reg conv_load_end, conv_out_end, conv_end;
reg median_load_end, median_out_end, median_end;
reg sobel_load_end, sobel_out_end, sobel_end;
reg o_out_valid_w, o_in_ready_w, o_op_ready_w;
reg [13:0] o_out_data_w;

reg i_op_valid_r;
reg [3:0] i_op_mode_r;
reg i_in_valid_r;
reg [7:0] i_in_data_r;

wire sram_cen [0:7];
reg sram_wen [0:7];
reg [7:0] sram_data_write [0:7];
reg [7:0] sram_data_read [0:7];
// reg [7:0] sram_data_read_r [0:7];
reg [7:0] sram_addr [0:7];
reg [7:0] sram_addr_write, sram_addr_write_offset;
integer i;
reg [11:0] map_load_cnt;
reg [2:0] sram_write_idx;

reg [2:0] origin_x, origin_y;

reg [1:0] scale_mode;

reg [2:0] sram_disp_read_idx, sram_disp_read_idx_delay;
reg [7:0] disp_cnt;
reg [7:0] sram_addr_disp_read;
wire [7:0] sram_disp_out;
wire [5:0] origin_mode;
reg out_valid_disp;

reg [7:0] unit_in_data_0, unit_in_data_1, unit_in_data_2, unit_in_data_3, unit_in_data_4, unit_in_data_5, unit_in_data_6, unit_in_data_7;
reg [7:0] unit_in_data_0_pad, unit_in_data_1_pad, unit_in_data_2_pad, unit_in_data_3_pad, unit_in_data_4_pad, unit_in_data_5_pad, unit_in_data_6_pad, unit_in_data_7_pad;

reg data_mode;
reg data_mode_d1;
reg [2:0] sram_addr_decoder [0:7];
reg [2:0] sram_addr_encoder [0:7];
reg [7:0] sram_addr_conv [0:7];
reg [2:0] sram_addr_read_y_shift [0:7];
reg sram_addr_read_x_shift [0:7];

reg [6:0] conv_cnt;
reg out_valid_conv;
wire [13:0] conv_out_data_0, conv_out_data_1, conv_out_data_2, conv_out_data_3;
reg [13:0] conv_data_out;
wire conv_clear;
reg conv_active;
wire conv_mode;
wire conv_read_valid;

reg [2:0] sobel_state, n_sobel_state;
reg [7:0] sram_addr_sobel [0:7];
reg [6:0] sobel_cnt;
wire [13:0] sobel_out_data_0, sobel_out_data_1, sobel_out_data_2, sobel_out_data_3;
reg [13:0] sobel_data_out;
reg [13:0] data_out_load;
reg out_op;
wire sobel_clear;
wire sobel_start;
reg [1:0] sobel_mode;
reg sobel_mode_read;
wire sobel_read_valid, sobel_add_g_valid;
wire sobel_read_end;
wire sobel_nms_end;
wire sobel_comp_end;
wire sobel_comp_angle_end;
wire sobel_comp_g_end;
reg sobel_add_g_end;
reg [1:0] sobel_channel;
reg [1:0] sobel_output_channel;
reg out_valid_sobel;

reg [2:0] median_state, n_median_state;
reg [7:0] sram_addr_median [0:7];
reg [6:0] median_cnt;
reg [1:0] median_loc_control;
wire [13:0] median_out_data_0, median_out_data_1, median_out_data_2, median_out_data_3;
reg [13:0] median_data_out;
wire median_clear;
wire median_start;
reg median_mode;
reg [1:0] median_output_channel;
reg [7:0] median_in_data_buff_0;
reg [7:0] median_in_data_buff_1;
reg [7:0] median_in_data_buff_2;
reg [7:0] median_in_data_buff_3;
reg [7:0] median_in_data_buff_4;
reg [7:0] median_in_data_buff_5;
reg [7:0] median_in_data_buff_6;
reg [7:0] median_in_data_buff_7;
reg [7:0] median_in_data[0:15];
// reg [7:0] all_in_data[0:15];
/*reg median_up_center_end;
reg median_up_side_end;
reg median_up_corner_end;
reg median_load_down_end;
reg median_down_center_end;
reg median_down_side_end;
reg median_down_corner_end;*/
wire median_center_end;
wire median_side_end;
wire median_corner_end;
wire median_wait_end;
reg [1:0] median_channel;
reg [1:0] median_pair_mode;
reg median_mode_read, median_mode_read_d1;
reg out_valid_median;

reg out_load_op;
// -------------------------------------------------------- System FSM -------------------------------------------------------- 
always@*
	case(state)
		IDLE: n_state = OP_READ;
		OP_READ: n_state = OP_DECODE;
		OP_DECODE: 
			if(i_op_valid_r)
				case(i_op_mode_r)
					4'b0000: n_state = MAP_LOAD;
					4'b0001: n_state = R_SHIFT;
					4'b0010: n_state = L_SHIFT;
					4'b0011: n_state = U_SHIFT;
					4'b0100: n_state = D_SHIFT;
					4'b0101: n_state = DEPTH_RED;
					4'b0110: n_state = DEPTH_INC;
					4'b0111: n_state = DISP;
					4'b1000: n_state = CONV_LOAD;
					4'b1001: n_state = MEDIAN_LOAD;
					4'b1010: n_state = SOBEL_LOAD;
					// default: n_state = OP_DECODE;
					default: n_state = IDLE;
				endcase
			else
				n_state = OP_DECODE;
		MAP_LOAD:
			// if (map_load_end)
			if (map_load_end && i_in_valid_r)
				n_state = IDLE;
			else
				n_state = MAP_LOAD;

		R_SHIFT:
			if (r_shift_end)
				n_state = IDLE;
			else
				n_state = R_SHIFT;
		L_SHIFT:
			if (l_shift_end)
				n_state = IDLE;
			else
				n_state = L_SHIFT;
		U_SHIFT:
			if (u_shift_end)
				n_state = IDLE;
			else
				n_state = U_SHIFT;
		D_SHIFT:
			if (d_shift_end)
				n_state = IDLE;
			else
				n_state = D_SHIFT;
		DEPTH_RED:
			if (depth_red_end)
				n_state = IDLE;
			else
				n_state = DEPTH_RED;				
		DEPTH_INC:
			if (depth_inc_end)
				n_state = IDLE;
			else
				n_state = DEPTH_INC;
		DISP:
			if (disp_end)
				n_state = IDLE;
			else
				n_state = DISP;
		CONV_LOAD:
			if (conv_load_end)
				n_state = CONV_OUT;
			else
				n_state = CONV_LOAD;
		CONV_OUT:
			if (conv_out_end)
				n_state = OP_READ;
			else
				n_state = CONV_OUT;			
		MEDIAN_LOAD:
			// if (median_load_end)
			if (median_load_end && (median_output_channel == 2'd3))
				n_state = MEDIAN_OUT;
			else
				n_state = MEDIAN_LOAD;
		MEDIAN_OUT:
			if (median_end)
				n_state = OP_READ;
			/*else if (median_out_end)
				n_state = MEDIAN_LOAD;*/
			else
				n_state = MEDIAN_OUT;		
		SOBEL_LOAD:
			// if (sobel_load_end)
			if (sobel_load_end && (sobel_output_channel == 2'd3))
				n_state = SOBEL_OUT;
			else
				n_state = SOBEL_LOAD;
		SOBEL_OUT:
			if (sobel_end)
				n_state = OP_READ;
			/*else if (sobel_out_end)
				n_state = SOBEL_LOAD;*/
			else
				n_state = SOBEL_OUT;		
		default: n_state = state;
	endcase

always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		state <= 0;
	else
		state <= n_state;


// OP_READY
always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		o_op_ready_w <= 0;
	else
		if (state == OP_READ)
			o_op_ready_w <= 1;
		else
			o_op_ready_w <= 0;

assign o_op_ready = o_op_ready_w;

// IN_READY
always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		o_in_ready_w <= 1;
	else
		o_in_ready_w <= 1;		
	/*else
		if (state == MAP_LOAD)
			o_in_ready_w <= 1;
		else
			o_in_ready_w <= 0;*/

assign o_in_ready = o_in_ready_w;

// OUT_VALID
always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		o_out_valid_w <= 0;
	else
		if (state == DISP)
			o_out_valid_w <= out_valid_disp;
		else if (state == CONV_OUT)
			o_out_valid_w <= out_valid_conv;
		else if (state == MEDIAN_OUT)
			o_out_valid_w <= out_valid_median;
		else if (state == SOBEL_OUT)
			o_out_valid_w <= out_valid_sobel;
		else if (state == SOBEL_LOAD)
			o_out_valid_w <= out_load_op;
		else if (state == MEDIAN_LOAD)
			o_out_valid_w <= out_load_op;
		else
			o_out_valid_w <= 0;

assign o_out_valid = o_out_valid_w;


always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		o_out_data_w <= 0;
	else
		if (state == DISP)
			o_out_data_w <= {6'd0, sram_disp_out};
		else if (state == CONV_OUT)
			o_out_data_w <= conv_data_out;		
			// o_out_data_w <= sobel_data_out;	
		else if (state == SOBEL_OUT)
			o_out_data_w <= sobel_data_out;		
			// o_out_data_w <= data_out_load;	
		else if (state == SOBEL_LOAD)
			o_out_data_w <= data_out_load;		
		else if (state == MEDIAN_OUT)
			o_out_data_w <= median_data_out;
		else if (state == MEDIAN_LOAD)
			o_out_data_w <= data_out_load;		
		else
			o_out_data_w <= 0;

assign o_out_data = o_out_data_w;



// -------------------------------------------------------- SRAM Interface --------------------------------------------------------
sram_256x8 mem_u0 (.CLK(i_clk), .CEN(sram_cen[0]), .WEN(sram_wen[0]), .A(sram_addr[0]), .D(sram_data_write[0]), .Q(sram_data_read[0]));
sram_256x8 mem_u1 (.CLK(i_clk), .CEN(sram_cen[1]), .WEN(sram_wen[1]), .A(sram_addr[1]), .D(sram_data_write[1]), .Q(sram_data_read[1]));
sram_256x8 mem_u2 (.CLK(i_clk), .CEN(sram_cen[2]), .WEN(sram_wen[2]), .A(sram_addr[2]), .D(sram_data_write[2]), .Q(sram_data_read[2]));
sram_256x8 mem_u3 (.CLK(i_clk), .CEN(sram_cen[3]), .WEN(sram_wen[3]), .A(sram_addr[3]), .D(sram_data_write[3]), .Q(sram_data_read[3]));
sram_256x8 mem_u4 (.CLK(i_clk), .CEN(sram_cen[4]), .WEN(sram_wen[4]), .A(sram_addr[4]), .D(sram_data_write[4]), .Q(sram_data_read[4]));
sram_256x8 mem_u5 (.CLK(i_clk), .CEN(sram_cen[5]), .WEN(sram_wen[5]), .A(sram_addr[5]), .D(sram_data_write[5]), .Q(sram_data_read[5]));
sram_256x8 mem_u6 (.CLK(i_clk), .CEN(sram_cen[6]), .WEN(sram_wen[6]), .A(sram_addr[6]), .D(sram_data_write[6]), .Q(sram_data_read[6]));
sram_256x8 mem_u7 (.CLK(i_clk), .CEN(sram_cen[7]), .WEN(sram_wen[7]), .A(sram_addr[7]), .D(sram_data_write[7]), .Q(sram_data_read[7]));

// SRAM Chip Enable
/*always@*
	if (state == IDLE)
		for (i = 0; i < 8; i = i+1)
			// sram_cen[i] = 1;
			sram_cen[i] = 0;
	else
		for (i = 0; i < 8; i = i+1)
			sram_cen[i] = 0;*/	

/*always@*
	for (i = 0; i < 8; i = i+1)
		sram_cen[i] = 0;*/

assign sram_cen[0] = 0;
assign sram_cen[1] = 0;
assign sram_cen[2] = 0;
assign sram_cen[3] = 0;
assign sram_cen[4] = 0;
assign sram_cen[5] = 0;
assign sram_cen[6] = 0;
assign sram_cen[7] = 0;

// SRAM Write Enable	
always@*
	if (state == MAP_LOAD)
		for (i = 0; i < 8; i = i+1)
			if (sram_write_idx == i)
				sram_wen[i] = 0;
			else
				sram_wen[i] = 1;					
	else
		for (i = 0; i < 8; i = i+1)
			sram_wen[i] = 1;		

// SRAM Write Data
always@*
	if (state == MAP_LOAD)
		for (i = 0; i < 8; i = i+1)
			if (sram_write_idx == i)
				sram_data_write[i] = i_in_data_r;
			else
				sram_data_write[i] = 0;					
	else
		for (i = 0; i < 8; i = i+1)
			sram_data_write[i] = 0;	

// SRAM Addr
always@*
	if(state == MAP_LOAD)
		for (i = 0; i < 8; i = i+1)
			if (sram_write_idx == i)
				sram_addr[i] = sram_addr_write;
			else
				sram_addr[i] = 0;
	else if (state == DISP)
		for (i = 0; i < 8; i = i+1)
			if (sram_disp_read_idx == i)
				sram_addr[i] = sram_addr_disp_read;
			else
				sram_addr[i] = 0;
	else if (state == CONV_LOAD)
		for (i = 0; i < 8; i = i+1)
			sram_addr[i] = sram_addr_conv[i];	
	else if (state == SOBEL_LOAD)
		for (i = 0; i < 8; i = i+1)
			sram_addr[i] = sram_addr_sobel[i];
	else if (state == MEDIAN_LOAD)
		for (i = 0; i < 8; i = i+1)
			sram_addr[i] = sram_addr_median[i];
	else
		for (i = 0; i < 8; i = i+1)
			sram_addr[i] = 0;



// SRAM Write Index and Addr at MAP_LOAD state
always@*
	case(map_load_cnt[3:0])
		4'd0:    sram_write_idx = 3'd0;
		4'd1:    sram_write_idx = 3'd1;
		4'd2:    sram_write_idx = 3'd2;
		4'd3:    sram_write_idx = 3'd3;
		4'd4:    sram_write_idx = 3'd0;
		4'd5:    sram_write_idx = 3'd1;
		4'd6:    sram_write_idx = 3'd2;
		4'd7:    sram_write_idx = 3'd3;
		4'd8:    sram_write_idx = 3'd4;
		4'd9:    sram_write_idx = 3'd5;
		4'd10:   sram_write_idx = 3'd6;
		4'd11:   sram_write_idx = 3'd7;
		4'd12:   sram_write_idx = 3'd4;
		4'd13:   sram_write_idx = 3'd5;
		4'd14:   sram_write_idx = 3'd6;
		4'd15:   sram_write_idx = 3'd7;
		default: sram_write_idx = 3'd0;
	endcase		
/*always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		sram_write_idx <= 0;
	else
		case(map_load_cnt[3:0])
			4'd0:    sram_write_idx <= 3'd0;
			4'd1:    sram_write_idx <= 3'd1;
			4'd2:    sram_write_idx <= 3'd2;
			4'd3:    sram_write_idx <= 3'd3;
			4'd4:    sram_write_idx <= 3'd0;
			4'd5:    sram_write_idx <= 3'd1;
			4'd6:    sram_write_idx <= 3'd2;
			4'd7:    sram_write_idx <= 3'd3;
			4'd8:    sram_write_idx <= 3'd4;
			4'd9:    sram_write_idx <= 3'd5;
			4'd10:   sram_write_idx <= 3'd6;
			4'd11:   sram_write_idx <= 3'd7;
			4'd12:   sram_write_idx <= 3'd4;
			4'd13:   sram_write_idx <= 3'd5;
			4'd14:   sram_write_idx <= 3'd6;
			4'd15:   sram_write_idx <= 3'd7;
			default: sram_write_idx <= 3'd0;
		endcase	*/



always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		sram_addr_write_offset <= 0;
	else
		// if ((state == MAP_LOAD) && (map_load_cnt[3:0] == 4'd15))
		 if ((state == MAP_LOAD) && (map_load_cnt[3:0] == 4'd15) && i_in_valid_r)
			sram_addr_write_offset <= sram_addr_write_offset + 2'd2;
		else if (state == MAP_LOAD)
			sram_addr_write_offset <= sram_addr_write_offset;
		else
			sram_addr_write_offset <= 0;

wire sram_addr_write_shift;

assign sram_addr_write_shift = map_load_cnt[2];
/*always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		sram_addr_write <= 0;
	else
		sram_addr_write <= sram_addr_write_offset + sram_addr_write_shift;*/
always@*
	sram_addr_write = sram_addr_write_offset + sram_addr_write_shift;


// Delay 1 Cycle for Input Reg
reg map_load_op;
/*always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		map_load_op <= 0;
	else
		if ((state == MAP_LOAD) && (~map_load_end))
			map_load_op <= 1;
		else
			map_load_op <= 0;		*/
always@*
	map_load_op = (state == MAP_LOAD);

// Counter at MAP_LOAD state
always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		map_load_cnt <= 0;
	else
		// if(map_load_op)
		if (i_in_valid_r && map_load_op)
			map_load_cnt <= map_load_cnt + 1'b1;
		else if (map_load_op)
			map_load_cnt <= map_load_cnt;
		else
			map_load_cnt <= 0;

// Input Load Complete
always@*
	if ((state == MAP_LOAD) && (map_load_cnt == 12'd2047))
		map_load_end = 1;
	else
		map_load_end = 0;


// -------------------------------------------------------- Input Register -------------------------------------------------------- 
always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		i_op_valid_r <= 0;
	else
		i_op_valid_r <= i_op_valid;

always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		i_op_mode_r <= 0;
	else
		i_op_mode_r <= i_op_mode;

always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		i_in_valid_r <= 0;
	else
		i_in_valid_r <= i_in_valid;

always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		i_in_data_r <= 0;
	else
		i_in_data_r <= i_in_data; 


// -------------------------------------------------------- Origin Location -------------------------------------------------------- 
always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		origin_x <= 0;
	else
		if ((state == R_SHIFT) && (origin_x != 3'd6))
			origin_x <= origin_x + 1'b1;
		else if ((state == L_SHIFT) && (origin_x != 3'd0))
			origin_x <= origin_x - 1'b1;
		else
			origin_x <= origin_x;

always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		origin_y <= 0;
	else
		if ((state == U_SHIFT) && (origin_y != 3'd0))
			origin_y <= origin_y - 1'b1;
		else if ((state == D_SHIFT) && (origin_y != 3'd6))
			origin_y <= origin_y + 1'b1;
		else
			origin_y <= origin_y;

assign r_shift_end = (state == R_SHIFT);
assign l_shift_end = (state == L_SHIFT);
assign u_shift_end = (state == U_SHIFT);
assign d_shift_end = (state == D_SHIFT);



// -------------------------------------------------------- Input Data for PE -------------------------------------------------------- 
// SRAM Addr Decoder for Data
always@*
	case({origin_mode[4:3], origin_mode[0]})
		3'b00_0: begin
			sram_addr_decoder[0] = 3'd7;
			sram_addr_decoder[1] = 3'd4;
			sram_addr_decoder[2] = 3'd5;
			sram_addr_decoder[3] = 3'd6;
			sram_addr_decoder[4] = 3'd3;
			sram_addr_decoder[5] = 3'd0;
			sram_addr_decoder[6] = 3'd1;
			sram_addr_decoder[7] = 3'd2;
		end
		3'b00_1: begin
			sram_addr_decoder[0] = 3'd3;
			sram_addr_decoder[1] = 3'd0;
			sram_addr_decoder[2] = 3'd1;
			sram_addr_decoder[3] = 3'd2;
			sram_addr_decoder[4] = 3'd7;
			sram_addr_decoder[5] = 3'd4;
			sram_addr_decoder[6] = 3'd5;
			sram_addr_decoder[7] = 3'd6;
		end
		3'b01_0: begin
			sram_addr_decoder[0] = 3'd4;
			sram_addr_decoder[1] = 3'd5;
			sram_addr_decoder[2] = 3'd6;
			sram_addr_decoder[3] = 3'd7;
			sram_addr_decoder[4] = 3'd0;
			sram_addr_decoder[5] = 3'd1;
			sram_addr_decoder[6] = 3'd2;
			sram_addr_decoder[7] = 3'd3;
		end
		3'b01_1: begin
			sram_addr_decoder[0] = 3'd0;
			sram_addr_decoder[1] = 3'd1;
			sram_addr_decoder[2] = 3'd2;
			sram_addr_decoder[3] = 3'd3;
			sram_addr_decoder[4] = 3'd4;
			sram_addr_decoder[5] = 3'd5;
			sram_addr_decoder[6] = 3'd6;
			sram_addr_decoder[7] = 3'd7;
		end
		3'b10_0: begin
			sram_addr_decoder[0] = 3'd5;
			sram_addr_decoder[1] = 3'd6;
			sram_addr_decoder[2] = 3'd7;
			sram_addr_decoder[3] = 3'd4;
			sram_addr_decoder[4] = 3'd1;
			sram_addr_decoder[5] = 3'd2;
			sram_addr_decoder[6] = 3'd3;
			sram_addr_decoder[7] = 3'd0;
		end
		3'b10_1: begin
			sram_addr_decoder[0] = 3'd1;
			sram_addr_decoder[1] = 3'd2;
			sram_addr_decoder[2] = 3'd3;
			sram_addr_decoder[3] = 3'd0;
			sram_addr_decoder[4] = 3'd5;
			sram_addr_decoder[5] = 3'd6;
			sram_addr_decoder[6] = 3'd7;
			sram_addr_decoder[7] = 3'd4;
		end
		3'b11_0: begin
			sram_addr_decoder[0] = 3'd6;
			sram_addr_decoder[1] = 3'd7;
			sram_addr_decoder[2] = 3'd4;
			sram_addr_decoder[3] = 3'd5;
			sram_addr_decoder[4] = 3'd2;
			sram_addr_decoder[5] = 3'd3;
			sram_addr_decoder[6] = 3'd0;
			sram_addr_decoder[7] = 3'd1;
		end
		3'b11_1: begin
			sram_addr_decoder[0] = 3'd2;
			sram_addr_decoder[1] = 3'd3;
			sram_addr_decoder[2] = 3'd0;
			sram_addr_decoder[3] = 3'd1;
			sram_addr_decoder[4] = 3'd6;
			sram_addr_decoder[5] = 3'd7;
			sram_addr_decoder[6] = 3'd4;
			sram_addr_decoder[7] = 3'd5;
		end
		default: begin
			sram_addr_decoder[0] = 3'd0;
			sram_addr_decoder[1] = 3'd0;
			sram_addr_decoder[2] = 3'd0;
			sram_addr_decoder[3] = 3'd0;
			sram_addr_decoder[4] = 3'd0;
			sram_addr_decoder[5] = 3'd0;
			sram_addr_decoder[6] = 3'd0;
			sram_addr_decoder[7] = 3'd0;		
		end
	endcase	

// SRAM Addr Encoder for Data
always@*
	case({origin_mode[4:3], origin_mode[0]})
		3'b00_0: begin
			sram_addr_encoder[0] = 3'd5;
			sram_addr_encoder[1] = 3'd6;
			sram_addr_encoder[2] = 3'd7;
			sram_addr_encoder[3] = 3'd4;
			sram_addr_encoder[4] = 3'd1;
			sram_addr_encoder[5] = 3'd2;
			sram_addr_encoder[6] = 3'd3;
			sram_addr_encoder[7] = 3'd0;
		end
		3'b00_1: begin
			sram_addr_encoder[0] = 3'd1;
			sram_addr_encoder[1] = 3'd2;
			sram_addr_encoder[2] = 3'd3;
			sram_addr_encoder[3] = 3'd0;
			sram_addr_encoder[4] = 3'd5;
			sram_addr_encoder[5] = 3'd6;
			sram_addr_encoder[6] = 3'd7;
			sram_addr_encoder[7] = 3'd4;
		end
		3'b01_0: begin
			sram_addr_encoder[0] = 3'd4;
			sram_addr_encoder[1] = 3'd5;
			sram_addr_encoder[2] = 3'd6;
			sram_addr_encoder[3] = 3'd7;
			sram_addr_encoder[4] = 3'd0;
			sram_addr_encoder[5] = 3'd1;
			sram_addr_encoder[6] = 3'd2;
			sram_addr_encoder[7] = 3'd3;
		end
		3'b01_1: begin
			sram_addr_encoder[0] = 3'd0;
			sram_addr_encoder[1] = 3'd1;
			sram_addr_encoder[2] = 3'd2;
			sram_addr_encoder[3] = 3'd3;
			sram_addr_encoder[4] = 3'd4;
			sram_addr_encoder[5] = 3'd5;
			sram_addr_encoder[6] = 3'd6;
			sram_addr_encoder[7] = 3'd7;
		end
		3'b10_0: begin
			sram_addr_encoder[0] = 3'd7;
			sram_addr_encoder[1] = 3'd5;
			sram_addr_encoder[2] = 3'd5;
			sram_addr_encoder[3] = 3'd6;
			sram_addr_encoder[4] = 3'd3;
			sram_addr_encoder[5] = 3'd0;
			sram_addr_encoder[6] = 3'd1;
			sram_addr_encoder[7] = 3'd2;
		end
		3'b10_1: begin
			sram_addr_encoder[0] = 3'd3;
			sram_addr_encoder[1] = 3'd0;
			sram_addr_encoder[2] = 3'd1;
			sram_addr_encoder[3] = 3'd2;
			sram_addr_encoder[4] = 3'd7;
			sram_addr_encoder[5] = 3'd4;
			sram_addr_encoder[6] = 3'd5;
			sram_addr_encoder[7] = 3'd6;
		end
		3'b11_0: begin
			sram_addr_encoder[0] = 3'd6;
			sram_addr_encoder[1] = 3'd7;
			sram_addr_encoder[2] = 3'd4;
			sram_addr_encoder[3] = 3'd5;
			sram_addr_encoder[4] = 3'd2;
			sram_addr_encoder[5] = 3'd3;
			sram_addr_encoder[6] = 3'd0;
			sram_addr_encoder[7] = 3'd1;
		end
		3'b11_1: begin
			sram_addr_encoder[0] = 3'd2;
			sram_addr_encoder[1] = 3'd3;
			sram_addr_encoder[2] = 3'd0;
			sram_addr_encoder[3] = 3'd1;
			sram_addr_encoder[4] = 3'd6;
			sram_addr_encoder[5] = 3'd7;
			sram_addr_encoder[6] = 3'd4;
			sram_addr_encoder[7] = 3'd5;
		end
		default: begin
			sram_addr_encoder[0] = 3'd0;
			sram_addr_encoder[1] = 3'd0;
			sram_addr_encoder[2] = 3'd0;
			sram_addr_encoder[3] = 3'd0;
			sram_addr_encoder[4] = 3'd0;
			sram_addr_encoder[5] = 3'd0;
			sram_addr_encoder[6] = 3'd0;
			sram_addr_encoder[7] = 3'd0;
		end
	endcase

/*always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n) 
		for (i = 0; i < 8; i = i+1)
			sram_data_read_r[i] <= 0;
	else
		for (i = 0; i < 8; i = i+1)
			sram_data_read_r[i] <= sram_data_read[i];	*/
always@* begin
	unit_in_data_0 = sram_data_read[sram_addr_decoder[0]];
	unit_in_data_1 = sram_data_read[sram_addr_decoder[1]];
	unit_in_data_2 = sram_data_read[sram_addr_decoder[2]];
	unit_in_data_3 = sram_data_read[sram_addr_decoder[3]];
	unit_in_data_4 = sram_data_read[sram_addr_decoder[4]];
	unit_in_data_5 = sram_data_read[sram_addr_decoder[5]];
	unit_in_data_6 = sram_data_read[sram_addr_decoder[6]];
	unit_in_data_7 = sram_data_read[sram_addr_decoder[7]];
end

/*always@* begin
	unit_in_data_0 = sram_data_read_r[sram_addr_decoder[0]];
	unit_in_data_1 = sram_data_read_r[sram_addr_decoder[1]];
	unit_in_data_2 = sram_data_read_r[sram_addr_decoder[2]];
	unit_in_data_3 = sram_data_read_r[sram_addr_decoder[3]];
	unit_in_data_4 = sram_data_read_r[sram_addr_decoder[4]];
	unit_in_data_5 = sram_data_read_r[sram_addr_decoder[5]];
	unit_in_data_6 = sram_data_read_r[sram_addr_decoder[6]];
	unit_in_data_7 = sram_data_read_r[sram_addr_decoder[7]];
end*/


// Consider Padding of the Boundary
always@*
	case(state)
		CONV_LOAD:   data_mode = conv_mode;
		// SOBEL_LOAD:  data_mode = sobel_mode[0];
		SOBEL_LOAD:  data_mode = sobel_mode_read;
		/*SOBEL_LOAD:  
			if (sobel_channel == 0)
				data_mode = sobel_mode[0];
			else
				data_mode = ~sobel_mode[0];*/
		// MEDIAN_LOAD: data_mode = median_mode;
	    // MEDIAN_LOAD: data_mode = median_cnt[0];
		MEDIAN_LOAD: 
			if (median_channel != 0)
				data_mode = median_mode_read_d1; 
			else
				data_mode = median_mode_read; 
		default:     data_mode = 0;
	endcase

// Data Mode delay 1 cycle for input
always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		data_mode_d1 <= 0;
	else
		data_mode_d1 <= data_mode;

// Location 0
always@* 
	if (origin_x == 3'd0)
		unit_in_data_0_pad = 0;
	else if (origin_y == 3'd0)
		case(data_mode_d1)
			1'b0:    unit_in_data_0_pad = 0;
			1'b1:    unit_in_data_0_pad = unit_in_data_0;
			default: unit_in_data_0_pad = unit_in_data_0;
		endcase
	else
		unit_in_data_0_pad = unit_in_data_0;

// Location 1
always@* 
	if (origin_y == 3'd0)
		case(data_mode_d1)
			1'b0:    unit_in_data_1_pad = 0;
			1'b1:    unit_in_data_1_pad = unit_in_data_1;
			default: unit_in_data_1_pad = unit_in_data_1;
		endcase
	else
		unit_in_data_1_pad = unit_in_data_1;

// Location 2
always@* 
	if (origin_y == 3'd0)
		case(data_mode_d1)
			1'b0:    unit_in_data_2_pad = 0;
			1'b1:    unit_in_data_2_pad = unit_in_data_2;
			default: unit_in_data_2_pad = unit_in_data_2;
		endcase
	else
		unit_in_data_2_pad = unit_in_data_2;

// Location 3
always@* 
	if (origin_x == 3'd6)
		unit_in_data_3_pad = 0;
	else if (origin_y == 3'd0)
		case(data_mode_d1)
			1'b0:    unit_in_data_3_pad = 0;
			1'b1:    unit_in_data_3_pad = unit_in_data_3;
			default: unit_in_data_3_pad = unit_in_data_3;
		endcase
	else
		unit_in_data_3_pad = unit_in_data_3;


// Location 4
always@* 
	if (origin_x == 3'd0)
		unit_in_data_4_pad = 0;
	else if (origin_y == 3'd6)
		case(data_mode_d1)
			1'b0:    unit_in_data_4_pad = unit_in_data_4;
			1'b1:    unit_in_data_4_pad = 0;
			default: unit_in_data_4_pad = unit_in_data_4;
		endcase
	else
		unit_in_data_4_pad = unit_in_data_4;

// Location 5
always@* 
	if (origin_y == 3'd6)
		case(data_mode_d1)
			1'b0:    unit_in_data_5_pad = unit_in_data_5;
			1'b1:    unit_in_data_5_pad = 0;
			default: unit_in_data_5_pad = unit_in_data_5;
		endcase
	else
		unit_in_data_5_pad = unit_in_data_5;

// Location 6
always@* 
	if (origin_y == 3'd6)
		case(data_mode_d1)
			1'b0:    unit_in_data_6_pad = unit_in_data_6;
			1'b1:    unit_in_data_6_pad = 0;
			default: unit_in_data_6_pad = unit_in_data_6;
		endcase
	else
		unit_in_data_6_pad = unit_in_data_6;

// Location 7
always@* 
	if (origin_x == 3'd6)
		unit_in_data_7_pad = 0;
	else if (origin_y == 3'd6)
		case(data_mode_d1)
			1'b0:    unit_in_data_7_pad = unit_in_data_7;
			1'b1:    unit_in_data_7_pad = 0;
			default: unit_in_data_7_pad = unit_in_data_7;
		endcase
	else
		unit_in_data_7_pad = unit_in_data_7;


// ----------------------------------------------------- Addr Shift for different mode ----------------------------------------------------- 
// Calculate Addr shiter for 8 different pixels
reg [2:0] data_loc_x [0:7]; 
reg [2:0] data_loc_y [0:7]; 

always@* begin
	case(data_mode)
		1'b0: begin
			data_loc_x[0] = origin_x - 2'd1;
			data_loc_y[0] = origin_y - 2'd1;
		end
		1'b1: begin
			data_loc_x[0] = origin_x - 2'd1;
			data_loc_y[0] = origin_y + 2'd1;
		end	
		default: begin
			data_loc_x[0] = 0;
			data_loc_y[0] = 0;
		end
	endcase
end

always@* begin
	case(data_mode)
		1'b0: begin
			data_loc_x[1] = origin_x;
			data_loc_y[1] = origin_y - 2'd1;
		end
		1'b1: begin
			data_loc_x[1] = origin_x;
			data_loc_y[1] = origin_y + 2'd1;
		end	
		default: begin
			data_loc_x[1] = 0;
			data_loc_y[1] = 0;
		end
	endcase
end

always@* begin
	case(data_mode)
		1'b0: begin
			data_loc_x[2] = origin_x + 2'd1;
			data_loc_y[2] = origin_y - 2'd1;
		end
		1'b1: begin
			data_loc_x[2] = origin_x + 2'd1;
			data_loc_y[2] = origin_y + 2'd1;
		end	
		default: begin
			data_loc_x[2] = 0;
			data_loc_y[2] = 0;
		end
	endcase
end

always@* begin
	case(data_mode)
		1'b0: begin
			data_loc_x[3] = origin_x + 2'd2;
			data_loc_y[3] = origin_y - 2'd1;
		end
		1'b1: begin
			data_loc_x[3] = origin_x + 2'd2;
			data_loc_y[3] = origin_y + 2'd1;
		end	
		default: begin
			data_loc_x[3] = 0;
			data_loc_y[3] = 0;
		end
	endcase
end

always@* begin
	case(data_mode)
		1'b0: begin
			data_loc_x[4] = origin_x - 2'd1;
			data_loc_y[4] = origin_y;
		end
		1'b1: begin
			data_loc_x[4] = origin_x - 2'd1;
			data_loc_y[4] = origin_y + 2'd2;
		end	
		default: begin
			data_loc_x[4] = 0;
			data_loc_y[4] = 0;
		end
	endcase
end

always@* begin
	case(data_mode)
		1'b0: begin
			data_loc_x[5] = origin_x;
			data_loc_y[5] = origin_y;
		end
		1'b1: begin
			data_loc_x[5] = origin_x;
			data_loc_y[5] = origin_y + 2'd2;
		end	
		default: begin
			data_loc_x[5] = 0;
			data_loc_y[5] = 0;
		end
	endcase
end

always@* begin
	case(data_mode)
		1'b0: begin
			data_loc_x[6] = origin_x + 2'd1;
			data_loc_y[6] = origin_y;
		end
		1'b1: begin
			data_loc_x[6] = origin_x + 2'd1;
			data_loc_y[6] = origin_y + 2'd2;
		end	
		default: begin
			data_loc_x[6] = 0;
			data_loc_y[6] = 0;
		end
	endcase
end

always@* begin
	case(data_mode)
		1'b0: begin
			data_loc_x[7] = origin_x + 2'd2;
			data_loc_y[7] = origin_y;
		end
		1'b1: begin
			data_loc_x[7] = origin_x + 2'd2;
			data_loc_y[7] = origin_y + 2'd2;
		end	
		default: begin
			data_loc_x[7] = 0;
			data_loc_y[7] = 0;
		end
	endcase
end

always@* 
	for (i = 0; i < 8; i = i+1) begin
		sram_addr_read_y_shift[i] = data_loc_y[i][2:1] << 1;
		sram_addr_read_x_shift[i] = data_loc_x[i][2];
	end

// -------------------------------------------------------- Depth Scaling -------------------------------------------------------- 
// Mode: 0:32, 1:16, 2: 8
always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		scale_mode <= 0;
	else
		if ((state == DEPTH_RED) && (scale_mode != 2'd2))
			scale_mode <= scale_mode + 1'b1;
		else if ((state == DEPTH_INC) && (scale_mode != 2'd0))
			scale_mode <= scale_mode - 1'b1;	
		else
			scale_mode <= scale_mode;

assign depth_red_end = (state == DEPTH_RED);
assign depth_inc_end = (state == DEPTH_INC);						


// -------------------------------------------------------- Display Region --------------------------------------------------------
reg [7:0] sram_addr_disp_read_offset;
always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		disp_cnt <= 0;
	else 
		if (state == DISP)
			disp_cnt <= disp_cnt + 1'b1;
		else 
			disp_cnt <= 0;

assign origin_mode = {origin_x, origin_y};
always@*
	case({origin_mode[4:3], origin_mode[0]})
		3'b00_0: 
			case(disp_cnt[1:0])
				2'b00:   sram_disp_read_idx = 3'd0;
				2'b01:   sram_disp_read_idx = 3'd1;
				2'b10:   sram_disp_read_idx = 3'd4;
				2'b11:   sram_disp_read_idx = 3'd5;
				default: sram_disp_read_idx = 3'd0;				
			endcase
		3'b00_1: 
			case(disp_cnt[1:0])
				2'b00:   sram_disp_read_idx = 3'd4;
				2'b01:   sram_disp_read_idx = 3'd5;
				2'b10:   sram_disp_read_idx = 3'd0;
				2'b11:   sram_disp_read_idx = 3'd1;
				default: sram_disp_read_idx = 3'd0;				
			endcase
		3'b01_0: 
			case(disp_cnt[1:0])
				2'b00:   sram_disp_read_idx = 3'd1;
				2'b01:   sram_disp_read_idx = 3'd2;
				2'b10:   sram_disp_read_idx = 3'd5;
				2'b11:   sram_disp_read_idx = 3'd6;
				default: sram_disp_read_idx = 3'd0;				
			endcase
		3'b01_1: 
			case(disp_cnt[1:0])
				2'b00:   sram_disp_read_idx = 3'd5;
				2'b01:   sram_disp_read_idx = 3'd6;
				2'b10:   sram_disp_read_idx = 3'd1;
				2'b11:   sram_disp_read_idx = 3'd2;
				default: sram_disp_read_idx = 3'd0;				
			endcase		
		3'b10_0: 
			case(disp_cnt[1:0])
				2'b00:   sram_disp_read_idx = 3'd2;
				2'b01:   sram_disp_read_idx = 3'd3;
				2'b10:   sram_disp_read_idx = 3'd6;
				2'b11:   sram_disp_read_idx = 3'd7;
				default: sram_disp_read_idx = 3'd0;				
			endcase
		3'b10_1: 
			case(disp_cnt[1:0])
				2'b00:   sram_disp_read_idx = 3'd6;
				2'b01:   sram_disp_read_idx = 3'd7;
				2'b10:   sram_disp_read_idx = 3'd2;
				2'b11:   sram_disp_read_idx = 3'd3;
				default: sram_disp_read_idx = 3'd0;				
			endcase		
		3'b11_0: 
			case(disp_cnt[1:0])
				2'b00:   sram_disp_read_idx = 3'd3;
				2'b01:   sram_disp_read_idx = 3'd0;
				2'b10:   sram_disp_read_idx = 3'd7;
				2'b11:   sram_disp_read_idx = 3'd4;
				default: sram_disp_read_idx = 3'd0;				
			endcase
		3'b11_1: 
			case(disp_cnt[1:0])
				2'b00:   sram_disp_read_idx = 3'd7;
				2'b01:   sram_disp_read_idx = 3'd4;
				2'b10:   sram_disp_read_idx = 3'd3;
				2'b11:   sram_disp_read_idx = 3'd0;
				default: sram_disp_read_idx = 3'd0;				
			endcase		
		default: sram_disp_read_idx = 3'd0;
	endcase

always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		sram_addr_disp_read_offset <= 0;
	else
		if ((state == DISP) && (disp_cnt[1:0] == 2'd3))
			sram_addr_disp_read_offset <= sram_addr_disp_read_offset + 4'd8;
		else if (state == DISP)
			sram_addr_disp_read_offset <= sram_addr_disp_read_offset;
		else
			sram_addr_disp_read_offset <= 0;

reg [2:0] disp_cur_x;
reg [2:0] disp_cur_y;
wire sram_addr_disp_read_x_shift;
wire [2:0] sram_addr_disp_read_y_shift;

always@*
	case(disp_cnt[1:0])
		2'b00: begin
			disp_cur_x = origin_x;
			disp_cur_y = origin_y;
		end
		2'b01: begin
			disp_cur_x = origin_x + 1'b1;
			disp_cur_y = origin_y;
		end
		2'b10: begin
			disp_cur_x = origin_x;
			disp_cur_y = origin_y + 1'b1;
		end
		2'b11: begin
			disp_cur_x = origin_x + 1'b1;
			disp_cur_y = origin_y + 1'b1;
		end
		default: begin
			disp_cur_x = 0;
			disp_cur_y = 0;
		end
	endcase

assign sram_addr_disp_read_y_shift = disp_cur_y[2:1] << 1;
assign sram_addr_disp_read_x_shift = disp_cur_x[2];


always@*
	sram_addr_disp_read = sram_addr_disp_read_offset + sram_addr_disp_read_x_shift + sram_addr_disp_read_y_shift;

// Display Complete
always@*
	if ((state == DISP) && (disp_cnt == 8'd128) && (scale_mode == 2'd0))          
		disp_end = 1;
	else if ((state == DISP) && (disp_cnt == 8'd64) && (scale_mode == 2'd1))    
		disp_end = 1;
	else if ((state == DISP) && (disp_cnt == 8'd32) && (scale_mode == 2'd2))
		disp_end = 1;
	else
		disp_end = 0;

// Delay Index for SRAM
always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		sram_disp_read_idx_delay <= 0;
	else
		sram_disp_read_idx_delay <= sram_disp_read_idx;


// Output Valid for DISP
always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		out_valid_disp <= 0;
	else
		if (state == DISP)
			out_valid_disp <= 1;
		else
			out_valid_disp <= 0;



// DISP Output
assign sram_disp_out = sram_data_read[sram_disp_read_idx_delay];


// -------------------------------------------------------- Convolution Instance -------------------------------------------------------- 
/*conv_unit conv_u0 (.i_clk(i_clk), .i_rst_n(i_rst_n), .conv_mode(conv_mode), .conv_active(conv_active), .conv_clear(conv_clear),
				   .i_in_data_0(unit_in_data_0_pad), .i_in_data_1(unit_in_data_1_pad), .i_in_data_2(unit_in_data_2_pad), .i_in_data_3(unit_in_data_3_pad),
				   .i_in_data_4(unit_in_data_4_pad), .i_in_data_5(unit_in_data_5_pad), .i_in_data_6(unit_in_data_6_pad), .i_in_data_7(unit_in_data_7_pad),
				   .o_out_data_0(conv_out_data_0), .o_out_data_1(conv_out_data_1), .o_out_data_2(conv_out_data_2), .o_out_data_3(conv_out_data_3));*/

always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		conv_cnt <= 0;
	else
		if (state == CONV_LOAD && ~conv_load_end)
			conv_cnt <= conv_cnt + 1'b1;
		else if (state == CONV_OUT && ~conv_out_end)
			conv_cnt <= conv_cnt + 1'b1;		
		else
			conv_cnt <= 0;

// Mode determined by LSB of the counter
assign conv_mode = conv_cnt[0];

always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		conv_active <= 0;
	else
		if ((state == CONV_LOAD) && (conv_cnt >= 8'd1) && ~conv_load_end)
			conv_active <= 1;
		else
			conv_active <= 0;

assign conv_clear          = (state == IDLE);
assign conv_read_valid     = (conv_cnt > 8'd2);


// Conv Load Complete
always@*
	/*if ((state == CONV_LOAD) && (conv_cnt == 8'd65) && (scale_mode == 2'd0))          
		conv_load_end = 1;
	else if ((state == CONV_LOAD) && (conv_cnt == 8'd33) && (scale_mode == 2'd1))    
		conv_load_end = 1;
	else if ((state == CONV_LOAD) && (conv_cnt == 8'd17) && (scale_mode == 2'd2))
		conv_load_end = 1;*/
	if ((state == CONV_LOAD) && (conv_cnt == 8'd66) && (scale_mode == 2'd0))          
		conv_load_end = 1;
	else if ((state == CONV_LOAD) && (conv_cnt == 8'd34) && (scale_mode == 2'd1))    
		conv_load_end = 1;
	else if ((state == CONV_LOAD) && (conv_cnt == 8'd18) && (scale_mode == 2'd2))
		conv_load_end = 1;
	else
		conv_load_end = 0;

// Conv Out Complete
always@*
	if ((state == CONV_OUT) && (conv_cnt == 8'd3))          
		conv_out_end = 1;
	else
		conv_out_end = 0;

// ------------------------------------------------------ Convolution SRAM Addr ------------------------------------------------------ 

// Conv Read SRAM Addr Offset
reg [7:0] sram_addr_conv_read_offset;
always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		sram_addr_conv_read_offset <= 0;
	else 
		if ((state == CONV_LOAD) && (conv_cnt[0] == 1'b1))
			sram_addr_conv_read_offset <= sram_addr_conv_read_offset + 4'd8;
		else if (state == CONV_LOAD)
			sram_addr_conv_read_offset <= sram_addr_conv_read_offset;
		else
			sram_addr_conv_read_offset <= 0;


always@* begin
	sram_addr_conv[0] = sram_addr_conv_read_offset + sram_addr_read_x_shift[sram_addr_encoder[0]] + sram_addr_read_y_shift[sram_addr_encoder[0]];
	sram_addr_conv[1] = sram_addr_conv_read_offset + sram_addr_read_x_shift[sram_addr_encoder[1]] + sram_addr_read_y_shift[sram_addr_encoder[1]];
	sram_addr_conv[2] = sram_addr_conv_read_offset + sram_addr_read_x_shift[sram_addr_encoder[2]] + sram_addr_read_y_shift[sram_addr_encoder[2]];
	sram_addr_conv[3] = sram_addr_conv_read_offset + sram_addr_read_x_shift[sram_addr_encoder[3]] + sram_addr_read_y_shift[sram_addr_encoder[3]];
	sram_addr_conv[4] = sram_addr_conv_read_offset + sram_addr_read_x_shift[sram_addr_encoder[4]] + sram_addr_read_y_shift[sram_addr_encoder[4]];
	sram_addr_conv[5] = sram_addr_conv_read_offset + sram_addr_read_x_shift[sram_addr_encoder[5]] + sram_addr_read_y_shift[sram_addr_encoder[5]];
	sram_addr_conv[6] = sram_addr_conv_read_offset + sram_addr_read_x_shift[sram_addr_encoder[6]] + sram_addr_read_y_shift[sram_addr_encoder[6]];
	sram_addr_conv[7] = sram_addr_conv_read_offset + sram_addr_read_x_shift[sram_addr_encoder[7]] + sram_addr_read_y_shift[sram_addr_encoder[7]];
end

// ------------------------------------------------------ Convolution Output ------------------------------------------------------ 
always@*
	case(conv_cnt[1:0])
		/*2'd0:    conv_data_out = conv_out_data_0;
		2'd1:    conv_data_out = conv_out_data_1;
		2'd2:    conv_data_out = conv_out_data_2;
		2'd3:    conv_data_out = conv_out_data_3;*/
		2'd0:    conv_data_out = sobel_out_data_0;
		2'd1:    conv_data_out = sobel_out_data_1;
		2'd2:    conv_data_out = sobel_out_data_2;
		2'd3:    conv_data_out = sobel_out_data_3;
		default: conv_data_out = 0;  
	endcase

always@*
	if (state == CONV_OUT)
		out_valid_conv = 1;
	else
		out_valid_conv = 0;		



// -------------------------------------------------------- Sobel Instance -------------------------------------------------------- 
// parameter [2:0] SOBEL_IDLE = 3'd0, SOBEL_READ = 3'd1, SOBEL_COMP_G = 3'd2, SOBEL_COMP_ANGLE = 3'd3, SOBEL_NMS = 3'd4;
parameter [2:0] SOBEL_IDLE = 3'd0, SOBEL_READ = 3'd1, SOBEL_COMP_G = 3'd2, SOBEL_COMP_ANGLE = 3'd3, SOBEL_NMS = 3'd4, SOBEL_WAIT = 3'd5;
processing_unit # (.CONV_LOAD(CONV_LOAD), .CONV_OUT(CONV_OUT), .SOBEL_LOAD(SOBEL_LOAD), .IDLE(IDLE),
				   .SOBEL_IDLE(SOBEL_IDLE), .SOBEL_READ(SOBEL_READ),  .SOBEL_COMP_G(SOBEL_COMP_G), .SOBEL_COMP_ANGLE(SOBEL_COMP_ANGLE),
                   .SOBEL_NMS(SOBEL_NMS), .SOBEL_WAIT(SOBEL_WAIT))
processing_u0     (.i_clk(i_clk), .i_rst_n(i_rst_n), 
				   .state(state), 
				   .conv_mode(conv_mode), .conv_active(conv_active), .conv_clear(conv_clear), .conv_read_valid(conv_read_valid),
                   .sobel_state(sobel_state), .sobel_mode(sobel_mode_read), .sobel_clear(sobel_clear), .sobel_read_valid(sobel_read_valid), .sobel_add_g_valid(sobel_add_g_valid),
			       .i_in_data_0(unit_in_data_0_pad), .i_in_data_1(unit_in_data_1_pad), .i_in_data_2(unit_in_data_2_pad), .i_in_data_3(unit_in_data_3_pad),
			       .i_in_data_4(unit_in_data_4_pad), .i_in_data_5(unit_in_data_5_pad), .i_in_data_6(unit_in_data_6_pad), .i_in_data_7(unit_in_data_7_pad),
			       .o_out_data_0(sobel_out_data_0), .o_out_data_1(sobel_out_data_1), .o_out_data_2(sobel_out_data_2), .o_out_data_3(sobel_out_data_3));
// Sobel Sub Control Unit 
always@*
    case(sobel_state)
        SOBEL_IDLE: 
            if (sobel_start)
				n_sobel_state = SOBEL_READ;
            else
                n_sobel_state = SOBEL_IDLE;
        SOBEL_READ:
            if (sobel_read_end)
                n_sobel_state = SOBEL_COMP_G;
            else
                n_sobel_state = SOBEL_READ;
        SOBEL_COMP_G:
			if (sobel_out_end)
				n_sobel_state = SOBEL_IDLE;
            else if (sobel_comp_g_end)
                n_sobel_state = SOBEL_COMP_ANGLE;
            else
                n_sobel_state = SOBEL_COMP_G;
        SOBEL_COMP_ANGLE:
            if (sobel_comp_end)
				n_sobel_state = SOBEL_NMS;
			else if (sobel_comp_angle_end)
                n_sobel_state = SOBEL_COMP_G;			
            else
                n_sobel_state = SOBEL_COMP_ANGLE;	

        SOBEL_NMS: 
        	if(sobel_nms_end)
                // n_sobel_state = SOBEL_IDLE;
				// n_sobel_state = SOBEL_READ;
				n_sobel_state = SOBEL_WAIT;
            else
                n_sobel_state = SOBEL_NMS;  
		SOBEL_WAIT:
			n_sobel_state = SOBEL_COMP_G;
		default: n_sobel_state = sobel_state;        
    endcase

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        sobel_state <= 0;
    else
        sobel_state <= n_sobel_state;


always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		sobel_cnt <= 0;
	else
		if (sobel_state == SOBEL_WAIT)
			sobel_cnt <= sobel_cnt;
		else if (sobel_load_end && (sobel_output_channel != 2'd3))
			// sobel_cnt <= 2'd2;
			sobel_cnt <= 3'd5;		
		else if (state == SOBEL_LOAD && ~sobel_load_end)	
			sobel_cnt <= sobel_cnt + 1'b1;
		else if (state == SOBEL_OUT && ~sobel_out_end)
			sobel_cnt <= sobel_cnt + 1'b1;		
		else
			sobel_cnt <= 0;


// Sobel Load Complete (System FSM)
reg sobel_load_end_d1;
reg median_load_end_d1;
always@*
	// if ((state == SOBEL_LOAD) && (sobel_cnt == 8'd9))          // Cycle Number: READ_X: 2, READ_Y: 2, CG: 4, CA: 4, ADD_G:1, NMS: 1
	if ((state == SOBEL_LOAD) && (sobel_cnt == 8'd8))          // Cycle Number: READ_X: 2, READ_Y: 2, CG: 4, CA: 4, ADD_G:1, NMS: 1
		sobel_load_end = 1;
	else
		sobel_load_end = 0;

always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		sobel_load_end_d1 <= 0;
	else
		sobel_load_end_d1 <= sobel_load_end;

// Sobel Out Complete (System FSM)
always@*
	if ((state == SOBEL_OUT) && (sobel_cnt == 8'd3))          
		sobel_out_end = 1;
	else
		sobel_out_end = 0;

// Sobel Complete (System FSM)
always@*
	// if ((state == SOBEL_OUT) && (sobel_cnt == 8'd3) && (sobel_channel == 2'd3))          
	if ((state == SOBEL_OUT) && (sobel_cnt == 8'd3))   
		sobel_end = 1;
	else
		sobel_end = 0;


reg [13:0] o_out_data_tmp_0;
reg [13:0] o_out_data_tmp_1;
reg [13:0] o_out_data_tmp_2;
reg [13:0] o_out_data_tmp_3;

// Out reg cnt
reg [1:0] out_load_cnt;
// reg out_op;
always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n) begin
		o_out_data_tmp_0 <= 0;
		o_out_data_tmp_1 <= 0;
		o_out_data_tmp_2 <= 0;
		o_out_data_tmp_3 <= 0;		
	end
	else
		// if (sobel_load_end) begin
		if (sobel_load_end_d1) begin
			o_out_data_tmp_0 <= sobel_out_data_0;
			o_out_data_tmp_1 <= sobel_out_data_1;
			o_out_data_tmp_2 <= sobel_out_data_2;
			o_out_data_tmp_3 <= sobel_out_data_3;				
		end
		// else if (median_load_end_d1) begin
		else if (median_load_end) begin
			o_out_data_tmp_0 <= median_out_data_0;
			o_out_data_tmp_1 <= median_out_data_1;
			o_out_data_tmp_2 <= median_out_data_2;
			o_out_data_tmp_3 <= median_out_data_3;		
			/*o_out_data_tmp_0 <= sobel_out_data_0;
			o_out_data_tmp_1 <= sobel_out_data_1;
			o_out_data_tmp_2 <= sobel_out_data_2;
			o_out_data_tmp_3 <= sobel_out_data_3;	*/
		end
		else begin
			o_out_data_tmp_0 <= o_out_data_tmp_0;
			o_out_data_tmp_1 <= o_out_data_tmp_1;
			o_out_data_tmp_2 <= o_out_data_tmp_2;
			o_out_data_tmp_3 <= o_out_data_tmp_3;				
		end
always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n) 
		out_load_cnt <= 0;
	else
		if (out_load_op)
			out_load_cnt <= out_load_cnt + 1'b1;
		else
			out_load_cnt <= 0;

always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n) 
		out_load_op <= 0;
	else
		// if (sobel_load_end)
		if (sobel_load_end_d1)
			out_load_op <= 1;
		// else if (median_load_end_d1)
		else if (median_load_end)
			out_load_op <= 1;
		else if (out_load_cnt == 2'd3)
			out_load_op <= 0;
		else
			out_load_op <= out_load_op;

always@*
	case(out_load_cnt)
		2'b00: data_out_load = o_out_data_tmp_0;
		2'b01: data_out_load = o_out_data_tmp_1;
		2'b10: data_out_load = o_out_data_tmp_2;
		2'b11: data_out_load = o_out_data_tmp_3;
		default: data_out_load = 0;
	endcase


// Sobel Sub Control Signal (Sub FSM)
assign sobel_start          = (sobel_cnt == 8'd1) && (state == SOBEL_LOAD);
assign sobel_read_valid     = (sobel_cnt != 8'd2);
assign sobel_add_g_valid    = (sobel_cnt != 8'd5);

assign sobel_read_end       = (sobel_cnt == 8'd4);
assign sobel_comp_g_end     = (sobel_cnt == 8'd6);
assign sobel_comp_angle_end = (sobel_cnt == 8'd7);
assign sobel_comp_end       = (sobel_cnt == 8'd7);
assign sobel_nms_end        = (sobel_cnt == 8'd8);

// Mode determined by LSB of the counter
// assign sobel_mode = sobel_cnt[1:0];
always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		sobel_mode_read <= 0;
	else
		// if ((state == SOBEL_LOAD) && (sobel_state != SOBEL_COMP_G))
		if (sobel_read_end || (sobel_state == SOBEL_WAIT))
			sobel_mode_read <= 0;
		else if (state == SOBEL_LOAD)
			sobel_mode_read <= sobel_mode_read + 1'b1;
		else
			sobel_mode_read <= 0;

// assign sobel_clear = sobel_start;
assign sobel_clear = (sobel_cnt == 8'd7) || sobel_end || sobel_start;
// Calculate Sobel Channel
always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		sobel_channel <= 0;
	else
		// if (sobel_out_end)
		// if (sobel_load_end)
		// if (sobel_comp_g_end)
		if (sobel_read_end || (sobel_state == SOBEL_WAIT))
			sobel_channel <= sobel_channel + 1'b1;
		else if (state == IDLE)
			sobel_channel <= 0;
		else
			sobel_channel <= sobel_channel;

// Calculate Output Channel
always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		sobel_output_channel <= 0;
	else
		if (sobel_load_end)
			sobel_output_channel <= sobel_output_channel + 1'b1;
		else if (state == IDLE)
			sobel_output_channel <= 0;
		else
			sobel_output_channel <= sobel_output_channel;

// ------------------------------------------------------ Sobel SRAM Addr ------------------------------------------------------ 

// Sobel Read SRAM Addr Offset
reg [7:0] sram_addr_sobel_read_offset;
always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		sram_addr_sobel_read_offset <= 0;
	else 
		// if (sobel_out_end)
		// if (sobel_load_end)
		// if (sobel_comp_g_end)
		if (sobel_read_end || (sobel_state == SOBEL_WAIT))
			sram_addr_sobel_read_offset <= sram_addr_sobel_read_offset + 4'd8;
		else if ((state == SOBEL_LOAD) || (state == SOBEL_OUT))
			sram_addr_sobel_read_offset <= sram_addr_sobel_read_offset;
		else
			sram_addr_sobel_read_offset <= 0;


always@* begin
	sram_addr_sobel[0] = sram_addr_sobel_read_offset + sram_addr_read_x_shift[sram_addr_encoder[0]] + sram_addr_read_y_shift[sram_addr_encoder[0]];
	sram_addr_sobel[1] = sram_addr_sobel_read_offset + sram_addr_read_x_shift[sram_addr_encoder[1]] + sram_addr_read_y_shift[sram_addr_encoder[1]];
	sram_addr_sobel[2] = sram_addr_sobel_read_offset + sram_addr_read_x_shift[sram_addr_encoder[2]] + sram_addr_read_y_shift[sram_addr_encoder[2]];
	sram_addr_sobel[3] = sram_addr_sobel_read_offset + sram_addr_read_x_shift[sram_addr_encoder[3]] + sram_addr_read_y_shift[sram_addr_encoder[3]];
	sram_addr_sobel[4] = sram_addr_sobel_read_offset + sram_addr_read_x_shift[sram_addr_encoder[4]] + sram_addr_read_y_shift[sram_addr_encoder[4]];
	sram_addr_sobel[5] = sram_addr_sobel_read_offset + sram_addr_read_x_shift[sram_addr_encoder[5]] + sram_addr_read_y_shift[sram_addr_encoder[5]];
	sram_addr_sobel[6] = sram_addr_sobel_read_offset + sram_addr_read_x_shift[sram_addr_encoder[6]] + sram_addr_read_y_shift[sram_addr_encoder[6]];
	sram_addr_sobel[7] = sram_addr_sobel_read_offset + sram_addr_read_x_shift[sram_addr_encoder[7]] + sram_addr_read_y_shift[sram_addr_encoder[7]];
end


// ------------------------------------------------------ Sobel Output ------------------------------------------------------ 
always@*
	case(sobel_cnt[1:0])
		2'd0:    sobel_data_out = sobel_out_data_0;
		2'd1:    sobel_data_out = sobel_out_data_1;
		2'd2:    sobel_data_out = sobel_out_data_2;
		2'd3:    sobel_data_out = sobel_out_data_3;
		default: sobel_data_out = 0;  
	endcase

always@*
	if (state == SOBEL_OUT)
		// out_valid_sobel = 1;
		out_valid_sobel = out_load_op; 
	else
		out_valid_sobel = 0;	


// -------------------------------------------------------- Median Instance -------------------------------------------------------- 
// parameter [2:0] MEDIAN_IDLE = 3'd0, MEDIAN_UP_CENTER = 3'd1, MEDIAN_UP_SIDE = 3'd2, MEDIAN_UP_CORNER = 3'd3, MEDIAN_LOAD_DOWN = 3'd4, MEDIAN_DOWN_CENTER = 3'd5, MEDIAN_DOWN_SIDE = 3'd6, MEDIAN_DOWN_CORNER = 3'd7;
parameter [2:0] MEDIAN_IDLE = 3'd0, MEDIAN_READ = 3'd1, MEDIAN_CENTER = 3'd2, MEDIAN_SIDE = 3'd3, MEDIAN_CORNER = 3'd4, MEDIAN_WAIT = 3'd5;
median_unit # (.MEDIAN_IDLE(MEDIAN_IDLE), .MEDIAN_READ(MEDIAN_READ), .MEDIAN_CENTER(MEDIAN_CENTER), .MEDIAN_SIDE(MEDIAN_SIDE), .MEDIAN_CORNER(MEDIAN_CORNER), .MEDIAN_WAIT(MEDIAN_WAIT))
median_u0     (.i_clk(i_clk), .i_rst_n(i_rst_n), .median_state(median_state), .median_clear(median_clear), .median_loc_control(median_loc_control), 
			  .i_in_data_0(median_in_data[0]), .i_in_data_1(median_in_data[1]), .i_in_data_2(median_in_data[2]), .i_in_data_3(median_in_data[3]),
			  .i_in_data_4(median_in_data[4]), .i_in_data_5(median_in_data[5]), .i_in_data_6(median_in_data[6]), .i_in_data_7(median_in_data[7]),
			  .i_in_data_8(median_in_data[8]), .i_in_data_9(median_in_data[9]), .i_in_data_10(median_in_data[10]), .i_in_data_11(median_in_data[11]),
			  .i_in_data_12(median_in_data[12]), .i_in_data_13(median_in_data[13]), .i_in_data_14(median_in_data[14]), .i_in_data_15(median_in_data[15]),			  
			  .o_out_data_0(median_out_data_0), .o_out_data_1(median_out_data_1), .o_out_data_2(median_out_data_2), .o_out_data_3(median_out_data_3));
/*all_unit # (       .CONV_LOAD(CONV_LOAD), .CONV_OUT(CONV_OUT), .SOBEL_LOAD(SOBEL_LOAD), .MEDIAN_LOAD(MEDIAN_LOAD), .MEDIAN_OUT(MEDIAN_OUT),
				   .SOBEL_IDLE(SOBEL_IDLE), .SOBEL_READ(SOBEL_READ),  .SOBEL_COMP_G(SOBEL_COMP_G), .SOBEL_COMP_ANGLE(SOBEL_COMP_ANGLE),
                   .SOBEL_NMS(SOBEL_NMS), .SOBEL_WAIT(SOBEL_WAIT), 
				   .MEDIAN_IDLE(MEDIAN_IDLE), .MEDIAN_READ(MEDIAN_READ), .MEDIAN_CENTER(MEDIAN_CENTER), .MEDIAN_SIDE(MEDIAN_SIDE), .MEDIAN_CORNER(MEDIAN_CORNER), .MEDIAN_WAIT(MEDIAN_WAIT))
all_u0     (       .i_clk(i_clk), .i_rst_n(i_rst_n), 
				   .state(state), 
				   .conv_mode(conv_mode), .conv_active(conv_active), .conv_clear(conv_clear), .conv_read_valid(conv_read_valid),
                   .sobel_state(sobel_state), .sobel_mode(sobel_mode_read), .sobel_clear(sobel_clear), .sobel_read_valid(sobel_read_valid), .sobel_add_g_valid(sobel_add_g_valid),
			       .median_state(median_state), .median_clear(median_clear), .median_loc_control(median_loc_control),
				   .i_in_data_0(all_in_data[0]), .i_in_data_1(all_in_data[1]), .i_in_data_2(all_in_data[2]), .i_in_data_3(all_in_data[3]),
				   .i_in_data_4(all_in_data[4]), .i_in_data_5(all_in_data[5]), .i_in_data_6(all_in_data[6]), .i_in_data_7(all_in_data[7]),
				   .i_in_data_8(all_in_data[8]), .i_in_data_9(all_in_data[9]), .i_in_data_10(all_in_data[10]), .i_in_data_11(all_in_data[11]),
				   .i_in_data_12(all_in_data[12]), .i_in_data_13(all_in_data[13]), .i_in_data_14(all_in_data[14]), .i_in_data_15(all_in_data[15]),
			       .o_out_data_0(sobel_out_data_0), .o_out_data_1(sobel_out_data_1), .o_out_data_2(sobel_out_data_2), .o_out_data_3(sobel_out_data_3));*/

/*always@*
	if (state == MEDIAN_LOAD || state == MEDIAN_OUT)
		for (i = 0; i < 16 ;i = i+1)
			all_in_data[i] = median_in_data[i];
	else begin
		all_in_data[0] = unit_in_data_0_pad;
		all_in_data[1] = unit_in_data_1_pad;
		all_in_data[2] = unit_in_data_2_pad;
		all_in_data[3] = unit_in_data_3_pad;
		all_in_data[4] = unit_in_data_4_pad;
		all_in_data[5] = unit_in_data_5_pad;
		all_in_data[6] = unit_in_data_6_pad;
		all_in_data[7] = unit_in_data_7_pad;
		all_in_data[8] = 0;
		all_in_data[9] = 0;
		all_in_data[10] = 0;
		all_in_data[11] = 0;
		all_in_data[12] = 0;
		all_in_data[13] = 0;
		all_in_data[14] = 0;
		all_in_data[15] = 0;
	end*/

// Median Sub Control Unit 
always@*
    case(median_state)
        MEDIAN_IDLE: 
            if (median_start)
				n_median_state = MEDIAN_READ;
            else
                n_median_state = MEDIAN_IDLE;
		MEDIAN_READ:
			n_median_state = MEDIAN_CENTER;
        MEDIAN_CENTER: 
            if (median_center_end)
                n_median_state = MEDIAN_SIDE;
            else
                n_median_state = MEDIAN_CENTER;
        MEDIAN_SIDE:
            if (median_side_end)
                n_median_state = MEDIAN_CORNER;
            else
                n_median_state = MEDIAN_SIDE;
        MEDIAN_CORNER:
			/*if (median_load_end && (median_output_channel == 3'd3))
				n_median_state = MEDIAN_IDLE; */
            if (median_corner_end)
                n_median_state = MEDIAN_WAIT;
            else
                n_median_state = MEDIAN_CORNER;
		MEDIAN_WAIT: 
			if (median_load_end && (median_output_channel == 3'd3))
				n_median_state = MEDIAN_IDLE;			
			else
				n_median_state = MEDIAN_CENTER;
		default: n_median_state = median_state;        
    endcase

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        median_state <= 0;
    else
        median_state <= n_median_state;



always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		median_cnt <= 0;
	else
		if (median_load_end && (median_output_channel != 2'd3))
			median_cnt <= 3'd3;
		else if (state == MEDIAN_LOAD && ~median_load_end)
			median_cnt <= median_cnt + 1'b1;
		else if (state == MEDIAN_OUT && ~median_out_end)
			median_cnt <= median_cnt + 1'b1;		
		else
			median_cnt <= 0;

// Sobel Load Complete (System FSM)
always@*
	// if ((state == MEDIAN_LOAD) && (median_cnt == 8'd20))          // Cycle Number: UP_CENTER: 4, UP_SIDE: 4, UP_CORNER: 1, LOAD_DOWN = 1, DOWN_CENTER: 4, DOWN_SIDE: 4, DOWN_CORNER: 1,
	if ((state == MEDIAN_LOAD) && (median_cnt == 8'd12))          // Cycle Number: LOAD: 1, CENTER: 4, SIDE: 4, CORNER: 1, WAIT: 1
		median_load_end = 1;
	else
		median_load_end = 0;

always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		median_load_end_d1 <= 0;
	else
		median_load_end_d1 <= median_load_end;

// Sobel Out Complete (System FSM)
always@*
	if ((state == MEDIAN_OUT) && (median_cnt == 8'd3))          
		median_out_end = 1;
	else
		median_out_end = 0;

// Sobel Complete (System FSM)
always@*
	// if ((state == MEDIAN_OUT) && (median_cnt == 8'd3) && (median_channel == 2'd3))        
	if ((state == MEDIAN_OUT) && (median_cnt == 8'd3))    
		median_end = 1;
	else
		median_end = 0;

// Sobel Sub Control Signal (Sub FSM)
assign median_start            = (median_cnt == 8'd1) && (state == MEDIAN_LOAD);
assign median_center_end       = (median_cnt == 8'd6);
assign median_side_end         = (median_cnt == 8'd10);
assign median_corner_end       = (median_cnt == 8'd11);
assign median_wait_end         = (median_cnt == 8'd12);

always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		median_mode_read <= 0;
	else
		if ((state == MEDIAN_LOAD) && ((median_state == MEDIAN_IDLE) || (median_state == MEDIAN_READ) || (median_state == MEDIAN_SIDE)))
			median_mode_read <= median_mode_read + 1'b1;
		else
			median_mode_read <= 0;
always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		median_mode_read_d1 <= 0;
	else
		median_mode_read_d1 <= median_mode_read;

// assign median_clear = median_start;
assign median_clear = ((median_state == MEDIAN_WAIT) && (median_output_channel != 3'd3)) || (state == OP_READ);

always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		median_loc_control <= 0;
	else 
		// if ((median_state == MEDIAN_UP_CENTER) || (median_state == MEDIAN_UP_SIDE) || (median_state == MEDIAN_DOWN_CENTER) || (median_state == MEDIAN_DOWN_SIDE))
		if ((median_state == MEDIAN_CENTER) || (median_state == MEDIAN_SIDE))
			median_loc_control <= median_loc_control + 1'b1;
		else
			median_loc_control <= median_loc_control;
	
// assign median_cnt_lsb = median_cnt[1:0];

// Calculate Sobel Channel
always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		median_channel <= 0;
	else
		// if (median_out_end)
		if (median_cnt == 4'd9)
			median_channel <= median_channel + 1'b1;
		else if (state == IDLE)
			median_channel <= 0;
		else
			median_channel <= median_channel;

// Calculate Output Channel
always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		median_output_channel <= 0;
	else
		if (median_load_end)
			median_output_channel <= median_output_channel + 1'b1;
		else if (state == IDLE)
			median_output_channel <= 0;
		else
			median_output_channel <= median_output_channel;

// ------------------------------------------------------ Median Data Buffer ------------------------------------------------------ 
always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		median_in_data_buff_0 <= 0;
	else

		if (median_state == MEDIAN_CORNER) 
			median_in_data_buff_0 <= unit_in_data_0_pad;
		else
			median_in_data_buff_0 <= median_in_data_buff_0;

always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		median_in_data_buff_1 <= 0;
	else
		if (median_state == MEDIAN_CORNER) 
			median_in_data_buff_1 <= unit_in_data_1_pad;
		else
			median_in_data_buff_1 <= median_in_data_buff_1;

always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		median_in_data_buff_2 <= 0;
	else
		if (median_state == MEDIAN_CORNER) 
			median_in_data_buff_2 <= unit_in_data_2_pad;
		else
			median_in_data_buff_2 <= median_in_data_buff_2;

always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		median_in_data_buff_3 <= 0;
	else
		if (median_state == MEDIAN_CORNER) 
			median_in_data_buff_3 <= unit_in_data_3_pad;
		else
			median_in_data_buff_3 <= median_in_data_buff_3;

always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		median_in_data_buff_4 <= 0;
	else
		if (median_state == MEDIAN_CORNER) 
			median_in_data_buff_4 <= unit_in_data_4_pad;
		else
			median_in_data_buff_4 <= median_in_data_buff_4;

always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		median_in_data_buff_5 <= 0;
	else
		if (median_state == MEDIAN_CORNER) 
			median_in_data_buff_5 <= unit_in_data_5_pad;
		else
			median_in_data_buff_5 <= median_in_data_buff_5;

always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		median_in_data_buff_6 <= 0;
	else
		if (median_state == MEDIAN_CORNER) 
			median_in_data_buff_6 <= unit_in_data_6_pad;
		else
			median_in_data_buff_6 <= median_in_data_buff_6;


always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		median_in_data_buff_7 <= 0;
	else
		if (median_state == MEDIAN_CORNER) 
			median_in_data_buff_7 <= unit_in_data_7_pad;
		else
			median_in_data_buff_7 <= median_in_data_buff_7;

always@*
	if ((median_state == MEDIAN_IDLE) || (median_state == MEDIAN_READ)) begin
		median_in_data[0] = unit_in_data_0_pad;
		median_in_data[1] = unit_in_data_1_pad;
		median_in_data[2] = unit_in_data_2_pad;
		median_in_data[3] = unit_in_data_3_pad;
		median_in_data[4] = unit_in_data_4_pad;
		median_in_data[5] = unit_in_data_5_pad;
		median_in_data[6] = unit_in_data_6_pad;
		median_in_data[7] = unit_in_data_7_pad;
		median_in_data[8] = unit_in_data_0_pad;
		median_in_data[9] = unit_in_data_1_pad;
		median_in_data[10] = unit_in_data_2_pad;
		median_in_data[11] = unit_in_data_3_pad;
		median_in_data[12] = unit_in_data_4_pad;
		median_in_data[13] = unit_in_data_5_pad;
		median_in_data[14] = unit_in_data_6_pad;
		median_in_data[15] = unit_in_data_7_pad;
	end

	else begin
		median_in_data[0] = median_in_data_buff_0;
		median_in_data[1] = median_in_data_buff_1;
		median_in_data[2] = median_in_data_buff_2;
		median_in_data[3] = median_in_data_buff_3;
		median_in_data[4] = median_in_data_buff_4;
		median_in_data[5] = median_in_data_buff_5;
		median_in_data[6] = median_in_data_buff_6;
		median_in_data[7] = median_in_data_buff_7;
		median_in_data[8] = unit_in_data_0_pad;
		median_in_data[9] = unit_in_data_1_pad;
		median_in_data[10] = unit_in_data_2_pad;
		median_in_data[11] = unit_in_data_3_pad;
		median_in_data[12] = unit_in_data_4_pad;
		median_in_data[13] = unit_in_data_5_pad;
		median_in_data[14] = unit_in_data_6_pad;
		median_in_data[15] = unit_in_data_7_pad;
	end


// ------------------------------------------------------ Median SRAM Addr ------------------------------------------------------ 

// Sobel Read SRAM Addr Offset
reg [7:0] sram_addr_median_read_offset;
always@(posedge i_clk or negedge i_rst_n)
	if (~i_rst_n)
		sram_addr_median_read_offset <= 0;
	else 
		if (median_cnt == 4'd9)
			sram_addr_median_read_offset <= sram_addr_median_read_offset + 4'd8;
		else if ((state == MEDIAN_LOAD) || (state == MEDIAN_OUT))
			sram_addr_median_read_offset <= sram_addr_median_read_offset;
		else
			sram_addr_median_read_offset <= 0;


always@* begin
	sram_addr_median[0] = sram_addr_median_read_offset + sram_addr_read_x_shift[sram_addr_encoder[0]] + sram_addr_read_y_shift[sram_addr_encoder[0]];
	sram_addr_median[1] = sram_addr_median_read_offset + sram_addr_read_x_shift[sram_addr_encoder[1]] + sram_addr_read_y_shift[sram_addr_encoder[1]];
	sram_addr_median[2] = sram_addr_median_read_offset + sram_addr_read_x_shift[sram_addr_encoder[2]] + sram_addr_read_y_shift[sram_addr_encoder[2]];
	sram_addr_median[3] = sram_addr_median_read_offset + sram_addr_read_x_shift[sram_addr_encoder[3]] + sram_addr_read_y_shift[sram_addr_encoder[3]];
	sram_addr_median[4] = sram_addr_median_read_offset + sram_addr_read_x_shift[sram_addr_encoder[4]] + sram_addr_read_y_shift[sram_addr_encoder[4]];
	sram_addr_median[5] = sram_addr_median_read_offset + sram_addr_read_x_shift[sram_addr_encoder[5]] + sram_addr_read_y_shift[sram_addr_encoder[5]];
	sram_addr_median[6] = sram_addr_median_read_offset + sram_addr_read_x_shift[sram_addr_encoder[6]] + sram_addr_read_y_shift[sram_addr_encoder[6]];
	sram_addr_median[7] = sram_addr_median_read_offset + sram_addr_read_x_shift[sram_addr_encoder[7]] + sram_addr_read_y_shift[sram_addr_encoder[7]];
end

// ------------------------------------------------------ Sobel Output ------------------------------------------------------ 
always@*
	case(median_cnt[1:0])
		2'd0:    median_data_out = median_out_data_0;
		2'd1:    median_data_out = median_out_data_1;
		2'd2:    median_data_out = median_out_data_2;
		2'd3:    median_data_out = median_out_data_3;
		default: median_data_out = 0;  
	endcase

always@*
	if (state == MEDIAN_OUT)
		out_valid_median = out_load_op; 
	else
		out_valid_median = 0;	


endmodule

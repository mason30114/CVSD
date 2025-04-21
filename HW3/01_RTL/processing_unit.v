module processing_unit # (
    parameter IDLE = 5'd0,
    parameter CONV_LOAD = 5'd11,
    parameter CONV_OUT = 5'd12,
    parameter SOBEL_LOAD = 5'd15,    
    parameter SOBEL_IDLE = 3'd0,
    parameter SOBEL_READ = 3'd1,
    parameter SOBEL_COMP_G = 3'd2,
    parameter SOBEL_COMP_ANGLE = 3'd3,
    parameter SOBEL_WAIT = 3'd4,
    parameter SOBEL_NMS = 3'd5
) (
    input         i_clk,
	input         i_rst_n,
    input  [ 7:0] i_in_data_0,
    input  [ 7:0] i_in_data_1,
    input  [ 7:0] i_in_data_2,
    input  [ 7:0] i_in_data_3,
    input  [ 7:0] i_in_data_4,
    input  [ 7:0] i_in_data_5,
    input  [ 7:0] i_in_data_6,
    input  [ 7:0] i_in_data_7,

    input  [ 4:0] state,
    input         conv_mode, 
    input         conv_active,
    input         conv_clear,    
    input         conv_read_valid,

    input  [ 2:0]  sobel_state,
    // input  [ 1:0]  sobel_mode,
    input          sobel_mode,
    input          sobel_clear,
    input          sobel_read_valid,
    input          sobel_add_g_valid,

	output reg [ 13:0] o_out_data_0,
	output reg [ 13:0] o_out_data_1,
	output reg [ 13:0] o_out_data_2,
	output reg [ 13:0] o_out_data_3    
);

reg [7:0] i_in_data_0_r, i_in_data_1_r, i_in_data_2_r, i_in_data_3_r, i_in_data_4_r, i_in_data_5_r, i_in_data_6_r, i_in_data_7_r;
reg [12:0] i_in_data_0_r_pad, i_in_data_1_r_pad, i_in_data_2_r_pad, i_in_data_3_r_pad, i_in_data_4_r_pad, i_in_data_5_r_pad, i_in_data_6_r_pad, i_in_data_7_r_pad;
reg [12:0] i_in_data_0_r_pad_conv, i_in_data_1_r_pad_conv, i_in_data_2_r_pad_conv, i_in_data_3_r_pad_conv, i_in_data_4_r_pad_conv, i_in_data_5_r_pad_conv, i_in_data_6_r_pad_conv, i_in_data_7_r_pad_conv;
// reg [1:0] sobel_mode_d1, sobel_mode_d2, sobel_mode_d3;
reg sobel_mode_d1, sobel_mode_d2, sobel_mode_d3;
reg [2:0] sobel_state_d1;
reg conv_mode_d1;
integer i, j;
reg [1:0] tan_cnt;

reg signed [13:0] conv_in_data_large [0:3][0:5];
reg signed [13:0] conv_in_data_small [0:3][0:3];

reg [2:0]  in_weight_shift_large_x [0:5];
wire [2:0]  in_weight_shift_small_x [0:3];
reg [2:0]  in_weight_shift_large_y [0:5];
wire [2:0]  in_weight_shift_small_y [0:3];
wire        in_sign_large_x [0:5];
wire        in_sign_small_x [0:3];
reg        in_sign_large_y [0:5];
reg        in_sign_small_y [0:3];
reg [12:0] in_data_shift_0_x [0:5];
reg [12:0] in_data_shift_1_x [0:5];
reg [12:0] in_data_shift_2_x [0:3];
reg [12:0] in_data_shift_3_x [0:3];
reg [12:0] in_data_shift_0_y [0:5];
reg [12:0] in_data_shift_1_y [0:5];
reg [12:0] in_data_shift_2_y [0:3];
reg [12:0] in_data_shift_3_y [0:3];

reg [12:0] in_data_shift_zero_filted_0_x [0:5];
reg [12:0] in_data_shift_zero_filted_1_x [0:5];
reg [12:0] in_data_shift_zero_filted_2_x [0:3];
reg [12:0] in_data_shift_zero_filted_3_x [0:3];
reg [12:0] in_data_shift_zero_filted_0_y [0:5];
reg [12:0] in_data_shift_zero_filted_1_y [0:5];
reg [12:0] in_data_shift_zero_filted_2_y [0:3];
reg [12:0] in_data_shift_zero_filted_3_y [0:3];

reg signed [13:0] in_data_shift_zero_filted_signed_0_x [0:5];
reg signed [13:0] in_data_shift_zero_filted_signed_1_x [0:5];
reg signed [13:0] in_data_shift_zero_filted_signed_2_x [0:3];
reg signed [13:0] in_data_shift_zero_filted_signed_3_x [0:3];
reg signed [13:0] in_data_shift_zero_filted_signed_0_y [0:5];
reg signed [13:0] in_data_shift_zero_filted_signed_1_y [0:5];
reg signed [13:0] in_data_shift_zero_filted_signed_2_y [0:3];
reg signed [13:0] in_data_shift_zero_filted_signed_3_y [0:3];

reg signed [13:0] sobel_in_data_large [0:3][0:5];
reg signed [13:0] sobel_in_data_small [0:3][0:3];



reg signed [16:0] Gx_add_0_in;
reg signed [16:0] Gx_add_1_in;
reg signed [16:0] Gx_add_2_in;
reg signed [16:0] Gx_add_3_in;

reg signed [16:0] Gy_add_0_in;
reg signed [16:0] Gy_add_1_in;
reg signed [16:0] Gy_add_2_in;
reg signed [16:0] Gy_add_3_in;

reg signed [17:0] Gx_add_0_out;
reg signed [17:0] Gx_add_1_out;
reg signed [17:0] Gx_add_2_out;
reg signed [17:0] Gx_add_3_out;

reg signed [17:0] Gy_add_0_out;
reg signed [17:0] Gy_add_1_out;
reg signed [17:0] Gy_add_2_out;
reg signed [17:0] Gy_add_3_out;

reg signed [17:0] G_conv_add_0_out;
reg signed [17:0] G_conv_add_1_out;
reg signed [17:0] G_conv_add_2_out;
reg signed [17:0] G_conv_add_3_out;


wire signed [20:0] Gx_current_pad [0:3];
wire signed [20:0] Gy_current_pad [0:3];

reg signed [20:0] Gx_current_shift [0:3][0:5];
reg Gx_current_sign [0:3];

reg signed [23:0] Gx_current_pad_identical [0:3];
reg signed [23:0] Gy_current_pad_identical [0:3];

reg signed [23:0] tan_0225 [0:3];
reg signed [23:0] tan_0450 [0:3];
reg signed [23:0] tan_0675 [0:3];
reg signed [23:0] tan_1125 [0:3];
reg signed [23:0] tan_1350 [0:3];
reg signed [23:0] tan_1575 [0:3];

reg signed [24:0] tan_add_0000 [0:3];
reg signed [24:0] tan_add_0225 [0:3];
reg signed [24:0] tan_add_0450 [0:3];
reg signed [24:0] tan_add_0675 [0:3];
reg signed [24:0] tan_add_1125 [0:3];
reg signed [24:0] tan_add_1350 [0:3]; 
reg signed [24:0] tan_add_1575 [0:3];

reg signed [18:0] Post_add_in_0[0:1];
reg signed [18:0] Post_add_in_1[0:1];
reg signed [18:0] Post_add_in_2[0:1];
reg signed [18:0] Post_add_in_3[0:1];
reg signed [18:0] Post_add_in_4[0:1];
reg signed [18:0] Post_add_in_5[0:1];

wire signed [19:0] Post_add_out_0;
wire signed [19:0] Post_add_out_1;
wire signed [19:0] Post_add_out_2;
wire signed [19:0] Post_add_out_3;
wire signed [19:0] Post_add_out_4;
wire signed [19:0] Post_add_out_5;

// --------------------------------------------------------- Input Register ---------------------------------------------------------
// Input Pixel (8.0)
always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        i_in_data_0_r <= 0;
    else
        i_in_data_0_r <= i_in_data_0;        

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        i_in_data_1_r <= 0;
    else
        i_in_data_1_r <= i_in_data_1;    

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        i_in_data_2_r <= 0;
    else
        i_in_data_2_r <= i_in_data_2;    

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        i_in_data_3_r <= 0;
    else
        i_in_data_3_r <= i_in_data_3;    

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        i_in_data_4_r <= 0;
    else
        i_in_data_4_r <= i_in_data_4;    

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        i_in_data_5_r <= 0;
    else
        i_in_data_5_r <= i_in_data_5;    

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        i_in_data_6_r <= 0;
    else
        i_in_data_6_r <= i_in_data_6;   

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        i_in_data_7_r <= 0;
    else
        i_in_data_7_r <= i_in_data_7;    

// Delay Conv Mode
always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        conv_mode_d1 <= 0;
    else
        conv_mode_d1 <= conv_mode;

// Delay sobel mode
always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        sobel_mode_d1 <= 0;
    else
        sobel_mode_d1 <= sobel_mode;

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        sobel_mode_d2 <= 0;
    else
        sobel_mode_d2 <= sobel_mode_d1;    

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        sobel_mode_d3 <= 0;
    else
        sobel_mode_d3 <= sobel_mode_d2; 


always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        sobel_state_d1 <= 0;
    else
        sobel_state_d1 <= sobel_state;


// --------------------------------------------------------- Convolution Input Data ---------------------------------------------------------
// conv_mode = 0: 0:ul, 1:ur, 2: dl, 3: dr
// conv_mode = 1: 0:dl, 1:dr, 2: ul, 3: ur
reg  [2:0] in_weight_shift_large_conv [0:5];
// wire [2:0] in_weight_shift_small [0:3];
reg signed  [12:0] in_data_shift_0_conv [0:5];
reg signed  [12:0] in_data_shift_1_conv [0:5];
reg signed  [12:0] in_data_shift_2_conv [0:3];
reg signed  [12:0] in_data_shift_3_conv [0:3];

always@*
    case(conv_mode)
    1'b0: begin
        in_weight_shift_large_conv[0] = 3'd4;
        in_weight_shift_large_conv[1] = 3'd3;
        in_weight_shift_large_conv[2] = 3'd4;
        in_weight_shift_large_conv[3] = 3'd3;
        in_weight_shift_large_conv[4] = 3'd2;
        in_weight_shift_large_conv[5] = 3'd3;
    end
    1'b1: begin
        in_weight_shift_large_conv[0] = 3'd3;
        in_weight_shift_large_conv[1] = 3'd2;
        in_weight_shift_large_conv[2] = 3'd3;
        in_weight_shift_large_conv[3] = 3'd4;
        in_weight_shift_large_conv[4] = 3'd3;
        in_weight_shift_large_conv[5] = 3'd4;
    end
    default: begin
        in_weight_shift_large_conv[0] = 3'd0;
        in_weight_shift_large_conv[1] = 3'd0;
        in_weight_shift_large_conv[2] = 3'd0;
        in_weight_shift_large_conv[3] = 3'd0;
        in_weight_shift_large_conv[4] = 3'd0;
        in_weight_shift_large_conv[5] = 3'd0;
    end
    endcase


// assign in_weight_shift_small[0] = 3'd4;
// assign in_weight_shift_small[1] = 3'd3;
// assign in_weight_shift_small[2] = 3'd4;


always@* begin
    i_in_data_0_r_pad_conv = {1'b0, i_in_data_0_r, 4'd0};
    i_in_data_1_r_pad_conv = {1'b0, i_in_data_1_r, 4'd0};
    i_in_data_2_r_pad_conv = {1'b0, i_in_data_2_r, 4'd0};
    i_in_data_3_r_pad_conv = {1'b0, i_in_data_3_r, 4'd0};
    i_in_data_4_r_pad_conv = {1'b0, i_in_data_4_r, 4'd0};
    i_in_data_5_r_pad_conv = {1'b0, i_in_data_5_r, 4'd0};
    i_in_data_6_r_pad_conv = {1'b0, i_in_data_6_r, 4'd0};
    i_in_data_7_r_pad_conv = {1'b0, i_in_data_7_r, 4'd0};
end

// Input Shifted by kernal (8.4)
always@* begin
    in_data_shift_0_conv[0] = i_in_data_0_r_pad_conv >> in_weight_shift_large_conv[0];
    in_data_shift_0_conv[1] = i_in_data_1_r_pad_conv >> in_weight_shift_large_conv[1];
    in_data_shift_0_conv[2] = i_in_data_2_r_pad_conv >> in_weight_shift_large_conv[2];
    in_data_shift_0_conv[3] = i_in_data_4_r_pad_conv >> in_weight_shift_large_conv[3];
    in_data_shift_0_conv[4] = i_in_data_5_r_pad_conv >> in_weight_shift_large_conv[4];
    in_data_shift_0_conv[5] = i_in_data_6_r_pad_conv >> in_weight_shift_large_conv[5];
end
always@* begin
    in_data_shift_1_conv[0] = i_in_data_1_r_pad_conv >> in_weight_shift_large_conv[0];
    in_data_shift_1_conv[1] = i_in_data_2_r_pad_conv >> in_weight_shift_large_conv[1];
    in_data_shift_1_conv[2] = i_in_data_3_r_pad_conv >> in_weight_shift_large_conv[2];
    in_data_shift_1_conv[3] = i_in_data_5_r_pad_conv >> in_weight_shift_large_conv[3];
    in_data_shift_1_conv[4] = i_in_data_6_r_pad_conv >> in_weight_shift_large_conv[4];
    in_data_shift_1_conv[5] = i_in_data_7_r_pad_conv >> in_weight_shift_large_conv[5];
end
always@* begin
    case(conv_mode)
        1'b0: begin
            in_data_shift_2_conv[0] = i_in_data_4_r_pad_conv >> 3'd4;
            in_data_shift_2_conv[1] = i_in_data_5_r_pad_conv >> 3'd3;
            in_data_shift_2_conv[2] = i_in_data_6_r_pad_conv >> 3'd4;
            in_data_shift_2_conv[3] = 0;
        end
        1'b1: begin
            in_data_shift_2_conv[0] = i_in_data_0_r_pad_conv >> 3'd4;
            in_data_shift_2_conv[1] = i_in_data_1_r_pad_conv >> 3'd3;
            in_data_shift_2_conv[2] = i_in_data_2_r_pad_conv >> 3'd4;
            in_data_shift_2_conv[3] = 0;
        end
        default: begin
            in_data_shift_2_conv[0] = 0;
            in_data_shift_2_conv[1] = 0;
            in_data_shift_2_conv[2] = 0;
            in_data_shift_2_conv[3] = 0;
        end
    endcase
end
always@* begin
    case(conv_mode)
        1'b0: begin
            in_data_shift_3_conv[0] = i_in_data_5_r_pad_conv >> 3'd4;
            in_data_shift_3_conv[1] = i_in_data_6_r_pad_conv >> 3'd3;
            in_data_shift_3_conv[2] = i_in_data_7_r_pad_conv >> 3'd4;
            in_data_shift_3_conv[3] = 0;
        end
        1'b1: begin
            in_data_shift_3_conv[0] = i_in_data_1_r_pad_conv >> 3'd4;
            in_data_shift_3_conv[1] = i_in_data_2_r_pad_conv >> 3'd3;
            in_data_shift_3_conv[2] = i_in_data_3_r_pad_conv >> 3'd4;
            in_data_shift_3_conv[3] = 0;
        end
        default: begin
            in_data_shift_3_conv[0] = 0;
            in_data_shift_3_conv[1] = 0;
            in_data_shift_3_conv[2] = 0;
            in_data_shift_3_conv[3] = 0;
        end
    endcase
end

always@* begin
    for (j = 0; j < 6; j= j+1) begin
        conv_in_data_large[0][j] = {in_data_shift_0_conv[j][12], in_data_shift_0_conv[j]};
        conv_in_data_large[1][j] = {in_data_shift_1_conv[j][12], in_data_shift_1_conv[j]};
        conv_in_data_large[2][j] = 0;
        conv_in_data_large[3][j] = 0;
    end
    for (j = 0; j < 4; j = j+1) begin
        conv_in_data_small[0][j] = {in_data_shift_2_conv[j][12], in_data_shift_2_conv[j]};
        conv_in_data_small[1][j] = {in_data_shift_3_conv[j][12], in_data_shift_3_conv[j]};
        conv_in_data_small[2][j] = 0;
        conv_in_data_small[3][j] = 0;
    end
end

// --------------------------------------------------------- Sobel Input Data ---------------------------------------------------------
// sobel_mode = 0: 0:ul, 1:ur, 2: dl, 3: dr
// sobel_mode = 1: 0:dl, 1:dr, 2: ul, 3: ur
// Note that 3'd3 represent the output value is 0
always@*
    case(sobel_mode_d2)
    1'b0: begin
        in_weight_shift_large_x[0] = 3'd0;
        in_weight_shift_large_x[1] = 3'd3;
        in_weight_shift_large_x[2] = 3'd0;
        in_weight_shift_large_x[3] = 3'd1;
        in_weight_shift_large_x[4] = 3'd3;
        in_weight_shift_large_x[5] = 3'd1;
    end
    1'b1: begin
        in_weight_shift_large_x[0] = 3'd1;
        in_weight_shift_large_x[1] = 3'd3;
        in_weight_shift_large_x[2] = 3'd1;
        in_weight_shift_large_x[3] = 3'd0;
        in_weight_shift_large_x[4] = 3'd3;
        in_weight_shift_large_x[5] = 3'd0;
    end
    default: begin
        in_weight_shift_large_x[0] = 3'd0;
        in_weight_shift_large_x[1] = 3'd0;
        in_weight_shift_large_x[2] = 3'd0;
        in_weight_shift_large_x[3] = 3'd0;
        in_weight_shift_large_x[4] = 3'd0;
        in_weight_shift_large_x[5] = 3'd0;
    end
    endcase

always@*
    case(sobel_mode_d2)
    1'b0: begin
        in_weight_shift_large_y[0] = 3'd0;
        in_weight_shift_large_y[1] = 3'd1;
        in_weight_shift_large_y[2] = 3'd0;
        in_weight_shift_large_y[3] = 3'd3;
        in_weight_shift_large_y[4] = 3'd3;
        in_weight_shift_large_y[5] = 3'd3;
    end
    1'b1: begin
        in_weight_shift_large_y[0] = 3'd3;
        in_weight_shift_large_y[1] = 3'd3;
        in_weight_shift_large_y[2] = 3'd3;
        in_weight_shift_large_y[3] = 3'd0;
        in_weight_shift_large_y[4] = 3'd1;
        in_weight_shift_large_y[5] = 3'd0;
    end
    default: begin
        in_weight_shift_large_y[0] = 3'd0;
        in_weight_shift_large_y[1] = 3'd0;
        in_weight_shift_large_y[2] = 3'd0;
        in_weight_shift_large_y[3] = 3'd0;
        in_weight_shift_large_y[4] = 3'd0;
        in_weight_shift_large_y[5] = 3'd0;
    end
    endcase


assign in_weight_shift_small_x[0] = 3'd0;
assign in_weight_shift_small_x[1] = 3'd3;
assign in_weight_shift_small_x[2] = 3'd0;

assign in_weight_shift_small_x[3] = 3'd3;

assign in_weight_shift_small_y[0] = 3'd0;
assign in_weight_shift_small_y[1] = 3'd1;
assign in_weight_shift_small_y[2] = 3'd0;
   
assign in_weight_shift_small_y[3] = 3'd3;

always@* begin
    i_in_data_0_r_pad = {1'b0, i_in_data_0_r, 4'd0};
    i_in_data_1_r_pad = {1'b0, i_in_data_1_r, 4'd0};
    i_in_data_2_r_pad = {1'b0, i_in_data_2_r, 4'd0};
    i_in_data_3_r_pad = {1'b0, i_in_data_3_r, 4'd0};
    i_in_data_4_r_pad = {1'b0, i_in_data_4_r, 4'd0};
    i_in_data_5_r_pad = {1'b0, i_in_data_5_r, 4'd0};
    i_in_data_6_r_pad = {1'b0, i_in_data_6_r, 4'd0};
    i_in_data_7_r_pad = {1'b0, i_in_data_7_r, 4'd0};
end

// Input Shifted by kernal (9.4)
always@* begin
    in_data_shift_0_x[0] = i_in_data_0_r_pad << in_weight_shift_large_x[0];
    in_data_shift_0_x[1] = i_in_data_1_r_pad << in_weight_shift_large_x[1];
    in_data_shift_0_x[2] = i_in_data_2_r_pad << in_weight_shift_large_x[2];
    in_data_shift_0_x[3] = i_in_data_4_r_pad << in_weight_shift_large_x[3];
    in_data_shift_0_x[4] = i_in_data_5_r_pad << in_weight_shift_large_x[4];
    in_data_shift_0_x[5] = i_in_data_6_r_pad << in_weight_shift_large_x[5];
end
always@* begin
    in_data_shift_1_x[0] = i_in_data_1_r_pad << in_weight_shift_large_x[0];
    in_data_shift_1_x[1] = i_in_data_2_r_pad << in_weight_shift_large_x[1];
    in_data_shift_1_x[2] = i_in_data_3_r_pad << in_weight_shift_large_x[2];
    in_data_shift_1_x[3] = i_in_data_5_r_pad << in_weight_shift_large_x[3];
    in_data_shift_1_x[4] = i_in_data_6_r_pad << in_weight_shift_large_x[4];
    in_data_shift_1_x[5] = i_in_data_7_r_pad << in_weight_shift_large_x[5];
end

always@* begin
    in_data_shift_0_y[0] = i_in_data_0_r_pad << in_weight_shift_large_y[0];
    in_data_shift_0_y[1] = i_in_data_1_r_pad << in_weight_shift_large_y[1];
    in_data_shift_0_y[2] = i_in_data_2_r_pad << in_weight_shift_large_y[2];
    in_data_shift_0_y[3] = i_in_data_4_r_pad << in_weight_shift_large_y[3];
    in_data_shift_0_y[4] = i_in_data_5_r_pad << in_weight_shift_large_y[4];
    in_data_shift_0_y[5] = i_in_data_6_r_pad << in_weight_shift_large_y[5];
end
always@* begin
    in_data_shift_1_y[0] = i_in_data_1_r_pad << in_weight_shift_large_y[0];
    in_data_shift_1_y[1] = i_in_data_2_r_pad << in_weight_shift_large_y[1];
    in_data_shift_1_y[2] = i_in_data_3_r_pad << in_weight_shift_large_y[2];
    in_data_shift_1_y[3] = i_in_data_5_r_pad << in_weight_shift_large_y[3];
    in_data_shift_1_y[4] = i_in_data_6_r_pad << in_weight_shift_large_y[4];
    in_data_shift_1_y[5] = i_in_data_7_r_pad << in_weight_shift_large_y[5];
end

always@* begin
    case(sobel_mode_d2)
        1'b0: begin
            in_data_shift_2_x[0] = i_in_data_4_r_pad << in_weight_shift_small_x[0];
            in_data_shift_2_x[1] = i_in_data_5_r_pad << in_weight_shift_small_x[1];
            in_data_shift_2_x[2] = i_in_data_6_r_pad << in_weight_shift_small_x[2];
            in_data_shift_2_x[3] = 0;
        end
        1'b1: begin
            in_data_shift_2_x[0] = i_in_data_0_r_pad << in_weight_shift_small_x[0];
            in_data_shift_2_x[1] = i_in_data_1_r_pad << in_weight_shift_small_x[1];
            in_data_shift_2_x[2] = i_in_data_2_r_pad << in_weight_shift_small_x[2];
            in_data_shift_2_x[3] = 0;
        end
        default: begin
            in_data_shift_2_x[0] = 0;
            in_data_shift_2_x[1] = 0;
            in_data_shift_2_x[2] = 0;
            in_data_shift_2_x[3] = 0;
        end
    endcase
end
always@* begin
    case(sobel_mode_d2)
        1'b0: begin
            in_data_shift_3_x[0] = i_in_data_5_r_pad << in_weight_shift_small_x[0];
            in_data_shift_3_x[1] = i_in_data_6_r_pad << in_weight_shift_small_x[1];
            in_data_shift_3_x[2] = i_in_data_7_r_pad << in_weight_shift_small_x[2];
            in_data_shift_3_x[3] = 0;
        end
        1'b1: begin
            in_data_shift_3_x[0] = i_in_data_1_r_pad << in_weight_shift_small_x[0];
            in_data_shift_3_x[1] = i_in_data_2_r_pad << in_weight_shift_small_x[1];
            in_data_shift_3_x[2] = i_in_data_3_r_pad << in_weight_shift_small_x[2];
            in_data_shift_3_x[3] = 0;
        end
        default: begin
            in_data_shift_3_x[0] = 0;
            in_data_shift_3_x[1] = 0;
            in_data_shift_3_x[2] = 0;
            in_data_shift_3_x[3] = 0;
        end
    endcase
end
always@* begin
    case(sobel_mode_d2)
        1'b0: begin
            in_data_shift_2_y[0] = i_in_data_4_r_pad << in_weight_shift_small_y[0];
            in_data_shift_2_y[1] = i_in_data_5_r_pad << in_weight_shift_small_y[1];
            in_data_shift_2_y[2] = i_in_data_6_r_pad << in_weight_shift_small_y[2];
            in_data_shift_2_y[3] = 0;
        end
        1'b1: begin
            in_data_shift_2_y[0] = i_in_data_0_r_pad << in_weight_shift_small_y[0];
            in_data_shift_2_y[1] = i_in_data_1_r_pad << in_weight_shift_small_y[1];
            in_data_shift_2_y[2] = i_in_data_2_r_pad << in_weight_shift_small_y[2];
            in_data_shift_2_y[3] = 0;
        end
        default: begin
            in_data_shift_2_y[0] = 0;
            in_data_shift_2_y[1] = 0;
            in_data_shift_2_y[2] = 0;
            in_data_shift_2_y[3] = 0;
        end
    endcase
end
always@* begin
    case(sobel_mode_d2)
        1'b0: begin
            in_data_shift_3_y[0] = i_in_data_5_r_pad << in_weight_shift_small_y[0];
            in_data_shift_3_y[1] = i_in_data_6_r_pad << in_weight_shift_small_y[1];
            in_data_shift_3_y[2] = i_in_data_7_r_pad << in_weight_shift_small_y[2];
            in_data_shift_3_y[3] = 0;
        end
        1'b1: begin
            in_data_shift_3_y[0] = i_in_data_1_r_pad << in_weight_shift_small_y[0];
            in_data_shift_3_y[1] = i_in_data_2_r_pad << in_weight_shift_small_y[1];
            in_data_shift_3_y[2] = i_in_data_3_r_pad << in_weight_shift_small_y[2];
            in_data_shift_3_y[3] = 0;
        end
        default: begin
            in_data_shift_3_y[0] = 0;
            in_data_shift_3_y[1] = 0;
            in_data_shift_3_y[2] = 0;
            in_data_shift_3_y[3] = 0;
        end
    endcase
end


// Filter out value of zero-kernal 
always@*
    for (i = 0; i < 6; i = i+1)
        in_data_shift_zero_filted_0_x[i] = (in_weight_shift_large_x[i] == 3'd3)? 0 : in_data_shift_0_x[i];

always@*
    for (i = 0; i < 6; i = i+1)
        in_data_shift_zero_filted_1_x[i] = (in_weight_shift_large_x[i] == 3'd3)? 0 : in_data_shift_1_x[i];    

always@*
    for (i = 0; i < 4; i = i+1)
        in_data_shift_zero_filted_2_x[i] = (in_weight_shift_small_x[i] == 3'd3)? 0 : in_data_shift_2_x[i];

always@*
    for (i = 0; i < 4; i = i+1)
        in_data_shift_zero_filted_3_x[i] = (in_weight_shift_small_x[i] == 3'd3)? 0 : in_data_shift_3_x[i];    


always@*
    for (i = 0; i < 6; i = i+1)
        in_data_shift_zero_filted_0_y[i] = (in_weight_shift_large_y[i] == 3'd3)? 0 : in_data_shift_0_y[i];

always@*
    for (i = 0; i < 6; i = i+1)
        in_data_shift_zero_filted_1_y[i] = (in_weight_shift_large_y[i] == 3'd3)? 0 : in_data_shift_1_y[i];    

always@*
    for (i = 0; i < 4; i = i+1)
        in_data_shift_zero_filted_2_y[i] = (in_weight_shift_small_y[i] == 3'd3)? 0 : in_data_shift_2_y[i];

always@*
    for (i = 0; i < 4; i = i+1)
        in_data_shift_zero_filted_3_y[i] = (in_weight_shift_small_y[i] == 3'd3)? 0 : in_data_shift_3_y[i];  

// Sobel Kernal Filter (Sign) 
// 1: neg, 0: pos
assign in_sign_large_x[0] = 1;
assign in_sign_large_x[1] = 0;
assign in_sign_large_x[2] = 0;
assign in_sign_large_x[3] = 1;
assign in_sign_large_x[4] = 0;
assign in_sign_large_x[5] = 0;

always@* begin
    case(sobel_mode_d2)
        1'b0: begin
            in_sign_large_y[0] = 1;
            in_sign_large_y[1] = 1;
            in_sign_large_y[2] = 1;
            in_sign_large_y[3] = 0;
            in_sign_large_y[4] = 0;
            in_sign_large_y[5] = 0;
        end
        1'b1: begin
            in_sign_large_y[0] = 0;
            in_sign_large_y[1] = 0;
            in_sign_large_y[2] = 0;
            in_sign_large_y[3] = 0;
            in_sign_large_y[4] = 0;
            in_sign_large_y[5] = 0;
        end
        default: begin
            in_sign_large_y[0] = 1;
            in_sign_large_y[1] = 1;
            in_sign_large_y[2] = 1;
            in_sign_large_y[3] = 0;
            in_sign_large_y[4] = 0;
            in_sign_large_y[5] = 0;
        end
    endcase
end



assign in_sign_small_x[0] = 1;
assign in_sign_small_x[1] = 0;
assign in_sign_small_x[2] = 0;
assign in_sign_small_x[3] = 0;


always@* begin
    case(sobel_mode_d2)
        1'b0: begin
            in_sign_small_y[0] = 1;
            in_sign_small_y[1] = 1;
            in_sign_small_y[2] = 1;
            in_sign_small_y[3] = 0;
        end
        1'b1: begin
            in_sign_small_y[0] = 0;
            in_sign_small_y[1] = 0;
            in_sign_small_y[2] = 0;
            in_sign_small_y[3] = 0;
        end
        default: begin
            in_sign_small_y[0] = 0;
            in_sign_small_y[1] = 0;
            in_sign_small_y[2] = 0;
            in_sign_small_y[3] = 0;
        end
    endcase
end    


// Covert to positve signed value (1.9.4)
always@*
    for (i = 0; i < 6; i = i+1)
        in_data_shift_zero_filted_signed_0_x[i] = {1'b0, in_data_shift_zero_filted_0_x[i]};

always@*
    for (i = 0; i < 6; i = i+1)
        in_data_shift_zero_filted_signed_1_x[i] = {1'b0, in_data_shift_zero_filted_1_x[i]};

always@*
    for (i = 0; i < 4; i = i+1)
        in_data_shift_zero_filted_signed_2_x[i] = {1'b0, in_data_shift_zero_filted_2_x[i]};

always@*
    for (i = 0; i < 4; i = i+1)
        in_data_shift_zero_filted_signed_3_x[i] = {1'b0, in_data_shift_zero_filted_3_x[i]}; 

always@*
    for (i = 0; i < 6; i = i+1)
        in_data_shift_zero_filted_signed_0_y[i] = {1'b0, in_data_shift_zero_filted_0_y[i]};

always@*
    for (i = 0; i < 6; i = i+1)
        in_data_shift_zero_filted_signed_1_y[i] = {1'b0, in_data_shift_zero_filted_1_y[i]};

always@*
    for (i = 0; i < 4; i = i+1)
        in_data_shift_zero_filted_signed_2_y[i] = {1'b0, in_data_shift_zero_filted_2_y[i]};

always@*
    for (i = 0; i < 4; i = i+1)
        in_data_shift_zero_filted_signed_3_y[i] = {1'b0, in_data_shift_zero_filted_3_y[i]}; 


// Sobel Signed Data Input (1.9.4)
always@* begin
    for (i = 0; i < 6; i = i+1)
        sobel_in_data_large[0][i] = (in_sign_large_x[i])? (-in_data_shift_zero_filted_signed_0_x[i]) : in_data_shift_zero_filted_signed_0_x[i];
    for (i = 0; i < 6; i = i+1)
        sobel_in_data_large[1][i] = (in_sign_large_x[i])? (-in_data_shift_zero_filted_signed_1_x[i]) : in_data_shift_zero_filted_signed_1_x[i];
    for (i = 0; i < 6; i = i+1)
        sobel_in_data_large[2][i] = (in_sign_large_y[i])? (-in_data_shift_zero_filted_signed_0_y[i]) : in_data_shift_zero_filted_signed_0_y[i];
    for (i = 0; i < 6; i = i+1)
        sobel_in_data_large[3][i] = (in_sign_large_y[i])? (-in_data_shift_zero_filted_signed_1_y[i]) : in_data_shift_zero_filted_signed_1_y[i];
end

always@* begin
    for (i = 0; i < 4; i = i+1)
        sobel_in_data_small[0][i] = (in_sign_small_x[i])? (-in_data_shift_zero_filted_signed_2_x[i]) : in_data_shift_zero_filted_signed_2_x[i];
    for (i = 0; i < 4; i = i+1)
        sobel_in_data_small[1][i] = (in_sign_small_x[i])? (-in_data_shift_zero_filted_signed_3_x[i]) : in_data_shift_zero_filted_signed_3_x[i];
    for (i = 0; i < 4; i = i+1)
        sobel_in_data_small[2][i] = (in_sign_small_y[i])? (-in_data_shift_zero_filted_signed_2_y[i]) : in_data_shift_zero_filted_signed_2_y[i];
    for (i = 0; i < 4; i = i+1)
        sobel_in_data_small[3][i] = (in_sign_small_y[i])? (-in_data_shift_zero_filted_signed_3_y[i]) : in_data_shift_zero_filted_signed_3_y[i];
end

// --------------------------------------------------------- Calculate Tangent Value ---------------------------------------------------------
// Approximation of Tangent value

assign Gx_current_pad[0] = {Gx_add_0_out, 3'b0};
assign Gx_current_pad[1] = {Gx_add_1_out, 3'b0};
assign Gx_current_pad[2] = {Gx_add_2_out, 3'b0};
assign Gx_current_pad[3] = {Gx_add_3_out, 3'b0};

assign Gy_current_pad[0] = {Gy_add_0_out, 3'b0};
assign Gy_current_pad[1] = {Gy_add_1_out, 3'b0};
assign Gy_current_pad[2] = {Gy_add_2_out, 3'b0};
assign Gy_current_pad[3] = {Gy_add_3_out, 3'b0};


// Shift Gx (1.13.7)
always@*
    for (i = 0; i < 4; i = i+1) begin
        Gx_current_shift[i][0] = Gx_current_pad[i] >>> 2;
        Gx_current_shift[i][1] = Gx_current_pad[i] >>> 3;
        Gx_current_shift[i][2] = Gx_current_pad[i] >>> 5;
        Gx_current_shift[i][3] = Gx_current_pad[i] >>> 7;
        Gx_current_shift[i][4] = Gx_current_pad[i] <<  1;
        Gx_current_shift[i][5] = 0;
    end


// --------------------------------------------------------- Adder Tree (Gx, Gy, tan)---------------------------------------------------------

// Select Adder Tree Stage 1 Input 
reg signed [20:0] add_tree_large_stage1_in [0:3][0:5];
reg signed [20:0] add_tree_small_stage1_in [0:3][0:3];
always@*
    for (i = 0; i < 4; i = i+1) 
        for (j = 0; j < 6; j = j+1) 
            if (state == CONV_LOAD)
                add_tree_large_stage1_in[i][j] = {{8{conv_in_data_large[i][j][12]}}, conv_in_data_large[i][j]};
            else
                case(sobel_state)
                    SOBEL_READ:   add_tree_large_stage1_in[i][j] = {{7{sobel_in_data_large[i][j][13]}}, sobel_in_data_large[i][j]};
                    SOBEL_COMP_ANGLE: add_tree_large_stage1_in[i][j] = {{7{sobel_in_data_large[i][j][13]}}, sobel_in_data_large[i][j]};
                    SOBEL_NMS:   add_tree_large_stage1_in[i][j] = {{7{sobel_in_data_large[i][j][13]}}, sobel_in_data_large[i][j]};
                    //SOBEL_WAIT:   add_tree_large_stage1_in[i][j] = {{7{sobel_in_data_large[i][j][13]}}, sobel_in_data_large[i][j]};
                    SOBEL_COMP_G: add_tree_large_stage1_in[i][j] = Gx_current_shift[i][j];
                    default:      add_tree_large_stage1_in[i][j] = 0;
                endcase
                /*if (sobel_state == SOBEL_COMP_G)
                    add_tree_large_stage1_in[i][j] = Gx_current_shift[i][j];
                else
                    add_tree_large_stage1_in[i][j] = {{7{sobel_in_data_large[i][j][13]}}, sobel_in_data_large[i][j]};*/

always@*
    for (i = 0; i < 4; i = i+1) 
        for (j = 0; j < 4; j = j+1) 
            if (state == CONV_LOAD)
                add_tree_small_stage1_in[i][j] = {{8{conv_in_data_small[i][j][12]}}, conv_in_data_small[i][j]};
            else
                case(sobel_state)
                    SOBEL_READ:   add_tree_small_stage1_in[i][j] = {{7{sobel_in_data_small[i][j][13]}}, sobel_in_data_small[i][j]};
                    SOBEL_COMP_ANGLE: add_tree_small_stage1_in[i][j] = {{7{sobel_in_data_small[i][j][13]}}, sobel_in_data_small[i][j]};
                    SOBEL_NMS:   add_tree_small_stage1_in[i][j] = {{7{sobel_in_data_small[i][j][13]}}, sobel_in_data_small[i][j]};
                    // SOBEL_WAIT:   add_tree_large_stage1_in[i][j] = {{7{sobel_in_data_small[i][j][13]}}, sobel_in_data_small[i][j]};
                    SOBEL_COMP_G: add_tree_small_stage1_in[i][j] = Gx_current_shift[i][j];
                    default:      add_tree_small_stage1_in[i][j] = 0;
                endcase
                /*if (sobel_state == SOBEL_COMP_G)
                    add_tree_small_stage1_in[i][j] = Gx_current_shift[i][j];
                else
                    add_tree_large_stage1_in[i][j] = {{7{sobel_in_data_small[i][j][13]}}, sobel_in_data_small[i][j]};*/


// Addition of Stage 1 (Large: 3*4 adder, Small: 2*4 adder) (1.14.7)
reg signed [21:0] add_tree_large_stage1_out [0:3][0:2];
reg signed [21:0] add_tree_small_stage1_out [0:3][0:1];
always@* 
    for (i = 0; i < 4; i = i+1) begin 
        add_tree_large_stage1_out[i][0] = add_tree_large_stage1_in[i][0] + add_tree_large_stage1_in[i][1];
        add_tree_large_stage1_out[i][1] = add_tree_large_stage1_in[i][2] + add_tree_large_stage1_in[i][3];
        add_tree_large_stage1_out[i][2] = add_tree_large_stage1_in[i][4] + add_tree_large_stage1_in[i][5];
    end
always@* 
    for (i = 0; i < 4; i = i+1) begin
        add_tree_small_stage1_out[i][0] = add_tree_small_stage1_in[i][0] + add_tree_small_stage1_in[i][1];
        add_tree_small_stage1_out[i][1] = add_tree_small_stage1_in[i][2] + add_tree_small_stage1_in[i][3];
    end

// Select Adder Tree Stage 2 Input 
reg signed [21:0] add_tree_large_stage2_in [0:3][0:2];
reg signed [21:0] add_tree_small_stage2_in [0:3][0:1];
always@*
    for (i = 0; i < 4; i = i+1) 
        for (j = 0; j < 3; j = j+1) 
            if (state == CONV_LOAD)
                add_tree_large_stage2_in[i][j] = add_tree_large_stage1_out[i][j];
            else
                case(sobel_state)
                    SOBEL_READ:   add_tree_large_stage2_in[i][j] = add_tree_large_stage1_out[i][j];
                    SOBEL_COMP_G: add_tree_large_stage2_in[i][j] = add_tree_large_stage1_out[i][j];
                    SOBEL_NMS:    add_tree_large_stage2_in[i][j] = add_tree_large_stage1_out[i][j];
                    SOBEL_COMP_ANGLE:   add_tree_large_stage2_in[i][j] = add_tree_large_stage1_out[i][j];
                    default:      add_tree_large_stage2_in[i][j] = 0;
                endcase
                // add_tree_large_stage2_in[i][j] = add_tree_large_stage1_out[i][j];

always@*
    for (i = 0; i < 4; i = i+1) 
        for (j = 0; j < 2; j = j+1) 
            if (state == CONV_LOAD)
                add_tree_small_stage2_in[i][j] = add_tree_small_stage1_out[i][j];
            else            
                case(sobel_state)
                    SOBEL_READ:   add_tree_small_stage2_in[i][j] = add_tree_small_stage1_out[i][j];
                    SOBEL_COMP_G: add_tree_small_stage2_in[i][j] = add_tree_small_stage1_out[i][j];
                    SOBEL_NMS:    add_tree_small_stage2_in[i][j] = add_tree_small_stage1_out[i][j];
                    SOBEL_COMP_ANGLE:   add_tree_small_stage2_in[i][j] = add_tree_small_stage1_out[i][j];
                    default:      add_tree_small_stage2_in[i][j] = 0;
                endcase
                // add_tree_small_stage2_in[i][j] = add_tree_small_stage1_out[i][j];

// Addition of Stage 2 (Large: 1*4 adder, Small: 0 adder) (1.15.7)
reg signed [22:0] add_tree_large_stage2_out [0:3][0:1];
reg signed [22:0] add_tree_small_stage2_out [0:3][0:1];

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        for (i = 0; i < 4; i = i+1) begin
            add_tree_large_stage2_out[i][0] <= 0;
            add_tree_large_stage2_out[i][1] <= 0;
        end
    else
        for (i = 0; i < 4; i = i+1) begin
            add_tree_large_stage2_out[i][0] <= add_tree_large_stage2_in[i][0] + add_tree_large_stage2_in[i][1];
            add_tree_large_stage2_out[i][1] <= {add_tree_large_stage2_in[i][2][21], add_tree_large_stage2_in[i][2]};
        end

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        for (i = 0; i < 4; i = i+1) begin
            add_tree_small_stage2_out[i][0] <= 0;
            add_tree_small_stage2_out[i][1] <= 0;
        end
    else
        for (i = 0; i < 4; i = i+1) begin
            add_tree_small_stage2_out[i][0] <= {add_tree_small_stage2_in[i][0][21], add_tree_small_stage2_in[i][0]};
            add_tree_small_stage2_out[i][1] <= {add_tree_small_stage2_in[i][1][21], add_tree_small_stage2_in[i][1]};
        end

// Select Adder Tree Stage 3 Input 
reg signed [22:0] add_tree_large_stage3_in [0:3][0:1];
reg signed [22:0] add_tree_small_stage3_in [0:3][0:1];
always@*
    for (i = 0; i < 4; i = i+1) 
        for (j = 0; j < 2; j = j+1) 
            add_tree_large_stage3_in[i][j] = add_tree_large_stage2_out[i][j];

always@*
    for (i = 0; i < 4; i = i+1) 
        for (j = 0; j < 2; j = j+1) 
            add_tree_small_stage3_in[i][j] = add_tree_small_stage2_out[i][j];


// Addition of Stage 3 (Large: 1*4 adder, Small: 1*4 adder) (1.16.7)
reg signed [23:0] add_tree_large_stage3_out [0:3];
reg signed [23:0] add_tree_small_stage3_out [0:3];
always@*
    for (i = 0; i < 4; i = i+1) 
        add_tree_large_stage3_out[i] = add_tree_large_stage3_in[i][0] + add_tree_large_stage3_in[i][1];
always@*
    for (i = 0; i < 4; i = i+1) 
        add_tree_small_stage3_out[i] = add_tree_small_stage3_in[i][0] + add_tree_small_stage3_in[i][1];


// Store Tangent Value

always@*
    for (i = 0; i < 4; i = i+1)  begin
        Gx_current_pad_identical[i] = {{3{Gx_current_pad[i][20]}}, Gx_current_pad[i]};
        Gy_current_pad_identical[i] = {{3{Gy_current_pad[i][20]}}, Gy_current_pad[i]};
    end

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        for (i = 0; i < 4; i = i+1)
            tan_0225[i] <= 0;
    else
        for (i = 0; i < 4; i = i+1)
            if (sobel_state == SOBEL_COMP_G)
                tan_0225[i] <= add_tree_small_stage3_out[i];
                // tan_0225[i] <= add_tree_small_stage3_out[i][23:0];
            else if (sobel_state == SOBEL_COMP_ANGLE)
                tan_0225[i] <= tan_0225[i];    
            else
                tan_0225[i] <= 0;     

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        for (i = 0; i < 4; i = i+1)
            tan_0450[i] <= 0;
    else
        for (i = 0; i < 4; i = i+1)
            if (sobel_state == SOBEL_COMP_G)
                tan_0450[i] <= Gx_current_pad_identical[i];
            else if (sobel_state == SOBEL_COMP_ANGLE)
                tan_0450[i] <= tan_0450[i];    
            else
                tan_0450[i] <= 0;  

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        for (i = 0; i < 4; i = i+1)
            tan_0675[i] <= 0;
    else
        for (i = 0; i < 4; i = i+1)
            if (sobel_state == SOBEL_COMP_G)
                tan_0675[i] <= add_tree_large_stage3_out[i];
                // tan_0675[i] <= add_tree_large_stage3_out[i][23:0];
            else if (sobel_state == SOBEL_COMP_ANGLE)
                tan_0675[i] <= tan_0675[i];    
            else
                tan_0675[i] <= 0; 

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        for (i = 0; i < 4; i = i+1)
            tan_1125[i] <= 0;
    else
        for (i = 0; i < 4; i = i+1)
            if (sobel_state == SOBEL_COMP_G)
                tan_1125[i] <= (-add_tree_large_stage3_out[i]);
                // tan_1125[i] <= (-add_tree_large_stage3_out[i])[23:0];
            else if (sobel_state == SOBEL_COMP_ANGLE)
                tan_1125[i] <= tan_1125[i];    
            else
                tan_1125[i] <= 0;

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        for (i = 0; i < 4; i = i+1)
            tan_1350[i] <= 0;
    else
        for (i = 0; i < 4; i = i+1)
            if (sobel_state == SOBEL_COMP_G)
                tan_1350[i] <= (-Gx_current_pad_identical[i]);
            else if (sobel_state == SOBEL_COMP_ANGLE)
                tan_1350[i] <= tan_1350[i];    
            else
                tan_1350[i] <= 0;   

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        for (i = 0; i < 4; i = i+1)
            tan_1575[i] <= 0;
    else
        for (i = 0; i < 4; i = i+1)
            if (sobel_state == SOBEL_COMP_G)
                tan_1575[i] <= (-add_tree_small_stage3_out[i]);
                // tan_1575[i] <= (-add_tree_small_stage3_out[i])[23:0];
            else if (sobel_state == SOBEL_COMP_ANGLE)
                tan_1575[i] <= tan_1575[i];    
            else
                tan_1575[i] <= 0; 

always@(posedge i_clk or negedge i_rst_n) 
    if (~i_rst_n)  
        for (i = 0; i < 4; i = i+1)  
            Gx_current_sign[i] <= 0;
    else
        for (i = 0; i < 4; i = i+1)
            if (sobel_state == SOBEL_COMP_G)
                Gx_current_sign[i] <= Gx_current_pad[i][20];
            else
                Gx_current_sign[i] <= 0;


// --------------------------------------------------------- Find Nearest Angle ---------------------------------------------------------
reg [6:0] tan_compare_results [0:3]; // 0: most negative, 6: most positive
reg [1:0] tan_range [0:3];
always@*
    for (i = 0; i < 4; i = i+1) begin
        tan_compare_results[i][0] = (Gy_current_pad_identical[i] < tan_1125[i]);            
        tan_compare_results[i][1] = (Gy_current_pad_identical[i] < tan_1350[i]); 
        tan_compare_results[i][2] = (Gy_current_pad_identical[i] < tan_1575[i]);
        tan_compare_results[i][3] = Gy_current_pad_identical[i][23];
        tan_compare_results[i][4] = (Gy_current_pad_identical[i] < tan_0225[i]);
        tan_compare_results[i][5] = (Gy_current_pad_identical[i] < tan_0450[i]);
        tan_compare_results[i][6] = (Gy_current_pad_identical[i] < tan_0675[i]);
    end
// Indicate range of the angle (0: 0, 1: 45, 2: 90, 3: 135)
always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        for (i = 0; i < 4; i = i+1)
            tan_range[i] <= 0;
    else
        for (i = 0; i < 4; i = i+1)
            if (sobel_state == SOBEL_COMP_ANGLE)
                if (~Gx_current_sign[i])                                   // Gx > 0
                    case(tan_compare_results[i])
                        7'b1111111: tan_range[i] <= 2'd2;                  // 90    <= range <= 112.5
                        7'b1111110: tan_range[i] <= 2'd3;                  // 112.5 <= range <= 135
                        7'b1111100: tan_range[i] <= 2'd3;                  // 135   <= range <= 157.5 
                        7'b1111000: tan_range[i] <= 2'd0;                  // 157.5 <= range <= 180 
                        7'b1110000: tan_range[i] <= 2'd0;                  // 0     <= range <= 22.5 
                        7'b1100000: tan_range[i] <= 2'd1;                  // 22.5  <= range <= 45
                        7'b1000000: tan_range[i] <= 2'd1;                  // 45    <= range <= 67.5 
                        7'b0000000: tan_range[i] <= 2'd2;                  // 67.5  <= range <= 90
                        default:    tan_range[i] <= 2'd0;  
                    endcase  
                else                                                       // Gx < 0
                    case(tan_compare_results[i])
                        7'b1111111: tan_range[i] <= 2'd2;                  // 67.5  <= range <= 90
                        7'b0111111: tan_range[i] <= 2'd1;                  // 45    <= range <= 67.5
                        7'b0011111: tan_range[i] <= 2'd1;                  // 22.5  <= range <= 45 
                        7'b0001111: tan_range[i] <= 2'd0;                  // 0     <= range <= 22.5
                        7'b0000111: tan_range[i] <= 2'd0;                  // 157.5 <= range <= 180 
                        7'b0000011: tan_range[i] <= 2'd3;                  // 135   <= range <= 157.5
                        7'b0000001: tan_range[i] <= 2'd3;                  // 112.5 <= range <= 135 
                        7'b0000000: tan_range[i] <= 2'd2;                  // 90    <= range <= 112.5
                        default:    tan_range[i] <= 2'd0;  
                    endcase                  
            else
                tan_range[i] <= tan_range[i];     

// --------------------------------------------------------- Additional of Sobel Gx, Gy, Conv  ---------------------------------------------------------
reg G_reg_mode_sel;
always@*
    if (state == CONV_LOAD)
        G_reg_mode_sel = conv_mode_d1;
    else
        G_reg_mode_sel = sobel_mode_d3;
always@*
    case(G_reg_mode_sel)
        1'b0:    Gx_add_0_in = add_tree_large_stage3_out[0][16:0];
        1'b1:    Gx_add_0_in = add_tree_small_stage3_out[0][16:0];
        default: Gx_add_0_in = 0;
    endcase 
always@*
    case(G_reg_mode_sel)
        1'b0:    Gx_add_1_in = add_tree_large_stage3_out[1][16:0];
        1'b1:    Gx_add_1_in = add_tree_small_stage3_out[1][16:0];
        default: Gx_add_1_in = 0;
    endcase 

always@*
    case(G_reg_mode_sel)
        1'b0:    Gx_add_2_in = add_tree_small_stage3_out[0][16:0];
        1'b1:    Gx_add_2_in = add_tree_large_stage3_out[0][16:0];
        default: Gx_add_2_in = 0;
    endcase 
always@*
    case(G_reg_mode_sel) 
        1'b0:    Gx_add_3_in = add_tree_small_stage3_out[1][16:0];
        1'b1:    Gx_add_3_in = add_tree_large_stage3_out[1][16:0];
        default: Gx_add_3_in = 0;
    endcase 


always@*
    case(G_reg_mode_sel)
        1'b0:    Gy_add_0_in = add_tree_large_stage3_out[2][16:0];
        1'b1:    Gy_add_0_in = add_tree_small_stage3_out[2][16:0];
        default: Gy_add_0_in = 0;
    endcase 
always@*
    case(G_reg_mode_sel) 
        1'b0:    Gy_add_1_in = add_tree_large_stage3_out[3][16:0];
        1'b1:    Gy_add_1_in = add_tree_small_stage3_out[3][16:0];
        default: Gy_add_1_in = 0;
    endcase 

always@*
    case(G_reg_mode_sel)   
        1'b0:    Gy_add_2_in = add_tree_small_stage3_out[2][16:0];
        1'b1:    Gy_add_2_in = add_tree_large_stage3_out[2][16:0];
        default: Gy_add_2_in = 0;
    endcase 
always@*
    case(G_reg_mode_sel) 
        1'b0:    Gy_add_3_in = add_tree_small_stage3_out[3][16:0];
        1'b1:    Gy_add_3_in = add_tree_large_stage3_out[3][16:0];
        default: Gy_add_3_in = 0;
    endcase 


/*always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        Gx_add_0_out <= 0;
    else*/
//  
always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        G_conv_add_0_out <= 0;
    else
        if ((state == CONV_LOAD) && conv_read_valid)
            G_conv_add_0_out <= G_conv_add_0_out + Gx_add_0_in;
        else if (conv_clear)
            G_conv_add_0_out <= 0;  
        else
            G_conv_add_0_out <= G_conv_add_0_out;

//  
always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        G_conv_add_1_out <= 0;
    else
        if ((state == CONV_LOAD) && conv_read_valid)
            G_conv_add_1_out <= G_conv_add_1_out + Gx_add_1_in;
        else if (conv_clear)
            G_conv_add_1_out <= 0;  
        else
            G_conv_add_1_out <= G_conv_add_1_out;

//  
always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        G_conv_add_2_out <= 0;
    else
        if ((state == CONV_LOAD) && conv_read_valid)
            G_conv_add_2_out <= G_conv_add_2_out + Gx_add_2_in;
        else if (conv_clear)
            G_conv_add_2_out <= 0;  
        else
            G_conv_add_2_out <= G_conv_add_2_out;

//  
always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        G_conv_add_3_out <= 0;
    else
        if ((state == CONV_LOAD) && conv_read_valid)
            G_conv_add_3_out <= G_conv_add_3_out + Gx_add_3_in;
        else if (conv_clear)
            G_conv_add_3_out <= 0;  
        else
            G_conv_add_3_out <= G_conv_add_3_out;


always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        Gx_add_0_out <= 0;
    else
        if (((sobel_state  == SOBEL_READ) && sobel_read_valid) || (sobel_state == SOBEL_NMS) || (sobel_state == SOBEL_WAIT))
            Gx_add_0_out <= Gx_add_0_out + Gx_add_0_in;       
        else if (sobel_clear)
            Gx_add_0_out <= 0;
        else
            Gx_add_0_out <= Gx_add_0_out;

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        Gx_add_1_out <= 0;
    else
        if (((sobel_state  == SOBEL_READ) && sobel_read_valid) || (sobel_state == SOBEL_NMS) || (sobel_state == SOBEL_WAIT))
            Gx_add_1_out <= Gx_add_1_out + Gx_add_1_in;
        else if (sobel_clear)
            Gx_add_1_out <= 0;
        else
            Gx_add_1_out <= Gx_add_1_out;

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        Gx_add_2_out <= 0;
    else
        if (((sobel_state  == SOBEL_READ) && sobel_read_valid) || (sobel_state == SOBEL_NMS) || (sobel_state == SOBEL_WAIT))
            Gx_add_2_out <= Gx_add_2_out + Gx_add_2_in; 
        else if (sobel_clear)
            Gx_add_2_out <= 0;
        else
            Gx_add_2_out <= Gx_add_2_out;

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        Gx_add_3_out <= 0;
    else
        if (((sobel_state  == SOBEL_READ) && sobel_read_valid) || (sobel_state == SOBEL_NMS) || (sobel_state == SOBEL_WAIT))
            Gx_add_3_out <= Gx_add_3_out + Gx_add_3_in;
        else if (sobel_clear)
            Gx_add_3_out <= 0;
        else
            Gx_add_3_out <= Gx_add_3_out;



always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        Gy_add_0_out <= 0;
    else
        if (((sobel_state  == SOBEL_READ) && sobel_read_valid) || (sobel_state == SOBEL_NMS) || (sobel_state == SOBEL_WAIT))
            Gy_add_0_out <= Gy_add_0_out + Gy_add_0_in;
        else if (sobel_clear)
            Gy_add_0_out <= 0;
        else
            Gy_add_0_out <= Gy_add_0_out;

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        Gy_add_1_out <= 0;
    else
        if (((sobel_state  == SOBEL_READ) && sobel_read_valid) || (sobel_state == SOBEL_NMS) || (sobel_state == SOBEL_WAIT))
            Gy_add_1_out <= Gy_add_1_out + Gy_add_1_in;
        else if (sobel_clear)
            Gy_add_1_out <= 0;
        else
            Gy_add_1_out <= Gy_add_1_out;

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        Gy_add_2_out <= 0;
    else
        if (((sobel_state  == SOBEL_READ) && sobel_read_valid) || (sobel_state == SOBEL_NMS) || (sobel_state == SOBEL_WAIT))
            Gy_add_2_out <= Gy_add_2_out + Gy_add_2_in;
        else if (sobel_clear)
            Gy_add_2_out <= 0;
        else
            Gy_add_2_out <= Gy_add_2_out;

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        Gy_add_3_out <= 0;
    else
        if (((sobel_state  == SOBEL_READ) && sobel_read_valid) || (sobel_state == SOBEL_NMS) || (sobel_state == SOBEL_WAIT))
            Gy_add_3_out <= Gy_add_3_out + Gy_add_3_in;
        else if (sobel_clear)
            Gy_add_3_out <= 0;
        else
            Gy_add_3_out <= Gy_add_3_out;


// Compuation of G
reg signed [17:0] Gx_add_0_abs;
reg signed [17:0] Gx_add_1_abs;
reg signed [17:0] Gx_add_2_abs;
reg signed [17:0] Gx_add_3_abs;

reg signed [17:0] Gy_add_0_abs;
reg signed [17:0] Gy_add_1_abs;
reg signed [17:0] Gy_add_2_abs;
reg signed [17:0] Gy_add_3_abs;

reg signed [18:0] G_add_0_out;
reg signed [18:0] G_add_1_out;
reg signed [18:0] G_add_2_out;
reg signed [18:0] G_add_3_out;

// Absolute Value
always@*
    case({Gx_add_0_out[17]})
        1'b0:   Gx_add_0_abs =    Gx_add_0_out;
        1'b1:   Gx_add_0_abs =   -Gx_add_0_out;
        default: Gx_add_0_abs = 0;
    endcase
always@*
    case({Gx_add_1_out[17]})
        1'b0:   Gx_add_1_abs =    Gx_add_1_out;
        1'b1:   Gx_add_1_abs =   -Gx_add_1_out;
        default: Gx_add_1_abs = 0;
    endcase
always@*
    case({Gx_add_2_out[17]})
        1'b0:   Gx_add_2_abs =    Gx_add_2_out;
        1'b1:   Gx_add_2_abs =   -Gx_add_2_out;
        default: Gx_add_2_abs = 0;
    endcase
always@*
    case({Gx_add_3_out[17]})
        1'b0:   Gx_add_3_abs =    Gx_add_3_out;
        1'b1:   Gx_add_3_abs =   -Gx_add_3_out;
        default: Gx_add_3_abs = 0;
    endcase

always@*
    case({Gy_add_0_out[17]})
        1'b0:   Gy_add_0_abs =    Gy_add_0_out;
        1'b1:   Gy_add_0_abs =   -Gy_add_0_out;
        default: Gy_add_0_abs = 0;
    endcase

always@*
    case({Gy_add_1_out[17]})
        1'b0:   Gy_add_1_abs =    Gy_add_1_out;
        1'b1:   Gy_add_1_abs =   -Gy_add_1_out;
        default: Gy_add_1_abs = 0;
    endcase
always@*
    case({Gy_add_2_out[17]})
        1'b0:   Gy_add_2_abs =    Gy_add_2_out;
        1'b1:   Gy_add_2_abs =   -Gy_add_2_out;
        default: Gy_add_2_abs = 0;
    endcase
always@*
    case({Gy_add_3_out[17]})
        1'b0:   Gy_add_3_abs =    Gy_add_3_out;
        1'b1:   Gy_add_3_abs =   -Gy_add_3_out;
        default: Gy_add_3_abs = 0;
    endcase

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        G_add_0_out <= 0;
    else
        if (sobel_state == SOBEL_COMP_ANGLE)
            G_add_0_out <= Gx_add_0_abs + Gy_add_0_abs;
        else if (sobel_state == SOBEL_IDLE)
            G_add_0_out <= 0;        
        else
            G_add_0_out <= G_add_0_out;

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        G_add_1_out <= 0;
    else
        if (sobel_state == SOBEL_COMP_ANGLE)
            G_add_1_out <= Gx_add_1_abs + Gy_add_1_abs;
        else if (sobel_state == SOBEL_IDLE)
            G_add_1_out <= 0;   
        else
            G_add_1_out <= G_add_1_out;

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        G_add_2_out <= 0;
    else
        if (sobel_state == SOBEL_COMP_ANGLE)
            G_add_2_out <= Gx_add_2_abs + Gy_add_2_abs;
        else if (sobel_state == SOBEL_IDLE)
            G_add_2_out <= 0;   
        else
            G_add_2_out <= G_add_2_out;

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        G_add_3_out <= 0;
    else
        if (sobel_state == SOBEL_COMP_ANGLE)
            G_add_3_out <= Gx_add_3_abs + Gy_add_3_abs;
        else if (sobel_state == SOBEL_IDLE)
            G_add_3_out <= 0;   
        else
            G_add_3_out <= G_add_3_out;

// --------------------------------------------------------- Suppression  ---------------------------------------------------------
wire signed [19:0] G_add_01_out;
wire signed [19:0] G_add_02_out;
wire signed [19:0] G_add_03_out;
wire signed [19:0] G_add_12_out;
wire signed [19:0] G_add_13_out;
wire signed [19:0] G_add_23_out;

assign G_add_01_out = G_add_0_out - G_add_1_out;
assign G_add_02_out = G_add_0_out - G_add_2_out;
assign G_add_03_out = G_add_0_out - G_add_3_out;
assign G_add_12_out = G_add_1_out - G_add_2_out;
assign G_add_13_out = G_add_1_out - G_add_3_out;
assign G_add_23_out = G_add_2_out - G_add_3_out;


// Tan Range: (0: 0, 1: 45, 2: 90, 3: 135)
reg signed [18:0] G_suppresion_0_out;
reg signed [18:0] G_suppresion_1_out;
reg signed [18:0] G_suppresion_2_out;
reg signed [18:0] G_suppresion_3_out;
always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        G_suppresion_0_out <= 0;
    else
        if (sobel_state == SOBEL_NMS)   
            case(tan_range[0])
                2'd0:                                                     // Nearest Angle: 0
                    if (~G_add_01_out[19])                                // add_0 >= add_1
                        G_suppresion_0_out <= G_add_0_out; 
                    else                                                  // add_0 <  add_1
                        G_suppresion_0_out <= 0;
                2'd1:                                                     // Nearest Angle: 45
                    if (~G_add_03_out[19])                                // add_0 >= add_3
                        G_suppresion_0_out <= G_add_0_out;                 
                    else                                                  // add_0 <  add_3
                        G_suppresion_0_out <= 0;
                2'd2:                                                     // Nearest Angle: 90
                    if (~G_add_02_out[19])                                // add_0 >= add_2
                        G_suppresion_0_out <= G_add_0_out;                   
                    else                                                  // add_0 <  add_2
                        G_suppresion_0_out <= 0;
                2'd3:                                                     // Nearest Angle: 135
                    if (~G_add_0_out[0])
                        G_suppresion_0_out <= G_add_0_out;                // add_0 >= 0
                    else
                        G_suppresion_0_out <= 0;                          // add_0 <  0
                default: G_suppresion_0_out <= G_suppresion_0_out;
            endcase
        else
            G_suppresion_0_out <= G_suppresion_0_out;
                            
always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        G_suppresion_1_out <= 0;
    else
        if (sobel_state == SOBEL_NMS)   
            case(tan_range[1])
                2'd0:                                                     // Nearest Angle: 0
                    if (G_add_01_out[19] || &(~G_add_01_out))             // add_1 >= add_0
                        G_suppresion_1_out <= G_add_1_out;          
                    else                                                  // add_1 <  add_0
                        G_suppresion_1_out <= 0;
                2'd1:                                                     // Nearest Angle: 45
                    if (~G_add_1_out[0])
                        G_suppresion_1_out <= G_add_1_out;                // add_1 >= 0
                    else
                        G_suppresion_1_out <= 0;                          // add_1 <  0
                2'd2:                                                     // Nearest Angle: 90
                    if (~G_add_13_out[19])                                // add_1 >= add_3
                        G_suppresion_1_out <= G_add_1_out;                
                    else                                                  // add_1 <  add_3
                        G_suppresion_1_out <= 0;
                2'd3:                                                     // Nearest Angle: 135
                    if (~G_add_12_out[19])                                // add_1 >= add_2
                        G_suppresion_1_out <= G_add_1_out;                   
                    else                                                  // add_1 <  add_2
                        G_suppresion_1_out <= 0;
                default: G_suppresion_1_out <= G_suppresion_1_out;
            endcase
        else
            G_suppresion_1_out <= G_suppresion_1_out;

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        G_suppresion_2_out <= 0;
    else
        if (sobel_state == SOBEL_NMS)   
            case(tan_range[2])
                2'd0:                                                     // Nearest Angle: 0
                    if (~G_add_23_out[19])                                // add_2 >= add_3
                        G_suppresion_2_out <= G_add_2_out;          
                    else                                                  // add_2 <  add_3
                        G_suppresion_2_out <= 0;
                2'd1:                                                     // Nearest Angle: 45
                    if (~G_add_2_out[0])
                        G_suppresion_2_out <= G_add_2_out;                // add_2 >= 0
                    else
                        G_suppresion_2_out <= 0;                          // add_2 <  0
                2'd2:                                                     // Nearest Angle: 90
                    if (G_add_02_out[19] || &(~G_add_02_out))             // add_2 >= add_0
                        G_suppresion_2_out <= G_add_2_out;                 
                    else                                                  // add_2 <  add_0
                        G_suppresion_2_out <= 0;
                2'd3:                                                     // Nearest Angle: 135
                    if (G_add_12_out[19] || &(~G_add_12_out))             // add_2 >= add_1
                        G_suppresion_2_out <= G_add_2_out;           
                    else                                                  // add_2 <  add_1
                        G_suppresion_2_out <= 0;
            endcase
        else
            G_suppresion_2_out <= G_suppresion_2_out;
                            
always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        G_suppresion_3_out <= 0;
    else
        if (sobel_state == SOBEL_NMS)   
            case(tan_range[3])
                2'd0:                                                     // Nearest Angle: 0
                    if (G_add_23_out[19] || &(~G_add_23_out))             // add_3 >= add_2
                        G_suppresion_3_out <= G_add_3_out;            
                    else                                                  // add_3 <  add_2
                        G_suppresion_3_out <= 0;
                2'd1:                                                     // Nearest Angle: 45
                    if (G_add_03_out[19] || &(~G_add_03_out))             // add_3 >= add_0
                        G_suppresion_3_out <= G_add_3_out;                  
                    else                                                  // add_3 <  add_0
                            G_suppresion_3_out <= 0;
                2'd2:                                                     // Nearest Angle: 90
                    if (G_add_13_out[19] || &(~G_add_13_out))             // add_3 >= add_1
                        G_suppresion_3_out <= G_add_3_out;        
                    else                                                  // add_3 <  add_1
                        G_suppresion_3_out <= 0;
                2'd3:                                                     // Nearest Angle: 135
                    if (~G_add_3_out[0])
                        G_suppresion_3_out <= G_add_3_out;                // add_3 >= 0
                    else
                        G_suppresion_3_out <= 0;                          // add_3 <  0

                default: G_suppresion_3_out <= G_suppresion_3_out;
            endcase
        else
            G_suppresion_3_out <= G_suppresion_3_out;



// --------------------------------------------------------- Conv Output ---------------------------------------------------------
// Rounding (13.4) (Since Output is (1.13))
reg [16:0] conv_add_0_out_round;
reg [16:0] conv_add_1_out_round;
reg [16:0] conv_add_2_out_round;
reg [16:0] conv_add_3_out_round;

always@*
    if (G_conv_add_0_out[3]) 
        conv_add_0_out_round = G_conv_add_0_out + 4'b1000;
    else
        conv_add_0_out_round = G_conv_add_0_out;

always@*
    if (G_conv_add_1_out[3]) 
        conv_add_1_out_round = G_conv_add_1_out + 4'b1000;
    else
        conv_add_1_out_round = G_conv_add_1_out;
always@*
    if (G_conv_add_2_out[3]) 
        conv_add_2_out_round = G_conv_add_2_out + 4'b1000;
    else
        conv_add_2_out_round = G_conv_add_2_out;
always@*
    if (G_conv_add_3_out[3]) 
        conv_add_3_out_round = G_conv_add_3_out + 4'b1000;
    else
        conv_add_3_out_round = G_conv_add_3_out;



// --------------------------------------------------------- Sobel Output ---------------------------------------------------------

always@*
    if (state == CONV_OUT)  begin
        o_out_data_0 = {1'b0, conv_add_0_out_round[16:4]};
        o_out_data_1 = {1'b0, conv_add_1_out_round[16:4]};
        o_out_data_2 = {1'b0, conv_add_2_out_round[16:4]};
        o_out_data_3 = {1'b0, conv_add_3_out_round[16:4]};        
    end
    else begin
        o_out_data_0 = {G_suppresion_0_out[18], G_suppresion_0_out[16:4]};
        o_out_data_1 = {G_suppresion_1_out[18], G_suppresion_1_out[16:4]};
        o_out_data_2 = {G_suppresion_2_out[18], G_suppresion_2_out[16:4]};
        o_out_data_3 = {G_suppresion_3_out[18], G_suppresion_3_out[16:4]};
    end


endmodule
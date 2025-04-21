module median_unit # (
    parameter MEDIAN_IDLE = 3'd0,
    parameter MEDIAN_READ = 3'd1,
    parameter MEDIAN_CENTER = 3'd2,
    parameter MEDIAN_SIDE = 3'd3,
    parameter MEDIAN_CORNER = 3'd4,
    parameter MEDIAN_WAIT = 3'd5
    // parameter MEDIAN_UP_CORNER,
    // parameter MEDIAN_LOAD_DOWN,
    // parameter MEDIAN_DOWN_CENTER,
    // parameter MEDIAN_DOWN_SIDE,
    // parameter MEDIAN_DOWN_CORNER
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
    input  [ 7:0] i_in_data_8,
    input  [ 7:0] i_in_data_9,
    input  [ 7:0] i_in_data_10,
    input  [ 7:0] i_in_data_11,
    input  [ 7:0] i_in_data_12,
    input  [ 7:0] i_in_data_13,
    input  [ 7:0] i_in_data_14,
    input  [ 7:0] i_in_data_15,

    input  [ 2:0] median_state,
    input         median_clear,
    input  [ 1:0] median_loc_control, 

	output [13:0] o_out_data_0,
	output [13:0] o_out_data_1,
	output [13:0] o_out_data_2,
	output [13:0] o_out_data_3    
);

reg [7:0] i_in_data_0_r, i_in_data_1_r, i_in_data_2_r, i_in_data_3_r, i_in_data_4_r, i_in_data_5_r, i_in_data_6_r, i_in_data_7_r;
reg [12:0] i_in_data_0_r_pad, i_in_data_1_r_pad, i_in_data_2_r_pad, i_in_data_3_r_pad, i_in_data_4_r_pad, i_in_data_5_r_pad, i_in_data_6_r_pad, i_in_data_7_r_pad;
reg [7:0] i_in_data_8_r, i_in_data_9_r, i_in_data_10_r, i_in_data_11_r, i_in_data_12_r, i_in_data_13_r, i_in_data_14_r, i_in_data_15_r;
reg [12:0] i_in_data_8_r_pad, i_in_data_9_r_pad, i_in_data_10_r_pad, i_in_data_11_r_pad, i_in_data_12_r_pad, i_in_data_13_r_pad, i_in_data_14_r_pad, i_in_data_15_r_pad;
integer i;

reg signed [8:0] sorted_data_0 [0:4];
reg signed [8:0] sorted_data_1 [0:4];
reg signed [8:0] sorted_data_2 [0:4];
reg signed [8:0] sorted_data_3 [0:4];

// --------------------------------------------------------- Input Register ---------------------------------------------------------
// Input Pixel (8.0)
always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        i_in_data_0_r <= 0;
    else  
        if ((median_state == MEDIAN_IDLE) || (median_state == MEDIAN_WAIT)) 
            i_in_data_0_r <= i_in_data_0;       
        else
            i_in_data_0_r <= i_in_data_0_r;

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        i_in_data_1_r <= 0;
    else
        if ((median_state == MEDIAN_IDLE) || (median_state == MEDIAN_WAIT)) 
            i_in_data_1_r <= i_in_data_1;   
        else
            i_in_data_1_r <= i_in_data_1_r;

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        i_in_data_2_r <= 0;
    else
        if ((median_state == MEDIAN_IDLE) || (median_state == MEDIAN_WAIT)) 
            i_in_data_2_r <= i_in_data_2;   
        else
            i_in_data_2_r <= i_in_data_2_r; 

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        i_in_data_3_r <= 0;
    else
        if ((median_state == MEDIAN_IDLE) || (median_state == MEDIAN_WAIT)) 
            i_in_data_3_r <= i_in_data_3;   
        else
            i_in_data_3_r <= i_in_data_3_r;   

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        i_in_data_4_r <= 0;
    else
        if ((median_state == MEDIAN_IDLE) || (median_state == MEDIAN_WAIT)) 
            i_in_data_4_r <= i_in_data_4;   
        else
            i_in_data_4_r <= i_in_data_4_r;

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        i_in_data_5_r <= 0;
    else
        if ((median_state == MEDIAN_IDLE) || (median_state == MEDIAN_WAIT)) 
            i_in_data_5_r <= i_in_data_5;   
        else
            i_in_data_5_r <= i_in_data_5_r;

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        i_in_data_6_r <= 0;
    else
        if ((median_state == MEDIAN_IDLE) || (median_state == MEDIAN_WAIT)) 
            i_in_data_6_r <= i_in_data_6;   
        else
            i_in_data_6_r <= i_in_data_6_r;

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        i_in_data_7_r <= 0;
    else
        if ((median_state == MEDIAN_IDLE) || (median_state == MEDIAN_WAIT)) 
            i_in_data_7_r <= i_in_data_7;   
        else
            i_in_data_7_r <= i_in_data_7_r;

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        i_in_data_8_r <= 0;
    else
        if ((median_state == MEDIAN_READ) || (median_state == MEDIAN_WAIT)) 
            i_in_data_8_r <= i_in_data_8;   
        else
            i_in_data_8_r <= i_in_data_8_r;

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        i_in_data_9_r <= 0;
    else
        if ((median_state == MEDIAN_READ) || (median_state == MEDIAN_WAIT)) 
            i_in_data_9_r <= i_in_data_9;   
        else
            i_in_data_9_r <= i_in_data_9_r; 

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        i_in_data_10_r <= 0;
    else
        if ((median_state == MEDIAN_READ) || (median_state == MEDIAN_WAIT)) 
            i_in_data_10_r <= i_in_data_10;   
        else
            i_in_data_10_r <= i_in_data_10_r;  

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        i_in_data_11_r <= 0;
    else
        if ((median_state == MEDIAN_READ) || (median_state == MEDIAN_WAIT)) 
            i_in_data_11_r <= i_in_data_11;   
        else
            i_in_data_11_r <= i_in_data_11_r; 

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        i_in_data_12_r <= 0;
    else
        if ((median_state == MEDIAN_READ) || (median_state == MEDIAN_WAIT)) 
            i_in_data_12_r <= i_in_data_12;   
        else
            i_in_data_12_r <= i_in_data_12_r; 

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        i_in_data_13_r <= 0;
    else
        if ((median_state == MEDIAN_READ) || (median_state == MEDIAN_WAIT)) 
            i_in_data_13_r <= i_in_data_13;   
        else
            i_in_data_13_r <= i_in_data_13_r; 

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        i_in_data_14_r <= 0;
    else
        if ((median_state == MEDIAN_READ) || (median_state == MEDIAN_WAIT)) 
            i_in_data_14_r <= i_in_data_14;   
        else
            i_in_data_14_r <= i_in_data_14_r;   

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        i_in_data_15_r <= 0;
    else
        if ((median_state == MEDIAN_READ) || (median_state == MEDIAN_WAIT)) 
            i_in_data_15_r <= i_in_data_15;   
        else
            i_in_data_15_r <= i_in_data_15_r; 

// --------------------------------------------------------- Select Input for Adder Tree ---------------------------------------------------------
// Covert input to positve signed value (1.8)
reg signed [8:0] i_in_data_0_sign_r, i_in_data_1_sign_r, i_in_data_2_sign_r, i_in_data_3_sign_r, i_in_data_4_sign_r, i_in_data_5_sign_r, i_in_data_6_sign_r, i_in_data_7_sign_r;
reg signed [8:0] i_in_data_8_sign_r, i_in_data_9_sign_r, i_in_data_10_sign_r, i_in_data_11_sign_r, i_in_data_12_sign_r, i_in_data_13_sign_r, i_in_data_14_sign_r, i_in_data_15_sign_r;

always@* begin
    i_in_data_0_sign_r = {1'b0, i_in_data_0_r};
    i_in_data_1_sign_r = {1'b0, i_in_data_1_r};
    i_in_data_2_sign_r = {1'b0, i_in_data_2_r};
    i_in_data_3_sign_r = {1'b0, i_in_data_3_r};
    i_in_data_4_sign_r = {1'b0, i_in_data_4_r};
    i_in_data_5_sign_r = {1'b0, i_in_data_5_r};
    i_in_data_6_sign_r = {1'b0, i_in_data_6_r};
    i_in_data_7_sign_r = {1'b0, i_in_data_7_r};
    i_in_data_8_sign_r = {1'b0, i_in_data_8_r};
    i_in_data_9_sign_r = {1'b0, i_in_data_9_r};
    i_in_data_10_sign_r = {1'b0, i_in_data_10_r};
    i_in_data_11_sign_r = {1'b0, i_in_data_11_r};
    i_in_data_12_sign_r = {1'b0, i_in_data_12_r};
    i_in_data_13_sign_r = {1'b0, i_in_data_13_r};
    i_in_data_14_sign_r = {1'b0, i_in_data_14_r};
    i_in_data_15_sign_r = {1'b0, i_in_data_15_r};
end

// Input for comaprison
reg signed [8:0] median_in_data_0 [0:4];
reg signed [8:0] median_in_data_1 [0:4];
reg signed [8:0] median_in_data_2 [0:4];
reg signed [8:0] median_in_data_3 [0:4];

always@*       
    case(median_state)
        MEDIAN_CENTER: 
            case(median_loc_control)
                2'b00:
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_0[i] = i_in_data_5_sign_r;
                2'b01: 
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_0[i] = i_in_data_6_sign_r;
                2'b10:
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_0[i] = i_in_data_9_sign_r;
                2'b11:
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_0[i] = i_in_data_10_sign_r;
                default: 
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_0[i] = 0;
            endcase
        MEDIAN_SIDE: 
            case(median_loc_control)
                2'b00:
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_0[i] = i_in_data_1_sign_r;
                2'b01: 
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_0[i] = i_in_data_2_sign_r;
                2'b10:
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_0[i] = i_in_data_4_sign_r;
                2'b11:
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_0[i] = i_in_data_8_sign_r;
                default: 
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_0[i] = 0;
            endcase

        MEDIAN_CORNER:
            for (i = 0; i < 5; i = i+1)
                median_in_data_0[i] = i_in_data_0_sign_r;         
        default: 
            for (i = 0; i < 5; i = i+1)
                median_in_data_0[i] = 0;   
    endcase

always@*       
    case(median_state)
        MEDIAN_CENTER: 
            case(median_loc_control)
                2'b00:
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_1[i] = i_in_data_5_sign_r;
                2'b01: 
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_1[i] = i_in_data_6_sign_r;
                2'b10:
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_1[i] = i_in_data_9_sign_r;
                2'b11:
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_1[i] = i_in_data_10_sign_r;
                default: 
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_1[i] = 0;
            endcase
        MEDIAN_SIDE: 
            case(median_loc_control)
                2'b00:
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_1[i] = i_in_data_1_sign_r;
                2'b01: 
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_1[i] = i_in_data_2_sign_r;
                2'b10:
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_1[i] = i_in_data_7_sign_r;
                2'b11:
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_1[i] = i_in_data_11_sign_r;
                default: 
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_1[i] = 0;
            endcase

        MEDIAN_CORNER:
            for (i = 0; i < 5; i = i+1)
                median_in_data_1[i] = i_in_data_3_sign_r;    
        default: 
            for (i = 0; i < 5; i = i+1)
                median_in_data_1[i] = 0;        
    endcase

always@*       
    case(median_state)
        MEDIAN_CENTER: 
            case(median_loc_control)
                2'b00:
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_2[i] = i_in_data_5_sign_r;
                2'b01: 
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_2[i] = i_in_data_6_sign_r;
                2'b10:
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_2[i] = i_in_data_9_sign_r;
                2'b11:
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_2[i] = i_in_data_10_sign_r;
                default: 
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_2[i] = 0;
            endcase
        MEDIAN_SIDE: 
            case(median_loc_control)
                2'b00:
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_2[i] = i_in_data_13_sign_r;
                2'b01: 
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_2[i] = i_in_data_14_sign_r;
                2'b10:
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_2[i] = i_in_data_8_sign_r;
                2'b11:
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_2[i] = i_in_data_4_sign_r;
                default: 
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_2[i] = 0;
            endcase

        MEDIAN_CORNER:
            for (i = 0; i < 5; i = i+1)
                median_in_data_2[i] = i_in_data_12_sign_r;         
        default: 
            for (i = 0; i < 5; i = i+1)
                median_in_data_2[i] = 0;   
    endcase

always@*       
    case(median_state)
        MEDIAN_CENTER: 
            case(median_loc_control)
                2'b00:
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_3[i] = i_in_data_5_sign_r;
                2'b01: 
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_3[i] = i_in_data_6_sign_r;
                2'b10:
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_3[i] = i_in_data_9_sign_r;
                2'b11:
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_3[i] = i_in_data_10_sign_r;
                default: 
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_3[i] = 0;
            endcase
        MEDIAN_SIDE: 
            case(median_loc_control)
                2'b00:
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_3[i] = i_in_data_13_sign_r;
                2'b01: 
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_3[i] = i_in_data_14_sign_r;
                2'b10:
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_3[i] = i_in_data_11_sign_r;
                2'b11:
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_3[i] = i_in_data_7_sign_r;
                default: 
                    for (i = 0; i < 5; i = i+1)
                        median_in_data_3[i] = 0;
            endcase

        MEDIAN_CORNER:
            for (i = 0; i < 5; i = i+1)
                median_in_data_3[i] = i_in_data_15_sign_r;    
        default: 
            for (i = 0; i < 5; i = i+1)
                median_in_data_3[i] = 0;    
    endcase



// Register Data for comparison
reg signed [8:0] median_reg_data_0 [0:4];
reg signed [8:0] median_reg_data_1 [0:4];
reg signed [8:0] median_reg_data_2 [0:4];
reg signed [8:0] median_reg_data_3 [0:4];

always@*       
    for (i = 0; i < 5; i = i+1)
        median_reg_data_0[i] = sorted_data_0[i];
               
always@*       
    for (i = 0; i < 5; i = i+1)
        median_reg_data_1[i] = sorted_data_1[i];

always@*       
    for (i = 0; i < 5; i = i+1)
        median_reg_data_2[i] = sorted_data_2[i];

always@*       
    for (i = 0; i < 5; i = i+1)
        median_reg_data_3[i] = sorted_data_3[i];
// --------------------------------------------------------- Adder Tree ---------------------------------------------------------
// Addition of Stage 1 (1.9)
reg signed [9:0] add_0 [0:4];
reg signed [9:0] add_1 [0:4];
reg signed [9:0] add_2 [0:4];
reg signed [9:0] add_3 [0:4];

always@* 
    for (i = 0; i < 5; i = i+1)
        add_0[i] = median_in_data_0[i] - median_reg_data_0[i];

always@* 
    for (i = 0; i < 5; i = i+1)
        add_1[i] = median_in_data_1[i] - median_reg_data_1[i];

always@* 
    for (i = 0; i < 5; i = i+1)
        add_2[i] = median_in_data_2[i] - median_reg_data_2[i];

always@* 
    for (i = 0; i < 5; i = i+1)
        add_3[i] = median_in_data_3[i] - median_reg_data_3[i];



// --------------------------------------------------------- Sorted Register ---------------------------------------------------------
// 0: largest  4: smallest(output)
wire [4:0] add_0_sign;
wire [4:0] add_1_sign;
wire [4:0] add_2_sign;
wire [4:0] add_3_sign;
wire sorted_write_enable_0;
wire sorted_write_enable_1;
wire sorted_write_enable_2;
wire sorted_write_enable_3;

assign add_0_sign = {add_0[0][9], add_0[1][9], add_0[2][9], add_0[3][9], add_0[4][9]};
assign add_1_sign = {add_1[0][9], add_1[1][9], add_1[2][9], add_1[3][9], add_1[4][9]};
assign add_2_sign = {add_2[0][9], add_2[1][9], add_2[2][9], add_2[3][9], add_2[4][9]};
assign add_3_sign = {add_3[0][9], add_3[1][9], add_3[2][9], add_3[3][9], add_3[4][9]};


assign sorted_write_enable_0 = ((median_state == MEDIAN_CENTER) || (median_state == MEDIAN_SIDE) || (median_state == MEDIAN_CORNER)); 
assign sorted_write_enable_1 = ((median_state == MEDIAN_CENTER) || (median_state == MEDIAN_SIDE) || (median_state == MEDIAN_CORNER)); 
assign sorted_write_enable_2 = ((median_state == MEDIAN_CENTER) || (median_state == MEDIAN_SIDE) || (median_state == MEDIAN_CORNER)); 
assign sorted_write_enable_3 = ((median_state == MEDIAN_CENTER) || (median_state == MEDIAN_SIDE) || (median_state == MEDIAN_CORNER)); 


always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        for (i = 0; i < 5; i = i+1)        
            sorted_data_0[i] <= 0;
    else
        if (median_clear)
            for (i = 0; i < 5; i = i+1)        
                sorted_data_0[i] <= 0;        
        else if (sorted_write_enable_0)
            case(add_0_sign)  
                5'b00000: begin                 // > all 5 number
                    sorted_data_0[0] <= median_in_data_0[0];
                    for (i = 1; i < 5; i = i+1)
                        sorted_data_0[i] <= sorted_data_0[i-1];
                end
                5'b10000: begin                 // > 4 number
                    sorted_data_0[0] <= sorted_data_0[0];
                    sorted_data_0[1] <= median_in_data_0[0];
                    for (i = 2; i < 5; i = i+1)
                        sorted_data_0[i] <= sorted_data_0[i-1];
                end
                5'b11000: begin                 // > 3 number
                    for (i = 0; i < 2; i = i+1)
                        sorted_data_0[i] <= sorted_data_0[i];
                    sorted_data_0[2] <= median_in_data_0[0];
                    for (i = 3; i < 5; i = i+1)
                        sorted_data_0[i] <= sorted_data_0[i-1];
                end
                5'b11100: begin                 // > 2 number
                    for (i = 0; i < 3; i = i+1)
                        sorted_data_0[i] <= sorted_data_0[i];
                    sorted_data_0[3] <= median_in_data_0[0];
                    sorted_data_0[4] <= sorted_data_0[3];
                end
                5'b11110: begin                 // > 1 number
                    for (i = 0; i < 4; i = i+1)
                        sorted_data_0[i] <= sorted_data_0[i];
                    sorted_data_0[4] <= median_in_data_0[0];
                end
                default: 
                    for (i = 0; i < 5; i = i+1)
                        sorted_data_0[i] <= sorted_data_0[i];
            endcase
        else
            for (i = 0; i < 5; i = i+1)
                sorted_data_0[i] <= sorted_data_0[i];        

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        for (i = 0; i < 5; i = i+1)        
            sorted_data_1[i] <= 0;
    else
        if (median_clear)
            for (i = 0; i < 5; i = i+1)        
                sorted_data_1[i] <= 0;      
        else if (sorted_write_enable_1)
            case(add_1_sign)  
                5'b00000: begin                 // > all 5 number
                    sorted_data_1[0] <= median_in_data_1[0];
                    for (i = 1; i < 5; i = i+1)
                        sorted_data_1[i] <= sorted_data_1[i-1];
                end
                5'b10000: begin                 // > 4 number
                    sorted_data_1[0] <= sorted_data_1[0];
                    sorted_data_1[1] <= median_in_data_1[0];
                    for (i = 2; i < 5; i = i+1)
                        sorted_data_1[i] <= sorted_data_1[i-1];
                end
                5'b11000: begin                 // > 3 number
                    for (i = 0; i < 2; i = i+1)
                        sorted_data_1[i] <= sorted_data_1[i];
                    sorted_data_1[2] <= median_in_data_1[0];
                    for (i = 3; i < 5; i = i+1)
                        sorted_data_1[i] <= sorted_data_1[i-1];
                end
                5'b11100: begin                 // > 2 number
                    for (i = 0; i < 3; i = i+1)
                        sorted_data_1[i] <= sorted_data_1[i];
                    sorted_data_1[3] <= median_in_data_1[0];
                    sorted_data_1[4] <= sorted_data_1[3];
                end
                5'b11110: begin                 // > 1 number
                    for (i = 0; i < 4; i = i+1)
                        sorted_data_1[i] <= sorted_data_1[i];
                    sorted_data_1[4] <= median_in_data_1[0];
                end
                default: 
                    for (i = 0; i < 5; i = i+1)
                        sorted_data_1[i] <= sorted_data_1[i];
            endcase
        else
            for (i = 0; i < 5; i = i+1)
                sorted_data_1[i] <= sorted_data_1[i];     

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        for (i = 0; i < 5; i = i+1)        
            sorted_data_2[i] <= 0;
    else
        if (median_clear)
            for (i = 0; i < 5; i = i+1)        
                sorted_data_2[i] <= 0;      
        else if (sorted_write_enable_2)
            case(add_2_sign)  
                5'b00000: begin                 // > all 5 number
                    sorted_data_2[0] <= median_in_data_2[0];
                    for (i = 1; i < 5; i = i+1)
                        sorted_data_2[i] <= sorted_data_2[i-1];
                end
                5'b10000: begin                 // > 4 number
                    sorted_data_2[0] <= sorted_data_2[0];
                    sorted_data_2[1] <= median_in_data_2[0];
                    for (i = 2; i < 5; i = i+1)
                        sorted_data_2[i] <= sorted_data_2[i-1];
                end
                5'b11000: begin                 // > 3 number
                    for (i = 0; i < 2; i = i+1)
                        sorted_data_2[i] <= sorted_data_2[i];
                    sorted_data_2[2] <= median_in_data_2[0];
                    for (i = 3; i < 5; i = i+1)
                        sorted_data_2[i] <= sorted_data_2[i-1];
                end
                5'b11100: begin                 // > 2 number
                    for (i = 0; i < 3; i = i+1)
                        sorted_data_2[i] <= sorted_data_2[i];
                    sorted_data_2[3] <= median_in_data_2[0];
                    sorted_data_2[4] <= sorted_data_2[3];
                end
                5'b11110: begin                 // > 1 number
                    for (i = 0; i < 4; i = i+1)
                        sorted_data_2[i] <= sorted_data_2[i];
                    sorted_data_2[4] <= median_in_data_2[0];
                end
                default: 
                    for (i = 0; i < 5; i = i+1)
                        sorted_data_2[i] <= sorted_data_2[i];
            endcase
        else
            for (i = 0; i < 5; i = i+1)
                sorted_data_2[i] <= sorted_data_2[i];     

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        for (i = 0; i < 5; i = i+1)        
            sorted_data_3[i] <= 0;
    else
        if (median_clear)
            for (i = 0; i < 5; i = i+1)        
                sorted_data_3[i] <= 0;      
        else if (sorted_write_enable_3)
            case(add_3_sign)  
                5'b00000: begin                 // > all 5 number
                    sorted_data_3[0] <= median_in_data_3[0];
                    for (i = 1; i < 5; i = i+1)
                        sorted_data_3[i] <= sorted_data_3[i-1];
                end
                5'b10000: begin                 // > 4 number
                    sorted_data_3[0] <= sorted_data_3[0];
                    sorted_data_3[1] <= median_in_data_3[0];
                    for (i = 2; i < 5; i = i+1)
                        sorted_data_3[i] <= sorted_data_3[i-1];
                end
                5'b11000: begin                 // > 3 number
                    for (i = 0; i < 2; i = i+1)
                        sorted_data_3[i] <= sorted_data_3[i];
                    sorted_data_3[2] <= median_in_data_3[0];
                    for (i = 3; i < 5; i = i+1)
                        sorted_data_3[i] <= sorted_data_3[i-1];
                end
                5'b11100: begin                 // > 2 number
                    for (i = 0; i < 3; i = i+1)
                        sorted_data_3[i] <= sorted_data_3[i];
                    sorted_data_3[3] <= median_in_data_3[0];
                    sorted_data_3[4] <= sorted_data_3[3];
                end
                5'b11110: begin                 // > 1 number
                    for (i = 0; i < 4; i = i+1)
                        sorted_data_3[i] <= sorted_data_3[i];
                    sorted_data_3[4] <= median_in_data_3[0];
                end
                default: 
                    for (i = 0; i < 5; i = i+1)
                        sorted_data_3[i] <= sorted_data_3[i];
            endcase
        else
            for (i = 0; i < 5; i = i+1)
                sorted_data_3[i] <= sorted_data_3[i];     

// --------------------------------------------------------- Output ---------------------------------------------------------
assign o_out_data_0 = {5'd0, sorted_data_0[4]};
assign o_out_data_1 = {5'd0, sorted_data_1[4]};
assign o_out_data_2 = {5'd0, sorted_data_2[4]};
assign o_out_data_3 = {5'd0, sorted_data_3[4]};

endmodule
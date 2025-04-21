module alu #(
    parameter INST_W = 4,
    parameter INT_W  = 6,
    parameter FRAC_W = 10,
    parameter DATA_W = INT_W + FRAC_W
)(
    input                      i_clk,
    input                      i_rst_n,

    input                      i_in_valid,
    output                     o_busy,
    input         [INST_W-1:0] i_inst,
    input  signed [DATA_W-1:0] i_data_a,
    input  signed [DATA_W-1:0] i_data_b,

    output                     o_out_valid,
    output        [DATA_W-1:0] o_data
);

// Local Parameters
parameter ADD         = 4'b0000; 
parameter SUB         = 4'b0001; 
parameter MULT        = 4'b0010; 
parameter ACC         = 4'b0011; 
parameter SOFTPLUS    = 4'b0100; 
parameter XOR         = 4'b0101; 
parameter RIGHT_SHIFT = 4'b0110; 
parameter LEFT_ROT    = 4'b0111; 
parameter CLZ         = 4'b1000; 
parameter RM4         = 4'b1001; 
integer i;

// Wires and Regs
reg [DATA_W-1:0] op_out [0:9];
reg [DATA_W-1:0] o_data_tmp;
reg o_out_valid_tmp;


// ************************************************** 0. Signed Addition ************************************************** 
// Signed Addition (1.6.10)
reg signed [DATA_W:0] add_out_tmp;
always@*
    add_out_tmp = i_data_a + i_data_b;

// Saturation
always@*
    if (~add_out_tmp[DATA_W] && add_out_tmp[DATA_W-1])                     // Positive Saturation
        op_out[0] = {1'b0, {(DATA_W-1){1'b1}}};
    else if (add_out_tmp[DATA_W] && ~add_out_tmp[DATA_W-1])                // Negative Saturation
        op_out[0] = {1'b1, {(DATA_W-1){1'b0}}};
    else
        op_out[0] = {add_out_tmp[DATA_W], add_out_tmp[DATA_W-2:0]};
// ************************************************** 0. Signed Addition ************************************************** 



// ************************************************** 1. Signed Substraction ************************************************** 
// Signed Substraction (1.6.10)
reg signed [DATA_W:0] sub_out_tmp;
always@*
    sub_out_tmp = i_data_a - i_data_b;

// Saturation
always@*
    if (~sub_out_tmp[DATA_W] && sub_out_tmp[DATA_W-1])                     // Positive Saturation
        op_out[1] = {1'b0, {(DATA_W-1){1'b1}}};
    else if (sub_out_tmp[DATA_W] && ~sub_out_tmp[DATA_W-1])                // Negative Saturation
        op_out[1] = {1'b1, {(DATA_W-1){1'b0}}};
    else
        op_out[1] = {sub_out_tmp[DATA_W], sub_out_tmp[DATA_W-2:0]};
// ************************************************** 1. Signed Substraction ************************************************** 



// ************************************************** 2. Signed Multiplication **************************************************
// Signed Multiplication (1.11.20)
reg signed [2*DATA_W-1:0] mult_out_tmp;
always@*
    mult_out_tmp = i_data_a * i_data_b;


// Rounding (1.11.10)
wire signed [2*DATA_W-FRAC_W-1:0] mult_msb;
reg signed [2*DATA_W-FRAC_W-1:0] mult_rounding;

assign mult_msb = mult_out_tmp[2*DATA_W-1:FRAC_W];

always@*    
    if (mult_out_tmp[FRAC_W-1])                                        
        mult_rounding = mult_msb + 2'sb01;  
    else
        mult_rounding = mult_msb;           


// Saturation (1.5.10)
always@*
    if (~mult_rounding[2*DATA_W-FRAC_W-1] && |mult_rounding[2*DATA_W-FRAC_W-2:2*DATA_W-FRAC_W-7])                     // Positive Saturation
        op_out[2] = {1'b0, {(DATA_W-1){1'b1}}};
    else if (mult_rounding[2*DATA_W-FRAC_W-1] && ~(&mult_rounding[2*DATA_W-FRAC_W-2:2*DATA_W-FRAC_W-7]))              // Negative Saturation
        op_out[2] = {1'b1, {(DATA_W-1){1'b0}}};
    else
        op_out[2] = {mult_rounding[2*DATA_W-FRAC_W-1], mult_rounding[DATA_W-2:0]};

// ************************************************** 2. Signed Multiplication **************************************************



// ************************************************** 3. Signed Accumulation **************************************************
// Data Memory
reg signed [DATA_W+3:0] data_acc [0:15];
reg signed [DATA_W+3:0] data_acc_old;
reg signed [DATA_W+4:0] data_acc_new;


always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        for (i = 0; i < 16; i = i+1)
            data_acc[i] <= 0;
    else
        for (i = 0; i < 16; i = i+1) 
            if (i_inst == ACC && i == i_data_a)                       // i_inst control writability of memory
                data_acc[i] <= data_acc_new[DATA_W+3:0];     
            else
                data_acc[i] <= data_acc[i];  
// Accumulation
always@* begin
    data_acc_old = data_acc[i_data_a[3:0]];
    data_acc_new = data_acc_old + i_data_b;
end

// Saturatioin
always@*
    if (~data_acc_new[DATA_W+4] && |data_acc_new[DATA_W+3:DATA_W-1])
        op_out[3] = {1'b0, {(DATA_W-1){1'b1}}};
    else if (data_acc_new[DATA_W+4] && ~(&data_acc_new[DATA_W+3:DATA_W-1]))
        op_out[3] = {1'b1, {(DATA_W-1){1'b0}}};
    else
        op_out[3] = {data_acc_new[DATA_W+4], data_acc_new[DATA_W-2:0]};

// ************************************************** 3. Signed Accumulation **************************************************



// ************************************************** 4. SoftPlus ************************************************** 
// Interval Division
reg signed [INT_W-1:0] i_data_a_int;
reg [2:0] interval_idx; 
always@* begin
    i_data_a_int = i_data_a[(DATA_W-1) -: INT_W];
end

// Piecewise linear approximation 
always@*
    interval_idx = (i_data_a_int >=  6'sd2)?  3'd4 :            //  x >= 2
                   (i_data_a_int >=  6'sd0)?  3'd0 :            //  0 <= x < 2
                   (i_data_a_int >= -6'sd1)?  3'd1 :            // -1 <= x < 0
                   (i_data_a_int >= -6'sd2)?  3'd2 :            // -2 <= x < -1
                   (i_data_a_int >= -6'sd3)?  3'd3 :            // -3 <= x < -2
                                              3'd5 ;            //  x < -3



// Multiplication (1.7.10)
reg signed [DATA_W+1:0] softplus_mult_out [0:3];
always@* begin
    softplus_mult_out[0] = 3'sd2 * i_data_a;
    softplus_mult_out[1] = 3'sd1 * i_data_a;
    softplus_mult_out[2] = 3'sd2 * i_data_a;
    softplus_mult_out[3] = 3'sd1 * i_data_a;
end

// Addition (1.8.10)
reg signed [DATA_W+2:0] softplus_add_out [0:3];
always@* begin
    softplus_add_out[0] = softplus_mult_out[0] + $signed({8'sd2, 10'sd0});
    softplus_add_out[1] = softplus_mult_out[1] + $signed({8'sd2, 10'sd0});
    softplus_add_out[2] = softplus_mult_out[2] + $signed({8'sd5, 10'sd0});
    softplus_add_out[3] = softplus_mult_out[3] + $signed({8'sd3, 10'sd0});
end

// Division (Mult) (1.8.34)
parameter precision = 24;
parameter ONE_DIV_BY_THREE = 25'sb0_0101_0101_0101_0101_0101_0101;
parameter ONE_DIV_BY_NINE  = 25'sb0_0001_1100_0111_0001_1100_0111;
reg signed [DATA_W+precision+2:0] softplus_div_out [0:3];
always@* begin
    softplus_div_out[0] = softplus_add_out[0] * ONE_DIV_BY_THREE;
    softplus_div_out[1] = softplus_add_out[1] * ONE_DIV_BY_THREE;
    softplus_div_out[2] = softplus_add_out[2] * ONE_DIV_BY_NINE;
    softplus_div_out[3] = softplus_add_out[3] * ONE_DIV_BY_NINE;    
end

// Rounding (1.8.10)
wire signed [DATA_W+2:0] softplus_div_out_msb [0:3];
reg signed [DATA_W+2:0] softplus_div_out_rounding [0:3];

assign softplus_div_out_msb[0] = softplus_div_out[0][DATA_W+precision+2:precision];
assign softplus_div_out_msb[1] = softplus_div_out[1][DATA_W+precision+2:precision];
assign softplus_div_out_msb[2] = softplus_div_out[2][DATA_W+precision+2:precision];
assign softplus_div_out_msb[3] = softplus_div_out[3][DATA_W+precision+2:precision];

always@*      
    for (i = 0; i < 4; i = i+1)
        if (softplus_div_out[i][precision-1])                                        
            softplus_div_out_rounding[i] = softplus_div_out_msb[i] + 2'sb01;    
        else
            softplus_div_out_rounding[i] = softplus_div_out_msb[i];    



// Saturation (1.5.10)
reg signed [DATA_W-1:0] softplus_out_tmp [0:5];
always@* begin
    for (i = 0; i < 4; i = i+1)
        if (~softplus_div_out_rounding[i][DATA_W+2] && |softplus_div_out_rounding[i][DATA_W+1:DATA_W-1])                     // Positive Saturation
            softplus_out_tmp[i] = {1'b0, {(DATA_W-1){1'b1}}};
        else if (softplus_div_out_rounding[i][DATA_W+2] && ~(&softplus_div_out_rounding[i][DATA_W+1:DATA_W-1]))              // Negative Saturation
            softplus_out_tmp[i] = {1'b1, {(DATA_W-1){1'b0}}};
        else
            softplus_out_tmp[i] = {softplus_div_out_rounding[i][DATA_W+2], softplus_div_out_rounding[i][DATA_W-2:0]};
    softplus_out_tmp[4] = i_data_a;
    softplus_out_tmp[5] = 16'h0000;
end

// Output Selection
always@*
    op_out[4] = softplus_out_tmp[interval_idx];
// ************************************************** 4. SoftPlus ************************************************** 



// ************************************************** 5. XOR ************************************************** 
always@*
    op_out[5] = i_data_a ^ i_data_b;
// ************************************************** 5. XOR ************************************************** 



// ************************************************** 6. Arithmetic Right Shift **************************************************
always@*
    op_out[6] = i_data_a >>> i_data_b;
// ************************************************** 6. Arithmetic Right Shift **************************************************



// ************************************************** 7. Left Rotation **************************************************
reg [2*DATA_W-1:0] i_data_a_db;
reg [2*DATA_W-1:0] i_data_a_db_shift;
always@* begin
    i_data_a_db = {i_data_a, i_data_a};
    i_data_a_db_shift = i_data_a_db << i_data_b;
    op_out[7] = i_data_a_db_shift[2*DATA_W-1:DATA_W]; 
end
// ************************************************** 7. Left Rotation **************************************************



// ************************************************** 8. Count Leading Zeros **************************************************
reg [4:0] num_of_zeros_tmp [0:DATA_W];
reg [5:0] num_of_zeros_tmp_ext [0:DATA_W];
reg one_before [0:DATA_W];
always@* begin
    one_before[DATA_W] = 0;
    num_of_zeros_tmp[DATA_W] = 0;
    for (i = DATA_W-1; i >= 0; i = i-1) begin
        num_of_zeros_tmp_ext[i] = num_of_zeros_tmp[i+1] + (~i_data_a[i] && ~one_before[i+1]);
        num_of_zeros_tmp[i] = num_of_zeros_tmp_ext[i][4:0];
        one_before[i] = ~(~i_data_a[i] && ~one_before[i+1]);
    end
end

always@*
    op_out[8] = {11'sd0, num_of_zeros_tmp[0]};
// ************************************************** 8. Count Leading Zeros **************************************************



// ************************************************** 9. Reverse Match4 **************************************************
reg [12:0] data_eq;
always@*
    for (i = 0; i < 13; i = i+1)
        data_eq[i] = i_data_a[i +: 4]  == i_data_b[15-i -: 4];
always@*
    op_out[9] = {3'sd0, data_eq};

// ************************************************** 9. Reverse Match4 **************************************************



// ************************************************** Output **************************************************

// Output Data Selection
always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        o_data_tmp <= 0;
    else
        o_data_tmp <= op_out[i_inst];

assign o_data = o_data_tmp;

// Ouput Ready
assign o_busy = 1'b0;

// Output Valid
always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        o_out_valid_tmp <= 1'b0;
    else
        o_out_valid_tmp <= i_in_valid;
assign o_out_valid = o_out_valid_tmp;

// ************************************************** Output **************************************************


endmodule

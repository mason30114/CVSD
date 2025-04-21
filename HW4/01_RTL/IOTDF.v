`timescale 1ns/10ps
module IOTDF( clk, rst, in_en, iot_in, fn_sel, busy, valid, iot_out);
input          clk;
input          rst;
input          in_en;
input  [7:0]   iot_in;
input  [2:0]   fn_sel;
output         busy;
output         valid;
output [127:0] iot_out;

integer i;
localparam IDLE = 4'd0, WAIT = 4'd1, READ_EN = 4'd2, COMP_EN = 4'd3, READ_DE = 4'd4, COMP_DE = 4'd5, 
           READ_CRC = 4'd6, COMP_CRC = 4'd7, READ_MAX = 4'd8, COMP_MAX = 4'd9, OUT_MAX = 4'd10, READ_MIN = 4'd11, COMP_MIN = 4'd12, OUT_MIN = 4'd13;

// Control Signal Declaration
reg [3:0] state, n_state;
reg [4:0] sys_cnt;
reg [2:0] read_num;
wire read_num_max;
wire read_en_end, comp_en_end, read_de_end, comp_de_end, read_crc_end, comp_crc_end, read_max_end, comp_max_end, out_max_end, read_min_end, comp_min_end, out_min_end;
wire state_idle, state_wait, state_read_en, state_comp_en, state_read_de, state_comp_de, state_read_crc, state_comp_crc, state_read_max, state_comp_max, state_out_max, state_read_min, state_comp_min, state_out_min; 
wire comp_syc_read;


// Output Signal Declaration
reg busy_w;
reg valid_w;
reg [127:0] iot_out_w;

// Register 1 Declaration 
reg [127:0] in_data_reg_w;
reg [127:0] in_data_reg;
wire [15:0]  in_data_reg_read_valid;


// Next text Control (63:0)
wire [63:0] text_reg;
reg [63:0] text_reg_w;
wire [63:0] out_key_reg;
reg [63:0] out_key_reg_w;

wire [63:0] init_p_in;
wire [63:0] init_p_out;
wire [31:0] text_comp_in;
wire [31:0] text_indenity_in;
wire [47:0] text_expansion_out;
wire [47:0] F_xor_out;
wire [5:0] Sbox_in_1;
wire [5:0] Sbox_in_2;
wire [5:0] Sbox_in_3;
wire [5:0] Sbox_in_4;
wire [5:0] Sbox_in_5;
wire [5:0] Sbox_in_6;
wire [5:0] Sbox_in_7;
wire [5:0] Sbox_in_8;

wire [3:0] Sbox_out_1;
wire [3:0] Sbox_out_2;
wire [3:0] Sbox_out_3;
wire [3:0] Sbox_out_4;
wire [3:0] Sbox_out_5;
wire [3:0] Sbox_out_6;
wire [3:0] Sbox_out_7;
wire [3:0] Sbox_out_8;
wire [31:0] F_P_in;
wire [31:0] F_P_out;

wire [31:0] text_comp_out;

wire [63:0] text_final_p_out;

wire current_init_p;
wire current_final_p;
wire current_comp_switch;


// Next Key Control (55:0)
wire [55:0] key_reg;
reg [55:0] key_reg_w;
wire [63:0] key_pc1_in;
wire [55:0] key_pc1_out;
reg [55:0] key_pc2_in;
wire [47:0] key_pc2_out;
reg [55:0] key_shift_in;
reg [55:0] key_l_shift_1;
reg [55:0] key_l_shift_2;
reg [55:0] key_r_shift_1;
reg [55:0] key_r_shift_2;
wire current_pc1;
wire current_l_shift_1;
wire current_l_shift_2;
wire current_en_one_bit_round;
wire current_r_shift_1;
wire current_r_shift_2;
wire current_de_one_bit_round;

// Comparison Control
wire current_compare_max_1st, current_compare_max_2nd;
wire current_compare_min_1st, current_compare_min_2nd;
wire current_store_result_max, current_store_result_min;
wire comp_type_0, comp_type_1, comp_type_2;
wire comp_reset_max, comp_reset_min;
wire comp_result;

reg comp_result_1st, comp_result_1st_w;
reg comp_result_2nd, comp_result_2nd_w;
reg [127:0] comp_1st_reg, comp_1st_reg_w;
reg [127:0] comp_2nd_reg, comp_2nd_reg_w;
wire current_comp_out_1st, current_comp_out_2nd;
reg [127:0] current_comp_reg;

// CRC Control
wire crc_comp_syc_read;
wire crc_busy_control;
wire current_crc_comp;
wire current_crc_read;
reg [4:0] in_valid_cnt;
wire [130:0] in_data_reg_pad;
wire [7:0] crc_start_point;
reg [2:0] crc_result_reg, crc_result_reg_w;
reg [3:0] crc_shift_num;
reg [3:0] crc_shift_num_prev;
reg [7:0] current_crc_in;
reg [7:0] crc_in_concat;
wire [2:0] current_crc_out;
reg [7:0] crc_read_cnt;


// --------------------------------------------------- System Control ---------------------------------------------------------------
// FSM
always@*
    case(state)
        IDLE:
            n_state = WAIT;
        WAIT:
            case(fn_sel)
                3'b001:  n_state = READ_EN;
                3'b010:  n_state = READ_DE;
                3'b011:  n_state = READ_CRC;
                3'b100:  n_state = READ_MAX;
                3'b101:  n_state = READ_MIN;
                default: n_state = IDLE;
            endcase       
        READ_EN:
            if (read_en_end)
                n_state = COMP_EN;
            else
                n_state = READ_EN;
        COMP_EN:
            n_state = COMP_EN; 
        READ_DE:
            if (read_de_end)
                n_state = COMP_DE;
            else
                n_state = READ_DE;
        COMP_DE:
            n_state = COMP_DE;
        READ_CRC:
            if (read_crc_end)
                n_state = COMP_CRC;
            else
                n_state = READ_CRC;
        COMP_CRC:
            n_state = COMP_CRC;
        READ_MAX:
            if (read_max_end)
                n_state = COMP_MAX;
            else 
                n_state = READ_MAX;
        COMP_MAX:
            if (comp_max_end && read_num_max)
                n_state = OUT_MAX;
            else if (comp_max_end)
                n_state = WAIT;
            else
                n_state = COMP_MAX;     
        OUT_MAX:
            if (out_max_end)
                n_state = IDLE;
            else
                n_state = OUT_MAX; 
        READ_MIN:
            if (read_min_end)
                n_state = COMP_MIN;
            else 
                n_state = READ_MIN;     
        COMP_MIN:
            if (comp_min_end && read_num_max)
                n_state = OUT_MIN;
            else if (comp_min_end)
                n_state = WAIT;
            else
                n_state = COMP_MIN;     
        OUT_MIN:
            if (out_min_end)
                n_state = IDLE;
            else
                n_state = OUT_MIN;
        default: n_state = state;
    endcase

always@(posedge clk or posedge rst)                                                 // Need Clock Gating
    if (rst)
        state <= 0;
    else
        state <= n_state;



assign state_idle     = (state == IDLE);
assign state_wait     = (state == WAIT);
assign state_read_en  = (state == READ_EN);
assign state_comp_en  = (state == COMP_EN);
assign state_read_de  = (state == READ_DE);
assign state_comp_de  = (state == COMP_DE);
assign state_read_crc = (state == READ_CRC);
assign state_comp_crc = (state == COMP_CRC);
assign state_read_max = (state == READ_MAX);
assign state_comp_max = (state == COMP_MAX);
assign state_out_max  = (state == OUT_MAX);
assign state_read_min = (state == READ_MIN);
assign state_comp_min = (state == COMP_MIN);
assign state_out_min  = (state == OUT_MIN);


// Calculate Number Read (For Max and Min)
always@(posedge clk or posedge rst)
    if (rst)
        read_num <= 0;
    else
        if (comp_max_end || comp_min_end)
            read_num <= read_num + 1'b1;
        else
            read_num <= read_num;

assign read_num_max = (read_num == 3'd7);
// Output 
always@*
    if (state_wait)
        busy_w = 0;        
    else if (state_read_en || state_comp_en)
        busy_w = 0;
    else if (state_read_de || state_comp_de)
        busy_w = 0;
    else if (state_read_crc || (state_comp_crc && (crc_busy_control || comp_crc_end)))
        busy_w = 0;       
    else if (state_read_max && ~read_max_end)
        busy_w = 0;    
    else if (state_read_min && ~read_min_end)
        busy_w = 0;    
    else
        busy_w = 1;

assign busy = busy_w;

always@*
    if (comp_en_end)
        valid_w = 1;
    else if (comp_de_end)
        valid_w = 1;
    else if (comp_crc_end)
        valid_w = 1;
    else if (state_out_max)
        valid_w = 1;
    else if (state_out_min)
        valid_w = 1;
    else
        valid_w = 0;

assign valid = valid_w;


always@*
    if (comp_en_end)
        iot_out_w = {out_key_reg, text_final_p_out};
    else if (comp_de_end)
        iot_out_w = {out_key_reg, text_final_p_out};
    else if (comp_crc_end)
        iot_out_w = {125'd0, current_crc_out};
    else if (current_comp_out_1st)
        iot_out_w = comp_1st_reg;
    else if (current_comp_out_2nd)
        iot_out_w = comp_2nd_reg;
    else
        iot_out_w = 0;

assign iot_out = iot_out_w;

// System Counter  
always@(posedge clk or posedge rst)
    if (rst)
        sys_cnt <= 0;
    else
        if (comp_en_end || comp_de_end)
            sys_cnt <= 5'd1;
        else if (read_en_end || read_de_end || read_crc_end || comp_crc_end || read_max_end || comp_max_end || out_max_end || read_min_end || comp_min_end || out_min_end)
            sys_cnt <= 0;
        else if (state_comp_crc && (sys_cnt != 5'd16)) 
            sys_cnt <= sys_cnt + 1'b1;
        else if (~state_idle && ~state_wait && ~state_comp_crc)
            sys_cnt <= sys_cnt + 1'b1;            
        else
            sys_cnt <= sys_cnt;

assign read_en_end = state_read_en && (sys_cnt == 5'd15);
assign comp_en_end = state_comp_en && (sys_cnt == 5'd16);
assign read_de_end = state_read_de && (sys_cnt == 5'd15);
assign comp_de_end = state_comp_de && (sys_cnt == 5'd16);

assign read_crc_end = state_read_crc && (sys_cnt == 5'd15);
assign comp_crc_end = state_comp_crc && (crc_read_cnt >= 7'd123);


assign read_max_end = state_read_max && (sys_cnt == 5'd15);
assign comp_max_end = state_comp_max && (sys_cnt == 5'd2);
assign out_max_end  = state_out_max && (sys_cnt == 5'd1);

assign read_min_end = state_read_min && (sys_cnt == 5'd15);
assign comp_min_end = state_comp_min && (sys_cnt == 5'd2);
assign out_min_end  = state_out_min && (sys_cnt == 5'd1);



// Read for comp state
assign comp_syc_read = ((state_comp_en || state_comp_de) && (sys_cnt != 5'd15)); 
assign crc_comp_syc_read = ((state_comp_crc) && (sys_cnt < 5'd16));
assign crc_busy_control = state_comp_crc && (sys_cnt < 5'd15);

// Read cnt for input data
always@(posedge clk or posedge rst)
    if (rst)
        crc_read_cnt <= 0;
    else
        if (comp_crc_end)
            crc_read_cnt <= 0;
        else if (current_crc_comp)
            crc_read_cnt <= crc_read_cnt + crc_shift_num;
        else
            crc_read_cnt <= crc_read_cnt;


// --------------------------------------------------- Register 1 (Input Reg) ---------------------------------------------------------------
// Control
assign in_data_reg_read_valid[0]  = (sys_cnt[3:0] == 4'd0)  && (state_read_en || state_read_de || state_read_max || state_read_min || state_read_crc || state_comp_en || state_comp_de || (state_comp_crc && crc_comp_syc_read));
assign in_data_reg_read_valid[1]  = (sys_cnt[3:0] == 4'd1)  && (state_read_en || state_read_de || state_read_max || state_read_min || state_read_crc || state_comp_en || state_comp_de || (state_comp_crc && crc_comp_syc_read));
assign in_data_reg_read_valid[2]  = (sys_cnt[3:0] == 4'd2)  && (state_read_en || state_read_de || state_read_max || state_read_min || state_read_crc || state_comp_en || state_comp_de || (state_comp_crc && crc_comp_syc_read));
assign in_data_reg_read_valid[3]  = (sys_cnt[3:0] == 4'd3)  && (state_read_en || state_read_de || state_read_max || state_read_min || state_read_crc || state_comp_en || state_comp_de || (state_comp_crc && crc_comp_syc_read));
assign in_data_reg_read_valid[4]  = (sys_cnt[3:0] == 4'd4)  && (state_read_en || state_read_de || state_read_max || state_read_min || state_read_crc || state_comp_en || state_comp_de || (state_comp_crc && crc_comp_syc_read));
assign in_data_reg_read_valid[5]  = (sys_cnt[3:0] == 4'd5)  && (state_read_en || state_read_de || state_read_max || state_read_min || state_read_crc || state_comp_en || state_comp_de || (state_comp_crc && crc_comp_syc_read));
assign in_data_reg_read_valid[6]  = (sys_cnt[3:0] == 4'd6)  && (state_read_en || state_read_de || state_read_max || state_read_min || state_read_crc || state_comp_en || state_comp_de || (state_comp_crc && crc_comp_syc_read));
assign in_data_reg_read_valid[7]  = (sys_cnt[3:0] == 4'd7)  && (state_read_en || state_read_de || state_read_max || state_read_min || state_read_crc || state_comp_en || state_comp_de || (state_comp_crc && crc_comp_syc_read));
assign in_data_reg_read_valid[8]  = (sys_cnt[3:0] == 4'd8)  && (state_read_en || state_read_de || state_read_max || state_read_min || state_read_crc || state_comp_en || state_comp_de || (state_comp_crc && crc_comp_syc_read));
assign in_data_reg_read_valid[9]  = (sys_cnt[3:0] == 4'd9)  && (state_read_en || state_read_de || state_read_max || state_read_min || state_read_crc || state_comp_en || state_comp_de || (state_comp_crc && crc_comp_syc_read));
assign in_data_reg_read_valid[10] = (sys_cnt[3:0] == 4'd10) && (state_read_en || state_read_de || state_read_max || state_read_min || state_read_crc || state_comp_en || state_comp_de || (state_comp_crc && crc_comp_syc_read));
assign in_data_reg_read_valid[11] = (sys_cnt[3:0] == 4'd11) && (state_read_en || state_read_de || state_read_max || state_read_min || state_read_crc || state_comp_en || state_comp_de || (state_comp_crc && crc_comp_syc_read));
assign in_data_reg_read_valid[12] = (sys_cnt[3:0] == 4'd12) && (state_read_en || state_read_de || state_read_max || state_read_min || state_read_crc || state_comp_en || state_comp_de || (state_comp_crc && crc_comp_syc_read));
assign in_data_reg_read_valid[13] = (sys_cnt[3:0] == 4'd13) && (state_read_en || state_read_de || state_read_max || state_read_min || state_read_crc || state_comp_en || state_comp_de || (state_comp_crc && crc_comp_syc_read));
assign in_data_reg_read_valid[14] = (sys_cnt[3:0] == 4'd14) && (state_read_en || state_read_de || state_read_max || state_read_min || state_read_crc || state_comp_en || state_comp_de || (state_comp_crc && crc_comp_syc_read));
assign in_data_reg_read_valid[15] = (sys_cnt[3:0] == 4'd15) && (state_read_en || state_read_de || state_read_max || state_read_min || state_read_crc || state_comp_en || state_comp_de || (state_comp_crc && crc_comp_syc_read));


// Register
/*always@(posedge clk or posedge rst)
    if (rst)
        in_data_reg <= 0;
    else
        in_data_reg <= in_data_reg_w;*/
always@(posedge clk)
    in_data_reg <= in_data_reg_w;

always@*
    if (in_data_reg_read_valid[15])
        in_data_reg_w[127:120] = iot_in;
    else
        in_data_reg_w[127:120] = in_data_reg[127:120];    

always@*
    if (in_data_reg_read_valid[14])
        in_data_reg_w[119:112] = iot_in;
    else
        in_data_reg_w[119:112] = in_data_reg[119:112];   

always@*
    if (in_data_reg_read_valid[13])
        in_data_reg_w[111:104] = iot_in;
    else
        in_data_reg_w[111:104] = in_data_reg[111:104];   

always@*
    if (in_data_reg_read_valid[12])
        in_data_reg_w[103:96] = iot_in;
    else
        in_data_reg_w[103:96] = in_data_reg[103:96];  

always@*
    if (in_data_reg_read_valid[11])
        in_data_reg_w[95:88] = iot_in;
    else
        in_data_reg_w[95:88] = in_data_reg[95:88];  

always@*
    if (in_data_reg_read_valid[10])
        in_data_reg_w[87:80] = iot_in;
    else
        in_data_reg_w[87:80] = in_data_reg[87:80];  

always@*
    if (in_data_reg_read_valid[9])
        in_data_reg_w[79:72] = iot_in;
    else
        in_data_reg_w[79:72] = in_data_reg[79:72];  

always@*
    if (in_data_reg_read_valid[8])
        in_data_reg_w[71:64] = iot_in;
    else
        in_data_reg_w[71:64] = in_data_reg[71:64];

always@*
    if (in_data_reg_read_valid[7])
        in_data_reg_w[63:56] = iot_in;
    else
        in_data_reg_w[63:56] = in_data_reg[63:56];

always@*
    if (in_data_reg_read_valid[6])
        in_data_reg_w[55:48] = iot_in;
    else
        in_data_reg_w[55:48] = in_data_reg[55:48];

always@*
    if (in_data_reg_read_valid[5])
        in_data_reg_w[47:40] = iot_in;
    else
        in_data_reg_w[47:40] = in_data_reg[47:40];

 always@*
    if (in_data_reg_read_valid[4])
        in_data_reg_w[39:32] = iot_in;
    else
        in_data_reg_w[39:32] = in_data_reg[39:32]; 

always@*
    if (in_data_reg_read_valid[3])
        in_data_reg_w[31:24] = iot_in;
    else
        in_data_reg_w[31:24] = in_data_reg[31:24];    

always@*
    if (in_data_reg_read_valid[2])
        in_data_reg_w[23:16] = iot_in;
    else
        in_data_reg_w[23:16] = in_data_reg[23:16];  

always@*
    if (in_data_reg_read_valid[1])
        in_data_reg_w[15:8] = iot_in;
    else
        in_data_reg_w[15:8] = in_data_reg[15:8]; 

always@*
    if (in_data_reg_read_valid[0])
        in_data_reg_w[7:0] = iot_in;
    else
        in_data_reg_w[7:0] = in_data_reg[7:0]; 


// --------------------------------------------------- Register 2 (Text Reg / Output Reg 1) ---------------------------------------------------------------
// Init P
assign current_init_p = (state_comp_en || state_comp_de) && (sys_cnt[3:0] == 4'd0);
assign init_p_in = in_data_reg[63:0];

init_p init_p_u0(.init_p_in(init_p_in), .init_p_out(init_p_out));

// Computation Control
assign current_comp_switch = (state_comp_en || state_comp_de) && (sys_cnt != 5'd0) && (sys_cnt != 5'd16);

assign text_comp_in = text_reg[63:32];
assign text_indenity_in = text_reg[31:0];


// F Expansion
text_expansion_p text_expansion_p_u0 (.text_indenity_in(text_indenity_in), .text_expansion_out(text_expansion_out));

// F Xor
assign F_xor_out = text_expansion_out ^ key_pc2_out;

// F Sbox
assign Sbox_in_1 = F_xor_out[47:42];
assign Sbox_in_2 = F_xor_out[41:36];
assign Sbox_in_3 = F_xor_out[35:30];
assign Sbox_in_4 = F_xor_out[29:24];
assign Sbox_in_5 = F_xor_out[23:18];
assign Sbox_in_6 = F_xor_out[17:12];
assign Sbox_in_7 = F_xor_out[11:6];
assign Sbox_in_8 = F_xor_out[5:0];

Sbox_1 Sbox_1_u0 (.Sbox_in_1(Sbox_in_1), .Sbox_out_1(Sbox_out_1));
Sbox_2 Sbox_2_u0 (.Sbox_in_2(Sbox_in_2), .Sbox_out_2(Sbox_out_2));
Sbox_3 Sbox_3_u0 (.Sbox_in_3(Sbox_in_3), .Sbox_out_3(Sbox_out_3));
Sbox_4 Sbox_4_u0 (.Sbox_in_4(Sbox_in_4), .Sbox_out_4(Sbox_out_4));
Sbox_5 Sbox_5_u0 (.Sbox_in_5(Sbox_in_5), .Sbox_out_5(Sbox_out_5));
Sbox_6 Sbox_6_u0 (.Sbox_in_6(Sbox_in_6), .Sbox_out_6(Sbox_out_6));
Sbox_7 Sbox_7_u0 (.Sbox_in_7(Sbox_in_7), .Sbox_out_7(Sbox_out_7));
Sbox_8 Sbox_8_u0 (.Sbox_in_8(Sbox_in_8), .Sbox_out_8(Sbox_out_8));


// F P
assign F_P_in = {Sbox_out_1, Sbox_out_2, Sbox_out_3, Sbox_out_4, Sbox_out_5, Sbox_out_6, Sbox_out_7, Sbox_out_8};
F_P F_P_u0 (.F_P_in(F_P_in), .F_P_out(F_P_out));

// Comp xor
assign text_comp_out = text_comp_in ^ F_P_out;


// Final P
assign current_final_p = (state_comp_en || state_comp_de) && (sys_cnt == 5'd16);
final_p final_p_u0 (.text_reg({text_comp_out, text_indenity_in}), .text_final_p_out(text_final_p_out));

// For Max or Min comparison (1st) Larger: 1, Else:0
assign current_compare_max_1st = state_comp_max && (sys_cnt == 5'd0);
assign current_compare_max_2nd = state_comp_max && (sys_cnt == 5'd1);
assign current_compare_min_1st = state_comp_min && (sys_cnt == 5'd0);
assign current_compare_min_2nd = state_comp_min && (sys_cnt == 5'd1);
assign current_store_result_max = (state_comp_max) && (sys_cnt == 5'd2);
assign current_store_result_min = (state_comp_min) && (sys_cnt == 5'd2);

assign current_comp_out_1st = (state_out_max || state_out_min) && (sys_cnt == 5'd0);
assign current_comp_out_2nd = (state_out_max || state_out_min) && (sys_cnt == 5'd1);


// Type0:  > 1st and >  2nd in Max or  <= 1st and <= 2nd in Min
// Type1: <= 1st and >  2nd in Max or  >  1st and <= 2nd in Min
// Type2: <= 1st and <= 2nd in Max or  >  1st and >  2nd in Min
assign comp_type_0  = ((current_store_result_max && ( comp_result_1st &&  comp_result_2nd)) || (current_store_result_min && ( ~comp_result_1st &&  ~comp_result_2nd)));
assign comp_type_1  = ((current_store_result_max && (~comp_result_1st &&  comp_result_2nd)) || (current_store_result_min && ( comp_result_1st  &&  ~comp_result_2nd)));
assign comp_type_2  = ((current_store_result_max && (~comp_result_1st && ~comp_result_2nd)) || (current_store_result_min && ( comp_result_1st  &&   comp_result_2nd)));

assign comp_reset_max = (fn_sel == 3'b100) && (state_idle || out_max_end);
assign comp_reset_min = (fn_sel == 3'b101) && (state_idle || out_min_end);

always@*
    if (current_compare_max_1st)
        current_comp_reg = comp_1st_reg;
    else if (current_compare_max_2nd)
        current_comp_reg = comp_2nd_reg;
    else if (current_compare_min_1st)
        current_comp_reg = comp_1st_reg;
    else if (current_compare_min_2nd)
        current_comp_reg = comp_2nd_reg;
    else
        current_comp_reg = 0;

assign comp_result = (in_data_reg > current_comp_reg);

always@*
    if (current_compare_max_1st || current_compare_min_1st)
        comp_result_1st_w = comp_result;
    else
        comp_result_1st_w = comp_result_1st;

always@*
    if (current_compare_max_2nd || current_compare_min_2nd)
        comp_result_2nd_w = comp_result;
    else
        comp_result_2nd_w = comp_result_2nd;


always@(posedge clk or posedge rst)
    if (rst)
        comp_result_1st <= 0;
    else
        comp_result_1st <= comp_result_1st_w;


always@(posedge clk or posedge rst)
    if (rst)
        comp_result_2nd <= 0;
    else
        comp_result_2nd <= comp_result_2nd_w;



always@*
    if (comp_reset_max)
        comp_1st_reg_w[127:64] = 0;
    else if (comp_reset_min)
        comp_1st_reg_w[127:64] = 64'hffff_ffff_ffff_ffff;
    else if (current_init_p || current_crc_read || comp_type_0)  // En/De Mux
        comp_1st_reg_w[127:64] = in_data_reg[127:64];
    else
        comp_1st_reg_w[127:64] = comp_1st_reg[127:64];

always@*
    if (comp_reset_max)
        comp_1st_reg_w[63:0] = 0;
    else if (comp_reset_min)
        comp_1st_reg_w[63:0] = 64'hffff_ffff_ffff_ffff;
    else if (current_init_p)                                   // En/De Mux
        comp_1st_reg_w[63:0] = init_p_out;
    else if (current_comp_switch)
        comp_1st_reg_w[63:0] = {text_indenity_in, text_comp_out};
    else if (current_crc_read || comp_type_0)                            // CRC Mux
        comp_1st_reg_w[63:0] = in_data_reg[63:0];
    else
        comp_1st_reg_w[63:0] = comp_1st_reg[63:0];

always@*
    if (comp_reset_max)
        comp_2nd_reg_w[127:120] = 0;
    else if (comp_reset_min)
        comp_2nd_reg_w[127:120] = 8'hff;
    else if (comp_type_0)
        comp_2nd_reg_w[127:120] = comp_1st_reg[127:120];
    else if (comp_type_1)
        comp_2nd_reg_w[127:120] = in_data_reg[127:120];
    else
        comp_2nd_reg_w[127:120] = comp_2nd_reg[127:120];                

always@*
    if (comp_reset_max)
        comp_2nd_reg_w[119:64] = 0;
    else if (comp_reset_min)
        comp_2nd_reg_w[119:64] = 56'hffff_ffff_ffff_ff;
    else if (current_pc1)                                       // Key Mux
        comp_2nd_reg_w[119:64] = key_pc1_out;
    else if (current_l_shift_1 || current_l_shift_2)
        comp_2nd_reg_w[119:64] = key_pc2_in;
    else if (current_r_shift_1)
        comp_2nd_reg_w[119:64] = key_r_shift_1;
    else if (current_r_shift_2)
        comp_2nd_reg_w[119:64] = key_r_shift_2;
    else if (comp_type_0)
        comp_2nd_reg_w[119:64] = comp_1st_reg[119:64];
    else if (comp_type_1)
        comp_2nd_reg_w[119:64] = in_data_reg[119:64];
    else
        comp_2nd_reg_w[119:64] = comp_2nd_reg[119:64];

always@*
    if (comp_reset_max)
        comp_2nd_reg_w[63:0] = 0;
    else if (comp_reset_min)
        comp_2nd_reg_w[63:0] = 64'hffff_ffff_ffff_ffff;
    else if (comp_type_0)
        comp_2nd_reg_w[63:0] = comp_1st_reg[63:0];
    else if (comp_type_1)
        comp_2nd_reg_w[63:0] = in_data_reg[63:0];
    else
        comp_2nd_reg_w[63:0] = comp_2nd_reg[63:0];


always@(posedge clk)
    comp_1st_reg <= comp_1st_reg_w;

always@(posedge clk)
    comp_2nd_reg <= comp_2nd_reg_w;

assign key_reg = comp_2nd_reg[119:64];
assign text_reg = comp_1st_reg[63:0];
assign out_key_reg = comp_1st_reg[127:64];
// --------------------------------------------------- Register 3 (Key Reg /  Output Reg 2) ---------------------------------------------------------------
// PC1
assign current_pc1 = (state_comp_en || state_comp_de) && (sys_cnt[3:0] == 4'd0);
assign key_pc1_in = in_data_reg[127:64];
pc1_p pc1_p_u0(.key_pc1_in(key_pc1_in), .key_pc1_out(key_pc1_out));
        

// PC2
assign current_en_one_bit_round = ((sys_cnt == 5'd1) || (sys_cnt == 5'd2) || (sys_cnt == 5'd9) || (sys_cnt == 5'd16));
assign current_l_shift_1 = (state_comp_en) && current_en_one_bit_round;
assign current_l_shift_2 = (state_comp_en) && ~current_en_one_bit_round && (sys_cnt != 5'd0);
assign current_de_one_bit_round = ((sys_cnt == 5'd1) || (sys_cnt == 5'd8) || (sys_cnt == 5'd15) || (sys_cnt == 5'd16));
assign current_r_shift_1 = (state_comp_de) && current_de_one_bit_round;
assign current_r_shift_2 = (state_comp_de) && ~current_de_one_bit_round && (sys_cnt != 5'd0);

always@* begin
    key_l_shift_1[0] = key_reg[27];
    for (i = 0; i < 27; i = i+1) 
        key_l_shift_1[i+1] = key_reg[i]; 

    key_l_shift_1[28] = key_reg[55];    
    for (i = 28; i < 55; i = i+1) 
        key_l_shift_1[i+1] = key_reg[i]; 
end


always@* begin
    key_l_shift_2[0] = key_reg[26];
    key_l_shift_2[1] = key_reg[27];
    for (i = 0; i < 26; i = i+1) 
        key_l_shift_2[i+2] = key_reg[i]; 

    key_l_shift_2[28] = key_reg[54];
    key_l_shift_2[29] = key_reg[55];
    for (i = 28; i < 54; i = i+1) 
        key_l_shift_2[i+2] = key_reg[i]; 
end

always@* begin
    key_r_shift_1[27] = key_reg[0];
    for (i = 0; i < 27; i = i+1) 
        key_r_shift_1[i] = key_reg[i+1]; 

    key_r_shift_1[55] = key_reg[28];    
    for (i = 28; i < 55; i = i+1) 
        key_r_shift_1[i] = key_reg[i+1]; 
end



always@* begin
    key_r_shift_2[26] = key_reg[0];
    key_r_shift_2[27] = key_reg[1];
    for (i = 0; i < 26; i = i+1) 
        key_r_shift_2[i] = key_reg[i+2]; 

    key_r_shift_2[54] = key_reg[28];
    key_r_shift_2[55] = key_reg[29];
    for (i = 28; i < 54; i = i+1) 
        key_r_shift_2[i] = key_reg[i+2]; 
end



always@*
    if (current_l_shift_1)
        key_pc2_in = key_l_shift_1;
    else if (current_l_shift_2)
        key_pc2_in = key_l_shift_2;
    else if (current_r_shift_1)
        key_pc2_in = key_reg;
    else if (current_r_shift_2)
        key_pc2_in = key_reg;
    else
        key_pc2_in = 0;


pc2_p pc2_p_u0(.key_pc2_in(key_pc2_in), .key_pc2_out(key_pc2_out));




// --------------------------------------------------- CRC Reg ---------------------------------------------------------------

// Read Input Reg for CRC

assign current_crc_read = state_comp_crc && (sys_cnt == 5'd0);
assign current_crc_comp = state_comp_crc && (sys_cnt != 5'd0);

// ~sys_cnt: start point of the CRC input bit
reg [6:0] sys_cnt_inv;
wire [7:0] crc_start_point_shift_3;
wire [7:0] crc_start_point_shift_2;
wire [7:0] crc_start_point_shift_1;

// assign crc_start_point = 8'd130 - sys_cnt;
assign crc_start_point = 8'd130 - crc_read_cnt;
assign crc_start_point_shift_3 = (crc_start_point-2'd3);
assign crc_start_point_shift_2 = (crc_start_point-2'd2);
assign crc_start_point_shift_1 = (crc_start_point-2'd1);

// Padding the input for 3 bit zero
assign in_data_reg_pad = {comp_1st_reg, 3'd0};

// Concatenate CRC result with input for the next round
always@*
    if (crc_shift_num_prev == 4'd5)
        crc_in_concat = {crc_result_reg, in_data_reg_pad[crc_start_point_shift_3 -: 5]};
    else if  (crc_shift_num_prev == 4'd6)
        crc_in_concat = {crc_result_reg[1:0], in_data_reg_pad[crc_start_point_shift_2 -: 6]};
    else if  (crc_shift_num_prev == 4'd7)
        crc_in_concat = {crc_result_reg[0], in_data_reg_pad[crc_start_point_shift_1 -: 7]};
    else
        crc_in_concat = in_data_reg_pad[crc_start_point -: 8];



always@* 
    if (crc_start_point == 3'd6)                                        // {0,   in[3:0], 000}
        current_crc_in = {1'd0, crc_in_concat[7:1]};
    else if (crc_start_point == 3'd5)                                   // {00,  in[2:0], 000}
        current_crc_in = {2'd0, crc_in_concat[7:2]};
    else if (crc_start_point == 3'd4)                                   // {000,  in[1:0], 000}
        current_crc_in = {3'd0, crc_in_concat[7:3]};
    else if (crc_start_point == 3'd3)                                   // {0,   in[3:0], 000}
        current_crc_in = {4'd0, crc_in_concat[7:4]};
    else if (crc_start_point == 3'd2)                                   // {00,  in[2:0], 000}
        current_crc_in = {5'd0, crc_in_concat[7:5]};
    else if (crc_start_point == 3'd1)                                   // {000,  in[1:0], 000}
        current_crc_in = {6'd0, crc_in_concat[7:6]};
    else if (crc_start_point == 3'd0)                                   // {0000, in[0], 000}
        current_crc_in = {7'd0, crc_in_concat[7]};
    else
        current_crc_in = crc_in_concat;

crc_8bit_lut crc_8bit_lut_u0(.current_crc_in(current_crc_in), .current_crc_out(current_crc_out));

always@*
    if (current_crc_out[2])                                             // out = 1xx
        crc_shift_num = 4'd5;
    else if (current_crc_out[1])                                        // out = 01x
        crc_shift_num = 4'd6;        
    else if (current_crc_out[0])                                        // out = 001
        crc_shift_num = 4'd7; 
    else                                                                // out = 000
        crc_shift_num = 4'd8; 

always@(posedge clk or posedge rst)
    if (rst)
        crc_shift_num_prev <= 0;
    else
        if (comp_crc_end)
            crc_shift_num_prev <= 0;
        else if (current_crc_comp)
            crc_shift_num_prev <= crc_shift_num;
        else
            crc_shift_num_prev <= crc_shift_num_prev;

always@*
    if (comp_crc_end)
        crc_result_reg_w = 0;
    else if (current_crc_comp)
        crc_result_reg_w = current_crc_out;
    else
        crc_result_reg_w = crc_result_reg;

always@(posedge clk or posedge rst)
    if (rst)
        crc_result_reg <= 0;
    else
        crc_result_reg <= crc_result_reg_w;


endmodule
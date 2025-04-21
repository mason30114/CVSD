module ed25519 #(
    parameter DATA_W = 64,
    parameter PATN_W = 256,
    parameter IO_CYCLE = PATN_W/DATA_W
)(
    input               i_clk,
    input               i_rst,
    input               i_in_valid,
    input  [DATA_W-1:0] i_in_data,
    input               i_out_ready,
    output              o_in_ready,
    output              o_out_valid,
    output [DATA_W-1:0] o_out_data 

);

wire [254:0] q;
assign q = 255'b111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101101;
// Control Signal
parameter [3:0] IDLE = 4'd0, READ = 4'd1, SELF_T_MULT = 4'd2, POINT_DOUBLE = 4'd3, POINT_ADD = 4'd4, 
                R_MULT = 4'd5, OTHER_MULT = 4'd6, SELF_X_MULT = 4'd7, SUB_X = 4'd8, SUB_Y = 4'd9, OUT_DATA = 4'd10,
                INV_INIT = 4'd11, SELF_T_MOVE = 4'd12, SELF_Y_MULT = 4'd13, FIND_INV = 4'd14;

reg [7:0] sys_cnt, sys_cnt_w;
reg [3:0] state, n_state;
wire read_end, self_t_mult_end, point_double_end, point_add_end, r_mult_end, other_mult_end, self_x_mult_end, self_y_mult_end, sub_x_end, sub_y_end, out_data_end;
wire find_inv_end;
wire m_current_one;
wire q_minus_2_current_one;

// Output Signal
wire o_in_ready_w;
wire o_out_valid_w;
reg [DATA_W-1:0] o_out_data_w;

// ALU Signal
reg [PATN_W-2:0] X1_alu_in;
reg [PATN_W-2:0] Y1_alu_in;
reg [PATN_W-2:0] Z1_alu_in;
reg [PATN_W-2:0] T1_alu_in;
reg [PATN_W-2:0] X2_alu_in;
reg [PATN_W-2:0] Y2_alu_in;
reg [PATN_W-2:0] Z2_alu_in;
reg [PATN_W-2:0] T2_alu_in;
reg [2:0] arith_type;
reg alu_in_valid, alu_in_valid_w;
wire alu_out_ready;

wire alu_out_valid;
wire alu_in_ready;
wire [PATN_W-2:0] alu_X1_w_data;
wire              alu_X1_we;
wire [PATN_W-2:0] alu_Y1_w_data;
wire              alu_Y1_we;
wire [PATN_W-2:0] alu_Z1_w_data;
wire              alu_Z1_we;
wire [PATN_W-2:0] alu_T1_w_data;
wire              alu_T1_we;
wire [PATN_W-2:0] alu_X2_w_data;
wire              alu_X2_we;
wire [PATN_W-2:0] alu_Y2_w_data;
wire              alu_Y2_we;
wire [PATN_W-2:0] alu_Z2_w_data;
wire              alu_Z2_we;
wire [PATN_W-2:0] alu_T2_w_data;
wire              alu_T2_we;

reg [PATN_W-2:0] alu_T2_in;

// Regfile Signal
wire [PATN_W-2:0] X1_r_data;
wire [PATN_W-2:0] X1_w_data;
wire              X1_we;

wire [PATN_W-2:0] Y1_r_data;
wire [PATN_W-2:0] Y1_w_data;
wire              Y1_we;

wire [PATN_W-2:0] Z1_r_data;
wire [PATN_W-2:0] Z1_w_data;
wire              Z1_we;

wire [PATN_W-2:0] T1_r_data;
reg  [PATN_W-2:0] T1_w_data;
reg               T1_we;

wire [PATN_W-2:0] X2_r_data;
wire [PATN_W-2:0] X2_w_data;
wire              X2_we;

wire [PATN_W-2:0] Y2_r_data;
wire [PATN_W-2:0] Y2_w_data;
wire              Y2_we;

wire [PATN_W-2:0] Z2_r_data;
wire [PATN_W-2:0] Z2_w_data;
wire              Z2_we;

wire [PATN_W-2:0] T2_r_data;
wire [PATN_W-2:0] T2_w_data;
wire              T2_we;

wire [PATN_W-2:0] Xself_r_data;
wire [PATN_W-2:0] Xself_w_data;
wire              Xself_we;

wire [PATN_W-2:0] Yself_r_data;
wire [PATN_W-2:0] Yself_w_data;
wire              Yself_we;
/*wire [PATN_W-2:0] Zself_r_data;
wire [PATN_W-2:0] Zself_w_data;                               // Reduced (always = 1)
wire              Zself_we;*/

wire [PATN_W-2:0] Tself_r_data;
wire [PATN_W-2:0] Tself_w_data;
wire              Tself_we;

wire [PATN_W-2:0] M_r_data;
wire [PATN_W-2:0] M_w_data;
wire              M_we;

reg  [PATN_W-2:0] top_Xself_w_data;
reg  [PATN_W-2:0] top_Yself_w_data;
reg  [PATN_W-2:0] top_Tself_w_data;
reg               top_Xself_we;
reg               top_Yself_we;
reg               top_Tself_we;

reg  [PATN_W-2:0] top_M_w_data;
reg               top_M_we;




// In valid control
always@*
    case(state)
        SELF_T_MOVE: alu_in_valid_w = 1;
        SELF_T_MULT:
            if (alu_out_valid)
                alu_in_valid_w = 1;
            else
                alu_in_valid_w = 0;
        POINT_DOUBLE:
            if (alu_out_valid)                            
                alu_in_valid_w = 1;
            else 
                alu_in_valid_w = 0;

        POINT_ADD:
            if (alu_out_valid)
                alu_in_valid_w = 1;
            else 
                alu_in_valid_w = 0;
        FIND_INV: 
            if (find_inv_end)
                alu_in_valid_w = 1;
            else
                alu_in_valid_w = 0;                
        SELF_X_MULT:
            if (self_x_mult_end)
                alu_in_valid_w = 1;
            else
                alu_in_valid_w = 0;
        SELF_Y_MULT:
            if (self_y_mult_end)
                alu_in_valid_w = 1;
            else
                alu_in_valid_w = 0;
        SUB_X:
            if (sub_x_end)
                alu_in_valid_w = 1;
            else
                alu_in_valid_w = 0;   

        default: alu_in_valid_w = 0;
    endcase

always@(posedge i_clk)
    if (i_rst)
        alu_in_valid <= 0;
    else
        alu_in_valid <= alu_in_valid_w;

// ----------------------------------------------------------- System Control -----------------------------------------------------------
always@*
    case(state)
        IDLE: n_state = READ;
        READ:
            if (read_end)                                       // Start Initialization of self.T
                n_state = SELF_T_MOVE;                   
            else
                n_state = READ;
        SELF_T_MOVE: n_state = SELF_T_MULT;  
        SELF_T_MULT:
            if (self_t_mult_end)                                // Start Point Mult
                n_state = POINT_DOUBLE;
            else
                n_state = SELF_T_MULT;
        POINT_DOUBLE:
            if (point_double_end)                               // Start Find Inv
                n_state = FIND_INV;
            else if (alu_out_valid && m_current_one)
                n_state = POINT_ADD;
            else 
                n_state = POINT_DOUBLE;

        POINT_ADD:
            if (point_add_end)                                  // Start Find Inv
                n_state = FIND_INV;
            else if (alu_out_valid)
                n_state = POINT_DOUBLE;
            else 
                n_state = POINT_ADD;

        FIND_INV: 
            if (alu_out_valid)
                n_state = SELF_X_MULT;
            else
                n_state = FIND_INV;
        
        SELF_X_MULT:
            if (self_x_mult_end)
                n_state = SELF_Y_MULT;
            else
                n_state = SELF_X_MULT;
        SELF_Y_MULT:
            if (self_y_mult_end)
                n_state = SUB_X;
            else
                n_state = SELF_Y_MULT;

        SUB_X:
            if (sub_x_end)
                n_state = SUB_Y;
            else
                n_state = SUB_X;
        
        SUB_Y:
            if (sub_y_end)
                n_state = OUT_DATA;
            else
                n_state = SUB_Y;       

        OUT_DATA:
            if (out_data_end)
                n_state = IDLE;
            else
                n_state = OUT_DATA;

        default: n_state = state;
    endcase

always@(posedge i_clk)
    if (i_rst)
        state <= 0;
    else
        state <= n_state;

// System Counter
always@*
    case(state)
        READ:
            if (read_end)
                sys_cnt_w = 0;
            else if (i_in_valid && o_in_ready)                      // Successful Read
                sys_cnt_w = sys_cnt + 1'b1;
            else
                sys_cnt_w = sys_cnt;

        POINT_DOUBLE:          
            if (point_double_end)                             
                sys_cnt_w = 0;       
            else if (alu_out_valid && ~m_current_one)              // Current M bit = 0
                sys_cnt_w = sys_cnt + 1'b1;
            else 
                sys_cnt_w = sys_cnt;
         
        POINT_ADD:                                       
            if (point_add_end)  
                sys_cnt_w = 0;        
            else if (alu_out_valid)                                // Current M bit = 1                                     
                sys_cnt_w = sys_cnt + 1'b1;
            else 
                sys_cnt_w = sys_cnt;       

        R_MULT:
            if (r_mult_end)
                sys_cnt_w = 0;
            else if (alu_out_valid && ~q_minus_2_current_one)       // Current (q-2)^(-1) bit = 0
                sys_cnt_w = sys_cnt + 1'b1;
            else
                sys_cnt_w = sys_cnt;

        OTHER_MULT:
            if (other_mult_end)
                sys_cnt_w = 0;
            else if (alu_out_valid)                                // Current (q-2)^(-1) bit = 1
                sys_cnt_w = sys_cnt + 1'b1;
            else
                sys_cnt_w = sys_cnt;
        
        OUT_DATA:
            if (out_data_end)
                sys_cnt_w = 0;
            else if (o_out_valid && i_out_ready)                   // Successful Write 
                sys_cnt_w = sys_cnt + 1'b1;
            else
                sys_cnt_w = sys_cnt;    

        default: sys_cnt_w = sys_cnt;            

    endcase


always@(posedge i_clk)
    if (i_rst)
        sys_cnt <= 0;
    else
        sys_cnt <= sys_cnt_w;

assign read_end         = (state == READ)         && (sys_cnt == 8'd11)  && i_in_valid    && o_in_ready            ;
assign self_t_mult_end  = (state == SELF_T_MULT)  &&                        alu_out_valid                          ;
assign point_double_end = (state == POINT_DOUBLE) && (sys_cnt == 8'd254) && alu_out_valid && ~m_current_one        ;
assign point_add_end    = (state == POINT_ADD)    && (sys_cnt == 8'd254) && alu_out_valid                          ;
assign r_mult_end       = (state == R_MULT)       && (sys_cnt == 8'd254) && alu_out_valid && ~q_minus_2_current_one;
assign other_mult_end   = (state == OTHER_MULT)   && (sys_cnt == 8'd254) && alu_out_valid;
assign self_x_mult_end  = (state == SELF_X_MULT)                         && alu_out_valid                          ;
assign self_y_mult_end  = (state == SELF_Y_MULT)                         && alu_out_valid                          ;
assign sub_x_end        = (state == SUB_X)        &&                        alu_out_valid                          ;
assign sub_y_end        = (state == SUB_Y)        &&                        alu_out_valid                          ;
assign out_data_end     = (state == OUT_DATA)     && (sys_cnt == 8'd7)   && o_out_valid   && i_out_ready           ;

assign find_inv_end     = (state == FIND_INV)                            && alu_out_valid                          ;    
                                  
assign m_current_one = M_r_data[254];                                    
assign q_minus_2_current_one = ~((sys_cnt == 8'd250) || (sys_cnt == 8'd252)); 
// ----------------------------------------------------------- Output Signal -----------------------------------------------------------
assign o_in_ready_w  = (state == READ);
assign o_in_ready    = o_in_ready_w;

assign o_out_valid_w = (state == OUT_DATA);
assign o_out_valid   = o_out_valid_w;

always@*
    case(sys_cnt[2:0])
        3'd0: o_out_data_w = {1'b0, Xself_r_data[254:192]};
        3'd1: o_out_data_w = Xself_r_data[191:128];
        3'd2: o_out_data_w = Xself_r_data[127:64];
        3'd3: o_out_data_w = Xself_r_data[63:0];
        3'd4: o_out_data_w = {1'b0, Yself_r_data[254:192]};
        3'd5: o_out_data_w = Yself_r_data[191:128];
        3'd6: o_out_data_w = Yself_r_data[127:64];
        3'd7: o_out_data_w = Yself_r_data[63:0];
        default: o_out_data_w = 0;
    endcase



assign o_out_data = o_out_data_w;


// ----------------------------------------------------------- ALU Instance -----------------------------------------------------------

alu alu_u0 (.i_clk(i_clk), .i_rst(i_rst), 
            .alu_X1(X1_r_data), .alu_Y1(Y1_r_data), .alu_Z1(Z1_r_data), .alu_T1(T1_r_data),
            .alu_X2(Xself_r_data), .alu_Y2(Yself_r_data), /*.alu_Z2(255'd1),*/ .alu_T2(Tself_r_data),
            .alu_arith_type(arith_type), .alu_in_valid(alu_in_valid), 
            .alu_write_X1(alu_X1_w_data), .alu_X1_we(alu_X1_we), .alu_write_Y1(alu_Y1_w_data), .alu_Y1_we(alu_Y1_we), 
            .alu_write_Z1(alu_Z1_w_data), .alu_Z1_we(alu_Z1_we), .alu_write_T1(alu_T1_w_data), .alu_T1_we(alu_T1_we), 
            .alu_out_valid(alu_out_valid)
             );


assign alu_out_ready = 1;


always@*
    case(state)
        SELF_T_MULT: arith_type = 3'd0;
        POINT_DOUBLE: 
            if (point_double_end)
                arith_type = 3'd4;
            else if (m_current_one)
                arith_type = 3'd1;
            else
                arith_type = 3'd0;
        POINT_ADD:
            if (point_add_end)
                arith_type = 3'd4;
            else
                arith_type = 3'd0;
        FIND_INV: arith_type = 3'd2;
        SELF_X_MULT: arith_type = 3'd2;
        SELF_Y_MULT: arith_type = 3'd3;
        SUB_X: arith_type = 3'd3;
        default: arith_type = 3'd3;
    endcase

assign current_r_mult = (state == R_MULT) && alu_out_valid;
assign current_other_mult = (state == OTHER_MULT) && alu_out_valid;


// ----------------------------------------------------------- RegFile Instance -----------------------------------------------------------

regfile regfile_u0 (.clk(i_clk), .rst(i_rst),
                    .X1_r_data(X1_r_data), .X1_w_data(X1_w_data), .X1_we(X1_we), .Y1_r_data(Y1_r_data), .Y1_w_data(Y1_w_data), .Y1_we(Y1_we),
                    .Z1_r_data(Z1_r_data), .Z1_w_data(Z1_w_data), .Z1_we(Z1_we), .T1_r_data(T1_r_data), .T1_w_data(T1_w_data), .T1_we(T1_we),
                    .Xself_r_data(Xself_r_data), .Xself_w_data(Xself_w_data), .Xself_we(Xself_we), .Yself_r_data(Yself_r_data), .Yself_w_data(Yself_w_data), .Yself_we(Yself_we),
                    .Tself_r_data(Tself_r_data), .Tself_w_data(Tself_w_data), .Tself_we(Tself_we), .M_r_data(M_r_data), .M_w_data(M_w_data), .M_we(M_we)                     
                    );

assign current_move_init_T = (state == SELF_T_MOVE);
assign current_mult_init_T = (state == SELF_T_MULT) && alu_out_valid;

assign current_move_init_inv = (state == INV_INIT);

assign current_self_x_mult = (state == SELF_X_MULT) && alu_out_valid;
assign current_self_y_mult = (state == SELF_Y_MULT) && alu_out_valid;

assign current_sub_x = (state == SUB_X) && (Xself_r_data[0]) && alu_out_valid;
assign current_sub_y = (state == SUB_Y) && (Yself_r_data[0]) && alu_out_valid;

// r Reg
assign X1_w_data = alu_X1_w_data;
assign Y1_w_data = alu_Y1_w_data;
assign Z1_w_data = alu_Z1_w_data;

always@*
    if (current_move_init_T)
        T1_w_data = Xself_r_data;
    else if (current_mult_init_T)                          // Zero point
        T1_w_data = 0;
    else if (current_move_init_inv)
        T1_w_data = 1;  
    else if (self_y_mult_end)
        T1_w_data = q;        
    else
        T1_w_data = alu_T1_w_data;


assign X1_we = alu_X1_we;
assign Y1_we = alu_Y1_we;
assign Z1_we = alu_Z1_we;

always@*
    if (current_move_init_T || current_mult_init_T || current_move_init_inv || self_y_mult_end)
        T1_we = 1;
    else if ((state == SELF_X_MULT) || (state == SELF_Y_MULT) || (state == SUB_X) || (state == SUB_Y))
        T1_we = 0;
    else
        T1_we = alu_T1_we;


// self Reg
assign current_Xself_d0 = (state == READ) && (sys_cnt == 8'd4)   && i_in_valid && o_in_ready;
assign current_Xself_d1 = (state == READ) && (sys_cnt == 8'd5)   && i_in_valid && o_in_ready;
assign current_Xself_d2 = (state == READ) && (sys_cnt == 8'd6)   && i_in_valid && o_in_ready;
assign current_Xself_d3 = (state == READ) && (sys_cnt == 8'd7)   && i_in_valid && o_in_ready;
assign current_Yself_d0 = (state == READ) && (sys_cnt == 8'd8)   && i_in_valid && o_in_ready;
assign current_Yself_d1 = (state == READ) && (sys_cnt == 8'd9)   && i_in_valid && o_in_ready;
assign current_Yself_d2 = (state == READ) && (sys_cnt == 8'd10)  && i_in_valid && o_in_ready;
assign current_Yself_d3 = (state == READ) && (sys_cnt == 8'd11)  && i_in_valid && o_in_ready;



always@*
    if (current_Xself_d0)
        top_Xself_w_data = {i_in_data[DATA_W-2:0], 192'd0};
    else if (current_Xself_d1)
        top_Xself_w_data = {Xself_r_data[254:192], i_in_data[DATA_W-1:0], 128'd0};      
    else if (current_Xself_d2)
        top_Xself_w_data = {Xself_r_data[254:128], i_in_data[DATA_W-1:0], 64'd0};    
    else if (current_Xself_d3)
        top_Xself_w_data = {Xself_r_data[254:64], i_in_data[DATA_W-1:0]};   
    else if (current_self_x_mult)   
        top_Xself_w_data = alu_T1_w_data;
    else if (current_sub_x)
        top_Xself_w_data = alu_T1_w_data;        
    else
        top_Xself_w_data = Xself_r_data;

always@*
    if (current_Yself_d0)
        top_Yself_w_data = {i_in_data[DATA_W-2:0], 192'd0};
    else if (current_Yself_d1)
        top_Yself_w_data = {Yself_r_data[254:192], i_in_data[DATA_W-1:0], 128'd0};      
    else if (current_Yself_d2)
        top_Yself_w_data = {Yself_r_data[254:128], i_in_data[DATA_W-1:0], 64'd0};    
    else if (current_Yself_d3)
        top_Yself_w_data = {Yself_r_data[254:64], i_in_data[DATA_W-1:0]};
    else if (current_self_y_mult)   
        top_Yself_w_data = alu_T1_w_data; 
    else if (current_sub_y)
        top_Yself_w_data = alu_T1_w_data;        
    else
        top_Yself_w_data = Yself_r_data;

always@*
    if (current_move_init_T)
        top_Tself_w_data = Yself_r_data;
    else if (current_mult_init_T)
        top_Tself_w_data = alu_T1_w_data;
    else if (current_move_init_inv)
        top_Tself_w_data = 1;
    else if (current_other_mult && ~other_mult_end)
        top_Tself_w_data = alu_T1_w_data;
    else if (current_r_mult && q_minus_2_current_one && ~r_mult_end)
        top_Tself_w_data = Z1_r_data;
    else if (current_r_mult && ~q_minus_2_current_one && ~r_mult_end)
        top_Tself_w_data = alu_T1_w_data;
    else if (find_inv_end)
        top_Tself_w_data = X1_r_data;
    else if (current_self_x_mult)
        top_Tself_w_data = Y1_r_data;      
    else if (self_y_mult_end) 
        top_Tself_w_data = Xself_r_data;
    else if (sub_x_end) 
        top_Tself_w_data = Yself_r_data;    
    else
        top_Tself_w_data = Tself_r_data;

always@*
    if (current_Xself_d0 || current_Xself_d1 || current_Xself_d2 || current_Xself_d3 || current_self_x_mult || current_sub_x)
        top_Xself_we = 1;
    else
        top_Xself_we = 0;

always@*
    if (current_Yself_d0 || current_Yself_d1 || current_Yself_d2 || current_Yself_d3 || current_self_y_mult || current_sub_y)
        top_Yself_we = 1;
    else
        top_Yself_we = 0;

always@*
    if (current_move_init_T || current_mult_init_T || current_move_init_inv || current_other_mult || current_r_mult || find_inv_end || current_self_x_mult || self_y_mult_end || sub_x_end)
        top_Tself_we = 1;
    else
        top_Tself_we = 0;

assign Xself_w_data = top_Xself_w_data;
assign Yself_w_data = top_Yself_w_data;
assign Tself_w_data = top_Tself_w_data;
assign Xself_we = top_Xself_we;
assign Yself_we = top_Yself_we;
assign Tself_we = top_Tself_we;

// M reg
assign current_M_d0 = (state == READ) && (sys_cnt == 8'd0)  && i_in_valid && o_in_ready;
assign current_M_d1 = (state == READ) && (sys_cnt == 8'd1)  && i_in_valid && o_in_ready;
assign current_M_d2 = (state == READ) && (sys_cnt == 8'd2)  && i_in_valid && o_in_ready;
assign current_M_d3 = (state == READ) && (sys_cnt == 8'd3)  && i_in_valid && o_in_ready;

assign M_shift = ((state == POINT_DOUBLE) && (alu_out_valid && ~m_current_one)) || ((state == POINT_ADD) && (alu_out_valid));


always@*
    if (current_M_d0)
        top_M_w_data = {i_in_data[DATA_W-2:0], 192'd0};
    else if (current_M_d1)
        top_M_w_data = {M_r_data[254:192], i_in_data[DATA_W-1:0], 128'd0};      
    else if (current_M_d2)
        top_M_w_data = {M_r_data[254:128], i_in_data[DATA_W-1:0], 64'd0};    
    else if (current_M_d3)
        top_M_w_data = {M_r_data[254:64], i_in_data[DATA_W-1:0]};    
    else if (M_shift) 
        top_M_w_data = {M_r_data[253:0], M_r_data[254]};    
    else
        top_M_w_data = M_r_data;

always@*
    if (current_M_d0 || current_M_d1 || current_M_d2 || current_M_d3 || M_shift)
        top_M_we = 1;
    else
        top_M_we = 0;

assign M_w_data = top_M_w_data;
assign M_we = top_M_we;

endmodule

module regfile #(
    parameter DATA_W = 64,
    parameter PATN_W = 256,
    parameter IO_CYCLE = PATN_W/DATA_W
)(
    input              clk,
    input              rst,

    input [PATN_W-2:0] X1_w_data,
    input              X1_we,
    input [PATN_W-2:0] Y1_w_data,
    input              Y1_we,
    input [PATN_W-2:0] Z1_w_data,
    input              Z1_we,
    input [PATN_W-2:0] T1_w_data,
    input              T1_we,

    input [PATN_W-2:0] Xself_w_data,
    input              Xself_we,
    input [PATN_W-2:0] Yself_w_data,
    input              Yself_we,
    input [PATN_W-2:0] Tself_w_data,
    input              Tself_we,
    input [PATN_W-2:0] M_w_data,
    input              M_we,    

    output reg [PATN_W-2:0] X1_r_data,
    output reg [PATN_W-2:0] Y1_r_data,
    output reg [PATN_W-2:0] Z1_r_data,
    output reg [PATN_W-2:0] T1_r_data,


    output reg [PATN_W-2:0] Xself_r_data,
    output reg [PATN_W-2:0] Yself_r_data,
    output reg [PATN_W-2:0] Tself_r_data,   
    output reg [PATN_W-2:0] M_r_data    
);

always@(posedge clk)
    if (rst)
        X1_r_data <= 0;                      // Zero point
    else
        if (X1_we)
            X1_r_data <= X1_w_data;
        else
            X1_r_data <= X1_r_data;

always@(posedge clk)
    if (rst)
        Y1_r_data <= 1;                      // Zero point
    else
        if (Y1_we)
            Y1_r_data <= Y1_w_data;
        else
            Y1_r_data <= Y1_r_data;

always@(posedge clk)
    if (rst)
        Z1_r_data <= 1;                      // Zero point
    else
        if (Z1_we)
            Z1_r_data <= Z1_w_data;
        else
            Z1_r_data <= Z1_r_data;

always@(posedge clk)
    if (rst)
        T1_r_data <= 0;                      // Zero point
    else
        if (T1_we)
            T1_r_data <= T1_w_data;
        else
            T1_r_data <= T1_r_data;

always@(posedge clk)
    if (rst)
        Xself_r_data <= 0;
    else
        if (Xself_we)
            Xself_r_data <= Xself_w_data;
        else
            Xself_r_data <= Xself_r_data;

always@(posedge clk)
    if (rst)
        Yself_r_data <= 0;
    else
        if (Yself_we)
            Yself_r_data <= Yself_w_data;
        else
            Yself_r_data <= Yself_r_data;

always@(posedge clk)
    if (rst)
        Tself_r_data <= 0;
    else
        if (Tself_we)
            Tself_r_data <= Tself_w_data;
        else
            Tself_r_data <= Tself_r_data;

always@(posedge clk)
    if (rst)
        M_r_data <= 0;
    else
        if (M_we)
            M_r_data <= M_w_data;
        else
            M_r_data <= M_r_data;
endmodule

module alu(
    input i_clk,
    input i_rst,
    input [254:0] alu_X1,
    input [254:0] alu_Y1,
    input [254:0] alu_Z1,
    input [254:0] alu_T1,

    input [254:0] alu_X2,
    input [254:0] alu_Y2,
    // input [254:0] alu_Z2,
    input [254:0] alu_T2,

    input [2:0] alu_arith_type,
    input alu_in_valid,

    output reg [254:0] alu_write_X1,
    output reg [254:0] alu_write_Y1,
    output reg [254:0] alu_write_Z1,
    output reg [254:0] alu_write_T1,

    output reg alu_X1_we,
    output reg alu_Y1_we,
    output reg alu_Z1_we,
    output reg alu_T1_we,
    output reg alu_out_valid
);

wire [254:0] d;
assign d = 255'h52036cee2b6ffe738cc740797779e89800700a4d4141d8ab75eb4dca135978a3;

wire point_add, point_db, num_mult, scalar_sub, next_point_add, next_point_db;
wire alu_cnt_0, alu_cnt_1, alu_cnt_2, alu_cnt_3, alu_cnt_4, alu_cnt_5, alu_cnt_6, alu_cnt_7, alu_cnt_8, alu_cnt_9, alu_cnt_10; 

wire [2:0] arith_type_w;
reg [2:0] arith_type_r;

wire sec_point_add_w;
reg  sec_point_add_r;

wire sec_point_db_w;
reg  sec_point_db_r;

wire alu_op_w;
wire [1:0] cnt_start;
reg [3:0] alu_cnt_w, alu_cnt_r, alu_next_cnt;

wire mult_i_valid, mult_o_valid;
reg [254:0] add_in1, add_in2, add_out;
reg [254:0] sub_in1, sub_in2, sub_out;
reg [254:0] mult_in1, mult_in2, mult_out_w, mult_out_r;

wire update_reg2;
wire [254:0] X2_w, Y2_w, T2_w;
reg  [254:0] X2_r, Y2_r, T2_r;

assign point_db   = (arith_type_r == 3'b000);
assign point_add  = (arith_type_r == 3'b001);
assign num_mult   = (arith_type_r == 3'b010);
assign scalar_sub = (arith_type_r == 3'b011);
assign next_point_add  = (alu_arith_type == 3'b001);
assign next_point_db   = (alu_arith_type == 3'b000);

assign alu_cnt_0 = (alu_cnt_r == 0);
assign alu_cnt_1 = (alu_cnt_r == 1);
assign alu_cnt_2 = (alu_cnt_r == 2);
assign alu_cnt_3 = (alu_cnt_r == 3);
assign alu_cnt_4 = (alu_cnt_r == 4);
assign alu_cnt_5 = (alu_cnt_r == 5);
assign alu_cnt_6 = (alu_cnt_r == 6);
assign alu_cnt_7 = (alu_cnt_r == 7);
assign alu_cnt_8 = (alu_cnt_r == 8);
assign alu_cnt_9 = (alu_cnt_r == 9);
assign alu_cnt_10 = (alu_cnt_r == 10);

assign arith_type_w = (alu_out_valid) ? alu_arith_type : arith_type_r;
always@(posedge i_clk)
    if (i_rst)
        arith_type_r <= 3'b010;
    else
        arith_type_r <= arith_type_w;

assign sec_point_add_w = (sec_point_add_r) ? 1 : (point_add && alu_cnt_10);
always@(posedge i_clk)
    if (i_rst)
        sec_point_add_r <= 0;
    else
        sec_point_add_r <= sec_point_add_w;

//////////////////////////// Double //////////////////////////
assign sec_point_db_w = (sec_point_db_r) ? 1 : (point_db && alu_cnt_9);
always@(posedge i_clk)
    if (i_rst)
        sec_point_db_r <= 0;
    else
        sec_point_db_r <= sec_point_db_w;


assign cnt_start = (sec_point_add_r && next_point_add) ? 2 :
                   (sec_point_db_r && next_point_db)   ? 1 : 0;



assign alu_op_w = (alu_cnt_0) ? (alu_in_valid) : 1;
assign alu_next_cnt = alu_cnt_r + alu_op_w;

always@* begin
    if (point_add)
        alu_cnt_w = (alu_cnt_10) ? cnt_start : alu_next_cnt;
    else if (point_db) 
        alu_cnt_w = (alu_cnt_9)  ? cnt_start : alu_next_cnt;
    else if (num_mult) 
        alu_cnt_w = (alu_cnt_1)  ? cnt_start : alu_next_cnt;
    else
        alu_cnt_w = 0;
end

always@(posedge i_clk)
    if (i_rst)
        alu_cnt_r <= 0;
    else
        alu_cnt_r <= alu_cnt_w;

//////////////////////////// Find Inv //////////////////////////
reg [8:0] inv_cnt, inv_cnt_w;
reg [2:0] inv_state, n_inv_state;
parameter [2:0] INV_IDLE = 3'd0, INV_INIT = 3'd1, INV_FORWARD = 3'd2, INV_BACK = 3'd3, INV_POST = 3'd4;
wire inv_init_end, inv_forward_end, inv_back_end, inv_post_end;

               
always@*
    case(inv_state)
        INV_IDLE:
            if ((alu_arith_type == 3'd4) && alu_out_valid)
                n_inv_state = INV_INIT;
            else
                n_inv_state = INV_IDLE;

        INV_INIT:
            if (inv_init_end)
                n_inv_state = INV_FORWARD;
            else
                n_inv_state = INV_INIT;
        INV_FORWARD:
            if (inv_forward_end)
                n_inv_state = INV_BACK;  
            else
                n_inv_state = INV_FORWARD;  

        INV_BACK:
            if (inv_back_end)
                n_inv_state = INV_POST;  
            else
                n_inv_state = INV_BACK;

        INV_POST:
            if (inv_post_end)
                n_inv_state = INV_IDLE;  
            else
                n_inv_state = INV_POST;      
        default: n_inv_state = inv_state;
    endcase

always@(posedge i_clk)
    if (i_rst)
        inv_state <= 0;
    else
        inv_state <= n_inv_state;

always@(posedge i_clk)
    if (i_rst)
        inv_cnt <= 0;
    else
        if (inv_init_end || inv_forward_end || inv_back_end || inv_post_end)
            inv_cnt <= 0;
        else if (arith_type_r == 3'd4)
            inv_cnt <= inv_cnt + 1'b1;
        else
            inv_cnt <= inv_cnt;

assign inv_init_end    = (inv_state == INV_INIT);                             // Z1 -> T1
assign inv_forward_end = (inv_state == INV_FORWARD) && (inv_cnt == 9'd500);
assign inv_back_end    = (inv_state == INV_BACK)    && (inv_cnt == 9'd9);
assign inv_post_end    = (inv_state == INV_POST)    && (inv_cnt == 9'd3);


assign current_inv_init             = (inv_state == INV_INIT);
assign current_inv_forward_odd      = (inv_state == INV_FORWARD) && ( inv_cnt[0]);
assign current_inv_forward_even     = (inv_state == INV_FORWARD) && (~inv_cnt[0]);
assign current_inv_forward_even_ex0 = current_inv_forward_even   && (inv_cnt != 9'd0);


assign current_inv_forward_move_z3  = (inv_state == INV_FORWARD) && (inv_cnt == 9'd4);
assign current_inv_forward_move_z8  = (inv_state == INV_FORWARD) && (inv_cnt == 9'd5);

assign current_inv_back_odd         = (inv_state == INV_BACK) && ( inv_cnt[0]);
assign current_inv_back_even        = (inv_state == INV_BACK) && (~inv_cnt[0]);

assign current_inv_post_mult_z11     = (inv_state == INV_POST) && (inv_cnt == 9'd0);
assign current_inv_post_store_z11    = (inv_state == INV_POST) && (inv_cnt == 9'd1);
assign current_inv_post_mult_result  = (inv_state == INV_POST) && (inv_cnt == 9'd2);
assign current_inv_post_store_result = (inv_state == INV_POST) && (inv_cnt == 9'd3);

// add_in
always@* begin
    if (point_add)begin
        if (alu_cnt_0) begin
            add_in1 = alu_Y2;
            add_in2 = alu_X2;
        end else if (alu_cnt_2) begin
            add_in1 = alu_Y1;
            add_in2 = alu_X1;
        end else if (alu_cnt_3) begin
            add_in1 = alu_Z1;
            add_in2 = alu_Z1;
        end else if (alu_cnt_4) begin
            add_in1 = mult_out_r;
            add_in2 = mult_out_r;
        end else if (alu_cnt_5) begin
            add_in1 = alu_Z1;
            add_in2 = alu_T1;
        end else if (alu_cnt_6) begin
            add_in1 = mult_out_r;
            add_in2 = alu_X1;
        end else begin
            add_in1 = 0;
            add_in2 = 0;
        end
    end else if (point_db) begin
        if (alu_cnt_1) begin
            add_in1 = alu_X1;
            add_in2 = alu_Y1;
        end else if (alu_cnt_2) begin
            add_in1 = mult_out_r;
            add_in2 = mult_out_r;
        end else if (alu_cnt_4) begin
            add_in1 = alu_X1;
            add_in2 = mult_out_r;
        end else if (alu_cnt_5) begin
            add_in1 = alu_T1;
            add_in2 = alu_Y1;
        end else begin
            add_in1 = 0;
            add_in2 = 0;
        end
    end else begin
        add_in1 = 0;
        add_in2 = 0;
    end
end

// sub_in
always@* begin
    if (point_add)begin
        if (alu_cnt_0) begin
            sub_in1 = alu_Y2;
            sub_in2 = alu_X2;
        end else if (alu_cnt_2) begin
            sub_in1 = alu_Y1;
            sub_in2 = alu_X1;
        end else if (alu_cnt_5) begin
            sub_in1 = alu_Z1;
            sub_in2 = alu_T1;
        end else if (alu_cnt_6) begin
            sub_in1 = mult_out_r;
            sub_in2 = alu_X1;
        end else begin
            sub_in1 = 0;
            sub_in2 = 0;
        end
    end else if (point_db) begin
        if (alu_cnt_4) begin
            sub_in1 = alu_X1;
            sub_in2 = mult_out_r;
        end else if (alu_cnt_5) begin
            sub_in1 = alu_Z1;
            sub_in2 = mult_out_r;
        end else begin
            sub_in1 = 0;
            sub_in2 = 0;
        end
    end else if (scalar_sub) begin
        sub_in1 = alu_T1;
        sub_in2 = alu_T2;
    end else begin
        sub_in1 = 0;
        sub_in2 = 0;
    end
end

// mult_in
always@* begin
    if (point_add)begin
        if (alu_cnt_0) begin
            mult_in1 = alu_T2;
            mult_in2 = d;
        end else if (alu_cnt_2) begin
            mult_in1 = alu_T1;
            mult_in2 = T2_r;
        end else if (alu_cnt_3) begin
            mult_in1 = alu_X1;
            mult_in2 = X2_r;
        end else if (alu_cnt_4) begin
            mult_in1 = alu_Y1;
            mult_in2 = Y2_r;
        end else if (alu_cnt_6) begin
            mult_in1 = alu_Y1;
            mult_in2 = alu_Z1;
        end else if (alu_cnt_7) begin
            mult_in1 = alu_Z1;
            mult_in2 = alu_X1;
        end else if (alu_cnt_8) begin
            mult_in1 = alu_T1;
            mult_in2 = alu_Y1;
        end else if (alu_cnt_9) begin
            mult_in1 = alu_T1;
            mult_in2 = alu_X1;

        end else if (alu_cnt_10) begin
            mult_in1 = alu_Z1;
            mult_in2 = alu_Z1;

        end else begin
            mult_in1 = 0;
            mult_in2 = 0;
        end
    end else if (point_db) begin
        if (alu_cnt_0) begin
            mult_in1 = alu_Z1;
            mult_in2 = alu_Z1;
        end else if (alu_cnt_1) begin
            mult_in1 = alu_X1;
            mult_in2 = alu_X1;
        end else if (alu_cnt_2) begin
            mult_in1 = alu_Y1;
            mult_in2 = alu_Y1;
        end else if (alu_cnt_3) begin
            mult_in1 = alu_Z1;
            mult_in2 = alu_Z1;
        end else if (alu_cnt_5) begin
            mult_in1 = alu_Y1;
            mult_in2 = alu_Z1;
        end else if (alu_cnt_6) begin
            mult_in1 = alu_T1;
            mult_in2 = alu_Y1;
        end else if (alu_cnt_7) begin
            mult_in1 = alu_X1;
            mult_in2 = alu_Z1;
        end else if (alu_cnt_8) begin
            mult_in1 = alu_X1;
            mult_in2 = alu_T1;

        end else if (alu_cnt_9) begin
            mult_in1 = alu_Z1;
            mult_in2 = alu_Z1;   

        end else begin
            mult_in1 = 0;
            mult_in2 = 0;
        end
    end else if (num_mult) begin
        mult_in1 = alu_T1;
        mult_in2 = alu_T2;
    
    end else if (current_inv_forward_even) begin
        mult_in1 = alu_T1;
        mult_in2 = alu_T1;      
    end else if (current_inv_forward_odd) begin
        mult_in1 = alu_T1;
        mult_in2 = T2_r;   
    end else if (current_inv_back_even) begin
        mult_in1 = T2_r;
        mult_in2 = T2_r;    
    end else if (current_inv_post_mult_z11) begin
        mult_in1 = X2_r;
        mult_in2 = Y2_r;    
    end else if (current_inv_post_mult_result) begin  
        mult_in1 = T2_r;
        mult_in2 = alu_T1;                  
    end else begin
        mult_in1 = 0;
        mult_in2 = 0;
    end
end

mod_add u_mod_add(
    .A(add_in1),
    .B(add_in2),
    .add_out(add_out)
);

mod_sub u_mod_sub(
    .A(sub_in1),
    .B(sub_in2),
    .sub_out(sub_out)
);

mod_mult u_mod_mult(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .A(mult_in1),
    .B(mult_in2),
    .result_w(mult_out_w),
    .result_r(mult_out_r)
);

// X2_r, Y2_r, T2_r
assign update_reg2 = (point_add && alu_cnt_0);

// assign X2_w = (update_reg2) ? sub_out  : X2_r;
assign X2_w = (update_reg2) ?                 sub_out  :
              (current_inv_forward_move_z3) ? mult_out_w : X2_r;

// assign Y2_w = (update_reg2) ? add_out  : Y2_r;
assign Y2_w = (update_reg2) ?                 add_out  : 
              (current_inv_forward_move_z8) ? mult_out_w : Y2_r;

// assign T2_w = (point_add && alu_cnt_1) ? mult_out_w : T2_r;
assign T2_w = (point_add && alu_cnt_1)       ? mult_out_w : 
              (current_inv_init)             ? 255'd1     : 
              (current_inv_back_odd)         ? mult_out_w :
              (current_inv_forward_even_ex0) ? mult_out_w : T2_r;

always@(posedge i_clk)
    if (i_rst)
        X2_r <= 0;
    else
        X2_r <= X2_w;

always@(posedge i_clk)
    if (i_rst)
        Y2_r <= 0;
    else
        Y2_r <= Y2_w;

always@(posedge i_clk)
    if (i_rst)
        T2_r <= 0;
    else
        T2_r <= T2_w;

// output
// alu_write_X1, alu_X1_we
always@* begin
    if (point_add)begin
        if (alu_cnt_2) 
            alu_write_X1 = sub_out;
        else if ((alu_cnt_4) || (alu_cnt_9)) 
            alu_write_X1 = mult_out_w;
        else if (alu_cnt_6) 
            alu_write_X1 = add_out;
        else
            alu_write_X1 = 0;
    end else if (point_db) begin
        if ((alu_cnt_2) || (alu_cnt_9))
            alu_write_X1 = mult_out_w;
        else if (alu_cnt_5)
            alu_write_X1 = sub_out;
        else
            alu_write_X1 = 0;
    end else 
        alu_write_X1 = 0;
end
always@* begin
    if (point_add)
        alu_X1_we = ((alu_cnt_2) || (alu_cnt_4) || (alu_cnt_6) || (alu_cnt_9));
    else if (point_db) 
        alu_X1_we = ((alu_cnt_2) || (alu_cnt_5) || (alu_cnt_9));
    else 
        alu_X1_we = 0;
end

// alu_write_Y1, alu_Y1_we
always@* begin
    if (point_add)begin
        if (alu_cnt_2) 
            alu_write_Y1 = add_out;
        else if (alu_cnt_5) 
            alu_write_Y1 = sub_out;
        else if (alu_cnt_8) 
            alu_write_Y1 = mult_out_w;
        else
            alu_write_Y1 = 0;
    end else if (point_db) begin
        if (alu_cnt_4)
            alu_write_Y1 = sub_out;
        else if (alu_cnt_6)
            alu_write_Y1 = mult_out_w;
        else
            alu_write_Y1 = 0;
    end else
        alu_write_Y1 = 0;
end
always@* begin
    if (point_add)
        alu_Y1_we = ((alu_cnt_2) || (alu_cnt_5) || (alu_cnt_8));
    else if (point_db) 
        alu_Y1_we = (alu_cnt_4) || (alu_cnt_6);
    else 
        alu_Y1_we = 0;
end

// alu_write_Z1, alu_Z1_we
always@* begin
    if (point_add)begin
        if ((alu_cnt_3) || (alu_cnt_5)) 
            alu_write_Z1 = add_out;
        else if (alu_cnt_7)
            alu_write_Z1 = mult_out_w;
        else
            alu_write_Z1 = 0;
    end else if (point_db) begin
        if ((alu_cnt_1) || (alu_cnt_4))
            alu_write_Z1 = add_out;
        else if (alu_cnt_7)
            alu_write_Z1 = mult_out_w;
        else
            alu_write_Z1 = 0;
    end else 
        alu_write_Z1 = 0;
end
always@* begin
    if (point_add)
        alu_Z1_we = ((alu_cnt_3) || (alu_cnt_5) || (alu_cnt_7));
    else if (point_db) 
        alu_Z1_we = ((alu_cnt_1) || (alu_cnt_4) || (alu_cnt_7));
    else 
        alu_Z1_we = 0;
end

// alu_write_T1, alu_T1_we
always@* begin
    if (point_add)begin
        if (alu_cnt_4) 
            alu_write_T1 = add_out;
        else if (alu_cnt_6) 
            alu_write_T1 = sub_out;
        else if (alu_cnt_10)
            alu_write_T1 = mult_out_w;
        else
            alu_write_T1 = 0;
    end else if (point_db) begin
        if ((alu_cnt_2) || (alu_cnt_5))
            alu_write_T1 = add_out;
        else if (alu_cnt_8)
            alu_write_T1 = mult_out_w;
        else
            alu_write_T1 = 0;
    end else if (num_mult) begin
            alu_write_T1 = mult_out_w;
    end else if (scalar_sub) begin
            alu_write_T1 = sub_out;

    end else if (current_inv_init) begin
        alu_write_T1 = alu_Z1;

    end else if (current_inv_forward_odd) begin
        alu_write_T1 = mult_out_w;
    end else if (current_inv_post_store_z11) begin
        alu_write_T1 = mult_out_w;
    end else if (current_inv_post_store_result) begin
        alu_write_T1 = mult_out_w;        
    end else 
        alu_write_T1 = 0;
end
always@* begin
    if (point_add)
        alu_T1_we = ((alu_cnt_4) || (alu_cnt_6) || (alu_cnt_10));
    else if (point_db) 
        alu_T1_we = ((alu_cnt_2) || (alu_cnt_5) || (alu_cnt_8));
    else if (num_mult) 
        alu_T1_we = (alu_cnt_1);
    else if (scalar_sub)
        alu_T1_we = (alu_cnt_0);
    
    else if (current_inv_init)
        alu_T1_we = 1;
    else if (current_inv_forward_odd)
        alu_T1_we = 1;
    else if (current_inv_post_store_z11)
        alu_T1_we = 1;        
    else if (current_inv_post_store_result)
        alu_T1_we = 1;                
    else 
        alu_T1_we = 0;
end

always@* begin
    if (point_add)
        alu_out_valid = (alu_cnt_10);
    else if (point_db) 
        alu_out_valid = (alu_cnt_9);
    else if (num_mult) 
        alu_out_valid = (alu_cnt_1);
    else if (scalar_sub)
        alu_out_valid = (alu_cnt_0);
    else if (inv_post_end)
        alu_out_valid = 1;        
    else
        alu_out_valid = 0;
end

endmodule


module mod_add(
    input [254:0] A,
    input [254:0] B,
    output [254:0] add_out
);
wire [254:0] q;
assign q = 255'b111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101101;

wire [255:0] temp;

assign temp = A + B;
assign add_out = (temp > q) ? (temp - q) : temp;

endmodule


module mod_sub(
    input [254:0] A,
    input [254:0] B,
    output [254:0] sub_out
);
wire [254:0] q;
assign q = 255'b111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101101;

wire [254:0] temp, minus;
wire A_larger;

assign A_larger = (A > B);
assign temp = (A_larger) ? A : q; 
assign minus = temp - B;
assign sub_out = (A_larger) ? minus : A + minus;

endmodule


module mod_mult(
    input i_clk,
    input i_rst,
    input [254:0] A,
    input [254:0] B,
    output reg[254:0] result_w,
    output reg [254:0] result_r
);
wire [254:0] q;
assign q = 255'b111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101101;

wire [127:0] A1, A2;
wire [127:0] B1, B2;
wire [128:0] A1_add_A2, B1_add_B2;

reg [255:0] H, L;
reg [257:0] M;
reg i_valid_d1;

wire [260:0] M_sub_H;
wire [260:0] M_sub_H_sub_L;
reg [390:0] C1;
reg [265:0] CH;
reg i_valid_d2;

reg [391:0] T;

wire [136:0] TH;
wire [254:0] T1;
reg [255:0] T2;

// Stage 1
assign A1 = A[127:0];
assign A2 = {1'b0, A[254:128]};

assign B1 = B[127:0];
assign B2 = {1'b0, B[254:128]};

assign A1_add_A2 = A1 + A2;
assign B1_add_B2 = B1 + B2;

always@(posedge i_clk)
    if (i_rst)
        H <= 0;
    else
        H <= (A2 * B2);

always@(posedge i_clk)
    if (i_rst)
        L <= 0;
    else
        L <= (A1 * B1);

always@(posedge i_clk)
    if (i_rst)
        M <= 0;
    else
        M <= A1_add_A2 * B1_add_B2;

// Stage 2
assign M_sub_H = M - H;
assign M_sub_H_sub_L = M_sub_H - L;

always@*
    CH = (38*H) + L;

always@*
    C1 = M_sub_H_sub_L << 128;

always@*
    T = CH + C1;

assign TH = T[391:255];
assign T1 = T[254:0];

always@*
    T2 = TH*19 + T1;

always@*
    result_w = (T2 > q) ? T2 - q : T2;

always@(posedge i_clk)
    if (i_rst)
        result_r <= 0;
    else
        result_r <= result_w;

endmodule
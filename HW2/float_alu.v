module float_alu #( 
    parameter DATA_WIDTH = 32
) ( 
    output reg signed [DATA_WIDTH-1:0] alu_out, 
    input      signed [DATA_WIDTH-1:0] data_r1,
    input      signed [DATA_WIDTH-1:0] data_r2,
    input             [5:0]            op,
    output reg                         alu_nan
);

wire signed [DATA_WIDTH-1:0] fadd_out, flw_out, fsw_out, fclass_out, flt_out;
reg alu_nan_fadd, alu_nan_flt;


// ------------------------------------------------------------ Fadd / Fsub ----------------------------------------------------------------
// Classify Numbers (0: Nor, 1: Subnor, 2: Zero, 3: NaN or Inf)
localparam NOR = 2'd0, SUBNOR = 2'd1, ZERO = 2'd2, INV = 2'd3;
reg [1:0] r1_class;
reg [1:0] r2_class;
always@*
    if(data_r1[30:23] == 8'b1111_1111)                   
        r1_class = INV;                                      // NaN or Inf
    else if (data_r1[30:23] == 8'b0000_0000)
        if (|data_r1[22:0]) 
            r1_class = SUBNOR;                               // Subnor
        else
            r1_class = ZERO;                                 // Zero
    else
        r1_class = NOR;                                      // Nor
        
always@*
    if(data_r2[30:23] == 8'b1111_1111)                   
        r2_class = INV;                                      // NaN or Inf
    else if (data_r2[30:23] == 8'b0000_0000)
        if (|data_r2[22:0]) 
            r2_class = SUBNOR;                               // Subnor
        else
            r2_class = ZERO;                                 // Zero
    else
        r2_class = NOR;                                      // Nor


// Real Value (1.1.23) (All Pos)
// reg signed [25-1:0] r1_unshift;
// reg signed [25-1:0] r2_unshift;
reg signed [25+(254)-1:0] r1_unshift;
reg signed [25+(254)-1:0] r2_unshift;

always@*
    if (r1_class == SUBNOR)                                                   // $r1: Subnormal 
        // r1_unshift = {1'b0, 1'b0, data_r1[22:0]};\
        r1_unshift = {254'd0, 1'b0, 1'b0, data_r1[22:0]};
    else if (r1_class == NOR)                                                 // $r1: Normal 
        // r1_unshift = {1'b0, 1'b1, data_r1[22:0]};
        r1_unshift = {254'd0, 1'b0, 1'b1, data_r1[22:0]};
    else
        // r1_unshift = 32'd0;       
        r1_unshift = 279'd0; 

always@*
    if (r2_class == SUBNOR)                                                   // $r2: Subnormal 
        // r2_unshift = {1'b0, 1'b0, data_r2[22:0]};
        r2_unshift = {254'd0, 1'b0, 1'b0, data_r2[22:0]};
    else if (r2_class == NOR)                                                 // $r2: Normal 
        // r2_unshift = {1'b0, 1'b1, data_r2[22:0]};
        r2_unshift = {254'd0, 1'b0, 1'b1, data_r2[22:0]};        
    else
        // r2_unshift = 32'd0;    
        r2_unshift = 279'd0;    


// Shift Value 
reg signed [25+(254)-1:0] r1_shift;                                           // Don't Consider shift 255
reg signed [25+(254)-1:0] r2_shift;
always@*
    if (r1_class == SUBNOR)                                                   // $r1: Subnormal 
        r1_shift = r1_unshift << 1'b1;
    else if (r1_class == NOR)                                                 // $r1: Normal 
        r1_shift = r1_unshift << data_r1[30:23];    
    else                                                                  
        // r1_shift = 32'd0;
        r1_shift = 279'd0; 

always@*
    if (r2_class == SUBNOR)                                                   // $r2: Subnormal 
        r2_shift = r2_unshift << 1'b1;
    else if (r2_class == NOR)                                                 // $r2: Normal 
        r2_shift = r2_unshift << data_r2[30:23];    
    else                                                                  
        // r2_shift = 32'd0;   
        r2_shift = 279'd0;  

// Aligned Addition (fixed-point 2's comp)
reg signed [25+(254):0] aligned_add_result;
// reg signed [25+(254)+1:0] aligned_add_result_w;
// wire signed [25+(254):0] aligned_add_result;
always@*
    if(op[5])                                                                  // $f1 + f2
        case({data_r1[DATA_WIDTH-1], data_r2[DATA_WIDTH-1]})
            2'b00: aligned_add_result =  r1_shift + r2_shift;                  // Pos + Pos
            2'b01: aligned_add_result =  r1_shift - r2_shift;                  // Pos + Neg
            2'b10: aligned_add_result = -r1_shift + r2_shift;                  // Neg + Pos
            2'b11: aligned_add_result = -r1_shift - r2_shift;                  // Neg + Neg
            default: aligned_add_result = 0;
        endcase
    else                                                                       // $f1 - f2
        case({data_r1[DATA_WIDTH-1], data_r2[DATA_WIDTH-1]})
            2'b00: aligned_add_result =  r1_shift - r2_shift;                  // Pos - Pos
            2'b01: aligned_add_result =  r1_shift + r2_shift;                  // Pos - Neg
            2'b10: aligned_add_result = -r1_shift - r2_shift;                  // Neg - Pos
            2'b11: aligned_add_result = -r1_shift + r2_shift;                  // Neg - Neg
            default: aligned_add_result = 0;
        endcase    

// assign aligned_add_result = aligned_add_result_w[279:0];

// Convert fixed-point 2's comp to sign&mag
wire signed [25+(254):0] inverted_add_result;                                  // Invert 2's comp result
reg signed [25+(254):0] signed_and_mag_add_result;
assign inverted_add_result = -aligned_add_result;
always@*
    if(~aligned_add_result[279])                                                // Pos Result
        signed_and_mag_add_result = {1'b0, aligned_add_result[278:0]};
    else                                                                        // Neg Result
        signed_and_mag_add_result = {1'b1, inverted_add_result[278:0]};        

// wire [7:0] r1_exp, r2_exp;
// assign r1_exp = data_r1[30:23];
// assign r2_exp = data_r2[30:23];

// Determine larger Exp 
reg [9:0] larger_exp;
always@*
    if (data_r1[30:23] > data_r2[30:23])                                      // E1 > E2
        larger_exp = {2'd0, data_r1[30:23]};
    else                                                                      // E1 <= E2
        larger_exp = {2'd0, data_r2[30:23]};   

// Determine post-shift type (0: M>2, 1: 1<M<2, 2: M<1)
wire [8:0] int_bit_msb_loc;
// wire [8:0] int_bit_lsb_loc;
reg signed [1:0] add_result_int;
reg [1:0] post_shift_type;
assign int_bit_msb_loc = larger_exp + 5'd24;
// assign int_bit_lsb_loc = larger_exp + 5'd23; 
always@*
    add_result_int = signed_and_mag_add_result[int_bit_msb_loc -: 2];

always@*
    if (add_result_int >= 2'd2)
        post_shift_type = 2'd0;
    else if (add_result_int == 2'd0)
        post_shift_type = 2'd2;
    else
        post_shift_type = 2'd1;        


// CLZ for type 2
reg [9:0] num_of_zeros_tmp [0:279];
reg [10:0] num_of_zeros_tmp_ext [0:279];
reg one_before [0:279];
reg [9:0] zero_after_M;
integer i;

always@* begin
    one_before[279] = 0;
    num_of_zeros_tmp[279] = 0;
    for (i = 279-1; i >= 0; i = i-1) begin
        num_of_zeros_tmp_ext[i] = num_of_zeros_tmp[i+1] + (~signed_and_mag_add_result[i] && ~one_before[i+1]);
        num_of_zeros_tmp[i] = num_of_zeros_tmp_ext[i][9:0];
        one_before[i] = ~(~signed_and_mag_add_result[i] && ~one_before[i+1]);
    end
end

always@*
    zero_after_M = num_of_zeros_tmp[0] - (8'd255 - larger_exp);

// New Exp                           ----------------------------------------(May overflow?)--------------------------------------
reg [9:0] new_exp;
// reg [10:0] new_exp_w;
always@*
    case(post_shift_type)
        2'd0: new_exp = larger_exp + 1'b1;
        2'd1: new_exp = larger_exp;
        2'd2: 
            if (larger_exp >= zero_after_M) 
                new_exp = larger_exp - zero_after_M;
            else
                new_exp = 0;          
        default: new_exp = 11'd0;
    endcase

// assign new_exp = new_exp_w;

// Rounding and select new M
reg [22:0] new_M_nor;
reg [22:0] new_M_sub;
wire signed [25+(254):0] signed_and_mag_add_result_round;
reg signed [25+(254)+1:0] signed_and_mag_add_result_round_w;
reg signed [25+(254):0] rounding_shift;
reg signed [25+(254):0] signed_and_mag_add_result_shift;
reg guard_bit;
reg round_bit;
reg [8:0] guard_bit_loc;
reg [8:0] round_bit_loc;
reg [8:0] sticky_bit_msb_loc;
wire [8:0] m_bit_msb_loc, m_bit_msb_loc_sub;
wire [8:0] sticky_bit_shift_value;
wire [22:0] orig_M;
reg sticky_bit;

always@* begin
    guard_bit_loc = new_exp;
    round_bit_loc = new_exp - 1'b1; 
    sticky_bit_msb_loc = new_exp - 2'd2; 
end
assign sticky_bit_shift_value = (9'd279 - sticky_bit_msb_loc);
assign m_bit_msb_loc = new_exp + 5'd22; 
assign m_bit_msb_loc_sub = new_exp + 5'd23;

assign orig_M = signed_and_mag_add_result[m_bit_msb_loc -: 23];

always@* begin
    rounding_shift = 1'b1 << round_bit_loc;
    signed_and_mag_add_result_round_w = signed_and_mag_add_result + rounding_shift;
    signed_and_mag_add_result_shift = signed_and_mag_add_result << sticky_bit_shift_value;
end

assign signed_and_mag_add_result_round = signed_and_mag_add_result_round_w[279:0];

always@* begin
    guard_bit = signed_and_mag_add_result[guard_bit_loc];
    if (new_exp >= 9'd1)
        round_bit = signed_and_mag_add_result[round_bit_loc];
    else
        round_bit = 0;    
    if (new_exp >= 9'd2)        
        sticky_bit = |signed_and_mag_add_result_shift;
    else
        sticky_bit = 0;
end

// Normal Number M
always@*                                                                    
    if (~round_bit)                                                            // X.0XXX
        new_M_nor = signed_and_mag_add_result[m_bit_msb_loc -: 23];
    else if (round_bit && sticky_bit)                                          // X.1YYY (|YYY != 0)
        new_M_nor = signed_and_mag_add_result_round[m_bit_msb_loc -: 23];
    else if (~guard_bit && ~sticky_bit)                                        // 0.1000 
        new_M_nor = signed_and_mag_add_result[m_bit_msb_loc -: 23];
    else                                                                       // 1.1000
        new_M_nor = signed_and_mag_add_result_round[m_bit_msb_loc -: 23];

// Subnormal Number M
always@*                                                                       
    if (~round_bit)                                                            // X.0XXX
        new_M_sub = signed_and_mag_add_result[m_bit_msb_loc_sub -: 23];
    else if (round_bit && sticky_bit)                                          // X.1YYY (|YYY != 0)
        new_M_sub = signed_and_mag_add_result_round[m_bit_msb_loc_sub -: 23];
    else if (~guard_bit && ~sticky_bit)                                        // 0.1000 
        new_M_sub = signed_and_mag_add_result[m_bit_msb_loc_sub -: 23];
    else                                                                       // 1.1000
        new_M_sub = signed_and_mag_add_result_round[m_bit_msb_loc_sub -: 23];


// Classify Numbers (0: Nor, 1: Subnor, 2: Zero, 3: NaN or Inf)
reg [1:0] rd_class;
always@*
    if(new_exp[7:0] == 8'b1111_1111)                   
        rd_class = INV;                                      // NaN or Inf
    else if (new_exp[7:0] == 8'b0000_0000)
        if (|new_M_sub) 
            rd_class = SUBNOR;                               // Subnor
        else
            rd_class = ZERO;                                 // Zero
    else
        rd_class = NOR;                                      // Nor

// Consider the case when rounding cause EXP + 1
wire [8:0] new_exp_rounding;
assign new_exp_rounding = new_exp + 1'b1;

// Add Result
reg [DATA_WIDTH-1:0] fadd_out_tmp;
always@*
    if (r1_class == INV || r2_class == INV)                         // NaN or Inf as operand
        fadd_out_tmp = 32'd0;
    else if (rd_class == INV)                                       // Inf
        fadd_out_tmp = {signed_and_mag_add_result[279], 8'hff, 23'd0};
    else if (rd_class == SUBNOR)
        fadd_out_tmp = {signed_and_mag_add_result[279], new_exp[7:0], new_M_sub};  
    else if ((orig_M == 23'h7fffff) && (new_M_nor == 23'd0))
        fadd_out_tmp = {signed_and_mag_add_result[279], new_exp_rounding[7:0], 23'd0};        
    else if ((orig_M == 23'h7fffff) && (new_M_sub == 23'd0))
        fadd_out_tmp = {signed_and_mag_add_result[279], new_exp_rounding[7:0], 23'd0};            
    else                                        
        fadd_out_tmp = {signed_and_mag_add_result[279], new_exp[7:0], new_M_nor};            

assign fadd_out = fadd_out_tmp;

always@*
    if (r1_class == INV || r2_class == INV)                         // NaN or Inf as operand
        alu_nan_fadd = 1;
    else if (new_exp == 8'b1111_1111)                               // NaN or Inf as add result
        alu_nan_fadd = 1;
    else                                                           
        alu_nan_fadd = 0;   


// --------------------------------------------------------------------- Flw --------------------------------------------------------------------

assign flw_out = 0;

// --------------------------------------------------------------------- Fsw --------------------------------------------------------------------

assign fsw_out = 0;

// --------------------------------------------------------------------- Fclass --------------------------------------------------------------------
reg [31:0] fclass_out_tmp;
always@*
    case(data_r1[30:23])
        8'b1111_1111:
            if (|data_r1[22:0])                                                 // NaN
                fclass_out_tmp = 32'd8;
            else if (~data_r1[31])                                              // Pos Inf
                fclass_out_tmp = 32'd7;
            else                                                                // Neg Inf
                fclass_out_tmp = 32'd0;
        
        8'b0000_0000:
            if (~data_r1[31] && (|data_r1[22:0]))                               // Pos Subnormal
                fclass_out_tmp = 32'd5;
            else if (data_r1[31] && (|data_r1[22:0]))                           // Neg Subnormal
                fclass_out_tmp = 32'd2;
            else if (~data_r1[31])                                              // Pos Zero
                fclass_out_tmp = 32'd4;
            else                                                                // Neg Zero
                fclass_out_tmp = 32'd3;            
        default:
            if (~data_r1[31])                                                   // Pos Normal
                fclass_out_tmp = 32'd6;
            else                                                                // Neg Normal
                fclass_out_tmp = 32'd1;                

    endcase

assign fclass_out = fclass_out_tmp;

// --------------------------------------------------------------------- Flt --------------------------------------------------------------------
reg [31:0] flt_out_tmp;
always@*
    if (r1_class == INV || r2_class == INV)                                      // NaN or Inf
        flt_out_tmp = 32'd0;
    else if (r1_class == ZERO && r2_class == ZERO)                               // +0 and -0 are equal?
        flt_out_tmp = 32'd0;
    else if (~data_r1[DATA_WIDTH-1] && data_r2[DATA_WIDTH-1])                    // $r1: Pos $r2: Neg
        flt_out_tmp = 32'd0;
    else if (data_r1[DATA_WIDTH-1] && ~data_r2[DATA_WIDTH-1])                    // $r1: Neg $r2: Pos
        flt_out_tmp = 32'd1;
    else if (~data_r1[DATA_WIDTH-1] && ~data_r2[DATA_WIDTH-1])                   // $r1: Pos $r2: Pos
        if (data_r1[30:23] > data_r2[30:23])                                    
            flt_out_tmp = 32'd0;
        else if (data_r1[30:23] < data_r2[30:23])
            flt_out_tmp = 32'd1;
        else 
            if(data_r1[22:0] > data_r2[22:0])
                flt_out_tmp = 32'd0;
            else if (data_r1[22:0] < data_r2[22:0])
                flt_out_tmp = 32'd1;
            else
                flt_out_tmp = 32'd0;
    else                                                                         // $r1: Neg $r2: Neg            
        if (data_r1[30:23] > data_r2[30:23])                                    
            flt_out_tmp = 32'd1;
        else if (data_r1[30:23] < data_r2[30:23])
            flt_out_tmp = 32'd0;
        else 
            if(data_r1[22:0] > data_r2[22:0])
                flt_out_tmp = 32'd1;
            else if (data_r1[22:0] < data_r2[22:0])
                flt_out_tmp = 32'd0;
            else
                flt_out_tmp = 32'd0;

assign flt_out = flt_out_tmp;

always@*
    if (r1_class == INV || r2_class == INV)                                      // NaN or Inf
        alu_nan_flt = 1;
    else
        alu_nan_flt = 0;

// Nan or Inf Flag Selection
always@*
    case({op[5:4], op[0]})
        3'b100:  alu_nan = alu_nan_fadd;
        3'b010:  alu_nan = alu_nan_fadd;
        3'b001:  alu_nan = alu_nan_flt;
        default: alu_nan = 0;
    endcase


// Output Selection
always@*
    case(op)
        6'b10_0000: alu_out = fadd_out;
        6'b01_0000: alu_out = fadd_out;
        6'b00_1000: alu_out = flw_out;
        6'b00_0100: alu_out = fsw_out;
        6'b00_0010: alu_out = fclass_out;
        6'b00_0001: alu_out = flt_out;
        default:    alu_out = 0;     
    endcase

endmodule
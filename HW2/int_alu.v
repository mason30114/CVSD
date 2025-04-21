module int_alu #( 
    parameter DATA_WIDTH = 32
) ( 
    output reg signed [DATA_WIDTH-1:0] alu_out, 
    input      signed [DATA_WIDTH-1:0] data_r1,
    input      signed [DATA_WIDTH-1:0] data_r2,
    input      signed [11:0]           data_imm,
    input             [9:0]            op,
    output reg                         alu_overflow
);

wire signed [DATA_WIDTH-1:0] add_out, sub_out, addi_out, lw_out, sw_out, beq_out, blt_out, slt_out, sll_out, srl_out;
reg alu_overflow_add, alu_overflow_sub, alu_overflow_addi;


// --------------------------------------------------------------------- Add ---------------------------------------------------------------------
reg signed [DATA_WIDTH:0] add_out_tmp;
always@*
    add_out_tmp = data_r1 + data_r2;

assign add_out = {add_out_tmp[DATA_WIDTH], add_out_tmp[DATA_WIDTH-2:0]};

// Overflow Detection
always@*
    if (~add_out_tmp[DATA_WIDTH] && add_out_tmp[DATA_WIDTH-1])                     // Positive Overflow
        alu_overflow_add = 1;
    else if (add_out_tmp[DATA_WIDTH] && ~add_out_tmp[DATA_WIDTH-1])                // Negative Overflow
        alu_overflow_add = 1;
    else
        alu_overflow_add = 0;


// --------------------------------------------------------------------- Sub ---------------------------------------------------------------------
reg signed [DATA_WIDTH:0] sub_out_tmp;
always@*
    sub_out_tmp = data_r1 - data_r2;

assign sub_out = {sub_out_tmp[DATA_WIDTH], sub_out_tmp[DATA_WIDTH-2:0]};

// Overflow Detection
always@*
    if (~sub_out_tmp[DATA_WIDTH] && sub_out_tmp[DATA_WIDTH-1])                     // Positive Overflow
        alu_overflow_sub = 1;
    else if (sub_out_tmp[DATA_WIDTH] && ~sub_out_tmp[DATA_WIDTH-1])                // Negative Overflow
        alu_overflow_sub = 1;
    else
        alu_overflow_sub = 0;


// --------------------------------------------------------------------- Addi --------------------------------------------------------------------
reg signed [DATA_WIDTH:0] addi_out_tmp;
always@*
    addi_out_tmp = data_r1 + data_imm;

assign addi_out = {addi_out_tmp[DATA_WIDTH], addi_out_tmp[DATA_WIDTH-2:0]};

// Overflow Detection
always@*
    if (~addi_out_tmp[DATA_WIDTH] && addi_out_tmp[DATA_WIDTH-1])                     // Positive Overflow
        alu_overflow_addi = 1;
    else if (addi_out_tmp[DATA_WIDTH] && ~addi_out_tmp[DATA_WIDTH-1])                // Negative Overflow
        alu_overflow_addi = 1;
    else
        alu_overflow_addi = 0;

// --------------------------------------------------------------------- Lw --------------------------------------------------------------------
assign lw_out = 0;

// --------------------------------------------------------------------- Sw --------------------------------------------------------------------
assign sw_out = 0;

// --------------------------------------------------------------------- Beq --------------------------------------------------------------------
assign beq_out = 0;

// --------------------------------------------------------------------- Blt --------------------------------------------------------------------
assign blt_out = 0;

// --------------------------------------------------------------------- Slt --------------------------------------------------------------------
reg [31:0] slt_out_tmp;
always@*
    if (data_r1 < data_r2)
        slt_out_tmp = 32'd1;
    else
        slt_out_tmp = 32'd0;

assign slt_out = slt_out_tmp;

// --------------------------------------------------------------------- Sll --------------------------------------------------------------------
assign sll_out = data_r1 << data_r2;

// --------------------------------------------------------------------- Srl --------------------------------------------------------------------
assign srl_out = data_r1 >> data_r2;

// Overflow Flag Selection
always@*
    case(op[9:7])
        3'b100:  alu_overflow = alu_overflow_add;
        3'b010:  alu_overflow = alu_overflow_sub;
        3'b001:  alu_overflow = alu_overflow_addi;
        default: alu_overflow = 0;
    endcase

// Output Selection
always@*
    case(op)
        10'b10_0000_0000: alu_out = add_out;
        10'b01_0000_0000: alu_out = sub_out;
        10'b00_1000_0000: alu_out = addi_out;
        10'b00_0100_0000: alu_out = lw_out;
        10'b00_0010_0000: alu_out = sw_out;
        10'b00_0001_0000: alu_out = beq_out;
        10'b00_0000_1000: alu_out = blt_out;
        10'b00_0000_0100: alu_out = slt_out;
        10'b00_0000_0010: alu_out = sll_out;
        10'b00_0000_0001: alu_out = srl_out;
        default:          alu_out = 0;     
    endcase

endmodule
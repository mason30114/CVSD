module core #( // DO NOT MODIFY INTERFACE!!!
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
) ( 
    input i_clk,
    input i_rst_n,

    // Testbench IOs
    output [2:0] o_status, 
    output       o_status_valid,

    // Memory IOs
    output [ADDR_WIDTH-1:0] o_addr,
    output [DATA_WIDTH-1:0] o_wdata,
    output                  o_we,
    input  [DATA_WIDTH-1:0] i_rdata
);

// ---------------------------------------------------------------- Spyglass ----------------------------------------------------------------
// `include "../00_TB/define.v"

reg [DATA_WIDTH-1:0] inst_reg;
wire [6:0] opcode;
reg [2:0] inst_type;
reg [4:0] r1, r2, rd;
reg [2:0] funct3;
reg [6:0] funct7;
reg signed [11:0] imm;
wire op_add, op_sub, op_addi, op_lw, op_sw, op_beq, op_blt, op_slt, op_sll, op_srl, op_fadd, op_fsub, op_flw, op_fsw, op_fclass, op_flt, op_eof;

reg [2:0] o_status_w;
reg o_status_valid_w;
reg [2:0] state, n_state;
wire alu_overflow, alu_nan; 
wire data_addr_read_invalid, data_addr_write_invalid, inst_addr_read_invalid;
parameter IDLE = 3'd0, IF = 3'd1, ID = 3'd2, ALU_LOAD = 3'd3, DW = 3'd4, PC_GEN = 3'd5, PC_END = 3'd6, PC_INV = 3'd7;

reg [12:0] pc, pc_n;
// reg [13:0] pc_n;
wire inst_count_end;
reg signed [31:0] int_reg_file [0:31];
reg signed [31:0] float_reg_file [0:31];
wire signed [31:0] int_alu_out;
wire signed [31:0] float_alu_out;
reg signed [31:0] mem_load_out;
wire int_reg_store_alu;
wire int_reg_store_mem;
wire float_reg_store_alu;
wire float_reg_store_mem;
integer i;

wire signed [DATA_WIDTH-1:0] data_r1_int;
wire signed [DATA_WIDTH-1:0] data_r2_int;
wire signed [DATA_WIDTH-1:0] data_r1_float;
wire signed [DATA_WIDTH-1:0] data_r2_float;

reg [DATA_WIDTH-1:0] o_addr_w;
reg [DATA_WIDTH-1:0] o_wdata_w;
reg o_we_w;

wire [9:0] int_op;
wire [5:0] float_op;

// ---------------------------------------------------- Instruction Decoding ---------------------------------------------------- 
always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        inst_reg <= 0;
    else
        if (state == ID)
            inst_reg <= i_rdata;  
        else
            inst_reg <= inst_reg;       

assign opcode = inst_reg[6:0];

always@*
    case(opcode)                            
        7'b0110011: inst_type = `R_TYPE;
        7'b0010011: inst_type = `I_TYPE;
        7'b0000011: inst_type = `I_TYPE;
        7'b0100011: inst_type = `S_TYPE;
        7'b1100011: inst_type = `B_TYPE;
        7'b1010011: inst_type = `R_TYPE;
        7'b0000111: inst_type = `I_TYPE;
        7'b0100111: inst_type = `S_TYPE;
        `OP_EOF:    inst_type = `EOF_TYPE;
        default:    inst_type = 3'd6;                 // Invalid
    endcase

always@*
    case(inst_type)
        `R_TYPE:  begin
            r1        = inst_reg[19:15];
            r2        = inst_reg[24:20];
            rd        = inst_reg[11:7];
            funct3    = inst_reg[14:12];
            funct7    = inst_reg[31:25];
            imm       = 0;
        end
        `I_TYPE:  begin
            r1        = inst_reg[19:15];
            r2        = 0;
            rd        = inst_reg[11:7];
            funct3    = inst_reg[14:12];
            funct7    = 0;
            imm       = inst_reg[31:20];
        end
        `S_TYPE:  begin
            r1        = inst_reg[19:15];
            r2        = inst_reg[24:20];
            rd        = 0;
            funct3    = inst_reg[14:12];
            funct7    = 0;
            imm       = {inst_reg[31:25], inst_reg[11:7]};
        end
        `B_TYPE:  begin
            r1        = inst_reg[19:15];
            r2        = inst_reg[24:20];
            rd        = 0;
            funct3    = inst_reg[14:12];
            funct7    = 0;
            imm       = {inst_reg[31], inst_reg[7], inst_reg[30:25], inst_reg[11:8]};
        end
        default:  begin
            r1        = 0;
            r2        = 0;
            rd        = 0;
            funct3    = 0;
            funct7    = 0;
            imm       = 0;
        end
    endcase
  
assign op_add    =  (opcode == `OP_ADD    &&  funct7 == `FUNCT7_ADD    &&  funct3 == `FUNCT3_ADD   );
assign op_sub    =  (opcode == `OP_SUB    &&  funct7 == `FUNCT7_SUB    &&  funct3 == `FUNCT3_SUB   );
assign op_addi   =  (opcode == `OP_ADDI   &&  funct3 == `FUNCT3_ADDI                               );
assign op_lw     =  (opcode == `OP_LW     &&  funct3 == `FUNCT3_LW                                 );
assign op_sw     =  (opcode == `OP_SW     &&  funct3 == `FUNCT3_SW                                 );
assign op_beq    =  (opcode == `OP_BEQ    &&  funct3 == `FUNCT3_BEQ                                ); 
assign op_blt    =  (opcode == `OP_BLT    &&  funct3 == `FUNCT3_BLT                                ); 
assign op_slt    =  (opcode == `OP_SLT    &&  funct7 == `FUNCT7_SLT    &&  funct3 == `FUNCT3_SLT   ); 
assign op_sll    =  (opcode == `OP_SLL    &&  funct7 == `FUNCT7_SLL    &&  funct3 == `FUNCT3_SLL   );
assign op_srl    =  (opcode == `OP_SRL    &&  funct7 == `FUNCT7_SRL    &&  funct3 == `FUNCT3_SRL   ); 
assign op_fadd   =  (opcode == `OP_FADD   &&  funct7 == `FUNCT7_FADD   &&  funct3 == `FUNCT3_FADD  );
assign op_fsub   =  (opcode == `OP_FSUB   &&  funct7 == `FUNCT7_FSUB   &&  funct3 == `FUNCT3_FSUB  );
assign op_flw    =  (opcode == `OP_FLW    &&  funct3 == `FUNCT3_FLW                                );
assign op_fsw    =  (opcode == `OP_FSW    &&  funct3 == `FUNCT3_FSW                                );
assign op_fclass =  (opcode == `OP_FCLASS &&  funct7 == `FUNCT7_FCLASS &&  funct3 == `FUNCT3_FCLASS);
assign op_flt    =  (opcode == `OP_FLT    &&  funct7 == `FUNCT7_FLT    &&  funct3 == `FUNCT3_FLT   );
assign op_eof    =  (opcode == `OP_EOF                                                             );

// -------------------------------------------------------- FSM Control  -------------------------------------------------------- 

// State Transition
always@*
    case(state)
        IDLE:   n_state = IF;
        IF:     n_state = ID;
        ID:     n_state = ALU_LOAD;         
        ALU_LOAD: 
            if (alu_overflow || alu_nan || data_addr_read_invalid)
                n_state = PC_INV;
            else
                n_state = DW;       
        DW:     
            if (data_addr_write_invalid)
                n_state = PC_INV;
            else
                n_state = PC_GEN;     
        PC_GEN: 
            if (inst_count_end)
                n_state = PC_END;   
            else if(inst_addr_read_invalid)
                n_state = PC_INV;            
            else if (op_eof)
                n_state = PC_END;            
            else
                n_state = IF;
        PC_END: n_state = IDLE;
        PC_INV: n_state = IDLE;        
        default: n_state = state;
    endcase

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        state <= 0;
    else
        state <= n_state;

// Output Status
always@*
    case(state)
        PC_GEN: 
            if(inst_addr_read_invalid) 
                o_status_w = `INVALID_TYPE;
            else
                o_status_w = inst_type;            
        PC_INV:  o_status_w = `INVALID_TYPE;
        default: o_status_w = 3'd0;                           // Invalid
    endcase

always@*
    case(state)
        PC_GEN:  o_status_valid_w = 1;            
        PC_INV:  o_status_valid_w = 1;
        default: o_status_valid_w = 0;                        
    endcase

assign o_status = o_status_w;
assign o_status_valid = o_status_valid_w;    

// -------------------------------------------------------- Program Counter -------------------------------------------------------- 
always@*
    if(state == PC_GEN) 
        if(op_beq && (int_reg_file[r1] == int_reg_file[r2]))                                                    // if($r1 == $r2), $pc = $pc + im;
            pc_n = pc + $signed({imm, 1'b0});
        else if (op_blt && (int_reg_file[r1] < int_reg_file[r2]))                                               // if($r1 <  $r2), $pc = $pc + im;
            pc_n = pc + $signed({imm, 1'b0});              
        else
            pc_n = pc + 3'd4;        
    else
        pc_n = pc;

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        pc <= 0;
    else
        pc <= pc_n[12:0];

assign inst_addr_read_invalid = (state == PC_GEN) && ((pc_n[12:2] < 11'd0) || (pc_n[12:2] >= 11'd1024)) && (~inst_count_end);

reg [9:0] inst_count_w, inst_count;
always@*
    if (state == PC_GEN)
        inst_count_w = inst_count + 1'b1;
    else
        inst_count_w = inst_count;

always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        inst_count <= 0;
    else
        inst_count <= inst_count_w;

assign inst_count_end = (inst_count == 10'd1023);
// -------------------------------------------------------- Register File -------------------------------------------------------- 
// Integer Register Store Flag
assign int_reg_store_alu   = (state == ALU_LOAD) && (op_add  || op_sub  || op_addi || op_slt || op_sll || op_srl);
assign int_reg_store_mem   = (state == DW) && (op_lw);
assign float_reg_store_alu = (state == ALU_LOAD) && (op_fadd || op_fsub);
assign float_reg_store_mem = (state == DW) && (op_flw);

// Integer Register File 
always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        for (i = 0; i < 32; i = i+1)
            int_reg_file[i] <= 0;
    else
        for (i = 0; i < 32; i = i+1)
            if (rd == i && int_reg_store_alu)                                   // Store ALU output (ALU_LOAD state)
                int_reg_file[i] <= int_alu_out;
            else if (rd == i && (op_fclass || op_flt) && (state == ALU_LOAD))   // Special Case: Fclass or Flt
                int_reg_file[i] <= float_alu_out;                
            else if (rd == i && int_reg_store_mem)                              // Store Memory output (DW state)
                int_reg_file[i] <= i_rdata;            
            else
                int_reg_file[i] <= int_reg_file[i];  

// Float Register File 
always@(posedge i_clk or negedge i_rst_n)
    if (~i_rst_n)
        for (i = 0; i < 32; i = i+1)
            float_reg_file[i] <= 0;
    else
        for (i = 0; i < 32; i = i+1)
            if (rd == i && float_reg_store_alu)                                 // Store ALU output (ALU_LOAD state)
                float_reg_file[i] <= float_alu_out;
            else if (rd == i && float_reg_store_mem)                            // Store Memory output (DW state)
                float_reg_file[i] <= i_rdata;   
            else
                float_reg_file[i] <= float_reg_file[i];  

// -------------------------------------------------------- Memory Interface -------------------------------------------------------- 

// Address
always@*
    if (state == IF)                                                       // IF stage   
        o_addr_w = {19'd0, pc[12:2], 2'd0};
    else if (state == ALU_LOAD && (op_lw))                                 // LW 
        o_addr_w = data_r1_int + imm;
    else if (state == ALU_LOAD && (op_flw))                                // FLW     
        o_addr_w = data_r1_int + imm;  
    else if (state == DW && (op_sw))                                       // SW 
        o_addr_w = data_r1_int + imm;
    else if (state == DW && (op_fsw))                                      // FSW
        o_addr_w = data_r1_int + imm;
    else
        o_addr_w = 0;    
assign o_addr = o_addr_w;

// Read Data from inst addr
assign data_addr_read_invalid  = (state == ALU_LOAD) && (op_lw || op_flw) && ((o_addr[ADDR_WIDTH-1:2] < 11'd1024) || (o_addr[ADDR_WIDTH-1:2] > 11'd2047));
assign data_addr_write_invalid = (state == DW      ) && (op_sw || op_fsw) && ((o_addr[ADDR_WIDTH-1:2] < 11'd1024) || (o_addr[ADDR_WIDTH-1:2] > 11'd2047));

// Data
always@*
    if (state == DW && (op_sw))                              // SW 
        o_wdata_w = int_reg_file[r2];
    else if (state == DW && (op_fsw))                        // FSW
        o_wdata_w = float_reg_file[r2];
    else
        o_wdata_w = 0;    
assign o_wdata = o_wdata_w;

// WE
always@*
    if (data_addr_write_invalid)
        o_we_w = 0;
    else if ((state == DW) && (op_sw || op_fsw))                              // SW or FSW
        o_we_w = 1;
    else
        o_we_w = 0;    
assign o_we = o_we_w;

reg alu_add_out;
reg alu_sub_out;

// --------------------------------------------------------  ALU  -------------------------------------------------------- 
assign int_op = {op_add, op_sub, op_addi, op_lw, op_sw, op_beq, op_blt, op_slt, op_sll, op_srl};
assign float_op = {op_fadd, op_fsub, op_flw, op_fsw, op_fclass, op_flt};
assign data_r1_int = int_reg_file[r1];
assign data_r2_int = int_reg_file[r2];
assign data_r1_float = float_reg_file[r1];
assign data_r2_float = float_reg_file[r2];

int_alu # (
    .DATA_WIDTH(DATA_WIDTH)
) 
int_alu_U0 (
    .alu_out(int_alu_out),
    .data_r1(data_r1_int),
    .data_r2(data_r2_int),
    .data_imm(imm),
    .op(int_op),
    .alu_overflow(alu_overflow)
);

float_alu # (
    .DATA_WIDTH(DATA_WIDTH)
)
float_alu_U0 ( 
    .alu_out(float_alu_out),
    .data_r1(data_r1_float),
    .data_r2(data_r2_float),
    .op(float_op),
    .alu_nan(alu_nan)
);



endmodule
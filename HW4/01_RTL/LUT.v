module Sbox_1(
    input [5:0] Sbox_in_1,
    output reg [3:0] Sbox_out_1
);

always@*
    case(Sbox_in_1)
        6'd0: Sbox_out_1 = 4'd14;
        6'd1: Sbox_out_1 = 4'd0;
        6'd2: Sbox_out_1 = 4'd4;
        6'd3: Sbox_out_1 = 4'd15;
        6'd4: Sbox_out_1 = 4'd13;
        6'd5: Sbox_out_1 = 4'd7;
        6'd6: Sbox_out_1 = 4'd1;
        6'd7: Sbox_out_1 = 4'd4;
        6'd8: Sbox_out_1 = 4'd2;
        6'd9: Sbox_out_1 = 4'd14;
        6'd10: Sbox_out_1 = 4'd15;
        6'd11: Sbox_out_1 = 4'd2;
        6'd12: Sbox_out_1 = 4'd11;
        6'd13: Sbox_out_1 = 4'd13;
        6'd14: Sbox_out_1 = 4'd8;
        6'd15: Sbox_out_1 = 4'd1;
        6'd16: Sbox_out_1 = 4'd3;
        6'd17: Sbox_out_1 = 4'd10;
        6'd18: Sbox_out_1 = 4'd10;
        6'd19: Sbox_out_1 = 4'd6;
        6'd20: Sbox_out_1 = 4'd6;
        6'd21: Sbox_out_1 = 4'd12;
        6'd22: Sbox_out_1 = 4'd12;
        6'd23: Sbox_out_1 = 4'd11;
        6'd24: Sbox_out_1 = 4'd5;
        6'd25: Sbox_out_1 = 4'd9;
        6'd26: Sbox_out_1 = 4'd9;
        6'd27: Sbox_out_1 = 4'd5;
        6'd28: Sbox_out_1 = 4'd0;
        6'd29: Sbox_out_1 = 4'd3;
        6'd30: Sbox_out_1 = 4'd7;
        6'd31: Sbox_out_1 = 4'd8;
        6'd32: Sbox_out_1 = 4'd4;
        6'd33: Sbox_out_1 = 4'd15;
        6'd34: Sbox_out_1 = 4'd1;
        6'd35: Sbox_out_1 = 4'd12;
        6'd36: Sbox_out_1 = 4'd14;
        6'd37: Sbox_out_1 = 4'd8;
        6'd38: Sbox_out_1 = 4'd8;
        6'd39: Sbox_out_1 = 4'd2;
        6'd40: Sbox_out_1 = 4'd13;
        6'd41: Sbox_out_1 = 4'd4;
        6'd42: Sbox_out_1 = 4'd6;
        6'd43: Sbox_out_1 = 4'd9;
        6'd44: Sbox_out_1 = 4'd2;
        6'd45: Sbox_out_1 = 4'd1;
        6'd46: Sbox_out_1 = 4'd11;
        6'd47: Sbox_out_1 = 4'd7;
        6'd48: Sbox_out_1 = 4'd15;
        6'd49: Sbox_out_1 = 4'd5;
        6'd50: Sbox_out_1 = 4'd12;
        6'd51: Sbox_out_1 = 4'd11;
        6'd52: Sbox_out_1 = 4'd9;
        6'd53: Sbox_out_1 = 4'd3;
        6'd54: Sbox_out_1 = 4'd7;
        6'd55: Sbox_out_1 = 4'd14;
        6'd56: Sbox_out_1 = 4'd3;
        6'd57: Sbox_out_1 = 4'd10;
        6'd58: Sbox_out_1 = 4'd10;
        6'd59: Sbox_out_1 = 4'd0;
        6'd60: Sbox_out_1 = 4'd5;
        6'd61: Sbox_out_1 = 4'd6;
        6'd62: Sbox_out_1 = 4'd0;
        6'd63: Sbox_out_1 = 4'd13;
    endcase

endmodule



module Sbox_2(
    input [5:0] Sbox_in_2,
    output reg [3:0] Sbox_out_2
);

always@*
    case(Sbox_in_2)
        6'd0: Sbox_out_2 = 4'd15;
        6'd1: Sbox_out_2 = 4'd3;
        6'd2: Sbox_out_2 = 4'd1;
        6'd3: Sbox_out_2 = 4'd13;
        6'd4: Sbox_out_2 = 4'd8;
        6'd5: Sbox_out_2 = 4'd4;
        6'd6: Sbox_out_2 = 4'd14;
        6'd7: Sbox_out_2 = 4'd7;
        6'd8: Sbox_out_2 = 4'd6;
        6'd9: Sbox_out_2 = 4'd15;
        6'd10: Sbox_out_2 = 4'd11;
        6'd11: Sbox_out_2 = 4'd2;
        6'd12: Sbox_out_2 = 4'd3;
        6'd13: Sbox_out_2 = 4'd8;
        6'd14: Sbox_out_2 = 4'd4;
        6'd15: Sbox_out_2 = 4'd14;
        6'd16: Sbox_out_2 = 4'd9;
        6'd17: Sbox_out_2 = 4'd12;
        6'd18: Sbox_out_2 = 4'd7;
        6'd19: Sbox_out_2 = 4'd0;
        6'd20: Sbox_out_2 = 4'd2;
        6'd21: Sbox_out_2 = 4'd1;
        6'd22: Sbox_out_2 = 4'd13;
        6'd23: Sbox_out_2 = 4'd10;
        6'd24: Sbox_out_2 = 4'd12;
        6'd25: Sbox_out_2 = 4'd6;
        6'd26: Sbox_out_2 = 4'd0;
        6'd27: Sbox_out_2 = 4'd9;
        6'd28: Sbox_out_2 = 4'd5;
        6'd29: Sbox_out_2 = 4'd11;
        6'd30: Sbox_out_2 = 4'd10;
        6'd31: Sbox_out_2 = 4'd5;
        6'd32: Sbox_out_2 = 4'd0;
        6'd33: Sbox_out_2 = 4'd13;
        6'd34: Sbox_out_2 = 4'd14;
        6'd35: Sbox_out_2 = 4'd8;
        6'd36: Sbox_out_2 = 4'd7;
        6'd37: Sbox_out_2 = 4'd10;
        6'd38: Sbox_out_2 = 4'd11;
        6'd39: Sbox_out_2 = 4'd1;
        6'd40: Sbox_out_2 = 4'd10;
        6'd41: Sbox_out_2 = 4'd3;
        6'd42: Sbox_out_2 = 4'd4;
        6'd43: Sbox_out_2 = 4'd15;
        6'd44: Sbox_out_2 = 4'd13;
        6'd45: Sbox_out_2 = 4'd4;
        6'd46: Sbox_out_2 = 4'd1;
        6'd47: Sbox_out_2 = 4'd2;
        6'd48: Sbox_out_2 = 4'd5;
        6'd49: Sbox_out_2 = 4'd11;
        6'd50: Sbox_out_2 = 4'd8;
        6'd51: Sbox_out_2 = 4'd6;
        6'd52: Sbox_out_2 = 4'd12;
        6'd53: Sbox_out_2 = 4'd7;
        6'd54: Sbox_out_2 = 4'd6;
        6'd55: Sbox_out_2 = 4'd12;
        6'd56: Sbox_out_2 = 4'd9;
        6'd57: Sbox_out_2 = 4'd0;
        6'd58: Sbox_out_2 = 4'd3;
        6'd59: Sbox_out_2 = 4'd5;
        6'd60: Sbox_out_2 = 4'd2;
        6'd61: Sbox_out_2 = 4'd14;
        6'd62: Sbox_out_2 = 4'd15;
        6'd63: Sbox_out_2 = 4'd9;
    endcase

endmodule

module Sbox_3(
    input [5:0] Sbox_in_3,
    output reg [3:0] Sbox_out_3
);

always@*
    case(Sbox_in_3)
        6'd0: Sbox_out_3 = 4'd10;
        6'd1: Sbox_out_3 = 4'd13;
        6'd2: Sbox_out_3 = 4'd0;
        6'd3: Sbox_out_3 = 4'd7;
        6'd4: Sbox_out_3 = 4'd9;
        6'd5: Sbox_out_3 = 4'd0;
        6'd6: Sbox_out_3 = 4'd14;
        6'd7: Sbox_out_3 = 4'd9;
        6'd8: Sbox_out_3 = 4'd6;
        6'd9: Sbox_out_3 = 4'd3;
        6'd10: Sbox_out_3 = 4'd3;
        6'd11: Sbox_out_3 = 4'd4;
        6'd12: Sbox_out_3 = 4'd15;
        6'd13: Sbox_out_3 = 4'd6;
        6'd14: Sbox_out_3 = 4'd5;
        6'd15: Sbox_out_3 = 4'd10;
        6'd16: Sbox_out_3 = 4'd1;
        6'd17: Sbox_out_3 = 4'd2;
        6'd18: Sbox_out_3 = 4'd13;
        6'd19: Sbox_out_3 = 4'd8;
        6'd20: Sbox_out_3 = 4'd12;
        6'd21: Sbox_out_3 = 4'd5;
        6'd22: Sbox_out_3 = 4'd7;
        6'd23: Sbox_out_3 = 4'd14;
        6'd24: Sbox_out_3 = 4'd11;
        6'd25: Sbox_out_3 = 4'd12;
        6'd26: Sbox_out_3 = 4'd4;
        6'd27: Sbox_out_3 = 4'd11;
        6'd28: Sbox_out_3 = 4'd2;
        6'd29: Sbox_out_3 = 4'd15;
        6'd30: Sbox_out_3 = 4'd8;
        6'd31: Sbox_out_3 = 4'd1;
        6'd32: Sbox_out_3 = 4'd13;
        6'd33: Sbox_out_3 = 4'd1;
        6'd34: Sbox_out_3 = 4'd6;
        6'd35: Sbox_out_3 = 4'd10;
        6'd36: Sbox_out_3 = 4'd4;
        6'd37: Sbox_out_3 = 4'd13;
        6'd38: Sbox_out_3 = 4'd9;
        6'd39: Sbox_out_3 = 4'd0;
        6'd40: Sbox_out_3 = 4'd8;
        6'd41: Sbox_out_3 = 4'd6;
        6'd42: Sbox_out_3 = 4'd15;
        6'd43: Sbox_out_3 = 4'd9;
        6'd44: Sbox_out_3 = 4'd3;
        6'd45: Sbox_out_3 = 4'd8;
        6'd46: Sbox_out_3 = 4'd0;
        6'd47: Sbox_out_3 = 4'd7;
        6'd48: Sbox_out_3 = 4'd11;
        6'd49: Sbox_out_3 = 4'd4;
        6'd50: Sbox_out_3 = 4'd1;
        6'd51: Sbox_out_3 = 4'd15;
        6'd52: Sbox_out_3 = 4'd2;
        6'd53: Sbox_out_3 = 4'd14;
        6'd54: Sbox_out_3 = 4'd12;
        6'd55: Sbox_out_3 = 4'd3;
        6'd56: Sbox_out_3 = 4'd5;
        6'd57: Sbox_out_3 = 4'd11;
        6'd58: Sbox_out_3 = 4'd10;
        6'd59: Sbox_out_3 = 4'd5;
        6'd60: Sbox_out_3 = 4'd14;
        6'd61: Sbox_out_3 = 4'd2;
        6'd62: Sbox_out_3 = 4'd7;
        6'd63: Sbox_out_3 = 4'd12;
    endcase
endmodule


module Sbox_4(
    input [5:0] Sbox_in_4,
    output reg [3:0] Sbox_out_4
);
always@*
    case(Sbox_in_4)
        6'd0: Sbox_out_4 = 4'd7;
        6'd1: Sbox_out_4 = 4'd13;
        6'd2: Sbox_out_4 = 4'd13;
        6'd3: Sbox_out_4 = 4'd8;
        6'd4: Sbox_out_4 = 4'd14;
        6'd5: Sbox_out_4 = 4'd11;
        6'd6: Sbox_out_4 = 4'd3;
        6'd7: Sbox_out_4 = 4'd5;
        6'd8: Sbox_out_4 = 4'd0;
        6'd9: Sbox_out_4 = 4'd6;
        6'd10: Sbox_out_4 = 4'd6;
        6'd11: Sbox_out_4 = 4'd15;
        6'd12: Sbox_out_4 = 4'd9;
        6'd13: Sbox_out_4 = 4'd0;
        6'd14: Sbox_out_4 = 4'd10;
        6'd15: Sbox_out_4 = 4'd3;
        6'd16: Sbox_out_4 = 4'd1;
        6'd17: Sbox_out_4 = 4'd4;
        6'd18: Sbox_out_4 = 4'd2;
        6'd19: Sbox_out_4 = 4'd7;
        6'd20: Sbox_out_4 = 4'd8;
        6'd21: Sbox_out_4 = 4'd2;
        6'd22: Sbox_out_4 = 4'd5;
        6'd23: Sbox_out_4 = 4'd12;
        6'd24: Sbox_out_4 = 4'd11;
        6'd25: Sbox_out_4 = 4'd1;
        6'd26: Sbox_out_4 = 4'd12;
        6'd27: Sbox_out_4 = 4'd10;
        6'd28: Sbox_out_4 = 4'd4;
        6'd29: Sbox_out_4 = 4'd14;
        6'd30: Sbox_out_4 = 4'd15;
        6'd31: Sbox_out_4 = 4'd9;
        6'd32: Sbox_out_4 = 4'd10;
        6'd33: Sbox_out_4 = 4'd3;
        6'd34: Sbox_out_4 = 4'd6;
        6'd35: Sbox_out_4 = 4'd15;
        6'd36: Sbox_out_4 = 4'd9;
        6'd37: Sbox_out_4 = 4'd0;
        6'd38: Sbox_out_4 = 4'd0;
        6'd39: Sbox_out_4 = 4'd6;
        6'd40: Sbox_out_4 = 4'd12;
        6'd41: Sbox_out_4 = 4'd10;
        6'd42: Sbox_out_4 = 4'd11;
        6'd43: Sbox_out_4 = 4'd1;
        6'd44: Sbox_out_4 = 4'd7;
        6'd45: Sbox_out_4 = 4'd13;
        6'd46: Sbox_out_4 = 4'd13;
        6'd47: Sbox_out_4 = 4'd8;
        6'd48: Sbox_out_4 = 4'd15;
        6'd49: Sbox_out_4 = 4'd9;
        6'd50: Sbox_out_4 = 4'd1;
        6'd51: Sbox_out_4 = 4'd4;
        6'd52: Sbox_out_4 = 4'd3;
        6'd53: Sbox_out_4 = 4'd5;
        6'd54: Sbox_out_4 = 4'd14;
        6'd55: Sbox_out_4 = 4'd11;
        6'd56: Sbox_out_4 = 4'd5;
        6'd57: Sbox_out_4 = 4'd12;
        6'd58: Sbox_out_4 = 4'd2;
        6'd59: Sbox_out_4 = 4'd7;
        6'd60: Sbox_out_4 = 4'd8;
        6'd61: Sbox_out_4 = 4'd2;
        6'd62: Sbox_out_4 = 4'd4;
        6'd63: Sbox_out_4 = 4'd14;
    endcase

endmodule

module Sbox_5(
    input [5:0] Sbox_in_5,
    output reg [3:0] Sbox_out_5
);
always@*
    case(Sbox_in_5)
        6'd0: Sbox_out_5 = 4'd2;
        6'd1: Sbox_out_5 = 4'd14;
        6'd2: Sbox_out_5 = 4'd12;
        6'd3: Sbox_out_5 = 4'd11;
        6'd4: Sbox_out_5 = 4'd4;
        6'd5: Sbox_out_5 = 4'd2;
        6'd6: Sbox_out_5 = 4'd1;
        6'd7: Sbox_out_5 = 4'd12;
        6'd8: Sbox_out_5 = 4'd7;
        6'd9: Sbox_out_5 = 4'd4;
        6'd10: Sbox_out_5 = 4'd10;
        6'd11: Sbox_out_5 = 4'd7;
        6'd12: Sbox_out_5 = 4'd11;
        6'd13: Sbox_out_5 = 4'd13;
        6'd14: Sbox_out_5 = 4'd6;
        6'd15: Sbox_out_5 = 4'd1;
        6'd16: Sbox_out_5 = 4'd8;
        6'd17: Sbox_out_5 = 4'd5;
        6'd18: Sbox_out_5 = 4'd5;
        6'd19: Sbox_out_5 = 4'd0;
        6'd20: Sbox_out_5 = 4'd3;
        6'd21: Sbox_out_5 = 4'd15;
        6'd22: Sbox_out_5 = 4'd15;
        6'd23: Sbox_out_5 = 4'd10;
        6'd24: Sbox_out_5 = 4'd13;
        6'd25: Sbox_out_5 = 4'd3;
        6'd26: Sbox_out_5 = 4'd0;
        6'd27: Sbox_out_5 = 4'd9;
        6'd28: Sbox_out_5 = 4'd14;
        6'd29: Sbox_out_5 = 4'd8;
        6'd30: Sbox_out_5 = 4'd9;
        6'd31: Sbox_out_5 = 4'd6;
        6'd32: Sbox_out_5 = 4'd4;
        6'd33: Sbox_out_5 = 4'd11;
        6'd34: Sbox_out_5 = 4'd2;
        6'd35: Sbox_out_5 = 4'd8;
        6'd36: Sbox_out_5 = 4'd1;
        6'd37: Sbox_out_5 = 4'd12;
        6'd38: Sbox_out_5 = 4'd11;
        6'd39: Sbox_out_5 = 4'd7;
        6'd40: Sbox_out_5 = 4'd10;
        6'd41: Sbox_out_5 = 4'd1;
        6'd42: Sbox_out_5 = 4'd13;
        6'd43: Sbox_out_5 = 4'd14;
        6'd44: Sbox_out_5 = 4'd7;
        6'd45: Sbox_out_5 = 4'd2;
        6'd46: Sbox_out_5 = 4'd8;
        6'd47: Sbox_out_5 = 4'd13;
        6'd48: Sbox_out_5 = 4'd15;
        6'd49: Sbox_out_5 = 4'd6;
        6'd50: Sbox_out_5 = 4'd9;
        6'd51: Sbox_out_5 = 4'd15;
        6'd52: Sbox_out_5 = 4'd12;
        6'd53: Sbox_out_5 = 4'd0;
        6'd54: Sbox_out_5 = 4'd5;
        6'd55: Sbox_out_5 = 4'd9;
        6'd56: Sbox_out_5 = 4'd6;
        6'd57: Sbox_out_5 = 4'd10;
        6'd58: Sbox_out_5 = 4'd3;
        6'd59: Sbox_out_5 = 4'd4;
        6'd60: Sbox_out_5 = 4'd0;
        6'd61: Sbox_out_5 = 4'd5;
        6'd62: Sbox_out_5 = 4'd14;
        6'd63: Sbox_out_5 = 4'd3;
    endcase

endmodule


module Sbox_6(
    input [5:0] Sbox_in_6,
    output reg [3:0] Sbox_out_6
);
always@*
    case(Sbox_in_6)
        6'd0: Sbox_out_6 = 4'd12;
        6'd1: Sbox_out_6 = 4'd10;
        6'd2: Sbox_out_6 = 4'd1;
        6'd3: Sbox_out_6 = 4'd15;
        6'd4: Sbox_out_6 = 4'd10;
        6'd5: Sbox_out_6 = 4'd4;
        6'd6: Sbox_out_6 = 4'd15;
        6'd7: Sbox_out_6 = 4'd2;
        6'd8: Sbox_out_6 = 4'd9;
        6'd9: Sbox_out_6 = 4'd7;
        6'd10: Sbox_out_6 = 4'd2;
        6'd11: Sbox_out_6 = 4'd12;
        6'd12: Sbox_out_6 = 4'd6;
        6'd13: Sbox_out_6 = 4'd9;
        6'd14: Sbox_out_6 = 4'd8;
        6'd15: Sbox_out_6 = 4'd5;
        6'd16: Sbox_out_6 = 4'd0;
        6'd17: Sbox_out_6 = 4'd6;
        6'd18: Sbox_out_6 = 4'd13;
        6'd19: Sbox_out_6 = 4'd1;
        6'd20: Sbox_out_6 = 4'd3;
        6'd21: Sbox_out_6 = 4'd13;
        6'd22: Sbox_out_6 = 4'd4;
        6'd23: Sbox_out_6 = 4'd14;
        6'd24: Sbox_out_6 = 4'd14;
        6'd25: Sbox_out_6 = 4'd0;
        6'd26: Sbox_out_6 = 4'd7;
        6'd27: Sbox_out_6 = 4'd11;
        6'd28: Sbox_out_6 = 4'd5;
        6'd29: Sbox_out_6 = 4'd3;
        6'd30: Sbox_out_6 = 4'd11;
        6'd31: Sbox_out_6 = 4'd8;
        6'd32: Sbox_out_6 = 4'd9;
        6'd33: Sbox_out_6 = 4'd4;
        6'd34: Sbox_out_6 = 4'd14;
        6'd35: Sbox_out_6 = 4'd3;
        6'd36: Sbox_out_6 = 4'd15;
        6'd37: Sbox_out_6 = 4'd2;
        6'd38: Sbox_out_6 = 4'd5;
        6'd39: Sbox_out_6 = 4'd12;
        6'd40: Sbox_out_6 = 4'd2;
        6'd41: Sbox_out_6 = 4'd9;
        6'd42: Sbox_out_6 = 4'd8;
        6'd43: Sbox_out_6 = 4'd5;
        6'd44: Sbox_out_6 = 4'd12;
        6'd45: Sbox_out_6 = 4'd15;
        6'd46: Sbox_out_6 = 4'd3;
        6'd47: Sbox_out_6 = 4'd10;
        6'd48: Sbox_out_6 = 4'd7;
        6'd49: Sbox_out_6 = 4'd11;
        6'd50: Sbox_out_6 = 4'd0;
        6'd51: Sbox_out_6 = 4'd14;
        6'd52: Sbox_out_6 = 4'd4;
        6'd53: Sbox_out_6 = 4'd1;
        6'd54: Sbox_out_6 = 4'd10;
        6'd55: Sbox_out_6 = 4'd7;
        6'd56: Sbox_out_6 = 4'd1;
        6'd57: Sbox_out_6 = 4'd6;
        6'd58: Sbox_out_6 = 4'd13;
        6'd59: Sbox_out_6 = 4'd0;
        6'd60: Sbox_out_6 = 4'd11;
        6'd61: Sbox_out_6 = 4'd8;
        6'd62: Sbox_out_6 = 4'd6;
        6'd63: Sbox_out_6 = 4'd13;
    endcase
endmodule



module Sbox_7(
    input [5:0] Sbox_in_7,
    output reg [3:0] Sbox_out_7
);
always@*
    case(Sbox_in_7)
        6'd0: Sbox_out_7 = 4'd4;
        6'd1: Sbox_out_7 = 4'd13;
        6'd2: Sbox_out_7 = 4'd11;
        6'd3: Sbox_out_7 = 4'd0;
        6'd4: Sbox_out_7 = 4'd2;
        6'd5: Sbox_out_7 = 4'd11;
        6'd6: Sbox_out_7 = 4'd14;
        6'd7: Sbox_out_7 = 4'd7;
        6'd8: Sbox_out_7 = 4'd15;
        6'd9: Sbox_out_7 = 4'd4;
        6'd10: Sbox_out_7 = 4'd0;
        6'd11: Sbox_out_7 = 4'd9;
        6'd12: Sbox_out_7 = 4'd8;
        6'd13: Sbox_out_7 = 4'd1;
        6'd14: Sbox_out_7 = 4'd13;
        6'd15: Sbox_out_7 = 4'd10;
        6'd16: Sbox_out_7 = 4'd3;
        6'd17: Sbox_out_7 = 4'd14;
        6'd18: Sbox_out_7 = 4'd12;
        6'd19: Sbox_out_7 = 4'd3;
        6'd20: Sbox_out_7 = 4'd9;
        6'd21: Sbox_out_7 = 4'd5;
        6'd22: Sbox_out_7 = 4'd7;
        6'd23: Sbox_out_7 = 4'd12;
        6'd24: Sbox_out_7 = 4'd5;
        6'd25: Sbox_out_7 = 4'd2;
        6'd26: Sbox_out_7 = 4'd10;
        6'd27: Sbox_out_7 = 4'd15;
        6'd28: Sbox_out_7 = 4'd6;
        6'd29: Sbox_out_7 = 4'd8;
        6'd30: Sbox_out_7 = 4'd1;
        6'd31: Sbox_out_7 = 4'd6;
        6'd32: Sbox_out_7 = 4'd1;
        6'd33: Sbox_out_7 = 4'd6;
        6'd34: Sbox_out_7 = 4'd4;
        6'd35: Sbox_out_7 = 4'd11;
        6'd36: Sbox_out_7 = 4'd11;
        6'd37: Sbox_out_7 = 4'd13;
        6'd38: Sbox_out_7 = 4'd13;
        6'd39: Sbox_out_7 = 4'd8;
        6'd40: Sbox_out_7 = 4'd12;
        6'd41: Sbox_out_7 = 4'd1;
        6'd42: Sbox_out_7 = 4'd3;
        6'd43: Sbox_out_7 = 4'd4;
        6'd44: Sbox_out_7 = 4'd7;
        6'd45: Sbox_out_7 = 4'd10;
        6'd46: Sbox_out_7 = 4'd14;
        6'd47: Sbox_out_7 = 4'd7;
        6'd48: Sbox_out_7 = 4'd10;
        6'd49: Sbox_out_7 = 4'd9;
        6'd50: Sbox_out_7 = 4'd15;
        6'd51: Sbox_out_7 = 4'd5;
        6'd52: Sbox_out_7 = 4'd6;
        6'd53: Sbox_out_7 = 4'd0;
        6'd54: Sbox_out_7 = 4'd8;
        6'd55: Sbox_out_7 = 4'd15;
        6'd56: Sbox_out_7 = 4'd0;
        6'd57: Sbox_out_7 = 4'd14;
        6'd58: Sbox_out_7 = 4'd5;
        6'd59: Sbox_out_7 = 4'd2;
        6'd60: Sbox_out_7 = 4'd9;
        6'd61: Sbox_out_7 = 4'd3;
        6'd62: Sbox_out_7 = 4'd2;
        6'd63: Sbox_out_7 = 4'd12;
    endcase
endmodule


module Sbox_8(
    input [5:0] Sbox_in_8,
    output reg [3:0] Sbox_out_8
);
always@*
    case(Sbox_in_8)
        6'd0: Sbox_out_8 = 4'd13;
        6'd1: Sbox_out_8 = 4'd1;
        6'd2: Sbox_out_8 = 4'd2;
        6'd3: Sbox_out_8 = 4'd15;
        6'd4: Sbox_out_8 = 4'd8;
        6'd5: Sbox_out_8 = 4'd13;
        6'd6: Sbox_out_8 = 4'd4;
        6'd7: Sbox_out_8 = 4'd8;
        6'd8: Sbox_out_8 = 4'd6;
        6'd9: Sbox_out_8 = 4'd10;
        6'd10: Sbox_out_8 = 4'd15;
        6'd11: Sbox_out_8 = 4'd3;
        6'd12: Sbox_out_8 = 4'd11;
        6'd13: Sbox_out_8 = 4'd7;
        6'd14: Sbox_out_8 = 4'd1;
        6'd15: Sbox_out_8 = 4'd4;
        6'd16: Sbox_out_8 = 4'd10;
        6'd17: Sbox_out_8 = 4'd12;
        6'd18: Sbox_out_8 = 4'd9;
        6'd19: Sbox_out_8 = 4'd5;
        6'd20: Sbox_out_8 = 4'd3;
        6'd21: Sbox_out_8 = 4'd6;
        6'd22: Sbox_out_8 = 4'd14;
        6'd23: Sbox_out_8 = 4'd11;
        6'd24: Sbox_out_8 = 4'd5;
        6'd25: Sbox_out_8 = 4'd0;
        6'd26: Sbox_out_8 = 4'd0;
        6'd27: Sbox_out_8 = 4'd14;
        6'd28: Sbox_out_8 = 4'd12;
        6'd29: Sbox_out_8 = 4'd9;
        6'd30: Sbox_out_8 = 4'd7;
        6'd31: Sbox_out_8 = 4'd2;
        6'd32: Sbox_out_8 = 4'd7;
        6'd33: Sbox_out_8 = 4'd2;
        6'd34: Sbox_out_8 = 4'd11;
        6'd35: Sbox_out_8 = 4'd1;
        6'd36: Sbox_out_8 = 4'd4;
        6'd37: Sbox_out_8 = 4'd14;
        6'd38: Sbox_out_8 = 4'd1;
        6'd39: Sbox_out_8 = 4'd7;
        6'd40: Sbox_out_8 = 4'd9;
        6'd41: Sbox_out_8 = 4'd4;
        6'd42: Sbox_out_8 = 4'd12;
        6'd43: Sbox_out_8 = 4'd10;
        6'd44: Sbox_out_8 = 4'd14;
        6'd45: Sbox_out_8 = 4'd8;
        6'd46: Sbox_out_8 = 4'd2;
        6'd47: Sbox_out_8 = 4'd13;
        6'd48: Sbox_out_8 = 4'd0;
        6'd49: Sbox_out_8 = 4'd15;
        6'd50: Sbox_out_8 = 4'd6;
        6'd51: Sbox_out_8 = 4'd12;
        6'd52: Sbox_out_8 = 4'd10;
        6'd53: Sbox_out_8 = 4'd9;
        6'd54: Sbox_out_8 = 4'd13;
        6'd55: Sbox_out_8 = 4'd0;
        6'd56: Sbox_out_8 = 4'd15;
        6'd57: Sbox_out_8 = 4'd3;
        6'd58: Sbox_out_8 = 4'd3;
        6'd59: Sbox_out_8 = 4'd5;
        6'd60: Sbox_out_8 = 4'd5;
        6'd61: Sbox_out_8 = 4'd6;
        6'd62: Sbox_out_8 = 4'd8;
        6'd63: Sbox_out_8 = 4'd11;
    endcase
endmodule

module init_p (
    input [63:0] init_p_in,
    output [63:0] init_p_out
);

assign init_p_out = {init_p_in[6],init_p_in[14],init_p_in[22],init_p_in[30],init_p_in[38],init_p_in[46],init_p_in[54],init_p_in[62],
                     init_p_in[4],init_p_in[12],init_p_in[20],init_p_in[28],init_p_in[36],init_p_in[44],init_p_in[52],init_p_in[60],
                     init_p_in[2],init_p_in[10],init_p_in[18],init_p_in[26],init_p_in[34],init_p_in[42],init_p_in[50],init_p_in[58],
                     init_p_in[0],init_p_in[8],init_p_in[16],init_p_in[24],init_p_in[32],init_p_in[40],init_p_in[48],init_p_in[56],
                     init_p_in[7],init_p_in[15],init_p_in[23],init_p_in[31],init_p_in[39],init_p_in[47],init_p_in[55],init_p_in[63],
                     init_p_in[5],init_p_in[13],init_p_in[21],init_p_in[29],init_p_in[37],init_p_in[45],init_p_in[53],init_p_in[61],
                     init_p_in[3],init_p_in[11],init_p_in[19],init_p_in[27],init_p_in[35],init_p_in[43],init_p_in[51],init_p_in[59],
                     init_p_in[1],init_p_in[9],init_p_in[17],init_p_in[25],init_p_in[33],init_p_in[41],init_p_in[49],init_p_in[57]};

endmodule

module text_expansion_p (
    input [31:0] text_indenity_in,
    output [47:0] text_expansion_out
);

assign text_expansion_out = {text_indenity_in[0],text_indenity_in[31],text_indenity_in[30],text_indenity_in[29],text_indenity_in[28],text_indenity_in[27],text_indenity_in[28],text_indenity_in[27],
                             text_indenity_in[26],text_indenity_in[25],text_indenity_in[24],text_indenity_in[23],text_indenity_in[24],text_indenity_in[23],text_indenity_in[22],text_indenity_in[21],
                             text_indenity_in[20],text_indenity_in[19],text_indenity_in[20],text_indenity_in[19],text_indenity_in[18],text_indenity_in[17],text_indenity_in[16],text_indenity_in[15],
                             text_indenity_in[16],text_indenity_in[15],text_indenity_in[14],text_indenity_in[13],text_indenity_in[12],text_indenity_in[11],text_indenity_in[12],text_indenity_in[11],
                             text_indenity_in[10],text_indenity_in[9],text_indenity_in[8],text_indenity_in[7],text_indenity_in[8],text_indenity_in[7],text_indenity_in[6],text_indenity_in[5],
                             text_indenity_in[4],text_indenity_in[3],text_indenity_in[4],text_indenity_in[3],text_indenity_in[2],text_indenity_in[1],text_indenity_in[0],text_indenity_in[31]};                   
endmodule


module F_P(
    input [31:0] F_P_in,
    output [31:0] F_P_out
);
assign F_P_out = {F_P_in[16],F_P_in[25],F_P_in[12],F_P_in[11],F_P_in[3],F_P_in[20],F_P_in[4],F_P_in[15],
                  F_P_in[31],F_P_in[17],F_P_in[9],F_P_in[6],F_P_in[27],F_P_in[14],F_P_in[1],F_P_in[22],
                  F_P_in[30],F_P_in[24],F_P_in[8],F_P_in[18],F_P_in[0],F_P_in[5],F_P_in[29],F_P_in[23],
                  F_P_in[13],F_P_in[19],F_P_in[2],F_P_in[26],F_P_in[10],F_P_in[21],F_P_in[28],F_P_in[7]};
endmodule


module final_p (
    input [63:0] text_reg,
    output [63:0] text_final_p_out
);

assign text_final_p_out = {text_reg[24],text_reg[56],text_reg[16],text_reg[48],text_reg[8],text_reg[40],text_reg[0],text_reg[32],
                           text_reg[25],text_reg[57],text_reg[17],text_reg[49],text_reg[9],text_reg[41],text_reg[1],text_reg[33],
                           text_reg[26],text_reg[58],text_reg[18],text_reg[50],text_reg[10],text_reg[42],text_reg[2],text_reg[34],
                           text_reg[27],text_reg[59],text_reg[19],text_reg[51],text_reg[11],text_reg[43],text_reg[3],text_reg[35],
                           text_reg[28],text_reg[60],text_reg[20],text_reg[52],text_reg[12],text_reg[44],text_reg[4],text_reg[36],
                           text_reg[29],text_reg[61],text_reg[21],text_reg[53],text_reg[13],text_reg[45],text_reg[5],text_reg[37],
                           text_reg[30],text_reg[62],text_reg[22],text_reg[54],text_reg[14],text_reg[46],text_reg[6],text_reg[38],
                           text_reg[31],text_reg[63],text_reg[23],text_reg[55],text_reg[15],text_reg[47],text_reg[7],text_reg[39]};
endmodule

module pc1_p (
    input [63:0] key_pc1_in,
    output [55:0] key_pc1_out
);
assign key_pc1_out = {key_pc1_in[7],key_pc1_in[15],key_pc1_in[23],key_pc1_in[31],key_pc1_in[39],key_pc1_in[47],key_pc1_in[55],key_pc1_in[63],
                      key_pc1_in[6],key_pc1_in[14],key_pc1_in[22],key_pc1_in[30],key_pc1_in[38],key_pc1_in[46],key_pc1_in[54],key_pc1_in[62],
                      key_pc1_in[5],key_pc1_in[13],key_pc1_in[21],key_pc1_in[29],key_pc1_in[37],key_pc1_in[45],key_pc1_in[53],key_pc1_in[61],
                      key_pc1_in[4],key_pc1_in[12],key_pc1_in[20],key_pc1_in[28],key_pc1_in[1],key_pc1_in[9],key_pc1_in[17],key_pc1_in[25],
                      key_pc1_in[33],key_pc1_in[41],key_pc1_in[49],key_pc1_in[57],key_pc1_in[2],key_pc1_in[10],key_pc1_in[18],key_pc1_in[26],
                      key_pc1_in[34],key_pc1_in[42],key_pc1_in[50],key_pc1_in[58],key_pc1_in[3],key_pc1_in[11],key_pc1_in[19],key_pc1_in[27],
                      key_pc1_in[35],key_pc1_in[43],key_pc1_in[51],key_pc1_in[59],key_pc1_in[36],key_pc1_in[44],key_pc1_in[52],key_pc1_in[60]};
endmodule

module pc2_p (
    input [55:0] key_pc2_in,
    output [47:0] key_pc2_out
);
assign key_pc2_out = {key_pc2_in[42],key_pc2_in[39],key_pc2_in[45],key_pc2_in[32],key_pc2_in[55],key_pc2_in[51],key_pc2_in[53],key_pc2_in[28],
                       key_pc2_in[41],key_pc2_in[50],key_pc2_in[35],key_pc2_in[46],key_pc2_in[33],key_pc2_in[37],key_pc2_in[44],key_pc2_in[52],
                       key_pc2_in[30],key_pc2_in[48],key_pc2_in[40],key_pc2_in[49],key_pc2_in[29],key_pc2_in[36],key_pc2_in[43],key_pc2_in[54],
                       key_pc2_in[15],key_pc2_in[4],key_pc2_in[25],key_pc2_in[19],key_pc2_in[9],key_pc2_in[1],key_pc2_in[26],key_pc2_in[16],
                       key_pc2_in[5],key_pc2_in[11],key_pc2_in[23],key_pc2_in[8],key_pc2_in[12],key_pc2_in[7],key_pc2_in[17],key_pc2_in[0],
                       key_pc2_in[22],key_pc2_in[3],key_pc2_in[10],key_pc2_in[14],key_pc2_in[6],key_pc2_in[20],key_pc2_in[27],key_pc2_in[24]};
endmodule

module crc_8bit_lut(
    input [7:0] current_crc_in,
    output reg [2:0] current_crc_out
);

always@*
    case(current_crc_in)
        8'h00: current_crc_out = 3'd0;
        8'h01: current_crc_out = 3'd1;
        8'h02: current_crc_out = 3'd2;
        8'h03: current_crc_out = 3'd3;
        8'h04: current_crc_out = 3'd4;
        8'h05: current_crc_out = 3'd5;
        8'h06: current_crc_out = 3'd6;
        8'h07: current_crc_out = 3'd7;
        8'h08: current_crc_out = 3'd6;
        8'h09: current_crc_out = 3'd7;
        8'h0A: current_crc_out = 3'd4;
        8'h0B: current_crc_out = 3'd5;
        8'h0C: current_crc_out = 3'd2;
        8'h0D: current_crc_out = 3'd3;
        8'h0E: current_crc_out = 3'd0;
        8'h0F: current_crc_out = 3'd1;
        8'h10: current_crc_out = 3'd2;
        8'h11: current_crc_out = 3'd3;
        8'h12: current_crc_out = 3'd0;
        8'h13: current_crc_out = 3'd1;
        8'h14: current_crc_out = 3'd6;
        8'h15: current_crc_out = 3'd7;
        8'h16: current_crc_out = 3'd4;
        8'h17: current_crc_out = 3'd5;
        8'h18: current_crc_out = 3'd4;
        8'h19: current_crc_out = 3'd5;
        8'h1A: current_crc_out = 3'd6;
        8'h1B: current_crc_out = 3'd7;
        8'h1C: current_crc_out = 3'd0;
        8'h1D: current_crc_out = 3'd1;
        8'h1E: current_crc_out = 3'd2;
        8'h1F: current_crc_out = 3'd3;
        8'h20: current_crc_out = 3'd4;
        8'h21: current_crc_out = 3'd5;
        8'h22: current_crc_out = 3'd6;
        8'h23: current_crc_out = 3'd7;
        8'h24: current_crc_out = 3'd0;
        8'h25: current_crc_out = 3'd1;
        8'h26: current_crc_out = 3'd2;
        8'h27: current_crc_out = 3'd3;
        8'h28: current_crc_out = 3'd2;
        8'h29: current_crc_out = 3'd3;
        8'h2A: current_crc_out = 3'd0;
        8'h2B: current_crc_out = 3'd1;
        8'h2C: current_crc_out = 3'd6;
        8'h2D: current_crc_out = 3'd7;
        8'h2E: current_crc_out = 3'd4;
        8'h2F: current_crc_out = 3'd5;
        8'h30: current_crc_out = 3'd6;
        8'h31: current_crc_out = 3'd7;
        8'h32: current_crc_out = 3'd4;
        8'h33: current_crc_out = 3'd5;
        8'h34: current_crc_out = 3'd2;
        8'h35: current_crc_out = 3'd3;
        8'h36: current_crc_out = 3'd0;
        8'h37: current_crc_out = 3'd1;
        8'h38: current_crc_out = 3'd0;
        8'h39: current_crc_out = 3'd1;
        8'h3A: current_crc_out = 3'd2;
        8'h3B: current_crc_out = 3'd3;
        8'h3C: current_crc_out = 3'd4;
        8'h3D: current_crc_out = 3'd5;
        8'h3E: current_crc_out = 3'd6;
        8'h3F: current_crc_out = 3'd7;
        8'h40: current_crc_out = 3'd6;
        8'h41: current_crc_out = 3'd7;
        8'h42: current_crc_out = 3'd4;
        8'h43: current_crc_out = 3'd5;
        8'h44: current_crc_out = 3'd2;
        8'h45: current_crc_out = 3'd3;
        8'h46: current_crc_out = 3'd0;
        8'h47: current_crc_out = 3'd1;
        8'h48: current_crc_out = 3'd0;
        8'h49: current_crc_out = 3'd1;
        8'h4A: current_crc_out = 3'd2;
        8'h4B: current_crc_out = 3'd3;
        8'h4C: current_crc_out = 3'd4;
        8'h4D: current_crc_out = 3'd5;
        8'h4E: current_crc_out = 3'd6;
        8'h4F: current_crc_out = 3'd7;
        8'h50: current_crc_out = 3'd4;
        8'h51: current_crc_out = 3'd5;
        8'h52: current_crc_out = 3'd6;
        8'h53: current_crc_out = 3'd7;
        8'h54: current_crc_out = 3'd0;
        8'h55: current_crc_out = 3'd1;
        8'h56: current_crc_out = 3'd2;
        8'h57: current_crc_out = 3'd3;
        8'h58: current_crc_out = 3'd2;
        8'h59: current_crc_out = 3'd3;
        8'h5A: current_crc_out = 3'd0;
        8'h5B: current_crc_out = 3'd1;
        8'h5C: current_crc_out = 3'd6;
        8'h5D: current_crc_out = 3'd7;
        8'h5E: current_crc_out = 3'd4;
        8'h5F: current_crc_out = 3'd5;
        8'h60: current_crc_out = 3'd2;
        8'h61: current_crc_out = 3'd3;
        8'h62: current_crc_out = 3'd0;
        8'h63: current_crc_out = 3'd1;
        8'h64: current_crc_out = 3'd6;
        8'h65: current_crc_out = 3'd7;
        8'h66: current_crc_out = 3'd4;
        8'h67: current_crc_out = 3'd5;
        8'h68: current_crc_out = 3'd4;
        8'h69: current_crc_out = 3'd5;
        8'h6A: current_crc_out = 3'd6;
        8'h6B: current_crc_out = 3'd7;
        8'h6C: current_crc_out = 3'd0;
        8'h6D: current_crc_out = 3'd1;
        8'h6E: current_crc_out = 3'd2;
        8'h6F: current_crc_out = 3'd3;
        8'h70: current_crc_out = 3'd0;
        8'h71: current_crc_out = 3'd1;
        8'h72: current_crc_out = 3'd2;
        8'h73: current_crc_out = 3'd3;
        8'h74: current_crc_out = 3'd4;
        8'h75: current_crc_out = 3'd5;
        8'h76: current_crc_out = 3'd6;
        8'h77: current_crc_out = 3'd7;
        8'h78: current_crc_out = 3'd6;
        8'h79: current_crc_out = 3'd7;
        8'h7A: current_crc_out = 3'd4;
        8'h7B: current_crc_out = 3'd5;
        8'h7C: current_crc_out = 3'd2;
        8'h7D: current_crc_out = 3'd3;
        8'h7E: current_crc_out = 3'd0;
        8'h7F: current_crc_out = 3'd1;
        8'h80: current_crc_out = 3'd2;
        8'h81: current_crc_out = 3'd3;
        8'h82: current_crc_out = 3'd0;
        8'h83: current_crc_out = 3'd1;
        8'h84: current_crc_out = 3'd6;
        8'h85: current_crc_out = 3'd7;
        8'h86: current_crc_out = 3'd4;
        8'h87: current_crc_out = 3'd5;
        8'h88: current_crc_out = 3'd4;
        8'h89: current_crc_out = 3'd5;
        8'h8A: current_crc_out = 3'd6;
        8'h8B: current_crc_out = 3'd7;
        8'h8C: current_crc_out = 3'd0;
        8'h8D: current_crc_out = 3'd1;
        8'h8E: current_crc_out = 3'd2;
        8'h8F: current_crc_out = 3'd3;
        8'h90: current_crc_out = 3'd0;
        8'h91: current_crc_out = 3'd1;
        8'h92: current_crc_out = 3'd2;
        8'h93: current_crc_out = 3'd3;
        8'h94: current_crc_out = 3'd4;
        8'h95: current_crc_out = 3'd5;
        8'h96: current_crc_out = 3'd6;
        8'h97: current_crc_out = 3'd7;
        8'h98: current_crc_out = 3'd6;
        8'h99: current_crc_out = 3'd7;
        8'h9A: current_crc_out = 3'd4;
        8'h9B: current_crc_out = 3'd5;
        8'h9C: current_crc_out = 3'd2;
        8'h9D: current_crc_out = 3'd3;
        8'h9E: current_crc_out = 3'd0;
        8'h9F: current_crc_out = 3'd1;
        8'hA0: current_crc_out = 3'd6;
        8'hA1: current_crc_out = 3'd7;
        8'hA2: current_crc_out = 3'd4;
        8'hA3: current_crc_out = 3'd5;
        8'hA4: current_crc_out = 3'd2;
        8'hA5: current_crc_out = 3'd3;
        8'hA6: current_crc_out = 3'd0;
        8'hA7: current_crc_out = 3'd1;
        8'hA8: current_crc_out = 3'd0;
        8'hA9: current_crc_out = 3'd1;
        8'hAA: current_crc_out = 3'd2;
        8'hAB: current_crc_out = 3'd3;
        8'hAC: current_crc_out = 3'd4;
        8'hAD: current_crc_out = 3'd5;
        8'hAE: current_crc_out = 3'd6;
        8'hAF: current_crc_out = 3'd7;
        8'hB0: current_crc_out = 3'd4;
        8'hB1: current_crc_out = 3'd5;
        8'hB2: current_crc_out = 3'd6;
        8'hB3: current_crc_out = 3'd7;
        8'hB4: current_crc_out = 3'd0;
        8'hB5: current_crc_out = 3'd1;
        8'hB6: current_crc_out = 3'd2;
        8'hB7: current_crc_out = 3'd3;
        8'hB8: current_crc_out = 3'd2;
        8'hB9: current_crc_out = 3'd3;
        8'hBA: current_crc_out = 3'd0;
        8'hBB: current_crc_out = 3'd1;
        8'hBC: current_crc_out = 3'd6;
        8'hBD: current_crc_out = 3'd7;
        8'hBE: current_crc_out = 3'd4;
        8'hBF: current_crc_out = 3'd5;
        8'hC0: current_crc_out = 3'd4;
        8'hC1: current_crc_out = 3'd5;
        8'hC2: current_crc_out = 3'd6;
        8'hC3: current_crc_out = 3'd7;
        8'hC4: current_crc_out = 3'd0;
        8'hC5: current_crc_out = 3'd1;
        8'hC6: current_crc_out = 3'd2;
        8'hC7: current_crc_out = 3'd3;
        8'hC8: current_crc_out = 3'd2;
        8'hC9: current_crc_out = 3'd3;
        8'hCA: current_crc_out = 3'd0;
        8'hCB: current_crc_out = 3'd1;
        8'hCC: current_crc_out = 3'd6;
        8'hCD: current_crc_out = 3'd7;
        8'hCE: current_crc_out = 3'd4;
        8'hCF: current_crc_out = 3'd5;
        8'hD0: current_crc_out = 3'd6;
        8'hD1: current_crc_out = 3'd7;
        8'hD2: current_crc_out = 3'd4;
        8'hD3: current_crc_out = 3'd5;
        8'hD4: current_crc_out = 3'd2;
        8'hD5: current_crc_out = 3'd3;
        8'hD6: current_crc_out = 3'd0;
        8'hD7: current_crc_out = 3'd1;
        8'hD8: current_crc_out = 3'd0;
        8'hD9: current_crc_out = 3'd1;
        8'hDA: current_crc_out = 3'd2;
        8'hDB: current_crc_out = 3'd3;
        8'hDC: current_crc_out = 3'd4;
        8'hDD: current_crc_out = 3'd5;
        8'hDE: current_crc_out = 3'd6;
        8'hDF: current_crc_out = 3'd7;
        8'hE0: current_crc_out = 3'd0;
        8'hE1: current_crc_out = 3'd1;
        8'hE2: current_crc_out = 3'd2;
        8'hE3: current_crc_out = 3'd3;
        8'hE4: current_crc_out = 3'd4;
        8'hE5: current_crc_out = 3'd5;
        8'hE6: current_crc_out = 3'd6;
        8'hE7: current_crc_out = 3'd7;
        8'hE8: current_crc_out = 3'd6;
        8'hE9: current_crc_out = 3'd7;
        8'hEA: current_crc_out = 3'd4;
        8'hEB: current_crc_out = 3'd5;
        8'hEC: current_crc_out = 3'd2;
        8'hED: current_crc_out = 3'd3;
        8'hEE: current_crc_out = 3'd0;
        8'hEF: current_crc_out = 3'd1;
        8'hF0: current_crc_out = 3'd2;
        8'hF1: current_crc_out = 3'd3;
        8'hF2: current_crc_out = 3'd0;
        8'hF3: current_crc_out = 3'd1;
        8'hF4: current_crc_out = 3'd6;
        8'hF5: current_crc_out = 3'd7;
        8'hF6: current_crc_out = 3'd4;
        8'hF7: current_crc_out = 3'd5;
        8'hF8: current_crc_out = 3'd4;
        8'hF9: current_crc_out = 3'd5;
        8'hFA: current_crc_out = 3'd6;
        8'hFB: current_crc_out = 3'd7;
        8'hFC: current_crc_out = 3'd0;
        8'hFD: current_crc_out = 3'd1;
        8'hFE: current_crc_out = 3'd2;
        8'hFF: current_crc_out = 3'd3;

    endcase


endmodule
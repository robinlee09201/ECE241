module Lab7part1 (
	input [9:0]SW,
	input [0:0]KEY,
	output [0:6]HEX0,HEX2,HEX4,HEX5);
	wire [3:0]outdata;
	HEX_decorder HEX2_(SW[3:0],HEX2[0:6]);
	ram32x4 ram0(SW[8:4],KEY[0],SW[3:0],SW[9],outdata);
	HEX_decorder HEX0_(outdata[3:0],HEX0[0:6]);
	HEX_decorder HEX4_(SW[7:4],HEX4[0:6]);
	HEX_decorder HEX5_({SW[8],3'b000},HEX5[0:6]);
endmodule

module HEX_decorder(SW,HEX0);

	input[3:0] SW;
	output reg [0:6] HEX0;
	always@*
		case(SW)
		0: HEX0 = 7'b0000001;
		1: HEX0 = 7'b1001111;
		2: HEX0 = 7'b0010010;
		3: HEX0 = 7'b0000110;
		4: HEX0 = 7'b1001100;
		5: HEX0 = 7'b0100100;
		6: HEX0 = 7'b0100000;
		7: HEX0 = 7'b0001111;
		8: HEX0 = 7'b0000000;
		9: HEX0 = 7'b0000100;
		10: HEX0 = 7'b0001000;
		11: HEX0 = 7'b1100000;
		12: HEX0 = 7'b0110001;
		13: HEX0 = 7'b1000010;
		14: HEX0 = 7'b0110000;
		15: HEX0 = 7'b0111000;
		default:HEX0 = 7'b0000000;
	endcase
endmodule
// Part 2 skeleton

module fill
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK,						//	VGA BLANK
		VGA_SYNC,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK;				//	VGA BLANK
	output			VGA_SYNC;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK),
			.VGA_SYNC(VGA_SYNC),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
    
	 
	 
    // Instanciate datapath
	
    // Instanciate FSM control

endmodule


module FSM (key1, key2, selectA , selectB , LD_A, LD_B, ALU_OP, load, key0, clock, LD_out);
parameter [2:0] AX_S = 3'b000, AXX_S = 3'b001, BX_S = 3'b010, AXX_BX_S = 3'b011, AXX_BX_C_S = 3'b100, RESET_S = 3'b111, LOAD_AX_S = 3'b101, LOAD_BC_S = 3'b110;
parameter MULTI = 0, ADD = 1;
parameter[1:0] selRX = 2'b00, selRA = 2'b01, selRB= 2'b10, selRC = 2'b11;
  input key1, key2, key0, clock;
  output reg [1:0] selectA , selectB;
  output reg LD_A, LD_B, ALU_OP,LD_out, load;
  reg [2:0]PresentState, NextState;

  always@(*) begin 
    case (PresentState) 
	RESET_S:
				if(key1==0)
					NextState = LOAD_AX_S;
				else
					NextState = RESET_S;
	LOAD_AX_S:
				if(key1==0&&key2==1)
					NextState = LOAD_BC_S;
				else
					NextState = LOAD_AX_S;
	LOAD_BC_S:
				if(key1==1&&key2==1)
					NextState = AX_S;
				else if(key1==0&&key2==1)
					NextState = LOAD_AX_S;
				else
					NextState = LOAD_BC_S;
      AX_S: NextState = AXX_S;
      AXX_S: NextState = BX_S;
      BX_S: NextState = AXX_BX_S;
      AXX_BX_S: NextState = AXX_BX_C_S;
      default: NextState = RESET_S;
    endcase
  end

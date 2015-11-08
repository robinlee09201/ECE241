// Part 2 skeleton

module Lab7part2
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
    
		reg [6:0]posX,posY;
		reg [0:0]enable;
		reg [6:0]FSMX,FSMY;
		wire [6:0]FSM_X,FSM_Y;
		wire [0:0]enable_;
		assign FSM_X = FSMX;
		assign FSM_Y = FSMY;
		assign enable_ = enable;
		//Load X
		always@(posedge KEY[3])
			if(KEY[0]==0)
				posX<=7'b0;
			else 
				posX<=SW[6:0];
		//Load Y
		always@(posedge KEY[1])
			if(KEY[0]==0)
				posY<=7'b0;
			else
				begin
				posY<=SW[6:0];
				enable = 1'b1;
				end
		
    // Instanciate datapath
		datapath data_(SW[9:7],posX,posY,x,y,colour,KEY[0],CLOCK_50,KEY[2],FSM_X,FSM_Y);
    // Instanciate FSM control
		FSM fsm_(KEY[2],enable,KEY[0],CLOCK_50,FSM_X,FSM_Y,enable_);
endmodule


module FSM (
input [0:0]Black,Plot,ResetN,Clk,
inout [6:0]fsmx,fsmy,
inout [0:0]enable_);
	reg[6:0]FSMX,FSMY;
	reg[0:0]enable;
	assign fsmx = FSMX;
	assign fsmy = FSMY;
	assign enable_ = enable;
	always@(posedge Clk)
	if(ResetN==0)
		enable <=0;
	else if(Plot==1)
		begin
			if(Black==0)
				begin
				if(FSMY==3&&FSMX==3)
					begin
					FSMY <= 0;
					FSMX <= 0;
					enable <= 0;
					end
				else if(FSMX==3)
					begin
					FSMY <= FSMY +1;
					FSMX <= 0;
					enable <= 1;
					end
				else
					begin
					FSMY <= FSMY +1;
					FSMX <= FSMX +1;
					enable <= 1;
					end
				end
			else
				begin
				if(FSMX==160&&FSMY==120)
					begin
					FSMY <= 0;
					FSMX <= 0;
					enable <= 0;
					end
				else if(FSMX==160)
					begin
					FSMY <= FSMY +1;
					FSMX <= 0;
					enable <= 1;
					end
				else
					begin
					FSMY <= FSMY +1;
					FSMX <= FSMX +1;
					enable <= 1;
					end
				end
		end
endmodule
 
module datapath(
input [2:0]colorIn,
input [6:0]posXin,posYin,
output reg[7:0]posXout,
output reg[6:0]posYout,
output reg[2:0]colorOut,
input [0:0]ResetN,clk,Black,
inout [6:0]FSMX_,FSMY_);
	reg[6:0]FSMX,FSMY;
	assign FSMX_ = FSMX;
	assign FSMY_ = FSMY;
	always@(posedge clk)
	if(ResetN==0)
		begin
			FSMX <= 0;
			FSMY <= 0;
		end
	else if(Black == 1)
		begin
			posXout = {1'b0,FSMX};
			posYout = FSMY;
			colorOut = 3'b000;
		end
	else 
		begin
			posXout = {1'b0,posXin + FSMX};
			posYout = posYin + FSMY;
			colorOut = colorIn;
		end
 
endmodule


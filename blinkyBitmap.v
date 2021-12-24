
module Blinky(clk, ce, shpos, svpos, col, direction, xpos, ypos, aiState, aiTimer);
  
  parameter [11:0] colorMap = {`WHITE, `BLUE, `RED, `BLACK};
  parameter [11:0] frightenedColors = {`WHITE, `BLACK, `BLUE, `BLACK};
  parameter [11:0] frightened1Colors = {`RED, `BLACK, `WHITE, `BLACK};
  parameter [11:0] deadColors = {`WHITE, `BLUE, `BLACK, `BLACK};
  
  parameter WAIT_FRAME_TIME = 40 / (60 / `FRAME_RATE);
  
  //back, primary, eyes, eyes outer
  
  input clk;
  input ce;
  
  input [9:0] shpos;
  input [9:0] svpos;
  
  input [4:0] xpos;
  input [4:0] ypos;
  input [1:0] direction;
  input [3:0] aiState;
  input [5:0] aiTimer;
  
  output reg [2:0] col;
  
  reg animState = 0;
  
  wire [9:0] xScreenPos = {2'b0, xpos, 3'b0} - 20;
  wire [9:0] yScreenPos = {2'b0, ypos, 3'b0} - 20;
  
  wire [3:0] ysprpos;
  wire [3:0] xsprpos;
  
  wire [1:0] colIn;
  wire [1:0] infearColIn;
  
  reg [5:0] counter = 0;
  
  
  AnimatedSprite sprite(
    .clk(clk), 
    .shpos(shpos), 
    .svpos(svpos), 
    .xpos(xScreenPos), 
    .ypos(yScreenPos), 
    .yout(ysprpos), 
    .xout(xsprpos)
  );
  
  BlinkyBitmap blinky(
    .animState(animState), 
    .direction(direction), 
    .yin(ysprpos), 
    .xin(xsprpos), 
    .out(colIn)
  );
  
  FrightenedBitmap infear(
    .animState(animState), 
    .yin(ysprpos), 
    .xin(xsprpos), 
    .out(infearColIn)
  );
  
  always @(posedge clk) begin
    if (aiState[2:0] != `AI_FRIGHTENED)
      if (aiState == `AI_DEAD)
        col <= deadColors[colIn*3+:3];
      else
    	col <= colorMap[colIn*3+:3];
    else begin
      if (aiTimer <= 8 || animState)
        col <= frightenedColors[infearColIn*3+:3];
      else
        col <= frightened1Colors[infearColIn*3+:3];
    end
    
    if (ce) begin
      counter <= counter + 1'b1;
      if (counter >= WAIT_FRAME_TIME) begin
        counter <= 0;
        
        animState <= ~animState;
          
      end
    end
  end
  
  
endmodule


module BlinkyBitmap(animState, direction, yin, xin, out);
  
  input animState;
  input [1:0] direction;  
  input [3:0] yin;
  input [3:0] xin;
  output [1:0] out;
  
  reg [31:0] pacman[0:127];
  
  wire [6:0] caseexpr = {direction, animState, yin};
  
  assign out = pacman[caseexpr][xin*2+:2];
  
  initial begin
    /*{w:16,h:16,bpp:2, bpw:32,count:8}*/
    pacman['h00] = 32'b0;
    pacman['h01] = 32'b1010101000000000000;
    pacman['h02] = 32'b101001010101101000000000;
    pacman['h03] = 32'b11101011010111101011000000;
    pacman['h04] = 32'b111111111010111111111010000;
    pacman['h05] = 32'b111111111010111111111010000;
    pacman['h06] = 32'b101111101010101111101010000;
    pacman['h07] = 32'b10101010101010101010101010100;
    pacman['h08] = 32'b10101010101010101010101010100;
    pacman['h09] = 32'b10101010101010101010101010100;
    pacman['h0A] = 32'b10101010101010101010101010100;
    pacman['h0B] = 32'b10101010101010101010101010100;
    pacman['h0C] = 32'b10101010101010101010101010100;
    pacman['h0D] = 32'b10100010101000001010100010100;
    pacman['h0E] = 32'b10000000101000001010000000100;
    pacman['h0F] = 32'b0;
    
    pacman['h10] = 32'b0;
    pacman['h11] = 32'b1010101000000000000;
    pacman['h12] = 32'b101001010101101000000000;
    pacman['h13] = 32'b11101011010111101011000000;
    pacman['h14] = 32'b111111111010111111111010000;
    pacman['h15] = 32'b111111111010111111111010000;
    pacman['h16] = 32'b101111101010101111101010000;
    pacman['h17] = 32'b10101010101010101010101010100;
    pacman['h18] = 32'b10101010101010101010101010100;
    pacman['h19] = 32'b10101010101010101010101010100;
    pacman['h1A] = 32'b10101010101010101010101010100;
    pacman['h1B] = 32'b10101010101010101010101010100;
    pacman['h1C] = 32'b10101010101010101010101010100;
    pacman['h1D] = 32'b10101010001010101000101010100;
    pacman['h1E] = 32'b101000000010100000001010000;
    pacman['h1F] = 32'b0;
    
    pacman['h20] = 32'b0;
    pacman['h21] = 32'b1010101000000000000;
    pacman['h22] = 32'b10101010101010100000000;
    pacman['h23] = 32'b1010101010101010101000000;
    pacman['h24] = 32'b101011111010101011111010000;
    pacman['h25] = 32'b101111111110101111111110000;
    pacman['h26] = 32'b101111110100101111110100000;
    pacman['h27] = 32'b10101111110100101111110100100;
    pacman['h28] = 32'b10101011111010101011111010100;
    pacman['h29] = 32'b10101010101010101010101010100;
    pacman['h2A] = 32'b10101010101010101010101010100;
    pacman['h2B] = 32'b10101010101010101010101010100;
    pacman['h2C] = 32'b10101010101010101010101010100;
    pacman['h2D] = 32'b10100010101000001010100010100;
    pacman['h2E] = 32'b10000000101000001010000000100;
    pacman['h2F] = 32'b0;
    
    pacman['h30] = 32'b0;
    pacman['h31] = 32'b1010101000000000000;
    pacman['h32] = 32'b10101010101010100000000;
    pacman['h33] = 32'b1010101010101010101000000;
    pacman['h34] = 32'b101011111010101011111010000;
    pacman['h35] = 32'b101111111110101111111110000;
    pacman['h36] = 32'b101111110100101111110100000;
    pacman['h37] = 32'b10101111110100101111110100100;
    pacman['h38] = 32'b10101011111010101011111010100;
    pacman['h39] = 32'b10101010101010101010101010100;
    pacman['h3A] = 32'b10101010101010101010101010100;
    pacman['h3B] = 32'b10101010101010101010101010100;
    pacman['h3C] = 32'b10101010101010101010101010100;
    pacman['h3D] = 32'b10101010001010101000101010100;
    pacman['h3E] = 32'b101000000010100000001010000;
    pacman['h3F] = 32'b0;
    
    pacman['h40] = 32'b0;
    pacman['h41] = 32'b1010101000000000000;
    pacman['h42] = 32'b10101010101010100000000;
    pacman['h43] = 32'b1010101010101010101000000;
    pacman['h44] = 32'b101010101010101010101010000;
    pacman['h45] = 32'b101111101010101111101010000;
    pacman['h46] = 32'b111111111010111111111010000;
    pacman['h47] = 32'b10111111111010111111111010100;
    pacman['h48] = 32'b10111101011010111101011010100;
    pacman['h49] = 32'b10101101001010101101001010100;
    pacman['h4A] = 32'b10101010101010101010101010100;
    pacman['h4B] = 32'b10101010101010101010101010100;
    pacman['h4C] = 32'b10101010101010101010101010100;
    pacman['h4D] = 32'b10100010101000001010100010100;
    pacman['h4E] = 32'b10000000101000001010000000100;
    pacman['h4F] = 32'b0;
    
    pacman['h50] = 32'b0;
    pacman['h51] = 32'b1010101000000000000;
    pacman['h52] = 32'b10101010101010100000000;
    pacman['h53] = 32'b1010101010101010101000000;
    pacman['h54] = 32'b101010101010101010101010000;
    pacman['h55] = 32'b101111101010101111101010000;
    pacman['h56] = 32'b111111111010111111111010000;
    pacman['h57] = 32'b10111111111010111111111010100;
    pacman['h58] = 32'b10111101011010111101011010100;
    pacman['h59] = 32'b10101101001010101101001010100;
    pacman['h5A] = 32'b10101010101010101010101010100;
    pacman['h5B] = 32'b10101010101010101010101010100;
    pacman['h5C] = 32'b10101010101010101010101010100;
    pacman['h5D] = 32'b10101010001010101000101010100;
    pacman['h5E] = 32'b101000000010100000001010000;
    pacman['h5F] = 32'b0;
    
    pacman['h60] = 32'b0;
    pacman['h61] = 32'b1010101000000000000;
    pacman['h62] = 32'b10101010101010100000000;
    pacman['h63] = 32'b1010101010101010101000000;
    pacman['h64] = 32'b111110101010111110101010000;
    pacman['h65] = 32'b1111111101011111111101010000;
    pacman['h66] = 32'b1010111101011010111101010000;
    pacman['h67] = 32'b11010111101011010111101010100;
    pacman['h68] = 32'b10111110101010111110101010100;
    pacman['h69] = 32'b10101010101010101010101010100;
    pacman['h6A] = 32'b10101010101010101010101010100;
    pacman['h6B] = 32'b10101010101010101010101010100;
    pacman['h6C] = 32'b10101010101010101010101010100;
    pacman['h6D] = 32'b10100010101000001010100010100;
    pacman['h6E] = 32'b10000000101000001010000000100;
    pacman['h6F] = 32'b0;
    
    pacman['h70] = 32'b0;
    pacman['h71] = 32'b1010101000000000000;
    pacman['h72] = 32'b10101010101010100000000;
    pacman['h73] = 32'b1010101010101010101000000;
    pacman['h74] = 32'b111110101010111110101010000;
    pacman['h75] = 32'b1111111101011111111101010000;
    pacman['h76] = 32'b1010111101011010111101010000;
    pacman['h77] = 32'b11010111101011010111101010100;
    pacman['h78] = 32'b10111110101010111110101010100;
    pacman['h79] = 32'b10101010101010101010101010100;
    pacman['h7A] = 32'b10101010101010101010101010100;
    pacman['h7B] = 32'b10101010101010101010101010100;
    pacman['h7C] = 32'b10101010101010101010101010100;
    pacman['h7D] = 32'b10101010001010101000101010100;
    pacman['h7E] = 32'b101000000010100000001010000;
    pacman['h7F] = 32'b0;
    
  end
  
endmodule

module FrightenedBitmap(animState, yin, xin, out);
  
  input animState; 
  input [3:0] yin;
  input [3:0] xin;
  output [1:0] out;
  
  reg [31:0] pacman[0:31];
  
  wire [4:0] caseexpr = {animState, yin};
  
  assign out = pacman[caseexpr][xin*2+:2];
  
  initial begin
    /*{w:16,h:16,bpp:2, bpw:32,count:2}*/
    pacman['h00] = 32'b0;
    pacman['h01] = 32'b1010101000000000000;
    pacman['h02] = 32'b10101010101010100000000;
    pacman['h03] = 32'b1010101010101010101000000;
    pacman['h04] = 32'b101010101010101010101010000;
    pacman['h05] = 32'b101010101010101010101010000;
    pacman['h06] = 32'b101011111010111110101010000;
    pacman['h07] = 32'b10101011111010111110101010100;
    pacman['h08] = 32'b10101010101010101010101010100;
    pacman['h09] = 32'b10101010101010101010101010100;
    pacman['h0A] = 32'b10111110101111101011111010100;
    pacman['h0B] = 32'b11101011111010111110101110100;
    pacman['h0C] = 32'b10101010101010101010101010100;
    pacman['h0D] = 32'b10100010101000001010100010100;
    pacman['h0E] = 32'b10000000101000001010000000100;
    pacman['h0F] = 32'b0;
    
    pacman['h10] = 32'b0;
    pacman['h11] = 32'b1010101000000000000;
    pacman['h12] = 32'b10101010101010100000000;
    pacman['h13] = 32'b1010101010101010101000000;
    pacman['h14] = 32'b101010101010101010101010000;
    pacman['h15] = 32'b101010101010101010101010000;
    pacman['h16] = 32'b101011111010111110101010000;
    pacman['h17] = 32'b10101011111010111110101010100;
    pacman['h18] = 32'b10101010101010101010101010100;
    pacman['h19] = 32'b10101010101010101010101010100;
    pacman['h1A] = 32'b10111110101111101011111010100;
    pacman['h1B] = 32'b11101011111010111110101110100;
    pacman['h1C] = 32'b10101010101010101010101010100;
    pacman['h1D] = 32'b10101010001010101000101010100;
    pacman['h1E] = 32'b101000000010100000001010000;
    pacman['h1F] = 32'b0;
    
  end
  
endmodule
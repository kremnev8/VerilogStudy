
module Pacman(clk, ce, shpos, svpos, col, direction, xpos, ypos);
  
  parameter BORDER_X_MIN = 1;
  parameter BORDER_X_MAX = 28;
  parameter BORDER_Y_MIN = 1;
  parameter BORDER_Y_MAX = 28;
  
  parameter PRIMARY_COLOR = 1;
  
  parameter WAIT_FRAME_TIME = 18 / (60 / `FRAME_RATE);
  
  input clk;
  input ce;
  
  input [9:0] shpos;
  input [9:0] svpos;
  
  input [4:0] xpos;
  input [4:0] ypos;
  input [1:0] direction;
  //input mapData;
  
  output [2:0] col = colIn ? PRIMARY_COLOR : 0;;
  
  //reg [4:0] xpos = 2;
  //reg [4:0] ypos = 2;
  
  //output [4:0] oxPos = nextXPos;
  //output [4:0] oyPos = nextYPos;
  
  //wire [4:0] nextXPos = direction == 1 ? xpos - 1'b1 : direction == 3 ? xpos + 1'b1 : xpos;
  //wire [4:0] nextYPos = direction == 0 ? ypos - 1'b1 : direction == 2 ? ypos + 1'b1 : ypos;
  
  reg animState = 0;
  
  wire [9:0] xScreenPos = {2'b0, xpos, 3'b0} - 20;
  wire [9:0] yScreenPos = {2'b0, ypos, 3'b0} - 20;
  
  wire [3:0] ysprpos;
  wire [3:0] xsprpos;
  
  reg [5:0] counter = 0;
  
  wire colIn;
  
  
  AnimatedSprite sprite(
    .clk(clk), 
    .shpos(shpos), 
    .svpos(svpos), 
    .xpos(xScreenPos), 
    .ypos(yScreenPos), 
    .yout(ysprpos), 
    .xout(xsprpos)
  );
  
  PacManBitmap bitmap(
    .animState(animState), 
    .direction(direction), 
    .yin(ysprpos), 
    .xin(xsprpos), 
    .out(colIn)
  );
  
  always @(posedge clk) begin
    if (ce) begin
      counter <= counter + 1'b1;
      if (counter >= WAIT_FRAME_TIME) begin
        counter <= 0;
        
        animState <= ~animState;
          
      end
    end
  end
  
  
endmodule
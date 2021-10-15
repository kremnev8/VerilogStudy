

module AnimatedSprite(clk, shpos, svpos, rgb, 
                      xpos, ypos, 
                      animState, yin, xin, out);
  
  parameter FRAME_LEN = 2;
  parameter FRAME_TIME = 30;
  
  parameter SPRITE_SIZE = 16;
  
  parameter PRIMARY_COLOR = 1;
  
  input clk;
  input [9:0] shpos;
  input [9:0] svpos;
  
  output [2:0] rgb;
  
  input [9:0] xpos;
  input [9:0] ypos;
  
  output reg animState;
  output reg [3:0] yin;
  output reg [3:0] xin;
  input out;
  
  reg [7:0] frameCounter = 0;
  
  wire signed [9:0] deltaX = shpos - (xpos + SPRITE_SIZE/2);
  wire signed [9:0] deltaY = svpos - (ypos + SPRITE_SIZE/2);
  
  assign rgb = out ? PRIMARY_COLOR : 0;
  
  always @(posedge clk) begin
    if (deltaX > 0 && deltaY > 0 && deltaX < SPRITE_SIZE && deltaY < SPRITE_SIZE) begin
      yin <= deltaY[3:0];
      xin <= deltaX[3:0];
    end
    
  end
  
endmodule
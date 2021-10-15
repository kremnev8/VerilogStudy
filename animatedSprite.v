

module AnimatedSprite(clk, shpos, svpos, col, 
                      xpos, ypos, 
                      yout, xout, colIn);
  
  parameter FRAME_LEN = 2;
  parameter FRAME_TIME = 30;
  
  parameter SPRITE_SIZE = 16;
  
  parameter PRIMARY_COLOR = 1;
  
  input clk;
  input [9:0] shpos;
  input [9:0] svpos;
  
  output [2:0] col;
  
  input [9:0] xpos;
  input [9:0] ypos;
  
  output reg [3:0] yout;
  output reg [3:0] xout;
  input colIn;
  
  reg [7:0] frameCounter = 0;
  
  wire signed [9:0] deltaX = shpos / 2 - (xpos + SPRITE_SIZE/2);
  wire signed [9:0] deltaY = svpos / 2- (ypos + SPRITE_SIZE/2);
  
  assign col = colIn ? PRIMARY_COLOR : 0;
  
  always @(posedge clk) begin
    if (deltaX > 0 && deltaY > 0 && deltaX < SPRITE_SIZE && deltaY < SPRITE_SIZE) begin
      yout <= deltaY[3:0];
      xout <= deltaX[3:0];
    end else begin
      yout <= 0;
      xout <= 0;
    end
  end
  
endmodule
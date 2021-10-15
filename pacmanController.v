
module Pacman(clk, shpos, svpos, col, direction);
  
  parameter BORDER_X_MIN = -4;
  parameter BORDER_X_MAX = 196;
  parameter BORDER_Y_MIN = -4;
  parameter BORDER_Y_MAX = 196;
  
  input clk;
  input [9:0] shpos;
  input [9:0] svpos;
  output [2:0] col;
  
  reg signed [9:0] xpos = 100;
  reg signed [9:0] ypos = 100;
  
  input [1:0] direction;
  
  reg animState = 0;
  
  wire [3:0] ysprpos;
  wire [3:0] xsprpos;
  
  wire colIn;
  
  reg [7:0] counter = 0;
  
  
  AnimatedSprite sprite(
    .clk(clk), 
    .shpos(shpos), 
    .svpos(svpos), 
    .col(col), 
    .xpos(xpos), 
    .ypos(ypos), 
    .yout(ysprpos), 
    .xout(xsprpos), 
    .colIn(colIn)
  );
  
  PacManBitmap bitmap(
    .animState(animState), 
    .direction(direction), 
    .yin(ysprpos), 
    .xin(xsprpos), 
    .out(colIn)
  );
  
  always @(posedge clk) begin
    if (svpos == 480) begin
      counter <= counter + 1'b1;
      if (counter == 144) begin
        counter <= 0;
        
        animState <= ~animState;
        
        if (direction == 1) 
          xpos <= xpos - 1'b1;
        else if (direction == 3)
          xpos <= xpos + 1'b1;
        else if (direction == 0) 
          ypos <= ypos - 1'b1;
        else if (direction == 2)
          ypos <= ypos + 1'b1;
        
        if (xpos < BORDER_X_MIN)
          xpos <= BORDER_X_MIN;
        else if (xpos > BORDER_X_MAX)
          xpos <= BORDER_X_MAX;
        
        if (ypos < BORDER_Y_MIN)
          ypos <= BORDER_Y_MIN;
        else if (ypos > BORDER_Y_MAX)
          ypos <= BORDER_Y_MAX;
          
      end
    end
    
  end
  
  
endmodule
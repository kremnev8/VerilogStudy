
module ColorMixer (gridColor, pelletColor, 
                   text1Color, lifeColor, numbersColor, 
                   pacmanColor, blinkyColor, pinkyColor, rgb);
  
  input [2:0] gridColor;
  input [2:0] pelletColor;
  input [2:0] text1Color;
  input [2:0] lifeColor;
  
  input [2:0] numbersColor;
  
  input [2:0] pacmanColor;
  input [2:0] blinkyColor;
  input [2:0] pinkyColor;
  
  output [3:0] rgb;
  
  reg [2:0] totalColor;
  
  always @(*) begin
    if (gridColor != 0)
      totalColor = gridColor;
    else if (numbersColor != 0)
      totalColor = numbersColor;
    else if (text1Color != 0)
      totalColor = text1Color;
    else if (lifeColor != 0)
      totalColor = lifeColor;
    
    else if (pacmanColor != 0)
      totalColor = pacmanColor; 
    else if (blinkyColor != 0)
      totalColor = blinkyColor; 
    else if (pinkyColor != 0)
      totalColor = pinkyColor; 
    
    else if (pelletColor != 0)
      totalColor = pelletColor;
    else
      totalColor = 0;
    
  end
  
   ColorIndex Palette(
     .index(totalColor), 
     .color(rgb)
   );
  
endmodule

module ColorIndex(index, color);
  
  input [2:0] index;		
  output reg [3:0] color;	
  
  always @(*)
    case (index)     //gbgr
      3'd0: color = 4'b0000; //black
      3'd1: color = 4'b0011; //yellow
      3'd2: color = 4'b0001; //red
      3'd3: color = 4'b0111; //white
      
      3'd4: color = 4'b0100; //blue
      3'd5: color = 4'b1101; //pink
      3'd6: color = 4'b0110; //cyan
      3'd7: color = 4'b1011; //orange

      default: color = 0;
    endcase
endmodule
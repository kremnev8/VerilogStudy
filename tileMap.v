
module tileMap(tileType, rotation, yin, xin, out);
  
  input [1:0] tileType;	
  input [1:0] rotation;
  input [2:0] yin;
  input [2:0] xin;
  
  wire transpose = rotation == 1 || rotation == 3;
  wire flipY = rotation == 2 || rotation == 3;
  wire flipX = rotation == 1 || rotation == 2;
  
  
  wire [2:0] xpos1 = !transpose ? yin : xin;
  wire [2:0] ypos1 = !transpose ? xin : yin;
  
  wire [2:0] xpos = !flipX ? ~xpos1 : xpos1;
  wire [2:0] ypos = !flipY ? ~ypos1 : ypos1;
  
  output [2:0] out = bits[xpos] ? 3'd4 : 3'd0;
  
  reg [7:0] bits;

  // combine {digit,yofs} into single ROM address
  wire [4:0] caseexpr = {tileType, ypos};
  
  always @(*)
    case (caseexpr)/*{w:8,h:8,count:3}*/
      5'o10: bits = 8'b10000;
      5'o11: bits = 8'b10000;
      5'o12: bits = 8'b10000;
      5'o13: bits = 8'b10000;
      5'o14: bits = 8'b10000;
      5'o15: bits = 8'b10000;
      5'o16: bits = 8'b10000;
      5'o17: bits = 8'b10000;
      
      5'o20: bits = 8'b0;
      5'o21: bits = 8'b0;
      5'o22: bits = 8'b0;
      5'o23: bits = 8'b111;
      5'o24: bits = 8'b1000;
      5'o25: bits = 8'b10000;
      5'o26: bits = 8'b10000;
      5'o27: bits = 8'b10000;
      
      5'o30: bits = 8'b0;
      5'o31: bits = 8'b0;
      5'o32: bits = 8'b0;
      5'o33: bits = 8'b0;
      5'o34: bits = 8'b11;
      5'o35: bits = 8'b100;
      5'o36: bits = 8'b1000;
      5'o37: bits = 8'b1000;

      default: bits = 0;
    endcase
endmodule
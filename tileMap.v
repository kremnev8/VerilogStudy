
module tileMap(tileType, rotation, ypos, xpos, out);
  
  input [1:0] tileType;	
  input [1:0] rotation;
  input [2:0] ypos;
  input [2:0] xpos;
  
  output out = bits[~xpos];
  
  reg [7:0] bits;	// output (5 bits)

  // combine {digit,yofs} into single ROM address
  wire [4:0] caseexpr = {tileType, ypos};
  
  always @(*)
    case (caseexpr)/*{w:5,h:5,count:10}*/
      5'o10: bits = 8'b00010000;
      5'o11: bits = 8'b00010000;
      5'o12: bits = 8'b00010000;
      5'o13: bits = 8'b00010000;
      5'o14: bits = 8'b00010000;
      5'o15: bits = 8'b00010000;
      5'o16: bits = 8'b00010000;
      5'o17: bits = 8'b00010000;
      
      5'o20: bits = 8'b00000000;
      5'o21: bits = 8'b00000000;
      5'o22: bits = 8'b00000000;
      5'o23: bits = 8'b00000111;
      5'o24: bits = 8'b00001000;
      5'o25: bits = 8'b00010000;
      5'o26: bits = 8'b00010000;
      5'o27: bits = 8'b00010000;
      
      5'o30: bits = 8'b00000000;
      5'o31: bits = 8'b00000000;
      5'o32: bits = 8'b00000000;
      5'o33: bits = 8'b00000000;
      5'o34: bits = 8'b00000011;
      5'o35: bits = 8'b00000100;
      5'o36: bits = 8'b00001000;
      5'o37: bits = 8'b00001000;

      default: bits = 0;
    endcase
endmodule
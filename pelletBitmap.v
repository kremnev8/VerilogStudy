
module pelletBitmap(sprite, yin, xin, out);
  
  input [1:0] sprite;
  input [2:0] yin;
  input [2:0] xin;
  
  output out;
  assign out = bits[~xin];
  
  reg [7:0] bits;
  
  always @(*)
    case ({sprite, yin})/*{w:8,h:8,count:2}*/
      5'o10: bits = 8'b0;
      5'o11: bits = 8'b0;
      5'o12: bits = 8'b0;
      5'o13: bits = 8'b11000;
      5'o14: bits = 8'b11000;
      5'o15: bits = 8'b0;
      5'o16: bits = 8'b0;
      5'o17: bits = 8'b0;
     
      5'o20: bits = 8'b0;
      5'o21: bits = 8'b11000;
      5'o22: bits = 8'b111100;
      5'o23: bits = 8'b1111110;
      5'o24: bits = 8'b1111110;
      5'o25: bits = 8'b111100;
      5'o26: bits = 8'b11000;
      5'o27: bits = 8'b0;

      default: bits = 0;
    endcase
endmodule
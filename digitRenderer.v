
module CharacterRenderer(digitData, shpos, svpos, digit, xofs, yofs, colIn, colOut, color);
  
  parameter SPRITE_SIZE = 8;
  
  parameter X_POS = 455;
  parameter Y_POS = 50;
  
  parameter X_OFFSET = X_POS + 1;
  parameter Y_OFFSET = Y_POS + 1;
  
  parameter X_SCALE = 4;
  parameter Y_SCALE = 8;
  
  parameter DIRECTION = 1;
  
  parameter DIGITS = 5;
  parameter DATA_WIDTH = 4;
  parameter TOTAL_WIDTH = DIGITS*SPRITE_SIZE*X_SCALE;
  
  parameter LOW_X_BOUND = X_POS;
  parameter HIGH_X_BOUND = X_POS + TOTAL_WIDTH;
  
  parameter LOW_Y_BOUND = Y_POS;
  parameter HIGH_Y_BOUND = Y_POS + SPRITE_SIZE*Y_SCALE;
  
  
  input [2:0] color;
  
  input [DATA_WIDTH*DIGITS-1 :0] digitData;
  input [9:0] shpos;
  input [9:0] svpos;
  
  wire [9:0] movYpos = svpos - Y_OFFSET;
  output [$clog2(SPRITE_SIZE)-1:0] yofs = movYpos[$clog2(Y_SCALE)+:$clog2(SPRITE_SIZE)];
  
  wire [9:0] movHpos = shpos - X_OFFSET;
  output [$clog2(SPRITE_SIZE)-1:0] xofs = movHpos[$clog2(X_SCALE)+:$clog2(SPRITE_SIZE)];
  wire [3:0] curDigit = movHpos[$clog2(X_SCALE)+$clog2(SPRITE_SIZE)+:4];
  
  wire [3:0] digitFlip = DIRECTION == 1 ? ~curDigit + 1 : curDigit;
  
  output [DATA_WIDTH-1:0] digit = digitData[digitFlip*DATA_WIDTH+: DATA_WIDTH];
  
  input colIn;

  
  wire digitFilter = ( svpos > LOW_Y_BOUND && svpos < HIGH_Y_BOUND && shpos > LOW_X_BOUND && shpos < HIGH_X_BOUND ? colIn : 1'd0);
  output [2:0] colOut = digitFilter ? color : `BLACK;
  
endmodule
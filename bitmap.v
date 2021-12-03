
module testBitmap(animState, direction, yin, xin, out);
  
  input animState;
  input [1:0] direction;  
  input [3:0] yin;
  input [3:0] xin;
  output out;
  
  reg [15:0] pacman[0:128];
  
  wire [7:0] caseexpr = {1'b0, direction, animState, yin};
  
  assign out = pacman[caseexpr][~xin];
  
  initial begin
    /*{w:9,h:12,bpw:9,count:6}*/
    pacman['h00] = 9'b111000011;
    pacman['h01] = 9'b111000011;
    pacman['h02] = 9'b111100011;
    pacman['h03] = 9'b111100011;
    pacman['h04] = 9'b110110011;
    pacman['h05] = 9'b110110011;
    pacman['h06] = 9'b110011011;
    pacman['h07] = 9'b110011011;
    pacman['h08] = 9'b110001111;
    pacman['h09] = 9'b110001111;
    pacman['h0A] = 9'b110000111;
    pacman['h0B] = 9'b110000111;
  
    pacman['h10] = 9'b110000011;
    pacman['h11] = 9'b110000011;
    pacman['h12] = 9'b110000011;
    pacman['h13] = 9'b110000011;
    pacman['h14] = 9'b110000011;
    pacman['h15] = 9'b110000011;
    pacman['h16] = 9'b110000011;
    pacman['h17] = 9'b110000011;
    pacman['h18] = 9'b110000011;
    pacman['h19] = 9'b110000011;
    pacman['h1A] = 9'b111111111;
    pacman['h1B] = 9'b011111110;
  
    pacman['h20] = 9'b110000011;
    pacman['h21] = 9'b111000111;
    pacman['h22] = 9'b111101111;
    pacman['h23] = 9'b110111011;
    pacman['h24] = 9'b110010011;
    pacman['h25] = 9'b110000011;
    pacman['h26] = 9'b110000011;
    pacman['h27] = 9'b110000011;
    pacman['h28] = 9'b110000011;
    pacman['h29] = 9'b110000011;
    pacman['h2A] = 9'b110000011;
    pacman['h2B] = 9'b110000011;
  
    pacman['h30] = 9'b111111111;
    pacman['h31] = 9'b111111111;
    pacman['h32] = 9'b000111000;
    pacman['h33] = 9'b000111000;
    pacman['h34] = 9'b000111000;
    pacman['h35] = 9'b000111000;
    pacman['h36] = 9'b000111000;
    pacman['h37] = 9'b000111000;
    pacman['h38] = 9'b000111000;
    pacman['h39] = 9'b000111000;
    pacman['h3A] = 9'b111111111;
    pacman['h3B] = 9'b111111111;
  
    pacman['h40] = 9'b111111111;
    pacman['h41] = 9'b111111111;
    pacman['h42] = 9'b000000011;
    pacman['h43] = 9'b000000111;
    pacman['h44] = 9'b000001110;
    pacman['h45] = 9'b000011100;
    pacman['h46] = 9'b000111000;
    pacman['h47] = 9'b001110000;
    pacman['h48] = 9'b011100000;
    pacman['h49] = 9'b111000000;
    pacman['h4A] = 9'b111111111;
    pacman['h4B] = 9'b111111111;
  
    pacman['h50] = 9'b111111100;
    pacman['h51] = 9'b111111111;
    pacman['h52] = 9'b110000011;
    pacman['h53] = 9'b110000011;
    pacman['h54] = 9'b110000011;
    pacman['h55] = 9'b110000011;
    pacman['h56] = 9'b111111111;
    pacman['h57] = 9'b111111111;
    pacman['h58] = 9'b110000011;
    pacman['h59] = 9'b110000011;
    pacman['h5A] = 9'b110000011;
    pacman['h5B] = 9'b110000011;
   end
  
endmodule
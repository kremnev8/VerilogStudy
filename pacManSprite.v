
module PacManSprite(animState, direction, yin, xin, out);
  
  input animState;
  input [1:0] direction;  
  input [3:0] yin;
  input [3:0] xin;
  output out;
  
  reg [15:0] pacman[0:128];
  
  wire [7:0] caseexpr = {1'b0, direction, animState, yin};
  
  assign out = pacman[caseexpr][~xpos];
  
  initial begin
    /*{w:16,h:16,bpw:16,count:8}*/
    pacman['h00] = 16'b0;
    pacman['h01] = 16'b0;
    pacman['h02] = 16'b0;
    pacman['h03] = 16'b0;
    pacman['h04] = 16'b0;
    pacman['h05] = 16'b0;
    pacman['h06] = 16'b11000000000110;
    pacman['h07] = 16'b11100000001110;
    pacman['h08] = 16'b11110000011110;
    pacman['h09] = 16'b11111000111110;
    pacman['h0A] = 16'b11111101111110;
    pacman['h0B] = 16'b1111111111100;
    pacman['h0C] = 16'b1111111111100;
    pacman['h0D] = 16'b111111111000;
    pacman['h0E] = 16'b1111100000;
    pacman['h0F] = 16'b0;
    
    pacman['h10] = 16'b0;
    pacman['h11] = 16'b0;
    pacman['h12] = 16'b0;
    pacman['h13] = 16'b110000011000;
    pacman['h14] = 16'b1110000011100;
    pacman['h15] = 16'b1111000111100;
    pacman['h16] = 16'b11111000111110;
    pacman['h17] = 16'b11111000111110;
    pacman['h18] = 16'b11111101111110;
    pacman['h19] = 16'b11111101111110;
    pacman['h1A] = 16'b11111101111110;
    pacman['h1B] = 16'b1111111111100;
    pacman['h1C] = 16'b1111111111100;
    pacman['h1D] = 16'b111111111000;
    pacman['h1E] = 16'b1111100000;
    pacman['h1F] = 16'b0;
    
    pacman['h20] = 16'b0;
    pacman['h21] = 16'b1111100000;
    pacman['h22] = 16'b1111111000;
    pacman['h23] = 16'b111111100;
    pacman['h24] = 16'b11111100;
    pacman['h25] = 16'b1111110;
    pacman['h26] = 16'b111110;
    pacman['h27] = 16'b11110;
    pacman['h28] = 16'b111110;
    pacman['h29] = 16'b1111110;
    pacman['h2A] = 16'b11111100;
    pacman['h2B] = 16'b111111100;
    pacman['h2C] = 16'b1111111000;
    pacman['h2D] = 16'b1111100000;
    pacman['h2E] = 16'b0;
    pacman['h2F] = 16'b0;
    
    pacman['h30] = 16'b0;
    pacman['h31] = 16'b1111100000;
    pacman['h32] = 16'b111111111000;
    pacman['h33] = 16'b1111111111100;
    pacman['h34] = 16'b1111111111100;
    pacman['h35] = 16'b11111111110;
    pacman['h36] = 16'b11111110;
    pacman['h37] = 16'b11110;
    pacman['h38] = 16'b11111110;
    pacman['h39] = 16'b11111111110;
    pacman['h3A] = 16'b1111111111100;
    pacman['h3B] = 16'b1111111111100;
    pacman['h3C] = 16'b111111111000;
    pacman['h3D] = 16'b1111100000;
    pacman['h3E] = 16'b0;
    pacman['h3F] = 16'b0;
    
    pacman['h40] = 16'b0;
    pacman['h41] = 16'b11111000000;
    pacman['h42] = 16'b1111111110000;
    pacman['h43] = 16'b11111111111000;
    pacman['h44] = 16'b11111111111000;
    pacman['h45] = 16'b111111011111100;
    pacman['h46] = 16'b111110001111100;
    pacman['h47] = 16'b111100000111100;
    pacman['h48] = 16'b111000000011100;
    pacman['h49] = 16'b110000000001100;
    pacman['h4A] = 16'b0;
    pacman['h4B] = 16'b0;
    pacman['h4C] = 16'b0;
    pacman['h4D] = 16'b0;
    pacman['h4E] = 16'b0;
    pacman['h4F] = 16'b0;
    
    pacman['h50] = 16'b0;
    pacman['h51] = 16'b11111000000;
    pacman['h52] = 16'b1111111110000;
    pacman['h53] = 16'b11111111111000;
    pacman['h54] = 16'b11111111111000;
    pacman['h55] = 16'b111111011111100;
    pacman['h56] = 16'b111111011111100;
    pacman['h57] = 16'b111111011111100;
    pacman['h58] = 16'b111110001111100;
    pacman['h59] = 16'b111110001111100;
    pacman['h5A] = 16'b11110001111000;
    pacman['h5B] = 16'b11100000111000;
    pacman['h5C] = 16'b1100000110000;
    pacman['h5D] = 16'b0;
    pacman['h5E] = 16'b0;
    pacman['h5F] = 16'b0;
    
    pacman['h60] = 16'b0;
    pacman['h61] = 16'b0;
    pacman['h62] = 16'b11111000000;
    pacman['h63] = 16'b1111111000000;
    pacman['h64] = 16'b11111110000000;
    pacman['h65] = 16'b11111100000000;
    pacman['h66] = 16'b111111000000000;
    pacman['h67] = 16'b111110000000000;
    pacman['h68] = 16'b111100000000000;
    pacman['h69] = 16'b111110000000000;
    pacman['h6A] = 16'b111111000000000;
    pacman['h6B] = 16'b11111100000000;
    pacman['h6C] = 16'b11111110000000;
    pacman['h6D] = 16'b1111111000000;
    pacman['h6E] = 16'b11111000000;
    pacman['h6F] = 16'b0;
    
    pacman['h70] = 16'b0;
    pacman['h71] = 16'b0;
    pacman['h72] = 16'b11111000000;
    pacman['h73] = 16'b1111111110000;
    pacman['h74] = 16'b11111111111000;
    pacman['h75] = 16'b11111111111000;
    pacman['h76] = 16'b111111111100000;
    pacman['h77] = 16'b111111100000000;
    pacman['h78] = 16'b111100000000000;
    pacman['h79] = 16'b111111100000000;
    pacman['h7A] = 16'b111111111100000;
    pacman['h7B] = 16'b11111111111000;
    pacman['h7C] = 16'b11111111111000;
    pacman['h7D] = 16'b1111111110000;
    pacman['h7E] = 16'b11111000000;
    pacman['h7F] = 16'b0;
  end
  
endmodule
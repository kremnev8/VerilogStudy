
module PelletData(clk, reset, xpos_a, ypos_a, out_a,
                       xpos_b, ypos_b, clear_b, out_b);
  
  input clk;
  input reset;
  
  input [4:0] xpos_a;
  input [4:0] ypos_a;
  output reg out_a;
  
  input [4:0] xpos_b;
  input [4:0] ypos_b;
  input clear_b;
  output reg out_b;
  
  reg [31:0] bitarray[0:31];
  
  initial begin/*{w:32,h:32,bpw:32,count:1}*/
    bitarray['h00] = 32'b0;
    bitarray['h01] = 32'b0;
    bitarray['h02] = 32'b1111111111110011111111111100;
    bitarray['h03] = 32'b1000010000010010000010000100;
    bitarray['h04] = 32'b1000010000010010000010000100;
    bitarray['h05] = 32'b1000010000010010000010000100;
    bitarray['h06] = 32'b1111111111111111111111111100;
    bitarray['h07] = 32'b1000010010000000010010000100;
    bitarray['h08] = 32'b1000010010000000010010000100;
    bitarray['h09] = 32'b1111110011110011110011111100;
    bitarray['h0A] = 32'b10000000000000010000000;
    bitarray['h0B] = 32'b10000000000000010000000;
    bitarray['h0C] = 32'b10000000000000010000000;
    bitarray['h0D] = 32'b10000000000000010000000;
    bitarray['h0E] = 32'b10000000000000010000000;
    bitarray['h0F] = 32'b1111110000000000000011111100;
    bitarray['h10] = 32'b10000000000000010000000;
    bitarray['h11] = 32'b10000000000000010000000;
    bitarray['h12] = 32'b10000000000000010000000;
    bitarray['h13] = 32'b10000000000000010000000;
    bitarray['h14] = 32'b10000000000000010000000;
    bitarray['h15] = 32'b1111111111110011111111111100;
    bitarray['h16] = 32'b1000010000010010000010000100;
    bitarray['h17] = 32'b1000010000010010000010000100;
    bitarray['h18] = 32'b1000011111111111111110000100;
    bitarray['h19] = 32'b1000010010000000010010000100;
    bitarray['h1A] = 32'b1000010010000000010010000100;
    bitarray['h1B] = 32'b1111110011111111110011111100;
    bitarray['h1C] = 32'b0;
    bitarray['h1D] = 32'b0;
    bitarray['h1E] = 32'b0;
    bitarray['h1F] = 32'b0;
  end
  
  always@(posedge clk) begin
    if (reset) begin
      bitarray['h00] <= 32'b0;
      bitarray['h01] <= 32'b0;
      bitarray['h02] <= 32'b1111111111110011111111111100;
      bitarray['h03] <= 32'b1000010000010010000010000100;
      bitarray['h04] <= 32'b1000010000010010000010000100;
      bitarray['h05] <= 32'b1000010000010010000010000100;
      bitarray['h06] <= 32'b1111111111111111111111111100;
      bitarray['h07] <= 32'b1000010010000000010010000100;
      bitarray['h08] <= 32'b1000010010000000010010000100;
      bitarray['h09] <= 32'b1111110011110011110011111100;
      bitarray['h0A] <= 32'b10000000000000010000000;
      bitarray['h0B] <= 32'b10000000000000010000000;
      bitarray['h0C] <= 32'b10000000000000010000000;
      bitarray['h0D] <= 32'b10000000000000010000000;
      bitarray['h0E] <= 32'b10000000000000010000000;
      bitarray['h0F] <= 32'b1111110000000000000011111100;
      bitarray['h10] <= 32'b10000000000000010000000;
      bitarray['h11] <= 32'b10000000000000010000000;
      bitarray['h12] <= 32'b10000000000000010000000;
      bitarray['h13] <= 32'b10000000000000010000000;
      bitarray['h14] <= 32'b10000000000000010000000;
      bitarray['h15] <= 32'b1111111111110011111111111100;
      bitarray['h16] <= 32'b1000010000010010000010000100;
      bitarray['h17] <= 32'b1000010000010010000010000100;
      bitarray['h18] <= 32'b1000011111111111111110000100;
      bitarray['h19] <= 32'b1000010010000000010010000100;
      bitarray['h1A] <= 32'b1000010010000000010010000100;
      bitarray['h1B] <= 32'b1111110011111111110011111100;
      bitarray['h1C] <= 32'b0;
      bitarray['h1D] <= 32'b0;
      bitarray['h1E] <= 32'b0;
      bitarray['h1F] <= 32'b0;
    end else begin
      out_a <= bitarray[ypos_a][xpos_a];
      
      if (clear_b)
        bitarray[ypos_b][xpos_b] <= 0;
      else
        out_b <= bitarray[ypos_b][xpos_b];
    end
  end
  
endmodule
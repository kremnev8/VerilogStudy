
`include "hvsync_generator.v"
`include "AccessManager.v"

module ACMNG_TEST_top(clk, reset, pacmanCE, mainCE)
  
  input clk;
  input reset
  
    hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(reset),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos)
  );
  
  wire display_on;
  wire [9:0] hpos;
  wire [9:0] vpos;
  
  wire hsync, vsync;
  
  output pacmanCE;
  output mainCE;
  
  AccessManager ceCtr(
    .clk(clk), 
    .shpos(hpos), 
    .svpos(vpos), 
    .mainCE(mainCE), 
    .pacmanCE(pacmanCE)
  );
  
  
  
  
  
endmodule
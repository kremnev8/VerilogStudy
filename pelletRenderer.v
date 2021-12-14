
module pelletRenderer(shpos, svpos, xout, yout, din, color);
  
  input [9:0] shpos;
  input [9:0] svpos;
  input	din;
  
  output [4:0] xout = shpos[8:4] + 1;
  output [4:0] yout = svpos[8:4] + 1;
  
  output reg [2:0] color;
  
  wire [2:0] yofs = svpos[3:1]; // scanline of cell	   
  wire [2:0] xofs = shpos[3:1];      // which pixel to draw (0-7)
  
  wire colData;
  wire filteredColor = ( svpos < 10'h1e0 && shpos < 10'h1e0 ? colData : 1'd0);
  assign color = filteredColor ? `YELLOW : `BLACK;
  
  // digits ROM
  pelletBitmap bitmap(
    .sprite({1'b0, din}), 
    .yin(yofs), 
    .xin(xofs), 
    .out(colData)
    );
  
endmodule
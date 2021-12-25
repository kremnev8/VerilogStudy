
module AccessManager(clk, shpos, svpos, mainCE);
  
  input clk;
  input [9:0] shpos;
  input [9:0] svpos;
  
  output reg mainCE;
  
  
  always @(posedge clk) begin
    if (shpos == 300 && svpos != 0 && svpos % 120 == 0) begin
      mainCE <= 1;
    end
    else
      mainCE <= 0;
  end
  
endmodule
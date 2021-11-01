
module AccessManager(clk, shpos, svpos, mainCE, pacmanCE);
  
  input clk;
  input [9:0] shpos;
  input [9:0] svpos;
  
  output mainCE = select == 2'd0;
  output pacmanCE = select == 2'd1;
  
  reg [12:0] counter = 0;
  
  reg [1:0] select = 0;
  
  
  always @(posedge clk) begin
    if (svpos >= 10'd480) begin
      counter <= counter + 1'b1;
      if (counter >= 13'd4752) begin
        
        select <= select + 1'b1;
        if (select > 2'd1) begin
          select <= 0;
          counter <= 0;
        end
      end
    end
  end
  
endmodule
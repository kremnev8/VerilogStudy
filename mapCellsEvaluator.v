
`ifndef MapCellsEval_H
`define MapCellsEval_H

`include "cellStateCL.v"


module MapCellsEval(clk, mapData, worldWrite, worldWE, outxpos, outypos, ready);
  
  input clk;
  
  input mapData;
  output reg [7:0] worldWrite;
  	
  output reg worldWE;
  
  output wire [4:0] outxpos = xpos + (offsetX == 0 ? -5'd1 : (offsetX == 2 ? 5'd1 : 5'd0));
  output wire [4:0] outypos = ypos + (offsetY == 0 ? -5'd1 : (offsetY == 2 ? 5'd1 : 5'd0));
  
  reg [2:0] state;
  
  reg [4:0] xpos;
  reg [4:0] ypos;
  
  reg [8:0] neighbors;
  
  reg [1:0] offsetX;
  reg [1:0] offsetY;
  
  wire [3:0] cellIndex = {2'h0, offsetX} + offsetY * 2'h3;
  
  output reg ready = 0;
  
  wire [3:0] res;
  
  CellState State(
    .in(neighbors), 
    .out(res)
  );
  
  initial begin
    state = 3'h0;
    neighbors = 0;
  end
  
  always @(posedge clk) begin
    case(state)
      3'h0: begin
        xpos <= 5'h1;
        ypos <= 5'h1;
        offsetX <= 0;
        offsetY <= 0;
        state <= 3'h1;
      end
      3'h1: begin
        if (offsetY == 2'h3) begin
          offsetY <= 0;
          offsetX <= 0;
          state <= 3'h2;
        end else begin
          neighbors[~cellIndex] <= mapData;
          offsetX <= offsetX + 2'h1;
          if (offsetX == 2'h2) begin
            offsetX <= 0;
            offsetY <= offsetY + 2'h1;
          end
        end
      end
      3'h2: begin
        worldWrite <= {4'h0, res};
        worldWE <= 1;
        state <= 3'h3;
      end
      3'h3: begin
        worldWE <= 0;
        xpos <= xpos + 1'b1;
        neighbors <= 0;
        state <= 3'h1;
        if (xpos >= 5'd28) begin
          xpos <= 0;
          ypos <= ypos + 1'b1;
        end
        if (ypos >= 5'd30) begin
          ypos <= 0;
          //state <= 3'h4;
        end
      end
      3'h4: begin
        ready <= 1;
      end
      
      default:;
    endcase
  end

endmodule

`endif
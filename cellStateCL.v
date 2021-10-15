
`ifndef CellState_H
`define CellState_H

module CellState(in, out);
  
  input [8:0] in;	
  output reg [3:0] out;	// output (5 out)
  
  wire cel = in[4];
  wire top = in[1];
  wire bottom = in[7];
  wire left = in[3];
  wire right = in[5];
  
  wire tl = in[0];
  wire tr = in[2];
  wire bl = in[6];
  wire br = in[8];
  
  always @(*) begin
    if (cel) out = 0;
    else if (!top && !bottom && right) out = {2'd0, 2'd1};
    else if (!left && !right && top) out = {2'd1, 2'd1};
    else if (!top && !bottom && left) out = {2'd2, 2'd1};
    else if (!left && !right && bottom) out = {2'd3, 2'd1};
    
    
    else if (!bl && !top && !right && tr) out = {2'd0, 2'd2};
    else if (!br && !top && !left && tl) out = {2'd1, 2'd2};
    else if (!tr && !bottom && !left && bl) out = {2'd2, 2'd2};
    else if (!tl && !bottom && !right && br) out = {2'd3, 2'd2};
    
    
    else if (!top && !right && bl && left && bottom) out = {2'd0, 2'd3};
    else if (!top && !left && br && right && bottom) out = {2'd1, 2'd3};
    else if (!bottom && !left && tr && right && top) out = {2'd2, 2'd3};
    else if (!bottom && !right && tl && left && top) out = {2'd3, 2'd3};
    else out = 0;

  end
    
endmodule

`endif

module RandomNumber(clk, ce, out);
  
  
  input clk;
  input ce;
  
  output [3:0] out = state[3:0];
  
  reg [15:0] state = 16'hACE1;
  
  wire next = state[0] ^ state[2] ^ state[3] ^ state[5]; 
  
  always @(posedge clk) begin
    if (ce) begin
      state <= {next, state[14:0]};
    end
  end
  
  
endmodule
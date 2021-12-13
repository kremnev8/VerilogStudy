
module SpriteRegs(clk, reg_addr, in,  out, we, mapData, playerRot, frame);
 
  reg [7:0] sprite_reg [0:22];
  
  integer k;
  
  initial begin
    for (k = 0; k < 22; k = k + 1) begin
      sprite_reg[k] = 0;
    end
  end
  
  //0 PacMan pos x
  //1 PacMan pos y
  //2 PacMan rot
  
  //3 World map x pos
  //4 World map y pos
  
  //5 Blinky pos x
  //6 Blinky pos y
  //7 Blinky rot
  
  //8 Pinky pos x
  //9 Pinky pos y
  //10 Pinky rot
   
  //11 Inky pos x
  //12 Inky pos y
  //13 Inky rot
   
  //14 Clyde pos x
  //15 Clyde pos y
  //16 Clyde rot
  
  //17 Work done
  
  //32 World map data
  //33 Player desire rot
  //34 Frame count
  
  input clk;
  
  input [5:0] reg_addr;
  input mapData;
  input [1:0] playerRot;
  input [5:0] frame;
  
  output [7:0] out;
  input [7:0] in;
  input we;
  
  always @(posedge clk) begin
    if (we) begin
      sprite_reg[reg_addr[4:0]] <= in;
    end
  end
  
  always @(*) begin
    if (reg_addr[5] == 0) 
      out = sprite_reg[reg_addr[4:0]];
    else begin
      if (reg_addr[4:0] == 5'd0)
        out = {7'b0, mapData};
      else if (reg_addr[4:0] == 5'd1)
        out = {6'b0, playerRot};
      else if (reg_addr[4:0] == 5'd2)
        out = {2'b0, frame};
      else
        out = 0;
    end
  end
  
endmodule
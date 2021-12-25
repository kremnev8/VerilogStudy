
module SpriteRegs(clk, reset, reg_addr, in,  out, we, mapData, playerRot, frame, pelletData);
 
  reg [15:0] sprite_reg [0:42];
  
  integer k;
  
  initial begin
    for (k = 0; k < 43; k = k + 1) begin
      sprite_reg[k] = 0;
    end
  end   
  
  
  //0 PacMan pos x
  //1 PacMan pos y
  //2 PacMan rot
  //3 PacMan timer
  //4 PacMan wait
  //5 PacMan lifes
  
  //6 World map x pos
  //7 World map y pos
  
  //8 Blinky pos x
  //9 Blinky pos y
  //10 Blinky rot
  //11 Blinky timer
  //12 Blinky AI state
  //13 Blinky AI timer
  
  //14 Pinky pos x
  //15 Pinky pos y
  //16 Pinky rot
  //17 Pinky timer
  //18 Pinky AI state
  //19 Blinky AI timer
   
  //20 Inky pos x
  //21 Inky pos y
  //22 Inky rot
  //23 Inky timer
  //24 Inky AI state
  //25 Blinky AI timer
   
  //26 Clyde pos x
  //27 Clyde pos y
  //28 Clyde rot
  //29 Clyde timer
  //30 Clyde AI state
  //31 Blinky AI timer
  
  //32 Frame lock register
  
  //33 PelletX
  //34 PelletY
  //35 PelletClear
  //36 DisplayFlags
  
  //33 Score
  //34 ScoreDisplay
  
  //48 World map data
  //49 Player desire rot
  //50 Frame count
  //51 Pellet Data
  
  input clk;
  input reset;
  
  input [5:0] reg_addr;
  input mapData;
  input [1:0] playerRot;
  input [5:0] frame;
  input [1:0] pelletData;
  
  output [15:0] out;
  input [15:0] in;
  input we;
  
  always @(posedge clk) begin
    if (reset) begin
      for (k = 0; k < 43; k = k + 1) begin
        sprite_reg[k] <= 0;
      end
    end else if (we) begin
        sprite_reg[reg_addr[5:0]] <= in[15:0];
    end
  end
  
  always @(*) begin
    
    if (reg_addr[5:4] != 2'b11) 
        out = sprite_reg[reg_addr[5:0]];
    else begin
      if (reg_addr[3:0] == 4'd0)
        out = 16'(mapData);
      else if (reg_addr[3:0] == 4'd1)
        out = 16'(playerRot);
      else if (reg_addr[3:0] == 4'd2)
        out = 16'(frame);
      else if (reg_addr[3:0] == 4'd3)
        out = 16'(pelletData);
      else
        out = 0;
    end
  end
  
endmodule
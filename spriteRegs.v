
module SpriteRegs(clk, reset, reg_addr, in,  out, we, mapData, playerRot, frame, pelletData);
 
  reg [7:0] sprite_reg [0:26];
  reg [15:0] score;
  reg [15:0] scoreDisp;
  
  integer k;
  
  initial begin
    for (k = 0; k < 27; k = k + 1) begin
      sprite_reg[k] = 0;
    end
    score = 0;
    scoreDisp = 0;
  end
  
`define PACMAN_POS_X 0
`define PACMAN_POS_Y 1
`define PACMAN_ROT   2
`define PACMAN_TIMER 3 
`define PACMAN_WAIT  4 
`define PACMAN_LIFES 5
  
`define WORLD_POS_X  6
`define WORLD_POS_Y  7

`define BLINKY_POS_X 8
`define BLINKY_POS_Y 9
`define BLINKY_ROT   10
`define BLINKY_TIMER 11
`define BLINKY_WAIT  12 
  
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
  //12 Blinky wait
  
  //13 Pinky pos x
  //14 Pinky pos y
  //15 Pinky rot
  //16 Pinky timer
  //17 Pinky wait
   
  //18 Inky pos x
  //19 Inky pos y
  //20 Inky rot
  //21 Inky timer
  //22 Inky wait
   
  //23 Clyde pos x
  //24 Clyde pos y
  //25 Clyde rot
  //26 Clyde timer
  //27 Clyde wait
  //28 Frame lock register
  
  //29 PelletX
  //30 PelletY
  //31 PelletClear
  //26 Score
  //27 ScoreDisplay
  
  //32 World map data
  //33 Player desire rot
  //34 Frame count
  //35 Pellet Data
  
  input clk;
  input reset;
  
  input [5:0] reg_addr;
  input mapData;
  input [1:0] playerRot;
  input [5:0] frame;
  input pelletData;
  
  output [15:0] out;
  input [15:0] in;
  input we;
  
  always @(posedge clk) begin
    if (reset) begin
      for (k = 0; k < 26; k = k + 1) begin
        sprite_reg[k] <= 0;
      end
      score <= 0;
      scoreDisp <= 0;
    end else if (we) begin
      if (reg_addr[4:0] == 5'd26)
        score <= in;
      else if (reg_addr[4:0] == 5'd27)
        scoreDisp <= in;
      else
        sprite_reg[reg_addr[4:0]] <= in[7:0];
    end
  end
  
  always @(*) begin
    
    if (reg_addr[5] == 0) 
      if (reg_addr[4:0] == 5'd26)
        out = score;
      else if (reg_addr[4:0] == 5'd27)
        out = scoreDisp;
      else
        out = 16'(sprite_reg[reg_addr[4:0]]);
    else begin
      if (reg_addr[4:0] == 5'd0)
        out = 16'(mapData);
      else if (reg_addr[4:0] == 5'd1)
        out = 16'(playerRot);
      else if (reg_addr[4:0] == 5'd2)
        out = 16'(frame);
      else if (reg_addr[4:0] == 5'd3)
        out = 16'(pelletData);
      else
        out = 0;
    end
  end
  
endmodule

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
  
  //0 PacMan pos x
  //1 PacMan pos y
  //2 PacMan rot
  //3 PacMan timer
  
  //4 World map x pos
  //5 World map y pos
  
  //6 Blinky pos x
  //7 Blinky pos y
  //8 Blinky rot
  //9 Blinky timer
  
  //10 Pinky pos x
  //11 Pinky pos y
  //12 Pinky rot
  //13 Pinky timer
   
  //14 Inky pos x
  //15 Inky pos y
  //16 Inky rot
  //17 Inky rot
   
  //18 Clyde pos x
  //19 Clyde pos y
  //20 Clyde rot
  //21 Inky rot
  //22 Frame lock register
  
  //23 PelletX
  //24 PelletY
  //25 PelletClear
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
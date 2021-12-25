`include "enums.vh"

`include "hvsync_generator.v"
`include "ram.v"
`include "lfsr.v"
`include "cpu16.v"
`include "spriteRegs.v"
`include "AccessManager.v"
`include "ColorMixer.v"


`include "tileMap.v"
`include "MapData.v"
`include "mapCellsEvaluator.v"
`include "cellStateCL.v"

`include "pelletRenderer.v"
`include "pelletBitmap.v"
`include "pelletData.v"

`include "pacManBitmap.v"
`include "animatedSprite.v"
`include "pacmanController.v"

`include "blinkyBitmap.v"

`include "digits10.v"
`include "digitRenderer.v"

`include "alphabet.v"










module pacman_top(clk, reset, hsync, vsync, rgb, keycode, keystrobe);

  input clk, reset;
  
  output hsync, vsync;
  output [3:0] rgb;

  wire display_on;
  wire [9:0] hpos;
  wire [9:0] vpos;
  
  wire [9:0] ram_addr;
  wire [7:0] ram_read;
  wire [7:0] ram_write;
  wire ram_writeenable;
  
  input [7:0] keycode;
  //output reg keystrobe = 0;
  
  reg [7:0] value = 0;
  
  wire init;
  
  // RAM to hold 32x32 array of bytes
  RAM_sync tile_ram(
    .clk(clk),
    .dout(ram_read),
    .din(ram_write),
    .addr(ram_addr),
    .we(ram_writeenable)
  );
  
  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(reset),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos)
  );
 
  wire [4:0] row = vpos[8:4];	// 5-bit row, vpos / 8
  wire [4:0] col = hpos[8:4];	// 5-bit column, hpos / 8
  wire [2:0] rom_yofs = vpos[3:1]; // scanline of cell	   
  
  wire [3:0] digit = ram_read[3:0]; // read digit from RAM
  wire [2:0] xofs = hpos[3:1];      // which pixel to draw (0-7)
  
  assign ram_addr = init ? {row,col} : {evalXpos, evalYpos};	// 10-bit RAM address

  // digits ROM
  tileMap backTileMap(
    .tileType(ram_read[1:0]), 
    .rotation(ram_read[3:2]), 
    .yin(rom_yofs), 
    .xin(xofs), 
    .out(tilemapColor)
  );
  
  wire [4:0] evalXpos;
  wire [4:0] evalYpos;
  
  wire [4:0] mapDataAddr = ram_addr[9:5];
  wire [31:0] mapValues;
  wire [31:0] mapValues_b;
  
  
  MapData map(
    .addr_a(mapDataAddr), 
    .addr_b(regs.sprite_reg[`WORLD_POS_Y][4:0]), 
    .out_a(mapValues), 
    .out_b(mapValues_b)
  );
  
  MapCellsEval worldEval(
    .clk(clk), 
    .mapData(mapValues[ram_addr[4:0]]), 
    .worldWrite(ram_write), 
    .worldWE(ram_writeenable), 
    .outxpos(evalXpos), 
    .outypos(evalYpos), 
    .ready(init)
  );
  
  
  wire [4:0] pelletXpos;
  wire [4:0] pelletYpos;
  wire pelletTmpData;
  
  wire [2:0] pelletColor;
  
  pelletRenderer pellets(
    .shpos(hpos), 
    .svpos(vpos), 
    .xout(pelletXpos), 
    .yout(pelletYpos), 
    .din(pelletTmpData),
    .color(pelletColor)
  );
  
  wire [4:0] cpuPelletX = regs.sprite_reg[`PELLET_X][4:0];
  wire [4:0] cpuPelletY = regs.sprite_reg[`PELLET_Y][4:0];
  wire cpuPelletClear = regs.sprite_reg[`PELLET_CLEAR][0];
  
  wire isPowerUp = (cpuPelletX == 2 || cpuPelletX == 27) && (cpuPelletY == 4 || cpuPelletY == 24) && cpuPelletData;
  
  wire cpuPelletData;
  
  PelletData data(
    .clk(clk), 
    .reset(reset),
    .xpos_a(pelletXpos), 
    .ypos_a(pelletYpos), 
    .out_a(pelletTmpData),
    .xpos_b(cpuPelletX), 
    .ypos_b(cpuPelletY), 
    .clear_b(cpuPelletClear), 
    .out_b(cpuPelletData)
  );
  
  reg [1:0] dir = 1;
  
  wire mainCE;
  
  AccessManager ceCtr(
    .clk(clk), 
    .shpos(hpos),
    .svpos(vpos), 
    .mainCE(mainCE)
  );
  
  Pacman pacman(
    .clk(clk),
    .ce(mainCE),
    .shpos(hpos), 
    .svpos(vpos), 
    .col(pacmanColor), 
    .direction(regs.sprite_reg[`PACMAN_ROT][1:0]),
    .xpos(regs.sprite_reg[`PACMAN_POS_X][4:0]), 
    .ypos(regs.sprite_reg[`PACMAN_POS_Y][4:0])
  );
  
  Blinky blinky(
    .clk(clk), 
    .ce(mainCE), 
    .shpos(hpos), 
    .svpos(vpos), 
    .col(blinkyColor), 
    .direction(regs.sprite_reg[`BLINKY_ROT][1:0]),
    .xpos(regs.sprite_reg[`BLINKY_POS_X][4:0]), 
    .ypos(regs.sprite_reg[`BLINKY_POS_Y][4:0]),
    .aiState(regs.sprite_reg[`BLINKY_AI][3:0]),
    .aiTimer(regs.sprite_reg[`BLINKY_AI_TIMER][5:0])
  );
  
  wire [2:0] pinkyColor;
  
  Blinky
  #(
    .colorMap({`WHITE, `BLUE, `PINK, `BLACK})
  )
  pinky(
    .clk(clk), 
    .ce(mainCE), 
    .shpos(hpos), 
    .svpos(vpos), 
    .col(pinkyColor), 
    .direction(regs.sprite_reg[`PINKY_ROT][1:0]),
    .xpos(regs.sprite_reg[`PINKY_POS_X][4:0]), 
    .ypos(regs.sprite_reg[`PINKY_POS_Y][4:0]),
    .aiState(regs.sprite_reg[`PINKY_AI][3:0]),
    .aiTimer(regs.sprite_reg[`PINKY_AI_TIMER][5:0])
  );
  
  
  wire [2:0] inkyColor;
  
  Blinky
  #(
    .colorMap({`WHITE, `BLUE, `CYAN, `BLACK})
  )
  inky(
    .clk(clk), 
    .ce(mainCE), 
    .shpos(hpos), 
    .svpos(vpos), 
    .col(inkyColor), 
    .direction(regs.sprite_reg[`INKY_ROT][1:0]),
    .xpos(regs.sprite_reg[`INKY_POS_X][4:0]), 
    .ypos(regs.sprite_reg[`INKY_POS_Y][4:0]),
    .aiState(regs.sprite_reg[`INKY_AI][3:0]),
    .aiTimer(regs.sprite_reg[`INKY_AI_TIMER][5:0])
  );
  
  
  wire [2:0] clydeColor;
  
  Blinky
  #(
    .colorMap({`WHITE, `BLUE, `ORANGE, `BLACK})
  )
  clyde(
    .clk(clk), 
    .ce(mainCE), 
    .shpos(hpos), 
    .svpos(vpos), 
    .col(clydeColor), 
    .direction(regs.sprite_reg[`CLYDE_ROT][1:0]),
    .xpos(regs.sprite_reg[`CLYDE_POS_X][4:0]), 
    .ypos(regs.sprite_reg[`CLYDE_POS_Y][4:0]),
    .aiState(regs.sprite_reg[`CLYDE_AI][3:0]),
    .aiTimer(regs.sprite_reg[`CLYDE_AI_TIMER][5:0])
  );
  
  wire [2:0] digitXofs;
  wire [2:0] digitYofs;
  wire [3:0] digitData;
  wire digitColIn;
  
  CharacterRenderer
  #(
    .X_POS(455),
    .Y_POS(50),
    .X_SCALE(4),
    .Y_SCALE(8),
    .X_OFFSET(70)
  )
  ScoreDisp(
    .digitData({regs.sprite_reg[`SCORE_DISP], 4'd0}), 
    .shpos(hpos), 
    .svpos(vpos), 
    .digit(digitData),
    .xofs(digitXofs), 
    .yofs(digitYofs), 
    .colIn(digitColIn), 
    .colOut(digitColor),
    .color(`WHITE)
  );
  
  digits10 DigitBitmap(
    .digit(digitData), 
    .yofs(digitYofs), 
    .xofs(digitXofs), 
    .bits(digitColIn)
  );
  
  wire [2:0] alphaXofs;
  wire [2:0] alphaYofs;
  wire [4:0] alphaData;
  wire alphaColIn;
  
  reg [49:0] textData = {`SPACE, `SPACE, `EXCLAIM, `Y, `D, `A, `E, `R, `SPACE, `SPACE};
  
  reg [49:0] textData1 = {`SPACE, `R, `E, `V, `O, `SPACE, `E, `M, `A, `G};
  
  wire [49:0] displayText = regs.sprite_reg[`DISPLAY_FLAGS][1] ? textData1 : textData;
  wire [2:0] displayColor = regs.sprite_reg[`DISPLAY_FLAGS][1] ? `RED : `YELLOW;
  
  wire [2:0] textColor;
  
  
  CharacterRenderer 
  #(
    .DATA_WIDTH(5),
    .DIGITS(10),
    .X_POS(150),
    .Y_POS(270),
    .X_SCALE(2),
    .Y_SCALE(2),
    .DIRECTION(0)
  )
  readyDisp(
    .digitData(displayText), 
    .shpos(hpos), 
    .svpos(vpos), 
    .digit(alphaData),
    .xofs(alphaXofs), 
    .yofs(alphaYofs), 
    .colIn(alphaColIn), 
    .colOut(textColor),
    .color(displayColor)
  );
  
  
  Alphabet alphaBitmap(
    .character(alphaData), 
    .yin(alphaYofs), 
    .xin(alphaXofs), 
    .out(alphaColIn)
  );
  
  wire [3:0] lifeXofs;
  wire [3:0] lifeYofs;
  wire lifeData;
  wire lifeColIn;
  wire [2:0] lifeColor;
  
  reg [2:0] lives = {regs.sprite_reg[`PACMAN_LIFES] > 2, regs.sprite_reg[`PACMAN_LIFES] > 1, regs.sprite_reg[`PACMAN_LIFES] > 0};
  
  
  CharacterRenderer 
  #(
    .SPRITE_SIZE(16),
    .DATA_WIDTH(1),
    .DIGITS(3),
    .X_POS(465),
    .Y_POS(150),
    .X_SCALE(2),
    .Y_SCALE(2),
    .DIRECTION(0)
  )
  lifeDisp(
    .digitData(lives), 
    .shpos(hpos), 
    .svpos(vpos), 
    .digit(lifeData),
    .xofs(lifeXofs), 
    .yofs(lifeYofs), 
    .colIn(lifeColIn), 
    .colOut(lifeColor),
    .color(`YELLOW)
  );
  
  
  PacManLifeBitmap lifeBitmap(
    .shouldDraw(lifeData), 
    .yin(lifeYofs), 
    .xin(lifeXofs), 
    .out(lifeColIn)
  );
  
  wire [2:0] digitColor;
  
  wire [2:0] tilemapColor;	
  wire [2:0] gridColor = ( vpos < 10'h1e0 && hpos < 10'h1c0 ? tilemapColor : 3'd0);
  
  wire [2:0] pacmanColor;
  wire [2:0] blinkyColor;
  
  wire [2:0] text1Filtered = regs.sprite_reg[`DISPLAY_FLAGS][0] ? textColor : `BLACK;
 
  
  ColorMixer mixer(
    .gridColor(gridColor), 
    .numbersColor(digitColor),
    .text1Color(text1Filtered),
    .lifeColor(lifeColor),
    
    .pelletColor(pelletColor),
    .pacmanColor(pacmanColor), 
    .blinkyColor(blinkyColor),
    .pinkyColor(pinkyColor),
    .inkyColor(inkyColor),
    .clydeColor(clydeColor),
    
    .rgb(rgb)
  );
  
  reg [5:0] timeCounter = 0;
  
  always @(posedge clk) begin
    
    if (keycode[7]) begin
      case(keycode)
        8'hf7: begin 
          dir <= 0;
          keystrobe <= 1; 
        end
        8'hf3: begin 
          dir <= 2;
          keystrobe <= 1; 
        end
        8'he1: begin 
          dir <= 1;
          keystrobe <= 1; 
        end
        8'he4: begin 
          dir <= 3;
          keystrobe <= 1; 
        end
        default:;
      endcase
    end
    
    if (cpuKeystrobe)
      keystrobe <= 1;
    
    if (mainCE) begin
      regs.sprite_reg[`FRAME_SYNC] <= 1;
    end
    
  end
  
  wire [15:0] address_bus;
  wire write_enable;
  wire busy;
  wire hold = vpos < 10'd480;
  
  reg [15:0] to_cpu;
  wire [15:0] from_cpu;
  
  
  reg [15:0] ram[0:16319];
  reg [15:0] rom[0:2047];
  
  wire [15:0] regs_out;
  output reg keystrobe;
  
  SpriteRegs regs(
    .clk(clk),
    .reset(reset),
    .reg_addr(address_bus[5:0]), 
    .in(from_cpu),
    .out(regs_out), 
    .we(write_enable && address_bus[15:6] == 0),
    .mapData(mapValues_b[regs.sprite_reg[`WORLD_POS_X][4:0]]), 
    .playerRot(dir),
    .frame(timeCounter),
    .pelletData({isPowerUp, cpuPelletData})
  );
 
  
  wire cpuKeystrobe;
  
  CPU16 cpu(
    .clk(clk),
    .reset(reset),
    //.hold(0),
    .busy(busy),
    .address(address_bus),
    .data_in(to_cpu),
    .data_out(from_cpu),
    .write(write_enable),
    .keycode(keycode),
    .keystrobe(cpuKeystrobe)
  );

  always @(posedge clk)
    if (write_enable) begin
	  if (address_bus[15:14] == 0)
            ram[address_bus[13:0] - 14'd64] <= from_cpu;
    end
  
  always @(posedge clk) begin
    if (address_bus[15:14] == 0)
      if (address_bus[15:6] == 0)
      	to_cpu <= regs_out;
      else
        to_cpu <= ram[address_bus[13:0] - 14'd64];   //0x0000
    
    else if (address_bus[15:14] == 2'b01) 
      to_cpu <= rom[address_bus[10:0]];    //0x4000
    //else if (address_bus[15:14] == 2'b10)
    //to_cpu <= {8'b0, regs_out}; //0x8000
  end
  
`ifdef EXT_INLINE_ASM
  
  
  
  initial begin
    rom = '{
      __asm
.arch cpu16arch
.org 0x4000
.len 2048

.define PACMAN_POS_X 0
.define PACMAN_POS_Y 1
.define PACMAN_ROT   2
.define PACMAN_TIMER 3 
.define PACMAN_WAIT  4 
.define PACMAN_LIFES 5

.define WORLD_POS_X  6
.define WORLD_POS_Y  7
      
.define BLINKY_POS_X 8
.define BLINKY_POS_Y 9
.define BLINKY_ROT   10
.define BLINKY_TIMER 11
.define BLINKY_AI  12 
.define BLINKY_AI_TIMER  13
.define BLINKY_WAIT  14
      
.define PINKY_POS_X 15
.define PINKY_POS_Y 16
.define PINKY_ROT   17
.define PINKY_TIMER 18
.define PINKY_AI  19
.define PINKY_AI_TIMER  20
.define PINKY_WAIT  21
      
.define INKY_POS_X 22
.define INKY_POS_Y 23
.define INKY_ROT   24
.define INKY_TIMER 25
.define INKY_AI  26
.define INKY_AI_TIMER  27 
.define INKY_WAIT  28
      
.define CLYDE_POS_X 29
.define CLYDE_POS_Y 30
.define CLYDE_ROT   31
.define CLYDE_TIMER 32
.define CLYDE_AI  33
.define CLYDE_AI_TIMER  34 
.define CLYDE_WAIT  35

.define FRAME_SYNC   36      
.define PELLET_X 37
.define PELLET_Y 38   
.define PELLET_CLEAR 39
.define DISPLAY_FLAGS 40
.define SCORE 41
.define SCORE_DISP 42

.define MAP_DATA 48
.define PLAYER_ROT 49
.define FRAME_COUNT 50
.define PELLET_DATA 51
      
.define CURRENT_CHARACTER $C8   
.define START_TIMER $C9     
      
.define ENEMY_CHASE_TARGET_X $CA
.define ENEMY_CHASE_TARGET_Y $CB     
      
.define ENEMY_SCATTER_TARGET_X $Cc
.define ENEMY_SCATTER_TARGET_Y $CD 
      
.define CURRENT_KILL_SCORE $CE 
.define RAW_PELLETS_EATEN $CF 
      
.define CHARACTER_ARRAY $D0     
.define ALG_MIN_DIST $D8       
.define ALG_MIN_ROT $D9  
      
.define HOME_EXIT_TIMER $DA      
      
      
.define PACMAN_MOVE_SPEED 8
.define PACMAN_ENERIZE_MOVE_SPEED 5      
      
.define ENEMY_MOVE_SPEED 8
.define ENEMY_FAST_SPEED 7    
.define ENEMY_CRUISE_SPEED 6      
.define ENEMY_DEAD_MOVE_SPEED 3
      
; set these to fps*time

.define CHASE_TIME 230 ; fps*2*20   
.define SCATTER_TIME 80 ; fps*2*7
.define FRIGHTENED_TIME 80; fps*2*7

.define START_WAIT_TIME 80
.define KILL_WAIT_TIME 30
.define DEATH_WAIT_TIME 50
      
.define AI_CHASE 0
.define AI_SCATTER 1
.define AI_FRIGHTENED 2
.define AI_DEAD 3
.define AI_EXIT_HOME 4 
      
.define AI_AT_HOME 8      
      
      
      
Init:  
      mov	sp, @$2fff
      mov	ax, #0
      mov	[SCORE], ax
      mov	[RAW_PELLETS_EATEN], ax
      
      mov	ax, #BLINKY_POS_X
      mov	bx, #CHARACTER_ARRAY
      mov	[bx], ax
      
      mov	ax, #PINKY_POS_X
      inc	bx
      mov	[bx], ax
      
      mov	ax, #INKY_POS_X
      inc	bx
      mov	[bx], ax
      
      mov	ax, #CLYDE_POS_X
      inc	bx
      mov	[bx], ax
      
      mov	ax, #PACMAN_MOVE_SPEED
      mov	[PACMAN_WAIT], ax
      mov	ax, #3
      mov	[PACMAN_LIFES], ax
      
      
Start:
      mov	sp, @$2fff
      mov	ax, #START_WAIT_TIME
      mov	[START_TIMER], ax
      
      mov	bx, #15
      mov	[PACMAN_POS_X], bx
      mov	bx, #24
      mov	[PACMAN_POS_Y], bx
      
      mov	bx, #15
      mov	[BLINKY_POS_X], bx
      mov	bx, #12
      mov	[BLINKY_POS_Y], bx
      
      mov	bx, #14
      mov	[PINKY_POS_X], bx
      mov	bx, #15
      mov	[PINKY_POS_Y], bx
      
      mov	bx, #2
      mov	[PINKY_ROT], bx
      
      mov	bx, #16
      mov	[INKY_POS_X], bx
      mov	bx, #15
      mov	[INKY_POS_Y], bx
      
      mov	bx, #12
      mov	[CLYDE_POS_X], bx
      mov	bx, #15
      mov	[CLYDE_POS_Y], bx
      
      mov	ax, #1
      mov	[PACMAN_TIMER], ax
      mov	[BLINKY_TIMER], ax
      mov	[PINKY_TIMER], ax
      mov	[INKY_TIMER], ax
      
      mov	ax, #ENEMY_MOVE_SPEED
      mov	[BLINKY_WAIT], ax
      mov	[PINKY_WAIT], ax
      mov	[INKY_WAIT], ax
      mov	[CLYDE_WAIT], ax
      
      
      mov	ax, #AI_SCATTER
      mov	[BLINKY_AI], ax
      
      mov	ax, #AI_AT_HOME
      mov	[PINKY_AI], ax
      mov	[INKY_AI], ax
      mov	[CLYDE_AI], ax
      
      mov	ax, #1
      mov	[DISPLAY_FLAGS], ax
      
      mov	ax, #0
      mov	[BLINKY_AI_TIMER], ax
      mov	[PINKY_AI_TIMER], ax
      mov	[INKY_AI_TIMER], ax
      mov	[CLYDE_AI_TIMER], ax
      
      mov	ax, #90
      mov	[HOME_EXIT_TIMER], ax
      
; Start waiting
      
StartWait:
      
      
      
      mov	ax, [FRAME_SYNC]
      sub	ax, #1
      bnz	StartWait
      mov	[FRAME_SYNC], ax
      
      mov	ax, [START_TIMER]
      sub	ax, #1
      mov	[START_TIMER], ax
      
      bnz	StartWait
      
      mov	ax, #0
      mov	[DISPLAY_FLAGS], ax
      
      
; Core loop       
Loop:
      mov	ax, [FRAME_SYNC]
      sub	ax, #1
      bnz	Loop
      mov	[FRAME_SYNC], ax
      
      mov	ax, [HOME_EXIT_TIMER]
      add	ax, #1
      mov	[HOME_EXIT_TIMER], ax
      
      mov	ax, [PACMAN_TIMER]
      add	ax, #1
      mov	[PACMAN_TIMER], ax
      
      mov	bx, [PACMAN_WAIT]
      sub	ax, bx
      bnz	Blinky
      
      mov	ax, #0
      mov	[PACMAN_TIMER], ax
      mov	fx, @PacmanThink
      jsr	fx
      
Blinky: 
      mov	ax, #27
      mov	[ENEMY_SCATTER_TARGET_X], ax
      
      mov	ax, #2
      mov	[ENEMY_SCATTER_TARGET_Y], ax
      
      mov	ax, [PACMAN_POS_X]
      mov	[ENEMY_CHASE_TARGET_X], ax
      
      mov	ax, [PACMAN_POS_Y]
      mov	[ENEMY_CHASE_TARGET_Y], ax
      
      mov	ax, [RAW_PELLETS_EATEN]
      sub	ax, #196
      bpl	BlinkyFast
      
      jmp	BlinkyMove
BlinkyFast:
      sub	ax, #10
      bpl	BlinkyCruise
      
      mov	ax, #ENEMY_FAST_SPEED
      mov	[BLINKY_WAIT], ax
      
      jmp	BlinkyMove
BlinkyCruise:
      mov	ax, #ENEMY_CRUISE_SPEED
      mov	[BLINKY_WAIT], ax
      
BlinkyMove:      
      
      mov	cx, #0
      mov	ex, #BLINKY_POS_X
      mov	fx, @EnemyThink
      jsr	fx
      
Pinky: 
      mov	ax, #2
      mov	[ENEMY_SCATTER_TARGET_X], ax
      
      mov	ax, #2
      mov	[ENEMY_SCATTER_TARGET_Y], ax
      
      mov	ax, [PACMAN_ROT]
      bz	BugDir
      
      mov	dx, @GetVector
      jsr	dx
      
      asl	ax
      asl	ax
      
      asl	bx
      asl	bx
      
      mov	cx, [PACMAN_POS_X]
      add	ax, cx
      mov	[ENEMY_CHASE_TARGET_X], ax
      
      mov	cx, [PACMAN_POS_Y]
      add	bx, cx
      mov	[ENEMY_CHASE_TARGET_Y], bx

      jmp	PinkyMove
BugDir:      
      mov	ax, [PACMAN_POS_X]
      sub	ax, #4
      mov	[ENEMY_CHASE_TARGET_X], ax
      
      mov	bx, [PACMAN_POS_Y]
      sub	bx, #4
      mov	[ENEMY_CHASE_TARGET_Y], bx
      
PinkyMove:
      
      mov	cx, #0
      mov	ex, #PINKY_POS_X
      mov	fx, @EnemyThink
      jsr	fx

Inky: 
      mov	ax, #2
      mov	[ENEMY_SCATTER_TARGET_X], ax
      
      mov	ax, #27
      mov	[ENEMY_SCATTER_TARGET_Y], ax
      
      mov	ax, [PACMAN_ROT]
      bz	InkyBugDir
      
      mov	dx, @GetVector
      jsr	dx
      
      asl	ax
      asl	bx
      
      mov	cx, [PACMAN_POS_X]
      add	ax, cx
      
      mov	cx, [PACMAN_POS_Y]
      add	bx, cx
      
      jmp	InkyCalcTarget
      
InkyBugDir:      
      mov	ax, [PACMAN_POS_X]
      sub	ax, #2
      
      mov	bx, [PACMAN_POS_Y]
      sub	bx, #2 
      
InkyCalcTarget: 
      
      asl	ax
      asl	bx
      
      mov	cx, [BLINKY_POS_X]
      sub	ax, cx
      
      mov	cx, [BLINKY_POS_Y]
      sub	bx, cx
      
      mov	[ENEMY_CHASE_TARGET_X], ax
      mov	[ENEMY_CHASE_TARGET_Y], bx
      
      mov	cx, #30
      mov	ex, #INKY_POS_X
      mov	fx, @EnemyThink
      jsr	fx
      

Clyde:  
      mov	ax, #27
      mov	[ENEMY_SCATTER_TARGET_X], ax
      
      mov	ax, #27
      mov	[ENEMY_SCATTER_TARGET_Y], ax
      
      mov	ax, [CLYDE_POS_X]
      mov	bx, [PACMAN_POS_X]
      sub	ax, bx
      
      jsr	Square
      mov	ax, cx
      
      mov	ax, [CLYDE_POS_Y]
      mov	bx, [PACMAN_POS_Y]
      sub	ax, bx
      jsr	Square
      add	cx, ax
      
      sub	cx, #64
      bpl	ClydeFar
      
      mov	ax, #27
      mov	[ENEMY_CHASE_TARGET_X], ax
      
      mov	ax, #27
      mov	[ENEMY_CHASE_TARGET_Y], ax
      
      jmp	ClydeMove
      
ClydeFar: 
      
      mov	ax, [PACMAN_POS_X]
      mov	[ENEMY_CHASE_TARGET_X], ax
      
      mov	ax, [PACMAN_POS_Y]
      mov	[ENEMY_CHASE_TARGET_Y], ax
      
ClydeMove:
      
      mov	cx, #60
      mov	ex, #CLYDE_POS_X
      mov	fx, @EnemyThink
      jsr	fx      
      
      
EndLoop:      
      jmp Loop

      
      
; Character logic

      
; cx - score goal      
; ex - current enemy index   
EnemyThink:
      mov	bx, ex
      add	bx, #3
      
      mov	ax, [bx]
      add	ax, #1
      mov	[bx], ax
      
      and	ax, #3
      bnz	AIContnue
      
      add	bx, #2
      
      mov 	ax, [bx]
      add	ax, #1
      mov	[bx], ax

AIContnue:      
      
      mov	dx, [ex+3]
      
      mov	ax, [ex]
      mov	bx, [ex+1]
      
      jsr	IsTunnel
      bz	NormalSpeed
      
      lsr	dx
      
NormalSpeed:  
      mov	ax, dx
      
      mov	bx, [ex+6]
      sub	ax, bx
      bmi	EnemyWait
      
      mov	ax, #0
      mov	bx, ex
      add	bx, #3
      mov	[bx], ax
      
      mov	ax, [ex+4]
      mov	bx, ax
      and	bx, #AI_AT_HOME
      
      bnz	AtHome
      and	ax, #7
      
      bz	Chase
      sub	ax, #1
      bz	Scatter
      sub	ax, #1
      bz	Frightened
      sub	ax, #1
      bz	Respawn
      sub	ax, #1
      bz	ExitHouse
EnemyWait:
      rts

      
      
ExitHouse:   
      mov	ax, [ex]
      sub	ax, #14
      bnz	ExitCorrectX
      
      mov	bx, ex
      inc	bx
      
      mov	ax, [bx]
      sub	ax, #1
      mov	[bx], ax
      
      inc	bx
      mov	dx, #0
      mov	[bx], dx
      
      sub	ax, #12
      bz	StartScatter
      rts
      
ExitCorrectX:   
      mov	ax, #14
      mov	[ex], ax
      rts
      
      
AtHome:
      mov	bx, [RAW_PELLETS_EATEN]
      sub	bx, cx
      bpl	StartExitHouse

DontExitHouse:   
      mov	ax, [ex+4]
      and	ax, #7
      sub	ax, #AI_FRIGHTENED
      bnz	MoveInHome
      
      mov 	ax, [ex+5]
      sub	ax, @FRIGHTENED_TIME
      bpl	StopFrightened
     
MoveInHome:
      push	ex
      
      mov	ax, [ex+2]
      mov	bx, ex
      jsr	TryMove
      pop	ex
      
      add	ax, #0
      bz	HomeReverse
      
      rts      
      
HomeReverse: 
      jsr	ReverseMove
      rts

Scatter: 
      mov 	ax, [ex+5]
      sub	ax, @SCATTER_TIME
      bpl	StopScatter
      
      mov	ax, [ENEMY_SCATTER_TARGET_X]
      mov	bx, [ENEMY_SCATTER_TARGET_Y]
      
      jmp	Movement
        
Chase:    
      mov 	ax, [ex+5]
      sub	ax, @CHASE_TIME
      bpl	StopChase 
      
      mov	ax, [ENEMY_CHASE_TARGET_X]
      mov	bx, [ENEMY_CHASE_TARGET_Y]
      
      jmp	Movement
      
      
Frightened:       
      mov 	ax, [ex+5]
      sub	ax, @FRIGHTENED_TIME
      bpl	StopFrightened 
      
      jmp	RandomDirection

Respawn:
      mov	cx, [ex]
      sub	cx, #15
      bnz	GoToRespawn
      
      mov	dx, [ex+1]
      sub	dx, #12
      bnz	GoToRespawn
      
      mov	ax, #ENEMY_MOVE_SPEED
      mov	bx, ex
      add	bx, #6
      mov	[bx], ax
      
      jmp	StartScatter
      
GoToRespawn:     
      mov	ax, #15
      mov	bx, #12
      
      jmp	Movement

StartExitHouse:
      
      mov	ax, [HOME_EXIT_TIMER]
      sub	ax, #100
      bmi	DontExitHouse
      
      mov	ax, #PINKY_POS_X
      sub	ax, ex
      bz	ThenExit
      
CheckPinky:
      mov	ax, [PINKY_AI]
      sub	ax, #AI_AT_HOME
      bz	DontExitHouse
      
AmIinky:   
      mov	ax, #INKY_POS_X
      sub	ax, ex
      bz	ThenExit
      
CheckInky:  
      mov	ax, [INKY_AI]
      sub	ax, #AI_AT_HOME
      bz	DontExitHouse
      
ThenExit:      
      mov	ax, #0
      mov	[HOME_EXIT_TIMER], ax
      
      mov	ax, #AI_EXIT_HOME
      jsr	UpdateMode
      rts
      
      
      
StartFrightened:
      mov	ax, [ex+4]
      sub	ax, #AI_DEAD
      bz	DeadDoNotFear
      
      mov	ax, [ex+4]
      sub	ax, #AI_EXIT_HOME
      bz	DeadDoNotFear
      
      mov	ax, [ex+4]
      and	ax, #AI_AT_HOME
      add	ax, #AI_FRIGHTENED
      jsr	UpdateMode
      rts  
      
StartRespawn:
      
      mov	ax, #ENEMY_DEAD_MOVE_SPEED
      mov	bx, ex
      add	bx, #6
      mov	[bx], ax
      
      mov	ax, #AI_DEAD
      jsr	UpdateMode
      rts
      
DeadDoNotFear:      
      rts
      
StopFrightened:      
      mov	ax, #PACMAN_MOVE_SPEED
      mov	[PACMAN_WAIT], ax
      
      mov	ax, [ex+4]
      and	ax, #AI_AT_HOME
      add	ax, #AI_CHASE
      
      jsr	UpdateMode
      rts  
      
StopScatter:
      jsr	ReverseMove	
      
      mov	ax, #AI_CHASE
      jsr	UpdateMode
      rts
      
StopChase:  
      jsr	ReverseMove
      
StartScatter:

      mov	ax, #AI_SCATTER
      jsr	UpdateMode  
      rts
      
      
UpdateMode:      
      mov	bx, ex
      add	bx, #4
      
      mov	[bx], ax ; AI_MODE
      
      inc	bx
      mov	ax, #0
      mov	[bx], ax ; AI_TIMER
      rts
          
      
ReverseMove:
      mov	bx, ex
      add	bx, #2
      
      mov	ax, [bx]
      add	ax, #2
      and	ax, #3
      mov	[bx], ax
      rts
      
Movement:
      jsr	GetPath
      
      mov	bx, ex
      jsr	CharLogic
      rts
           
RandomDirection:
      rng	ax
      and	ax, #3
      
      mov	bx, [ex+2]
      add	bx, #2
      and	bx, #3
      
      
      mov	cx, ax
      sub	cx, bx
      bz	RandomDirection
      
      mov	bx, ex
      jsr	CharLogic
      rts
       

; PAC-MAN control logic      
      
PacmanThink:
      
      ;mov	ax, [10]
      ;add	ax, #1 
      ;mov	[10], ax
     
      
      mov	ax, [PLAYER_ROT]
      mov	bx, #PACMAN_POS_X
      
      jsr	CharLogic
      
      mov	ax, #BLINKY_POS_X
      jsr	TestCollision
      
      mov	ax, #PINKY_POS_X
      jsr	TestCollision
      
      mov	ax, #INKY_POS_X
      jsr	TestCollision
      
      mov	ax, #CLYDE_POS_X
      jsr	TestCollision
      
      mov	ax, [PACMAN_POS_X]
      mov	bx, [PACMAN_POS_Y]
      
      mov	[PELLET_X], ax
      mov	[PELLET_Y], bx
      
      mov	bx, [PELLET_DATA]
      bnz	IncScore
      rts
      
IncScore:
      mov	ax, #1
      mov	[PELLET_CLEAR], ax
      mov	ax, #0
      mov	[PELLET_CLEAR], ax
      
      sub	bx, #3
      bz	Energizer
      
      mov	ax, [SCORE]
      add	ax, #1
      mov	[SCORE], ax
      
      mov	ax, [RAW_PELLETS_EATEN]
      add	ax, #1
      mov	[RAW_PELLETS_EATEN], ax
      
      jmp	DisplayScore
      
Energizer:
      mov	ax, [SCORE]
      add	ax, #5
      mov	[SCORE], ax
      
      mov	ex, #BLINKY_POS_X
      jsr	StartFrightened
      
      mov	ex, #PINKY_POS_X
      jsr	StartFrightened
      
      mov	ex, #INKY_POS_X
      jsr	StartFrightened
      
      mov	ex, #CLYDE_POS_X
      jsr	StartFrightened
      
      mov	ax, #20
      mov	[CURRENT_KILL_SCORE], ax
      
      mov	ax, #PACMAN_ENERIZE_MOVE_SPEED
      mov	[PACMAN_WAIT], ax
      
DisplayScore:    
      mov	ax, [SCORE]
      jsr	ToDecimal
      
      rts

      
TestCollision:
      mov	cx, ax
      
      mov	ax, [PACMAN_POS_X]
      mov	bx, [cx] ; X POS
      sub	ax, bx
      
      jsr	Abs
      sub	ax, #2
      
      bpl	NoCollision
      
      mov	ax, [PACMAN_POS_Y]
      mov	bx, [cx+1] ; Y POS
      sub	ax, bx
      
      jsr	Abs
      sub	ax, #2
      
      bpl	NoCollision
      
      
      mov	ax, [cx+4] ; AI STATE
      sub	ax, #AI_FRIGHTENED
      bz	KillGhost
      sub	ax, #1
      bz	NoCollision
      
      
      ; Collision
      
      mov	ax, [PACMAN_LIFES]
      sub	ax, #1
      mov	[PACMAN_LIFES], ax
      
      bz	GameOver
      
      mov	ax, @DEATH_WAIT_TIME
      mov	[START_TIMER], ax
      
DeathWait:
      mov	ax, [FRAME_SYNC]
      sub	ax, #1
      bnz	DeathWait
      mov	[FRAME_SYNC], ax
      
      mov	ax, [START_TIMER]
      sub	ax, #1
      mov	[START_TIMER], ax
      
      bnz	DeathWait     
      
      
      jmp	Start
      
KillGhost:  
      
      mov	ex, cx
      jsr	StartRespawn
      
      mov	bx, [CURRENT_KILL_SCORE]
      
      mov	ax, [SCORE]
      add	ax, bx
      mov	[SCORE], ax
      
      asl	bx
      mov	[CURRENT_KILL_SCORE], bx
      
      sub	bx, @320
      bnz	DisplayNewScore
      
      mov	ax, #PACMAN_MOVE_SPEED
      mov	[PACMAN_WAIT], ax
      
DisplayNewScore: 
      
      jsr	ToDecimal
      
      mov	ax, @KILL_WAIT_TIME
      mov	[START_TIMER], ax
      
KillWait:
      mov	ax, [FRAME_SYNC]
      sub	ax, #1
      bnz	KillWait
      mov	[FRAME_SYNC], ax
      
      mov	ax, [START_TIMER]
      sub	ax, #1
      mov	[START_TIMER], ax
      
      bnz	KillWait
      
      
NoCollision:
      rts
      
GameOver:
      mov	ax, #3
      mov	[DISPLAY_FLAGS], ax
      
      halt
      jmp Init

      
; Movement logic for characters      
      
CharLogic: 
      push	ax
      push	bx
      
      jsr	TryMove
      add	ax, #0
      bz	WrongMove
      pop	bx
      pop	ax
      add	bx, #2
      
      mov	[bx], ax
      rts
      
WrongMove:
      pop	bx
      pop	ax
      
      mov	ax, [bx+2]
      
      jsr	TryMove
      rts
      
TryMove: ; Move character to position
      push	bx
      push	bx ; get direction vector
      jsr	GetVector
      
      pop	fx ; Add direction to pos
      add	ax, [fx]
      inc 	fx
      add	bx, [fx]
      
      jsr	TestPortals
      
      push	ax
      push	bx
      
      jsr	IsValid
      add	ax, #0
      bz	WrongRot
      
      pop	bx ; Apply new pos
      pop	ax
      pop	fx
      
      mov	[fx], ax
      inc	fx
      mov	[fx], bx
      mov	ax, #1
      rts
      
WrongRot:
      pop	ax ; Ignore
      pop	ax
      pop	ax
      mov	ax, #0
      rts
      
TestPortals:
      mov	ex, bx
      sub	ex, #$0F
      bnz	NotPortal
      
      mov	ex, ax
      sub	ex, #2
      bnz	TestRightPortal
      
      add	ax, #$19
      rts
      
TestRightPortal:
      mov	ex, ax
      sub	ex, #$1B
      bnz	NotPortal
      
      sub	ax, #$19
      rts
      
NotPortal:
      rts        
      
; Check _if this area is a tunnel
; ax, bx - pos
IsTunnel:
      push	ex
      mov	ex, bx
      sub	ex, #$0F
      bnz	NotTunnel
      
      mov	ex, ax
      sub	ex, #7
      bmi	ItIsATunnel
      
      mov	ex, ax
      sub	ex, #23
      bpl	ItIsATunnel
      
NotTunnel: 
      mov	ax, #0
      pop	ex
      rts       
      
ItIsATunnel: 
      mov	ax, #0
      pop	ex
      rts 
      
      
; Functions    

; Convert number to decimal
; ax - value      
ToDecimal:
      mov	ex, #0
      mov	cx, #0
      mov	[SCORE_DISP], cx
      
RepeatForDigit:      
      ; Clear carry
      mov	dx, #16 ; bit counter
      mov	bx, #0 ; mod10
      sec	#0
      
ConvertLoop:   
      rol	ax ; value
      rol	bx ; mod10
      
      ; Set carry
      sec	#1
      
      ; Subtract 10
      mov	cx, bx   
      sbb	cx, #10
      
      bcc	Ignore
      ; Save value
      mov	bx, cx 
      
Ignore: 
      
      dec	dx
      bnz	ConvertLoop
      
      
      rol	ax
      sec	#0
      mov	cx, bx
      mov	dx, ex
      
      asl	dx
      asl	dx
      
      jsr	ASLN
      
      mov	dx, [SCORE_DISP]
      add	dx, cx
      mov	[SCORE_DISP], dx
      
      inc	ex
      
      mov	cx, ex
      sub	cx, #4
      bnz	RepeatForDigit
      rts
    
      
; Pathfinding      
      
; ax, bx - target pos
; ex - current character
      
GetPath:
      
      mov	cx, ax
      mov	dx, bx
      
      mov	ax, @10000
      mov	[ALG_MIN_DIST], ax
      
      mov	ax, #0
      mov	[ALG_MIN_ROT], ax
      
      mov	ax, #0
 
DistCheckLoop:      
      push	ax
      
      mov	bx, [ex+2] ; Check. Can't reverse direction
      add	bx, #2
      and	bx, #3
      
      sub	bx, ax
      bz	IgnoreDirection1
      
      jsr	GetVector
      
      add	ax, [ex]
      inc	ex
      add	bx, [ex]
      dec	ex
      
      push	ax ; Check _if target is valid
      
      jsr	IsValid
      
      mov	fx, ax
      pop	ax
      add	fx, #0
      bz	IgnoreDirection1
      
      sub	ax, cx ; Calculate square distance
      sub	bx, dx
      
      push	cx
      push	bx
      
      jsr	Square
      
      mov	cx, ax
      pop	ax
      
      jsr	Square
      
      add	cx, ax ; X*X + Y*Y
      mov	ax, cx
      
      mov	bx, [ALG_MIN_DIST]
      sub	ax, bx
      bpl	IgnoreDirection
      
      ; Set _this direction as current
     
      mov	[ALG_MIN_DIST], cx
      
      pop	cx
      pop	ax
      mov	[ALG_MIN_ROT], ax

      jmp	NextDirection
      
IgnoreDirection: 
      pop	cx
IgnoreDirection1:       
      pop	ax

NextDirection:
      inc	ax
      mov	bx, ax
      sub	bx, #4
      bnz	DistCheckLoop
      
      ; Return result
      
      mov	ax, [ALG_MIN_ROT]
      rts
      
; Square of a number

; ax - number    
Square:
      push	cx
      push	dx
      
      jsr	Abs
      
      mov	cx, ax
      mov	dx, #8
      
      jsr	ASLN
      mov	bx, cx
      
      mov	cx, #8
      lsr	ax
      
MulLoop:
      bcc	DontAddSecond
      add	ax, bx
     
DontAddSecond:      
      ror	ax
      dec	cx
      bnz	MulLoop
      
      pop	dx
      pop	cx
      rts

; Absolute value of a number
      
Abs:
      add	ax, #0
      bpl	AbsPlus
      
      xor	ax, @$ffff
      add	ax, #1
      
AbsPlus:       
      rts 
      
; Logic shift N times
; cx - value, dx - times      
ASLN:
      add	dx, #0
      bz	ASLNZero
      asl	cx
      dec	dx
      bnz	ASLN
ASLNZero:      
      rts  
      
; Check _if character can enter this position

; ax, bx - position      
IsValid:
      push	fx
      push	ex
  
      mov	ex, ax ; Check X on boundary
      bz	NotValid
      sub	ex, #28
      bpl	NotValid
      
      mov	ex, bx ; Check Y on boundary
      bz	NotValid
      sub	ex, #28
      bpl	NotValid
      
      mov	[WORLD_POS_X], ax ; Check if map position
      mov	[WORLD_POS_Y], bx ; is valid
      mov	ex, [MAP_DATA]
      bnz	NotValid
      

RetIsValid:      
      mov	ax, #1
      pop	ex
      pop	fx
      rts
NotValid:
      mov	ax, #0
      pop	ex
      pop	fx
      rts

GetRotFromVector:
      push	cx
      push	dx
      
      jsr	EnsureNormalized
      
      pop	dx
      pop	cx
      
      add	ax, #0
      bnz	XNotZero
      mov	ax, bx
      add	ax, #1
      rts
      
XNotZero:   
      add	ax, #2
      rts

; ax, bx - input vector      
EnsureNormalized:
      add	ax, #0
      bz	XZero
      
      add	bx, #0
      bz	YZero
      rts
      
XZero:
      mov	cx, bx
      bpl	XPlus
      xor	cx, @$ffff
      add	cx, #1
      mov	dx, #2
      
XPlus:
      sub	dx, #1
      sub	cx, #1
      bz	Valid
      
      mov	bx, dx
      rts
      
YZero:
      
      mov	cx, ax
      bpl	YPlus
      xor	cx, @$ffff
      add	cx, #1
      mov	dx, #2
      
YPlus:
      sub	dx, #1
      sub	cx, #1
      bz	Valid
      
      mov	ax, dx
      rts
      
Valid:
      rts

; Calculate vector representing rotation value
      
GetVector:
      mov	bx, ax
      and	bx, #1 ;Check axis
      bnz	NotZero
      
      sub	ax, #1
      mov	bx, ax   ;y
      mov	ax, #0   ;x
      rts
NotZero:
      sub	ax, #2   ;x
      mov	bx, #0   ;y
      rts
      __endasm
    };
  end
`endif
      
endmodule

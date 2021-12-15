`include "hvsync_generator.v"
`include "ram.v"
`include "tileMap.v"
`include "MapData.v"
`include "mapCellsEvaluator.v"
`include "cellStateCL.v"
`include "pacManBitmap.v"
`include "animatedSprite.v"

`include "enums.vh"

`include "pacmanController.v"
`include "AccessManager.v"

`include "ColorMixer.v"
`include "cpu16.v"
`include "spriteRegs.v"
`include "blinkyBitmap.v"


`include "pelletRenderer.v"
`include "pelletBitmap.v"

`include "pelletData.v"
`include "digits10.v"










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
  tileMap numbers(
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
    .addr_b(regs.sprite_reg[5][4:0]), 
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
  
  wire [4:0] cpuPelletX = regs.sprite_reg[23][4:0];
  wire [4:0] cpuPelletY = regs.sprite_reg[24][4:0];
  wire cpuPelletClear = regs.sprite_reg[25][0];
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
    //.cpuCE(cpuCE),
    //.frameTime(ftime)
  );
  
  Pacman pacman(
    .clk(clk),
    .ce(mainCE),
    .shpos(hpos), 
    .svpos(vpos), 
    .col(pacmanColor), 
    .direction(regs.sprite_reg[2][1:0]),
    .xpos(regs.sprite_reg[0][4:0]), 
    .ypos(regs.sprite_reg[1][4:0])
   // .mapData(mapValues[pacmanX])
  );
  
  Blinky blinky(
    .clk(clk), 
    .ce(mainCE), 
    .shpos(hpos), 
    .svpos(vpos), 
    .col(blinkyColor), 
    .direction(regs.sprite_reg[8][1:0]),
    .xpos(regs.sprite_reg[6][4:0]), 
    .ypos(regs.sprite_reg[7][4:0])
  );
  
  wire [15:0] digitData  = regs.scoreDisp;
  
  wire [2:0] digitYofs = vpos[5:3];
  wire [9:0] movHpos = hpos - 70;
  wire [2:0] digitXofs = movHpos[4:2];
  wire [2:0] curDigit = movHpos[7:5];
  
  wire [3:0] curDData;
  
  always @(*) begin
    if (curDigit == 0)
      curDData = 0;
    else
      curDData = digitData[~curDigit*4+: 4];
  end
  
  wire [4:0] digitOut;
  
  digits10 digits(
    .digit(curDData), 
    .yofs(digitYofs), 
    .bits(digitOut)
  );

  wire [2:0] tilemapColor;	
  wire [2:0] gridColor = ( vpos < 10'h1e0 && hpos < 10'h1e0 ? tilemapColor : 3'd0);
  
  wire digitFilter = ( vpos > 10'h30 && vpos < 10'h70 && hpos > 10'h1c5 && hpos < 10'h270 ? digitOut[~digitXofs] : 1'd0);
  wire [2:0] digitColor = digitFilter ? `WHITE : `BLACK;
  
  wire [2:0] pacmanColor;
  wire [2:0] blinkyColor;
 
  
  ColorMixer mixer(
    .gridColor(gridColor), 
    .numbersColor(digitColor),
    .pelletColor(pelletColor),
    .pacmanColor(pacmanColor), 
    .blinkyColor(blinkyColor),
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
      regs.sprite_reg[22] <= 1;
    end
    
  end
  
  wire [15:0] address_bus;
  wire write_enable;
  wire busy;
  wire hold = vpos < 10'd480;
  
  reg [15:0] to_cpu;
  wire [15:0] from_cpu;
  
  
  reg [15:0] ram[0:16319];
  reg [15:0] rom[0:1023];
  
  wire [15:0] regs_out;
  output reg keystrobe;
  
  SpriteRegs regs(
    .clk(clk),
    .reset(reset),
    .reg_addr(address_bus[5:0]), 
    .in(from_cpu),
    .out(regs_out), 
    .we(write_enable && address_bus[15:6] == 0),
    .mapData(mapValues_b[regs.sprite_reg[4][4:0]]), 
    .playerRot(dir),
    .frame(timeCounter),
    .pelletData(cpuPelletData)
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
      to_cpu <= rom[address_bus[9:0]];    //0x4000
    //else if (address_bus[15:14] == 2'b10)
    //to_cpu <= {8'b0, regs_out}; //0x8000
  end
  
`ifdef EXT_INLINE_ASM
  
  
  
  initial begin
    rom = '{
      __asm
.arch cpu16arch
.org 0x4000
.len 1024
.define PACMAN_POS_X 0
.define PACMAN_POS_Y 1
.define PACMAN_ROT   2
.define PACMAN_TIMER 3 
      
.define PACMAN_WAIT  4

.define WORLD_POS_X  4
.define WORLD_POS_Y  5

.define BLINKY_POS_X 6
.define BLINKY_POS_Y 7
.define BLINKY_ROT   8
.define BLINKY_TIMER 9 
      
.define BLINKY_WAIT  6      
      
.define FRAME_SYNC   22       
.define PELLET_X 23
.define PELLET_Y 24     
.define PELLET_CLEAR 25
.define PELLET_DATA 35      
.define SCORE 26
.define SCORE_DISP 27
      
.define MAP_DATA 32
.define PLAYER_ROT 33
 
; Core loop      
      mov	sp, @$2fff
      mov	bx, #2
      mov	[PACMAN_POS_X], bx
      mov	[PACMAN_POS_Y], bx
      mov	bx, #27
      mov	[BLINKY_POS_X], bx
      mov	[BLINKY_POS_Y], bx
      
      mov	ax, #BLINKY_POS_X
      mov	[$C8], ax
      
      mov	ax, [BLINKY_POS_X]
      mov	bx, [BLINKY_POS_Y]
      
      mov	fx, @FindBFS
      jsr	fx
      
      mov	ax, #0
      mov	[PACMAN_TIMER], ax
      mov	[BLINKY_TIMER], ax
      mov	[SCORE], ax
      
      
Loop:
      mov	ax, [FRAME_SYNC]
      sub	ax, #1
      bnz	Loop
      mov	[FRAME_SYNC], ax
      
      mov	ax, [PACMAN_TIMER]
      add	ax, #1
      mov	[PACMAN_TIMER], ax
      
      sub	ax, #PACMAN_WAIT
      bmi	Next
      
      mov	ax, #0
      mov	[PACMAN_TIMER], ax
      mov	fx, @PacmanThink
      jsr	fx
      
Next:    
      mov	ax, [BLINKY_TIMER]
      add	ax, #1
      mov	[BLINKY_TIMER], ax
      
      sub	ax, #BLINKY_WAIT
      bnz	Next1
      
      mov	ax, #0
      mov	[BLINKY_TIMER], ax
      
      mov	fx, @BlinkyThink
      jsr	fx
      
Next1:      
      
      
      jmp Loop

      
      
; Character logic
      
      
BlinkyThink:
      mov	ax, [PACMAN_POS_X]
      mov	bx, [PACMAN_POS_Y]
      
      mov	cx, [BLINKY_POS_X]
      mov	dx, [BLINKY_POS_Y]
      
      mov	fx, @GetPath
      jsr	fx
      
      mov	cx, ax
      sub	cx, #4
      bz	Reroute
      
      
      mov	bx, #BLINKY_POS_X
      mov	fx, @CharLogic
      jsr	fx
      rts
      
Reroute:
      
      mov	ax, #BLINKY_POS_X
      mov	[$C8], ax
      
      mov	ax, [BLINKY_POS_X]
      mov	bx, [BLINKY_POS_Y]
      
      mov	fx, @FindBFS
      jsr	fx
      
      rts    
      
      
PacmanThink:
      
      mov	ax, [10]
      add	ax, #1 
      mov	[10], ax
     
      
      mov	ax, [PLAYER_ROT]
      mov	bx, #PACMAN_POS_X
      
      mov	dx, @CharLogic
      jsr	dx
      
      mov	ax, [PACMAN_POS_X]
      mov	bx, [PACMAN_POS_Y]
      
      mov	[PELLET_X], ax
      mov	[PELLET_Y], bx
      
      mov	ax, [PELLET_DATA]
      bnz	IncScore
      rts
      
IncScore:
      mov	ax, #1
      mov	[PELLET_CLEAR], ax
      mov	ax, #0
      mov	[PELLET_CLEAR], ax
      mov	ax, [SCORE]
      add	ax, #1
      mov	[SCORE], ax
      
      mov	ax, [SCORE]
      mov	fx, @ToDecimal
      jsr	fx
      
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
      
      mov	fx, @ASLN
      jsr	fx
      
      mov	dx, [SCORE_DISP]
      add	dx, cx
      mov	[SCORE_DISP], dx
      
      inc	ex
      
      mov	cx, ex
      sub	cx, #4
      bnz	RepeatForDigit
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
      
; Pathfinding      
      
; ax, bx - target pos
; cx, dx - current pos     
GetPath:
      mov	fx, @EncodePos
      jsr	fx
      push	ax
      
      mov	ax, cx
      mov	bx, dx

      mov	fx, @EncodePos
      jsr	fx
      mov	bx, ax
      pop	ax
      
      ; ax - target enc pos
      ; bx - current enc pos
      
SearchLoop: 
      mov	cx, ax ; Get value in map at target pos
      add	cx, #MAP_START
      mov	cx, [cx]
      and	cx, @$3ff
      
      bz	Failed
      
      ; cx - encoded position from map
      
      mov	dx, cx
      sub	dx, bx
      bz	PathFound
      
      ; set target pos to encoded pos
      mov	ax, cx
      jmp	SearchLoop
      
PathFound:  
      ; ax - move dir pos (encoded)
      ; bx - current pos (encoded)
      
      mov	cx, bx ; decode ax
      mov	fx, @DecodePos
      jsr	fx
      push	ax
      push	bx
      
      mov	ax, cx ; decode bx
      mov	fx, @DecodePos
      jsr	fx
      
      mov	cx, ax
      mov	dx, bx
      
      pop	bx
      pop	ax
      
      ; ax, bx - move dir pos
      ; cx, dx - current pos
      
      sub	ax, cx
      sub	bx, dx
      
           ; TODO
      halt ; Check _if position is normalized
           ; If not normalize and invert
           ; Needed to make portals work
      
      mov	fx, @GetRotFromVector
      jsr	fx
      rts
 
Failed:  
      mov	ax, #4
      rts
      
         ; Compute BFS of the map
FindBFS: ; ax, bx - start pos
      push	ax
      push	bx
      
      mov	fx, @InitQueue
      jsr	fx
      
      mov	fx, @MapClear
      jsr	fx
      
      pop	bx
      pop	ax
      mov	fx, @EncodePos
      jsr	fx
      mov	fx, @Enqueue
      jsr	fx
      
      
      
BFSLoop:

      mov	fx, @IsEmpty
      jsr	fx
      add	ax, #0
      bnz	EndBFS
      
      mov	fx, @Dequeue
      jsr	fx
      mov	cx, ax
      
      mov	fx, @IsVisited
      jsr	fx
      add	ax, #0
      bnz	BFSLoop
      
      push	cx
      mov	ax, cx
      mov	fx, @DecodePos
      jsr	fx

      
      mov	fx, @Neighbors
      jsr	fx
      
      pop	ax
      mov	fx, @SetVisited
      jsr	fx
      jmp	BFSLoop
      
EndBFS:
      rts
    
      
; Check _if position was not visited and can be reached      
CheckPos:
      
      mov	ex, @TestPortals
      jsr	ex
      
      push	dx
      push	cx
      push	bx
      push	ax
      
      mov	cx, ax
      mov	dx, bx
      
      mov	fx, @IsValid ; Check valid
      jsr	fx
      add	ax, #0
      bz	CheckRet
      
      mov	fx, @GetBack
      jsr	fx
      
      
      sub	ax, cx
      bnz	Add
      
      sub	bx, dx
      bnz	Add
      
CheckRet:  
      pop	ax
      pop	bx
      pop	cx
      pop	dx
      rts   
      
Add:
      pop	ax
      pop	bx
      pop	cx
      pop	dx
      
      mov	fx, @EncodePos
      jsr	fx
      
      push	ax
      
      mov	fx, @IsVisited
      jsr	fx
      add	ax, #0
      bnz	AddRet
      
      pop	ax
      
      mov	fx, @Enqueue
      jsr	fx
      
      push	ax
      mov	ax, cx
      mov	bx, dx
      
      mov	fx, @EncodePos
      jsr	fx
      
      pop	bx
      add	bx, #MAP_START
      mov	[bx], ax
      rts
      
AddRet:
      pop	ax
      rts  
      
GetBack:
      mov	ex, [$c8]

      mov	ax, [ex+2]
      add	ax, #2
      and	ax, #3
      mov	fx, @GetVector
      jsr	fx
      
      add	ax, [ex]
      
      inc	ex
      add	bx, [ex]
      rts      
      
           ; Find all Neighbors
Neighbors: ; ax, bx - start pos
      mov	cx, ax
      mov	dx, bx
      dec	bx
      
      mov	fx, @CheckPos
      jsr	fx

      mov	ax, cx
      mov	bx, dx
      dec	ax
      
      mov	fx, @CheckPos
      jsr	fx
      
      mov	ax, cx
      mov	bx, dx
      inc	bx
      
      mov	fx, @CheckPos
      jsr	fx
      
      mov	ax, cx
      mov	bx, dx
      inc	ax
      
      mov	fx, @CheckPos
      jsr	fx
      rts

; ax, bx - vector
; ax - result
EncodePos: ; Encode position vector into one value
      asl	bx
      asl	bx
      asl	bx
      asl	bx
      asl	bx
      add	ax, bx
      rts

; ax - value
; ax, bx - result      
DecodePos: ; Decode position value to a vector
      mov 	bx, ax
      and	ax, #$1f
      lsr	bx
      lsr	bx
      lsr	bx
      lsr	bx
      lsr	bx
      rts  
      
; Map
      
.define MAP_START 208
.define MAP_END 1232
.define VISITED_FLAG 4096
      
MapClear: ; Clear all values in the map area
      mov	ax, #MAP_START
      mov	bx, #0

ClearLoop:
      mov	[ax], bx
      inc	ax
      mov	cx, ax
      sub	cx, @MAP_END
      bnz	ClearLoop
      
      rts
 
IsVisited: ; Check if a postion has been visited
      add	ax, #MAP_START
      mov	bx, [ax]
      and 	bx, @VISITED_FLAG
      bnz	Visited
      mov	ax, #0
      rts
      
Visited:
      mov	ax, #1
      rts
      
SetVisited: ; Set position as visited
      mov	cx, ax
      add	cx, #MAP_START
      mov	ax, [cx]
      or	ax, @VISITED_FLAG
      mov	[cx], ax
      rts
      
; Queue
      
.define QUEUE_START_POS 64
.define QUEUE_END_POS 65
      
.define QUEUE_START 66 
.define QUEUE_END 194  
      
.define QUEUE_MASK 127      
 
      
InitQueue: ; Prepare queue
      mov	ax, #0
      mov	[QUEUE_START_POS], ax ; start
      mov	[QUEUE_END_POS], ax ; end
      
      mov	ax, #QUEUE_START
      mov	bx, #0

QueueClearLoop:
      mov	[ax], bx
      inc	ax
      mov	cx, ax
      sub	cx, #QUEUE_END
      bnz	QueueClearLoop
      
      rts
      
Enqueue: ; Add value to queue
      mov	bx, [QUEUE_END_POS]
      add	bx, #QUEUE_START
      mov	[bx], ax
      sub	bx, #QUEUE_START
      add	bx, #1
      and	bx, #QUEUE_MASK
      mov	[QUEUE_END_POS], bx
      rts
      
Dequeue: ; Remove value from queue
      mov	ax, [QUEUE_START_POS]
      add	ax, #QUEUE_START
      mov	bx, [ax]
      sub	ax, #QUEUE_START
      add	ax, #1
      and	ax, #QUEUE_MASK
      mov	[QUEUE_START_POS], ax
      mov	ax, bx
      rts
      
IsEmpty: ; Check if queue has any values stored
      mov	ax, [QUEUE_START_POS]
      mov	bx, [QUEUE_END_POS]
      sub	ax, bx
      bz	RetZero
      mov	ax, #0
      rts
RetZero:
      mov	ax, #1
      rts
      
      
CharLogic: ; Movement logic for characters
      push	ax
      push	bx
      
      mov	dx, @TryMove
      jsr	dx
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
      
      mov	dx, @TryMove
      jsr	dx
      rts
      
TryMove: ; Move character to position
      push	bx
      push	bx ; get direction vector
      mov	dx, @GetVector
      jsr	dx
      
      pop	fx ; Add direction to pos
      add	ax, [fx]
      inc 	fx
      add	bx, [fx]
      
      mov	dx, @TestPortals
      jsr	dx
      
      push	ax
      push	bx
      
      mov	fx, @IsValid ; Check valid
      jsr	fx
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
      
IsValid: ; Check if character can enter this position
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
      mov	ax, #1
      rts
NotValid:
      mov	ax, #0
      rts

GetRotFromVector:
      add	ax, #0
      bnz	XNotZero
      mov	ax, bx
      add	ax, #1
      rts
      
XNotZero:   
      add	ax, #2
      rts
      
GetVector: ; Calculate vector representing rotation value
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

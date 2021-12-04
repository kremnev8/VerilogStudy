`include "hvsync_generator.v"
`include "digits10.v"
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
`include "RandomNumber.v"

`include "bitmap.v"
`include "cpu16.v"

`include "spriteRegs.v"

`include "blinkyBitmap.v"










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
  output reg keystrobe = 0;
  
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
  
  wire [4:0] mapDataAddr = hold ? ram_addr[9:5] : regs.sprite_reg[4][4:0] ;
  wire [31:0] mapValues;
  
  
  MapData map(
    .caseexpr(mapDataAddr), 
    .bits(mapValues)
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
  
  reg [1:0] dir = 1;
  
  wire mainCE;
  wire pacmanCE;
  
  //output pacCE = pacmanCE;
  //output manCE = mainCE;
  
  AccessManager ceCtr(
    .clk(clk), 
    .shpos(hpos), 
    .svpos(vpos), 
    .mainCE(mainCE), 
    .pacmanCE(pacmanCE)
  );
  
  //wire [4:0] pacmanX;
  //wire [4:0] pacmanY;
  
  Pacman pacman(
    .clk(clk),
    .ce(pacmanCE),
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
    .ce(pacmanCE), 
    .shpos(hpos), 
    .svpos(vpos), 
    .col(blinkyColor), 
    .direction(regs.sprite_reg[7][1:0]),
    .xpos(regs.sprite_reg[5][4:0]), 
    .ypos(regs.sprite_reg[6][4:0])
  );

  wire [2:0] tilemapColor;	
  wire [2:0] gridColor = ( vpos < 10'h1e0 && hpos < 10'h1e0 ? tilemapColor : 3'd0);
  wire [2:0] pacmanColor;
  wire [2:0] blinkyColor;
  
  ColorMixer mixer(
    .gridColor(gridColor), 
    .pacmanColor(pacmanColor), 
    .blinkyColor(blinkyColor),
    .rgb(rgb)
  );
  
  always @(posedge clk) begin
    if (keycode[7]) begin
      case(keycode)
        8'hf7: dir <= 0;
        8'hf3: dir <= 2;
        8'he1: dir <= 1;
        8'he4: dir <= 3;
        default:;
      endcase
      keystrobe <= 1;
    end
    
    if (vpos == 1 && hpos == 1) begin
      if (regs.sprite_reg[17] > 0) 
        regs.sprite_reg[17] <= regs.sprite_reg[17] - 1'b1;
     
    end
    
  end
  
  wire [15:0] address_bus;
  wire write_enable;
  wire busy;
  wire hold = vpos < 10'd480;
  
  reg [15:0] to_cpu;
  wire [15:0] from_cpu;
  
  
  reg [15:0] ram[0:16383];
  reg [15:0] rom[0:255];
  
  wire [7:0] regs_out;
  
  SpriteRegs regs(
    .clk(clk),
    .reg_addr(address_bus[5:0]), 
    .in(from_cpu[7:0]),
    .out(regs_out), 
    .we(write_enable && address_bus[15:6] == 0),
    .mapData(mapValues[regs.sprite_reg[3][4:0]]), 
    .playerRot(dir)
  );
 
  
  CPU16 cpu(
          .clk(clk),
          .reset(reset),
          .hold(hold),
          .busy(busy),
          .address(address_bus),
          .data_in(to_cpu),
          .data_out(from_cpu),
          .write(write_enable));

  always @(posedge clk)
    if (write_enable) begin
	  if (address_bus[15:14] == 0)
            ram[address_bus[13:0]] <= from_cpu;
    end
  
  always @(posedge clk) begin
    if (address_bus[15:14] == 0)
      if (address_bus[15:6] == 0)
      	to_cpu <= {8'b0, regs_out};
      else
     	to_cpu <= ram[address_bus[13:0]];   //0x0000
    else if (address_bus[15:14] == 2'b01)
      to_cpu <= rom[address_bus[7:0]];    //0x4000
    //else if (address_bus[15:14] == 2'b10)
    //to_cpu <= {8'b0, regs_out}; //0x8000
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
  
  //32 World map data
  //33 Player desire rot
  
`ifdef EXT_INLINE_ASM
  
  
  
  initial begin
    rom = '{
      __asm
.arch cpu16arch
.org 0x4000
.len 256
.define PACMAN_POS_X 0
.define PACMAN_POS_Y 1
.define PACMAN_ROT   2

.define WORLD_POS_X  3
.define WORLD_POS_Y  4

.define BLINKY_POS_X 5
.define BLINKY_POS_Y 6
.define BLINKY_ROT 7
      
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
Loop:
      mov	ax, [17]
      bnz	Loop
      
      mov	ax, [PLAYER_ROT]
      mov	bx, #PACMAN_POS_X
      
      mov	dx, @CharLogic
      jsr	dx
      
      mov	ax, [PLAYER_ROT]
      add	ax, #2
      and	ax, #3
      mov	bx, #BLINKY_POS_X
      mov	dx, @CharLogic
      jsr	dx
      
      mov	bx, #1
      mov	[17], bx
      
      jmp Loop
      
; Functions      

      
FindBFS:
      
      
CheckPos:
      push	ax
      
      mov	fx, @IsValid ; Check valid
      jsr	fx
      add	ax, #0
      bnz	Add
      pop	ax
      rts
      
Add:
      
      
Neighbors:
      push	ax
      push	bx
      dec	ax
      
      mov	fx, @CheckPos
      jsr	fx
      
      
CharLogic:
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
      
TryMove:
      push	bx
      push	bx ; get direction vector
      mov	dx, @GetRotVector
      jsr	dx
      
      pop	fx ; Add direction to pos
      add	ax, [fx]
      inc 	fx
      add	bx, [fx]
      
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
      
      
IsValid:
      mov	cx, ax ; Check X on boundary
      bz	NotValid
      sub	cx, #28
      bpl	NotValid
      
      mov	cx, bx ; Check Y on boundary
      bz	NotValid
      sub	cx, #28
      bpl	NotValid
      
      mov	[WORLD_POS_X], ax ; Check if map position
      mov	[WORLD_POS_Y], bx ; is valid
      mov	cx, [MAP_DATA]
      bnz	NotValid
      mov	ax, #1
      rts
NotValid:
      mov	ax, #0
      rts
      
GetRotVector:
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

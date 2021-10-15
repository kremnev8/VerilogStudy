
`include "hvsync_generator.v"
`include "digits10.v"
`include "ram.v"
`include "tileMap.v"
`include "MapData.v"
`include "mapCellsEvaluator.v"
`include "cellStateCL.v"
`include "pacManBitmap.v"
`include "animatedSprite.v"

`include "pacmanController.v"





module pacman_top(clk, reset, hsync, vsync, rgb, keycode, keystrobe);

  input clk, reset;
  
  output hsync, vsync;
  output [2:0] rgb;

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
  RAM_sync ram(
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
  wire rom_bit;		   // 5 pixels per scanline
  
  wire [3:0] digit = ram_read[3:0]; // read digit from RAM
  wire [2:0] xofs = hpos[3:1];      // which pixel to draw (0-7)
  
  assign ram_addr = init ? {row,col} : {evalXpos, evalYpos};	// 10-bit RAM address

  // digits ROM
  tileMap numbers(
    .tileType(ram_read[1:0]), 
    .rotation(ram_read[3:2]), 
    .yin(rom_yofs), 
    .xin(xofs), 
    .out(rom_bit)
  );
  
  wire [31:0] mapValues;
  
  MapData map(
    .caseexpr(ram_addr[9:5]), 
    .bits(mapValues)
  );
  
  wire [4:0] evalXpos;
  wire [4:0] evalYpos;
  
  MapCellsEval worldEval(
    .clk(clk), 
    .mapData(mapValues[~ram_addr[4:0]]), 
    .worldWrite(ram_write), 
    .worldWE(ram_writeenable), 
    .outxpos(evalXpos), 
    .outypos(evalYpos), 
    .ready(init)
  );
  
  wire [2:0] color;
  reg [1:0] dir = 1;
  
  Pacman pacman(
    .clk(clk),
    .shpos(hpos), 
    .svpos(vpos), 
    .col(color), 
    .direction(dir)
    
  );
  

  // extract bit from ROM output
  wire r = display_on && 0;
  wire g = display_on && (color != 0);
  wire b = display_on && ( hpos < 10'h1e0 ? rom_bit : 1'b0);
  assign rgb = {b,g,r};
  
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
    
  end

  // increment the current RAM cell
  /*always @(posedge clk) begin
    
    
    case (hpos[2:0])
      // on 7th pixel of cell
      6: begin
        // increment RAM cell
        
        ram_write[7:3] <= 0;
        ram_write[2:0] <= {2'b00, mapValues[~col]};
        // only enable write on last scanline of cell
        ram_writeenable <= (vpos[3:1] == 7);
      end
      // on 8th pixel of cell
      7: begin
        // disable write
        ram_writeenable <= 0;
      end
    endcase
    
  end*/
      
endmodule

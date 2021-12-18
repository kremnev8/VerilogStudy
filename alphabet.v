
module Alphabet(character, yin, xin, out);
  
  input [4:0] character;  
  input [2:0] yin;
  input [2:0] xin;
  output out;
  
  reg [4:0] alphabet[0:224];
  
  wire [7:0] caseexpr = {character, yin};
  
  assign out = alphabet[caseexpr][xin];
  
  initial begin
    /*{w:5,h:8,bpw:5,count:28}*/
    alphabet['o00] = 5'b1110;
    alphabet['o01] = 5'b10001;
    alphabet['o02] = 5'b10001;
    alphabet['o03] = 5'b10001;
    alphabet['o04] = 5'b11111;
    alphabet['o05] = 5'b10001;
    alphabet['o06] = 5'b10001;
    alphabet['o07] = 5'b0;
					
    alphabet['o10] = 5'b1111;
    alphabet['o11] = 5'b10001;
    alphabet['o12] = 5'b10001;
    alphabet['o13] = 5'b1111;
    alphabet['o14] = 5'b10001;
    alphabet['o15] = 5'b10001;
    alphabet['o16] = 5'b1111;
    alphabet['o17] = 5'b0;
						
    alphabet['o20] = 5'b1110;
    alphabet['o21] = 5'b10001;
    alphabet['o22] = 5'b1;
    alphabet['o23] = 5'b1;
    alphabet['o24] = 5'b1;
    alphabet['o25] = 5'b10001;
    alphabet['o26] = 5'b1110;
    alphabet['o27] = 5'b0;
						
    alphabet['o30] = 5'b111;
    alphabet['o31] = 5'b1001;
    alphabet['o32] = 5'b10001;
    alphabet['o33] = 5'b10001;
    alphabet['o34] = 5'b10001;
    alphabet['o35] = 5'b1001;
    alphabet['o36] = 5'b111;
    alphabet['o37] = 5'b0;
						
    alphabet['o40] = 5'b11111;
    alphabet['o41] = 5'b1;
    alphabet['o42] = 5'b1;
    alphabet['o43] = 5'b1111;
    alphabet['o44] = 5'b1;
    alphabet['o45] = 5'b1;
    alphabet['o46] = 5'b11111;
    alphabet['o47] = 5'b0;
						
    alphabet['o50] = 5'b11111;
    alphabet['o51] = 5'b1;
    alphabet['o52] = 5'b1;
    alphabet['o53] = 5'b1111;
    alphabet['o54] = 5'b1;
    alphabet['o55] = 5'b1;
    alphabet['o56] = 5'b1;
    alphabet['o57] = 5'b0;
						
    alphabet['o60] = 5'b1110;
    alphabet['o61] = 5'b10001;
    alphabet['o62] = 5'b1;
    alphabet['o63] = 5'b11101;
    alphabet['o64] = 5'b10001;
    alphabet['o65] = 5'b10001;
    alphabet['o66] = 5'b11110;
    alphabet['o67] = 5'b0;
						
    alphabet['o70] = 5'b10001;
    alphabet['o71] = 5'b10001;
    alphabet['o72] = 5'b10001;
    alphabet['o73] = 5'b11111;
    alphabet['o74] = 5'b10001;
    alphabet['o75] = 5'b10001;
    alphabet['o76] = 5'b10001;
    alphabet['o77] = 5'b0;
    
    alphabet['o100] = 5'b1110;
    alphabet['o101] = 5'b100;
    alphabet['o102] = 5'b100;
    alphabet['o103] = 5'b100;
    alphabet['o104] = 5'b100;
    alphabet['o105] = 5'b100;
    alphabet['o106] = 5'b1110;
    alphabet['o107] = 5'b0;
						 
    alphabet['o110] = 5'b11100;
    alphabet['o111] = 5'b1000;
    alphabet['o112] = 5'b1000;
    alphabet['o113] = 5'b1000;
    alphabet['o114] = 5'b1000;
    alphabet['o115] = 5'b1001;
    alphabet['o116] = 5'b110;
    alphabet['o117] = 5'b0;
	
    alphabet['o120] = 5'b10001;
    alphabet['o121] = 5'b1001;
    alphabet['o122] = 5'b101;
    alphabet['o123] = 5'b11;
    alphabet['o124] = 5'b101;
    alphabet['o125] = 5'b1001;
    alphabet['o126] = 5'b10001;
    alphabet['o127] = 5'b0;
						 
    alphabet['o130] = 5'b1;
    alphabet['o131] = 5'b1;
    alphabet['o132] = 5'b1;
    alphabet['o133] = 5'b1;
    alphabet['o134] = 5'b1;
    alphabet['o135] = 5'b1;
    alphabet['o136] = 5'b11111;
    alphabet['o137] = 5'b0;
						 
    alphabet['o140] = 5'b10001;
    alphabet['o141] = 5'b11011;
    alphabet['o142] = 5'b10101;
    alphabet['o143] = 5'b10101;
    alphabet['o144] = 5'b10001;
    alphabet['o145] = 5'b10001;
    alphabet['o146] = 5'b10001;
    alphabet['o147] = 5'b0;
						 
    alphabet['o150] = 5'b10001;
    alphabet['o151] = 5'b10001;
    alphabet['o152] = 5'b10011;
    alphabet['o153] = 5'b10101;
    alphabet['o154] = 5'b11001;
    alphabet['o155] = 5'b10001;
    alphabet['o156] = 5'b10001;
    alphabet['o157] = 5'b0;
						 
    alphabet['o160] = 5'b1110;
    alphabet['o161] = 5'b10001;
    alphabet['o162] = 5'b10001;
    alphabet['o163] = 5'b10001;
    alphabet['o164] = 5'b10001;
    alphabet['o165] = 5'b10001;
    alphabet['o166] = 5'b1110;
    alphabet['o167] = 5'b0;
						 
    alphabet['o170] = 5'b1111;
    alphabet['o171] = 5'b10001;
    alphabet['o172] = 5'b10001;
    alphabet['o173] = 5'b1111;
    alphabet['o174] = 5'b1;
    alphabet['o175] = 5'b1;
    alphabet['o176] = 5'b1;
    alphabet['o177] = 5'b0;
						 
    alphabet['o200] = 5'b1110;
    alphabet['o201] = 5'b10001;
    alphabet['o202] = 5'b10001;
    alphabet['o203] = 5'b10001;
    alphabet['o204] = 5'b10101;
    alphabet['o205] = 5'b1001;
    alphabet['o206] = 5'b10110;
    alphabet['o207] = 5'b0;
						 
    alphabet['o210] = 5'b1111;
    alphabet['o211] = 5'b10001;
    alphabet['o212] = 5'b10001;
    alphabet['o213] = 5'b1111;
    alphabet['o214] = 5'b101;
    alphabet['o215] = 5'b1001;
    alphabet['o216] = 5'b10001;
    alphabet['o217] = 5'b0;
						 
    alphabet['o220] = 5'b11110;
    alphabet['o221] = 5'b1;
    alphabet['o222] = 5'b1;
    alphabet['o223] = 5'b1110;
    alphabet['o224] = 5'b10000;
    alphabet['o225] = 5'b10000;
    alphabet['o226] = 5'b1111;
    alphabet['o227] = 5'b0;
						 
    alphabet['o230] = 5'b11111;
    alphabet['o231] = 5'b100;
    alphabet['o232] = 5'b100;
    alphabet['o233] = 5'b100;
    alphabet['o234] = 5'b100;
    alphabet['o235] = 5'b100;
    alphabet['o236] = 5'b100;
    alphabet['o237] = 5'b0;
						 
    alphabet['o240] = 5'b10001;
    alphabet['o241] = 5'b10001;
    alphabet['o242] = 5'b10001;
    alphabet['o243] = 5'b10001;
    alphabet['o244] = 5'b10001;
    alphabet['o245] = 5'b10001;
    alphabet['o246] = 5'b1110;
    alphabet['o247] = 5'b0;
						 
    alphabet['o250] = 5'b10001;
    alphabet['o251] = 5'b10001;
    alphabet['o252] = 5'b10001;
    alphabet['o253] = 5'b10001;
    alphabet['o254] = 5'b10001;
    alphabet['o255] = 5'b1010;
    alphabet['o256] = 5'b100;
    alphabet['o257] = 5'b0;
						 
    alphabet['o260] = 5'b10001;
    alphabet['o261] = 5'b10001;
    alphabet['o262] = 5'b10001;
    alphabet['o263] = 5'b10101;
    alphabet['o264] = 5'b10101;
    alphabet['o265] = 5'b10101;
    alphabet['o266] = 5'b1010;
    alphabet['o267] = 5'b0;
						 
    alphabet['o270] = 5'b10001;
    alphabet['o271] = 5'b10001;
    alphabet['o272] = 5'b1010;
    alphabet['o273] = 5'b100;
    alphabet['o274] = 5'b1010;
    alphabet['o275] = 5'b10001;
    alphabet['o276] = 5'b10001;
    alphabet['o277] = 5'b0;
						 
    alphabet['o300] = 5'b10001;
    alphabet['o301] = 5'b10001;
    alphabet['o302] = 5'b10001;
    alphabet['o303] = 5'b1010;
    alphabet['o304] = 5'b100;
    alphabet['o305] = 5'b100;
    alphabet['o306] = 5'b100;
    alphabet['o307] = 5'b0;
						 
    alphabet['o310] = 5'b11111;
    alphabet['o311] = 5'b10000;
    alphabet['o312] = 5'b1000;
    alphabet['o313] = 5'b100;
    alphabet['o314] = 5'b10;
    alphabet['o315] = 5'b1;
    alphabet['o316] = 5'b11111;
    alphabet['o317] = 5'b0;
						 
    alphabet['o320] = 5'b1100;
    alphabet['o321] = 5'b1110;
    alphabet['o322] = 5'b110;
    alphabet['o323] = 5'b10;
    alphabet['o324] = 5'b0;
    alphabet['o325] = 5'b1;
    alphabet['o326] = 5'b0;
    alphabet['o327] = 5'b0;
						 
    alphabet['o330] = 5'b0;
    alphabet['o331] = 5'b0;
    alphabet['o332] = 5'b0;
    alphabet['o333] = 5'b0;
    alphabet['o334] = 5'b0;
    alphabet['o335] = 5'b0;
    alphabet['o336] = 5'b0;
    alphabet['o337] = 5'b0;
    
  end
  
endmodule
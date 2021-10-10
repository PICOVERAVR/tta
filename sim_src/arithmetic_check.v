`timescale 1ns / 1ns

module decode_check();
    reg rst, clk;
    
    reg [23:0] instr;
    
    wire valid;
    wire lit_mv; // 1 for literal being loaded, 0 for move instruction
    wire [6:0] src; // src register
    wire [6:0] dest; // destination register
    
    wire hl; // load high or low part of literal into register (if loading)
    wire [11:0] lit; // literal value to load (if loading)
    
    parameter clkp = 1;
    
    decodeunit d(.clk(clk), .rst(rst), .instr(instr), .valid(valid), .lit_mv(lit_mv), .src(src), .dest(dest), .hl(hl), .lit(lit));
    
    initial instr = 24'h0;
    initial clk = 1'b0;
    initial rst = 1'b0;
    
    always #(clkp / 2.0) begin
        clk = ~clk;
    end
    
    initial begin
        @(posedge clk);
        rst = 1'b1;
        @(posedge clk);
        @(posedge clk); // wait a few clocks to get everything settled and reset
        rst = 1'b0;
        instr = 24'h7F020; // move 0x1 -> 0x7F 
        @(posedge clk);
        instr = 24'h600FFF; // load $0xFFF -> 0x0 (high part)
    end
endmodule

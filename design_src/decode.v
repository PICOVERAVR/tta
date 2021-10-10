/*
decode ops coming in from memory

instruction encoding: 16 bits for an instruction
          7 6 5 4  3 2 1 0  F E D C  B A 9 8  7 6 5 4  3 2 1 0
r-type: [ 0 c x x  x d d d  d d d d  s s s s  s s s x  x x x x ] - 1-bit op, 1-bit conditional, 7-bit src, 7-bit dest
l-type: [ 1 c h x  x d d d  d d d d  l l l l  l l l l  l l l l ] - 1-bit op, 1-bit conditional, 1 bit high/low select, 7-bit dest, 12-bit literal
*/

`timescale 1ns / 1ns

module decodeunit(
    input clk,
    input rst,
    input [23:0] instr,
    
    output reg valid, // 0 if invalid instruction decoded
    output reg conditional, // 1 if depending on result from cmp unit
    
    output reg lit_mv, // 1 for literal being loaded, 0 for move instruction
    output reg [6:0] src, // src register
    output reg [6:0] dest, // destination register
    
    output reg hl, // load high or low part of literal into register (if loading) (0 for low)
    output reg [11:0] lit // literal value to load (if loading)
);

    parameter ireg = 1'b0;
    parameter iimm = 1'b1;

    parameter invalid_instr = 1'b0;
    parameter valid_instr = 1'b1;

    parameter literal = 1'b1;
    parameter move = 1'b0;
    
    wire intop;
    assign intop = instr[23]; // always the same regardless of instruction
    
    always @(negedge clk) begin
        conditional <= instr[22];
        dest <= instr[18:12];
        case (intop)
            ireg: begin // register move
                src <= instr[11:5];
                lit_mv <= move;
                valid <= valid_instr;
            end
            iimm: begin // literal load
                hl <= instr[21];
                lit <= instr[11:0];
                lit_mv <= literal;
                valid <= valid_instr;
            end
            default: begin
                valid <= invalid_instr;
            end
        endcase
    end
    
    always @(posedge rst) begin
        valid <= invalid_instr;
    end
    
endmodule

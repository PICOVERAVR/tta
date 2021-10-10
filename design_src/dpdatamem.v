`timescale 1ns / 1ps

module imem(
    input clk,
    input [23:0] addr,
    output reg [23:0] data
);
    parameter mem_size = 128;
    reg [23:0] rom[mem_size - 1:0];
    initial $readmemh("instr_mem.mem", rom);
    always @(negedge clk) begin
        data <= rom[addr];
    end
endmodule

module dpdmem(
    input clk,
    input [23:0] waddr,
    input [23:0] wdata,
    
    input [23:0] raddr,
    output reg [23:0] rdata,
    
    input wen
);
    
    parameter mem_size = 128;
    reg [23:0] ram[mem_size - 1:0];
    
    always @(negedge clk) begin
        if (wen) begin
            ram[waddr] <= wdata;
        end
        rdata <= ram[raddr];
    end
endmodule

/*
main design file holding everything together

R31: PC
R30: ~SP~
R29: ~FP~
R0: $0x0

*/

`timescale 1ns / 1ns

module proc_bus(
    input clk,
    input rst,
    
    output reg [23:0] iaddr, // exclude imem from unitfile because harvard arch, and saves spots. can be coalesced with dmem outside proc.
    input [23:0] idata,
    
    output [23:0] dwaddr,
    output [23:0] dwdata,
    
    output [23:0] draddr,
    input [23:0] drdata
);    
    parameter pc = 31; // pc addr is absolute
    parameter num_registers = 32;
    
    parameter fetch = 2'b00;
    parameter decode = 2'b01;
    parameter execute = 2'b10;
    
    parameter ireg = 1'b0;
    parameter iimm = 1'b1;
    
    parameter opcode = 23;
    parameter conditional = 22;
    parameter high_low_select = 21;
    
    reg [1:0] statecounter;
    
    // TODO: make the register file attached to the bus to make this a lot easier
    // add special output for PC value, avoids a useless state.
    
    reg [63:0] enablefile; // all enable signals
    
    reg cond;
    reg imm_load;
    reg hl;
    
    wire [23:0] move_bus;
    wire execute_conditional;
    
    u24add_bus a0(.clk(clk), .op_sel(), .bus(move_bus));
    u24sub_bus s0(.clk(clk), .op_sel(), .bus(move_bus));
    cmp_bus c(.clk(clk), .op_sel(), .bus(move_bus), .cmp_true(execute_conditional));
    
    always @(posedge clk) begin
        if (rst) begin
            statecounter <= fetch;
            //regfile[pc] <= 24'h0; // PC starts at address zero
            //regfile[0] <= 24'h0; // set R0 to 0x0
            enablefile <= 32'h0;
            
            cond <= 1'b0;
            imm_load <= 1'b0;
            hl <= 1'b0;
        end else begin
            case (statecounter)
                fetch: begin
                    enablefile <= 32'h0; // clear enablefile - don't want to write to things more than once.
                    //iaddr <= regfile[pc];
                    //regfile[pc] <= regfile[pc] + 1;
                    statecounter <= decode;
                end
                decode: begin
                    $display("got instr 0x%0h back, addr = 0x%0h.", idata, iaddr);
                    cond <= idata[conditional];
                    if (idata[18:12] >= num_registers) begin
                        enablefile <= enablefile | (1 << idata[18:12]); // set corresponding destination enable signal if not a storage register
                    end
                    case (idata[opcode])
                        ireg: begin // register move
                            if (idata[11:5] >= num_registers) begin
                                enablefile <= enablefile | (1 << idata[11:5]); // set corresponding destination enable signal
                            end
                        end
                        iimm: begin // literal load
                            imm_load <= 1'b1;
                            hl <= idata[high_low_select];
                            //lit <= instr[11:0];
                        end
                    endcase
                    statecounter <= execute;
                end
                execute: begin
                    //if (!cond || (cond && execute_conditional)) begin
                        // write enablefile to all registers
                    //end
                    statecounter <= fetch;
                end
                default: begin
                    $display("ERROR: invalid state counter %d.", statecounter);
                end
            endcase
        end
    end
endmodule

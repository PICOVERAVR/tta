/*
main design file holding everything together

R31: PC
R30: ~SP~
R29: ~FP~
R0: $0x0

*/

`timescale 1ns / 1ns

module proc(
    input clk,
    input rst,
    
    output reg [23:0] iaddr, // exclude imem from unitfile because harvard arch, and saves spots. can be coalesced with dmem outside proc.
    input [23:0] idata,
    
    output [23:0] dwaddr,
    output [23:0] dwdata,
    
    output [23:0] draddr,
    input [23:0] drdata
);
    parameter num_units = 11; // number of read and write ports is the same for no good reason
    
    parameter ua0opa = 0; // number is offset from wirefile, not register number
    parameter ua0opb = 1;
    
    parameter us0opa = 2;
    parameter us0opb = 3;
    
    parameter c0opa = 4;
    parameter c0opb = 5;
    parameter c0type = 6;
    
    parameter dw0addr = 7;
    parameter dw0data = 8;
    
    parameter dr0addr = 9;
    
    parameter statwrite = num_units - 1; // status register write port
    
    parameter ua0result = 0;
    
    parameter us0result = 1;
    
    parameter c0result = 2;
    
    parameter dr0data = 3;
    
    parameter statread = num_units - 1; // status register read port
    
    parameter pc = 31; // pc addr is absolute
    
    parameter fetch = 2'b00;
    parameter execute = 2'b01;
    parameter writeback = 2'b11;
    
    reg [23:0] unitfile [(num_units * 2) + 31:0];
    wire [23:0] inwirefile [num_units - 1:0];
    wire [23:0] outwirefile [num_units - 1:0];
    
    generate
        genvar i;
        for (i = 0; i < num_units; i = i + 1) begin
            assign inwirefile[i] = unitfile[i + 32]; // skip storage registers
        end
    endgenerate
    
    wire valid_instr, lit_mv, hl, cond;
    wire [6:0] src, dest;
    wire [11:0] lit;
    
    reg [1:0] statecounter;
    
    decodeunit d0(.clk(clk), .rst(rst), .instr(idata), .conditional(cond), .valid(valid_instr), .lit_mv(lit_mv), .hl(hl), .src(src), .dest(dest), .lit(lit));
    
    u24add ua0(.clk(clk), .opa(inwirefile[ua0opa]), .opb(inwirefile[ua0opb]), .result(outwirefile[ua0result]));
    u24sub us0(.clk(clk), .opa(inwirefile[us0opa]), .opb(inwirefile[us0opb]), .result(outwirefile[us0result]));
    
    cmp c0(.clk(clk), .opa(inwirefile[c0opa]), .opb(inwirefile[c0opb]), .type(inwirefile[c0type]), .result(outwirefile[c0result]));
    
    assign dwaddr = inwirefile[dw0addr]; // read and write units are connected directly to the respective wirefiles
    assign dwdata = inwirefile[dw0data];
    
    assign draddr = inwirefile[dr0addr];
    assign outwirefile[dr0data] = drdata;
    
    integer wb;
    
    always @(posedge clk) begin
        if (rst) begin
            statecounter <= fetch;
            unitfile[pc] <= 24'h0; // PC starts at address zero
            unitfile[0] <= 24'h0; // set R0 to 0x0
            unitfile[32 + statread] <= 24'h0;
        end else begin
            case (statecounter)
                fetch: begin
                    iaddr <= unitfile[pc];
                    unitfile[pc] <= unitfile[pc] + 1;
                    statecounter <= execute;
                end
                // decode executes on the falling edge of clk, result is fixed by execute stage
                execute: begin
                    $display("got instr 0x%0h back, addr = 0x%0h.", idata, iaddr);
                    $write("executed ");
                    if (cond == 1'b1) begin $write("conditional "); end
                    if (valid_instr) begin // if not valid, turn it into a nop by doing nothing.
                        if (!cond || (cond && outwirefile[c0result])) begin
                            if (lit_mv) begin // literal load, will fail if assigning a value to an output.
                                $display("load %d -> %d.", lit, dest);
                                unitfile[dest] <= hl ? { lit, unitfile[dest][11:0] } : { unitfile[dest][23:12], lit }; // load appropriate part
                            end else begin
                                $display("move %d -> %d.", src, dest);
                                unitfile[dest] <= unitfile[src];
                            end
                        end
                    end
                    else begin
                       $display("nop. (invalid instruction)");
                    end
                    statecounter <= writeback;
                end
                writeback: begin
                    for (wb = 0; wb < num_units; wb = wb + 1) begin
                        unitfile[wb + num_units + 32] <= outwirefile[wb]; // write back all output registers - BM this to see if writing only when changed is faster
                    end
                    statecounter <= fetch;
                end
                default: begin
                    $display("ERROR: invalid state counter %d.", statecounter);
                end
            endcase
        end
    end
endmodule

`timescale 1ns / 1ns

module main_check();
    reg clk, rst;

    wire [23:0] iaddr;
    wire [23:0] idata;
    
    wire [23:0] dwaddr;
    wire [23:0] dwdata;
    wire [23:0] draddr;
    wire [23:0] drdata;
    
    reg [24:0] imem[3:0];
    
    parameter clkp = 1;
    
    always #(clkp / 2.0) begin
        clk = ~clk;
    end
    
    initial clk = 1'b0;
    initial rst = 1'b0;
    
    // TODO: make this work with an 8-bit memory bus
    // TODO: write status register with stuff
    // TODO: turn off wen sometimes
    // TODO: prevent writes to R0
    // TODO: pipeline this
    // TODO: add more / multiple of each functional unit
    // TODO: add caches to the processor
    
    // long TODO: load code onto this processor from host, run it on actual FPGA
    
    // IDEA: could seperate all three stages into modules and add an enable signal to all three
    // that way we could eliminate the branch delay slot
    
    // here memories are totally different - iaddr 0 != daddr 0.
    imem #(.mem_size(128)) tm(.clk(clk), .addr(iaddr), .data(idata)); // test 128-word instruction memory
    dpdmem #(.mem_size(128)) tm2(.clk(clk), .waddr(dwaddr), .wdata(dwdata), .raddr(draddr), .rdata(drdata), .wen(1'b1)); // test 128-word data memory
    
    proc p0(.clk(clk), .rst(rst), .idata(idata), .iaddr(iaddr), .dwaddr(dwaddr), .dwdata(dwdata), .draddr(draddr), .drdata(drdata));
    
    initial begin
        @(posedge clk);
        rst = 1'b1;
        @(negedge clk);
        rst = 1'b0;
        @(posedge clk);
    end
    
endmodule

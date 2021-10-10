`timescale 1ns / 1ns

// TODO: add reset

module soc(
    input sysclk,
    output pio1,
    output pio2
);
    
    reg rst;

    wire [23:0] iaddr;
    wire [23:0] idata;
    
    wire [23:0] dwaddr;
    wire [23:0] dwdata;
    wire [23:0] draddr;
    wire [23:0] drdata;
    
    reg [24:0] imem[3:0];
    
    // note - iaddr 0 != daddr 0.
    imem #(.mem_size(32)) rom(.clk(sysclk), .addr(iaddr), .data(idata));
    dpdmem #(.mem_size(2048)) ram(.clk(sysclk), .waddr(dwaddr), .wdata(dwdata), .raddr(draddr), .rdata(drdata), .wen(1'b1));
    
    //proc p0(.clk(sysclk), .rst(rst), .idata(idata), .iaddr(iaddr), .dwaddr(dwaddr), .dwdata(dwdata), .draddr(draddr), .drdata(drdata));
    
    assign pio1 = drdata[0]; // garbage to get synthesizer to do something
    assign pio2 = sysclk; // garbage to get synthesizer to do something
    
endmodule
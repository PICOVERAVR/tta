/*

arithmetic functional units, to mix and match in the final design.
currently only supporting unsigned 24-bit arithmetic.

*/

`timescale 1ns / 1ns

module u24add(
    input clk,
    input [23:0] opa,
    input [23:0] opb,
    output reg [23:0] result
    //output reg [23:0] status
);
    
    //wire ov, z;
    //assign ov = {1'b0, opa} + {1'b0, opb} > 25'hFFFFFF ? 1'h1 : 1'h0;
    //assign z = opa + opb == 24'h0 ? 1'h1 : 1'h0;
    
    always @(posedge clk) begin
        result <= opa + opb;
        //status <= {22'h0, z, ov};
    end
endmodule

module u24sub(
    input clk,
    input [23:0] opa,
    input [23:0] opb,
    output reg [23:0] result
    //output reg [23:0] status
);

    //wire uv, z;
    //assign uv = {1'b0, opa} - {1'b0, opb} > 25'hFFFFFF ? 1'h1 : 1'h0;
    //assign z = opa - opb == 24'h0 ? 1'h1 : 1'h0;
    
    always @(posedge clk) begin
        result <= opa - opb;
        //status <= {22'h0, z, uv};
    end
endmodule
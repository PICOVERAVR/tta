`timescale 1ns / 1ns

module cmp(
    input clk,
    input [23:0] opa,
    input [23:0] opb,
    input [23:0] type,
    output reg [23:0] result
);
    parameter e = 3'h0;
    parameter ne = 3'h1;
    parameter g = 3'h2;
    parameter ge = 3'h3;
    parameter l = 3'h6;
    parameter le = 3'h7;
    parameter z = 3'h4;
    parameter nz = 3'h5;
    
    always @(posedge clk) begin
        case (type)
            e: begin
                result <= {23'h0, opa == opb ? 1'h1 : 1'h0}; // 1 for true, 0 for false
            end
            ne: begin
                result <= {23'h0, opa != opb ? 1'h1 : 1'h0};
            end
            g: begin
                result <= {23'h0, opa > opb ? 1'h1 : 1'h0};
            end
            ge: begin
                result <= {23'h0, opa >= opb ? 1'h1 : 1'h0};
            end
            l: begin
                result <= {23'h0, opa < opb ? 1'h1 : 1'h0};
            end
            le: begin
                result <= {23'h0, opa <= opb ? 1'h1 : 1'h0};
            end
            z: begin
                result <= {23'h0, opa == 24'h0 ? 1'h1 : 1'h0};
            end
            nz: begin
                result <= {23'h0, opa != 24'h0 ? 1'h1 : 'h0};
            end
            default: begin
                
            end
        endcase
    end
endmodule

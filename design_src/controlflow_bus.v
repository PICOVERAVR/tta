`timescale 1ns / 1ns

module cmp_bus(
    input clk,
    input [3:0] op_sel,
    inout [23:0] bus,
    output cmp_true
);
    parameter in_a = 4'b0001;
    parameter in_b = 4'b0010;
    parameter in_type = 4'b0100;
    parameter out_result = 4'b1000;
        
    parameter e = 3'h0;
    parameter ne = 3'h1;
    parameter g = 3'h2;
    parameter ge = 3'h3;
    parameter l = 3'h6;
    parameter le = 3'h7;
    parameter z = 3'h4;
    parameter nz = 3'h5;
    
    reg [23:0] opa, opb, result;
    assign bus = (op_sel == out_result) ? result : 24'hZ;
    assign cmp_true = (result == 24'h1) ? 1'b1 : 1'b0;
    
    always @(posedge clk) begin
        case (op_sel)
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
                $write("invalid case for cmp_bus!");
            end
        endcase
    end
endmodule

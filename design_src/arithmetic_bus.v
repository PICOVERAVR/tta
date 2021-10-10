/*

arithmetic functional units, to mix and match in the final design.
currently only supporting unsigned 24-bit arithmetic.

*/

`timescale 1ns / 1ns

module u24add_bus(
    input clk,
    input [2:0] op_sel,
    inout [23:0] bus
);
    reg [23:0] opa, opb, result;
    
    parameter in_a = 3'b01;
    parameter in_b = 3'b010;
    parameter out_result = 3'b100;
    
    assign bus = (op_sel == out_result) ? result : 24'hZ;
    always @(posedge clk) begin
        case (op_sel)
            in_a: begin
                opa <= bus;
            end
            in_b: begin
                opb <= bus;
            end
            out_result: begin
                result <= opa + opb;
            end
            default: begin
                $write("invalid case for u24add!");
            end
        endcase
    end
endmodule

module u24sub_bus(
    input clk,
    input [2:0] op_sel,
    inout [23:0] bus
);
    reg [23:0] opa, opb, result;
    
    parameter in_a = 3'b01;
    parameter in_b = 3'b010;
    parameter out_result = 3'b100;
    
    assign bus = (op_sel == out_result) ? result : 24'hZ;
    always @(posedge clk) begin
        case (op_sel)
            in_a: begin
                opa <= bus;
            end
            in_b: begin
                opb <= bus;
            end
            out_result: begin
                result <= opa - opb;
            end
            default: begin
                $write("invalid case for u24sub!");
            end
        endcase
    end
endmodule

module regfile_bus(
    input clk,
    input [31:0] op_sel,
    inout [23:0] bus
);

    reg [23:0] regfile[31:0];
    
    always @(posedge clk) begin
        case (op_sel)
            // ???
            default: begin
                $write("invalid case for regfile_bus!");
            end
        endcase
    end
endmodule
module Mux_PC (
    input   [1:0]   PCSrcE,
    input   [31:0]  PCPlus4F,
    input   [31:0]  PCTargetE,
    input   [31:0]  ALUResultE,
    output reg [31:0]  PC_next
)

always @(*) begin
    case (PCSrcE) 
        2'b00: PC_next = PCPlus4F;
        2'b01: PC_next = PCTargetE;
        2'b10: PC_next = ALUResultE;
        default: PC_next = PCPlus4F;
    endcase
end
endmodule
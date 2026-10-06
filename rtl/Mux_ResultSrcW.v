module Mux_ResultSrcW (
    input   [1:0]   ResultSrcW,
    input   [31:0]  ALUResultW,
    input   [31:0]  ReadDataW,
    input   [31:0]  PCPlus4W,
    output reg [31:0]  ALUResultE
);

always @(*) begin
    case (ResultSrcW) 
        2'b00: ALUResultE = ALUResultW;
        2'b01: ALUResultE = ReadDataW;
        2'b10: ALUResultE = PCPlus4W;
        default: ALUResultE = ALUResultW;
    endcase
end
endmodule
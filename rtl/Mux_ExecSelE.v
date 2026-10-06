module Mux_ExecSelE (
    input   [1:0]   ExecSelE,
    input   [31:0]  ALU,
    input   [31:0]  MULT,
    input   [31:0]  CRC,
    output reg [31:0]  ALUResultE
);

always @(*) begin
    case (ExecSelE) 
        2'b00: ALUResultE = ALU;
        2'b01: ALUResultE = MULT;
        2'b10: ALUResultE = CRC;
        default: ALUResultE = ALU;
    endcase
end
endmodule
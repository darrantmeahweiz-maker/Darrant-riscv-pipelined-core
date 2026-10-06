module Mux_ForwardBE (
    input   [1:0]   ForwardBE,
    input   [31:0]  RD2,
    input   [31:0]  ResultW,
    input   [31:0]  ALUResultM,
    output reg [31:0]  Formatted_RD2
);

always @(*) begin
    case (ForwardBE) 
        2'b00: Formatted_RD2 = RD2;
        2'b01: Formatted_RD2 = ResultW;
        2'b10: Formatted_RD2 = ALUResultM;
        default: Formatted_RD2 = RD2;
    endcase
end
endmodule
module Mux_ForwardAE (
    input   [1:0]   ForwardAE,
    input   [31:0]  RD1,
    input   [31:0]  ResultW,
    input   [31:0]  ALUResultM,
    output reg [31:0]  Formatted_RD1
);

always @(*) begin
    case (ForwardAE) 
        2'b00: Formatted_RD1 = RD1;
        2'b01: Formatted_RD1 = ResultW;
        2'b10: Formatted_RD1 = ALUResultM;
        default: Formatted_RD1 = RD1;
    endcase
end
endmodule
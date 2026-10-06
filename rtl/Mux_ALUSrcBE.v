module Mux_ALUSrcBE (
    input           ALUSrcBE,
    input   [31:0]  Formatted_SrcBE,
    input   [31:0]  ImmExtE,
    output reg [31:0]  SrcBE
);

always @(*) begin
    case (ALUSrcBE) 
        1'b0: SrcBE = Formatted_SrcBE;
        1'b1: SrcBE = ImmExtE;
        default: SrcBE = Formatted_SrcBE;
    endcase
end
endmodule
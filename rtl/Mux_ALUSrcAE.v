module Mux_ALUSrcAE (
    input   [1:0]   ALUSrcAE,
    input   [31:0]  Formatted_SrcAE,
    input   [31:0]  PCE,
    output reg [31:0]  SrcAE
);

always @(*) begin
    case (ALUSrcAE) 
        2'b00: SrcAE = Formatted_SrcAE;
        2'b01: SrcAE = PCE;
        2'b10: SrcAE = 0;
        default: SrcAE = Formatted_SrcAE;
    endcase
end
endmodule
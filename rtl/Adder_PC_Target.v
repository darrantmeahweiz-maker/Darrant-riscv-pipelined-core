module Adder_PC_Target (
    input   [31:0]  ImmExtE,
    input   [31:0]  PCE,
    output  [31:0]  PCTargetE
);

assign PCTargetE = PCE+ImmExtE;
endmodule
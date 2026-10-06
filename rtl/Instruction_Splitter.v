module Instruction_Splitter(
    input       [31:0]  InstrD,
    output      [6:0]   funct7,
    output      [4:0]   rs2,
    output      [4:0]   rs1,
    output      [2:0]   funct3,
    output      [4:0]   rd,
    output      [6:0]   opcode,
    output      [31:0]  Instr
);

assign funct7 = InstrD[31:25];
assign rs2 = InstrD[24:20];
assign rs1 = InstrD[19:15];
assign funct3 = InstrD[14:12];
assign rd = InstrD[11:7];
assign opcode = InstrD[6:0];
assign Instr = InstrD;

endmodule
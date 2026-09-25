module extend (
    input       [31:7]  InstrD,
    input       [2:0]   ImmSrcD,
    output reg  [31:0]  ImmExt
);

always @(*) begin
    case(ImmSrcD)
        3'b000: ImmExt = {{20{InstrD[31]}},InstrD[31:20]};                              //I-type (addi,lw,jalr)
        3'b001: ImmExt = {{20{InstrD[31]}},InstrD[31:25],InstrD[11:7]};                 //S-type (sw)
        3'b010: ImmExt = {{20{InstrD[31]}},InstrD[7],InstrD[30:25],InstrD[11:8],1'b0};  //B-type (Bne)
        3'b011: ImmExt = {{12{InstrD[31]}},InstrD[19:12],InstrD[20],InstrD[30:21],1'b0};//J-type (jal)
        3'b100: ImmExt = {InstrD[31:12],12'b0};                                         //U-type (lui,auipc)
        default: ImmExt = 32'b0;
    endcase
end
endmodule
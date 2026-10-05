module address_decoder (
    input [31:0] ALUResultM,
    input        MemWriteM,
    output       WE,        //from MemWriteM, then to DMEM
    output       OE         //output enable (read and write)
);

    wire DMEM_Select = (ALUResultM >= 32'h10010000 && ALUResultM <=32'h10010FFF) ? 1'b1 : 1'b0;
    wire UART_Select = (ALUResultM == 32'h30000000) ? 1'b1 : 1'b0;

    assign OE = DMEM_Select & ~MemWriteM;
    assign WE = DMEM_Select & MemWriteM;
endmodule
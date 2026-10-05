module Register_EX_MEM (
    input               i_Clk,

    // Inputs from Execute Stage 
    input               RegWriteE,
    input       [1:0]   ResultSrcE,
    input               MemWriteE,
    input       [31:0]  ALUResultE,
    input       [31:0]  WriteDataE,       // Value to be written to DMEM (from source register 2)
    input       [4:0]   RdE,
    input       [2:0]   funct3E,
    input       [31:0]  PCPlus4E,

    // Outputs to Memory Stage 
    output reg          RegWriteM,
    output reg  [1:0]   ResultSrcM,
    output reg          MemWriteM,
    output reg  [31:0]  ALUResultM,       // Acts as the memory address for lw/sw
    output reg  [31:0]  WriteDataM,
    output reg  [4:0]   RdM,
    output reg  [2:0]   funct3M,
    output reg  [31:0]  PCPlus4M
);

    always @(posedge i_Clk) begin
        // Pass all control signals and data cleanly from Execute to Memory stage
        RegWriteM  <= RegWriteE;
        ResultSrcM <= ResultSrcE;
        MemWriteM  <= MemWriteE;
        ALUResultM <= ALUResultE;
        WriteDataM <= WriteDataE;
        RdM        <= RdE;
        funct3M    <= funct3E;
        PCPlus4M   <= PCPlus4E;
    end

endmodule
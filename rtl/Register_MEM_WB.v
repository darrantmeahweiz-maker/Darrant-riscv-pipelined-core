module Register_MEM_WB(
    input               i_Clk,
    input               RegWriteM,
    input       [1:0]   ResultSrcM,
    input       [31:0]  ALUResultM,
    input       [31:0]  Formatted_RD,
    input       [4:0]   RdM,
    input       [31:0]  PCPlus4M,
    output reg          RegWriteW,
    output reg  [1:0]   ResultSrcW,
    output reg  [31:0]  ALUResultW,
    output reg  [31:0]  ReadDataW,
    output reg  [4:0]   RdW,
    output reg  [31:0]  PCPlus4W
);

    always @(posedge i_Clk) begin
        RegWriteW  <= RegWriteM;
        ResultSrcW <= ResultSrcM;
        ALUResultW <= ALUResultM;
        ReadDataW  <= Formatted_RD;   
        RdW        <= RdM;
        PCPlus4W   <= PCPlus4M;
    end

endmodule
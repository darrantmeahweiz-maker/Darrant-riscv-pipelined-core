module Register_MEM_WB (
    input  wire        i_Clk,

    // Control and Data from MEM Stage
    input  wire        RegWriteM,
    input  wire [1:0]  ResultSrcM,
    input  wire [31:0] ALUResultM,
    input  wire [4:0]  RdM,
    input  wire [2:0]  funct3M,
    input  wire [31:0] PCPlus4M,

    // Outputs to WB Stage
    output reg         RegWriteW,
    output reg  [1:0]  ResultSrcW,
    output reg  [31:0] ALUResultW,
    output reg  [4:0]  RdW,
    output reg  [2:0]  funct3W,
    output reg  [31:0] PCPlus4W
);

    always @(posedge i_Clk) begin
        RegWriteW  <= RegWriteM;
        ResultSrcW <= ResultSrcM;
        ALUResultW <= ALUResultM;
        RdW        <= RdM;
        funct3W    <= funct3M;
        PCPlus4W   <= PCPlus4M;
    end

endmodule
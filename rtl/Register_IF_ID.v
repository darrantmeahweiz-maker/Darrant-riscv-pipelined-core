module Register_IF_ID (
    input               i_Clk,
    input               StallD,
    input               FlushD,
    input       [31:0]  RD,
    input       [31:0]  PCF,
    input       [31:0]  PCPlus4F,

    output reg  [31:0]  InstrD,
    output reg  [31:0]  PCD,
    output reg  [31:0]  PCPlus4D
);

    always @ (posedge i_Clk) begin
        if (FlushD) begin
            InstrD   <= 32'h0;
            PCD      <= 32'h0;
            PCPlus4D <= 32'h0;
        end else if (StallD) begin
            InstrD   <= InstrD;
            PCD      <= PCD;
            PCPlus4D <= PCPlus4D;
        end else begin
            InstrD   <= RD;
            PCD      <= PCF;
            PCPlus4D <= PCPlus4F;
        end
    end

endmodule
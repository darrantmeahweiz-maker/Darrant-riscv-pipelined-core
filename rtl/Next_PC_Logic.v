module Next_PC_Logic (
    input           ZeroE,
    input           BranchE,
    input   [1:0]   JumpE,
    output reg  [1:0]   PCSrcE
);

always @(*) begin
    if (JumpE==2'b10) begin
        PCSrcE = 2'b10;
    end else if (JumpE==2'b01 || (BranchE==1'b1&&ZeroE==1'b1)) begin
        PCSrcE = 2'b01;
    end else begin
        PCSrcE = 2'b00;
    end
end
endmodule
module Next_PC_Logic (
    input           ZeroE,
    input           BranchE,
    input   [1:0]   JumpE,
    input           Pop_EnableE,       // NEW: Did we use the RAS?
    input           Mispredict_Flag,   // NEW: Was the RAS wrong?
    output reg [1:0] PCSrcE
);

always @(*) begin
    if (JumpE == 2'b10) begin
        // It's a JALR. If we used RAS and guessed right, suppress the jump!
        if (Pop_EnableE && !Mispredict_Flag) begin
            PCSrcE = 2'b00; // Suppress! Let the predicted instructions flow natively.
        end else begin
            PCSrcE = 2'b10; // Mispredict or normal JALR override
        end
    end else if (JumpE == 2'b01 || (BranchE == 1'b1 && ZeroE == 1'b1)) begin
        PCSrcE = 2'b01;
    end else begin
        PCSrcE = 2'b00;
    end
end
endmodule
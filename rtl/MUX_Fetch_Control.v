module MUX_Fetch_Control (
    input       [1:0] PCSrcE,
    input             Pop_Enable,
    output reg  [1:0] MUX_PCSel
);

always @(*) begin
    if (PCSrcE != 2'b00) begin
        // PRIORITY 1: Execute stage override
        // Route PCSrcE directly to the MUX (Selects 01 for PCTargetE or 10 for ALUResultE)
        MUX_PCSel = PCSrcE; 
        
    end else if (Pop_Enable == 1'b1) begin
        // PRIORITY 2: RAS Prediction
        // Force the MUX to select port 11 (Predicted_PC)
        MUX_PCSel = 2'b11; 
        
    end else begin
        // PRIORITY 3: Default Sequential Fetch
        // Force the MUX to select port 00 (PCPlus4F)
        MUX_PCSel = 2'b00; 
    end
end
endmodule
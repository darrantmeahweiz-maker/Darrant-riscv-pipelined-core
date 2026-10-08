module Pre_Decoder (
    input       [31:0]  InstrF,
    output wire         Push_Enable,
    output wire         Pop_Enable
);

    wire [6:0] opF  = InstrF[6:0];
    wire [4:0] rdF  = InstrF[11:7];
    wire [4:0] rs1F = InstrF[19:15];

    // Detect if instruction is a CALL
    wire is_JAL_F   = (opF == 7'b1101111);
    wire is_JALR_F  = (opF == 7'b1100111); 
    wire is_Call_F  = (is_JAL_F || is_JALR_F) && (rdF == 5'd1 || rdF == 5'd5); 
        //5'd1 (x1/ra) --> return address
        //5'd5 (x5/t0) --> Temporary register / Alternate link register

    // Detect if instruction is a RETURN
    wire is_Return_F= is_JALR_F && (rs1F == 5'd1 || rs1F == 5'd5) && (rdF == 5'd0);

    assign Push_Enable = is_Call_F;
    assign Pop_Enable  = is_Return_F;

endmodule
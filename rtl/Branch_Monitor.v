module Branch_Monitor(
    input   [31:0]  Predicted_PCE,
    input   [31:0]  ALUResultE,
    input           Pop_EnableE,
    output          Mispredict_Flag
);
    //The Mispredict_Flag goes HIGH if and only if:
    //1) The current instruction is actually a return (Pop_EnableE == 1)
    //2) The Predicted_PCE != ALUResultE);

    assign Mispredict_Flag = Pop_EnableE & (Predicted_PCE != ALUResultE);
endmodule
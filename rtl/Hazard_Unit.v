module Hazard_Unit (
    //Input for Data Forwarding (EX Stage)
    input       [4:0]   Rs1E,
    input       [4:0]   Rs2E,
    input       [4:0]   RdM, RdW,
    input               RegWriteM, RegWriteW,

    //Input for Load-Use Stalls (ID Stage)
    input       [4:0]   Rs1D,
    input       [4:0]   Rs2D,
    input       [4:0]   RdE,
    input       [1:0]   ResultSrcE, //bit 0 detect wheter EX stage is a Load instruction

    //Input for Control Hazards (EX Stage)
    input       [1:0]   PCSrcE,     //From Next PC Logic: >0 means Branch/Jump taken

    //Hazard Control Outputs
    output reg  [1:0]   ForwardAE, ForwardBE,
    output reg          StallF, StallD,
    output reg          FlushD, FlushE
);
    reg lwStall;

    always @(*) begin
        // Data Forwarding Logic 
            // add / lw / jal   instruction is legitimately writing a result back to register
            // Store and Branch instructions do not have a destination register

        //Forwarding for ALU Input A (Rs1E)
        if (RegWriteM && (RdM != 5'b0) && (RdM == Rs1E)) begin
            ForwardAE = 2'b10;      //forward from memory stage
        end else if (RegWriteW && (RdW != 5'b0) && (RdW == Rs1E)) begin
            ForwardAE = 2'b01;      //forward from writeback stage
        end else begin
            ForwardAE = 2'b00;
        end

        // Forwarding for ALU Input B (Rs2E)
        if (RegWriteM && (RdM != 5'b0) && (RdM == Rs2E)) begin
            ForwardBE = 2'b10;      // Forward from memory stage for operand B
        end else if (RegWriteW && (RdW != 5'b0) && (RdW == Rs2E)) begin
            ForwardBE = 2'b01;      // Forward from writeback stage for operand B
        end else begin
            ForwardBE = 2'b00;      // Default: use register file output for operand B
        end
    
        //Load-Use Stall Logic
            //Detect if the insturction in EX is a Load (ResultSrcE ==01) AND
            //its destination register matches either source register in ID.
            if ((ResultSrcE[0]==1'b1) && ((RdE==Rs1D)||(RdE==Rs2D))) begin
                lwStall = 1'b1;
            end else begin
                lwStall = 1'b0;
            end

        //Pipelined Stall and Flush routing (Control Hazard)
            //Flush --> create a NOP bubble --> all the data and control signals wiped out & forced to zero
            //1) Stall: Freeze PC (StallF) and ID stage (StallD) if Load-Use deteced
            StallF = lwStall;
            StallD = lwStall;

            //2) Flush ID: Clear instruction if Jump/Branch is taken
            // (PCSrcE = 01 for JAL/Branch, 10 for JALR)
            if (PCSrcE != 2'b00) begin
                FlushD = 1'b1;
            end else begin
                FlushD = 1'b0;
            end

            //3) Flush EX: Insert a bubble if Load-Use stalled OR if Jump/Branch taken
            if (lwStall || (PCSrcE != 2'b00)) begin
                FlushE = 1'b1;
            end else begin
                FlushE = 1'b0;
            end
    end
endmodule




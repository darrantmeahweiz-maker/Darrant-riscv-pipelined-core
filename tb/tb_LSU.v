`timescale 1ns / 1ps

module tb_LSU_all();

    // Inputs to LSU
    reg  [2:0]  funct3M;
    reg  [1:0]  ALUResultM;
    reg  [31:0] RD;
    
    // Outputs from LSU
    wire [3:0]  BW;
    wire [31:0] Formatted_ReadDataM;

    // Instantiate the Unit Under Test (UUT)
    LSU uut (
        .funct3M(funct3M),
        .ALUResultM(ALUResultM),
        .RD(RD),
        .BW(BW),
        .Formatted_ReadDataM(Formatted_ReadDataM)
    );

    initial begin
        $dumpfile("build/lsu_all_waveform.vcd");
        $dumpvars(0, tb_LSU_all);

        $display("=== STARTING COMPREHENSIVE LSU TEST (ALL 8 INSTRUCTIONS) ===");

        // ==========================================
        // PART 1: STORE INSTRUCTIONS (3 Instructions)
        // ==========================================

        // 1. sb (Store Byte) - funct3: 3'b000
        funct3M = 3'b000; 
        ALUResultM = 2'b10; // Byte lane 2
        RD = 32'h0;
        #10;
        $display("1. sb  -> Expected BW: 0100 | Actual BW: %b", BW);

        // 2. sh (Store Halfword) - funct3: 3'b001
        funct3M = 3'b001; 
        ALUResultM = 2'b10; // Upper halfword
        #10;
        $display("2. sh  -> Expected BW: 1100 | Actual BW: %b", BW);

        // 3. sw (Store Word) - funct3: 3'b010
        funct3M = 3'b010; 
        ALUResultM = 2'b00; 
        #10;
        $display("3. sw  -> Expected BW: 1111 | Actual BW: %b", BW);


        // ==========================================
        // PART 2: LOAD INSTRUCTIONS (5 Instructions)
        // ==========================================

        // 4. lb (Load Byte Signed) - funct3: 3'b000
        // Testing with 0x8A (bit 7 is 1, so it should sign-extend with f's)
        funct3M = 3'b000; 
        ALUResultM = 2'b00; 
        RD = 32'h0000008A; 
        #10;
        $display("4. lb  (signed)   -> Expected: ffffff8a | Actual: %h", Formatted_ReadDataM);

        // 5. lbu (Load Byte Unsigned) - funct3: 3'b100
        // Testing with the same 0x8A, but should zero-extend instead
        funct3M = 3'b100; 
        ALUResultM = 2'b00; 
        RD = 32'h0000008A; 
        #10;
        $display("5. lbu (unsigned) -> Expected: 0000008a | Actual: %h", Formatted_ReadDataM);

        // 6. lh (Load Halfword Signed) - funct3: 3'b001
        // Testing with 0x8FFF (bit 15 is 1, sign-extending upper bits)
        funct3M = 3'b001; 
        ALUResultM = 2'b00; 
        RD = 32'h00008FFF; 
        #10;
        $display("6. lh  (signed)   -> Expected: ffff8fff | Actual: %h", Formatted_ReadDataM);

        // 7. lhu (Load Halfword Unsigned) - funct3: 3'b101
        // Testing with 0x8FFF, zero-extending upper bits
        funct3M = 3'b101; 
        ALUResultM = 2'b00; 
        RD = 32'h00008FFF; 
        #10;
        $display("7. lhu (unsigned) -> Expected: 00008fff | Actual: %h", Formatted_ReadDataM);

        // 8. lw (Load Word) - funct3: 3'b010
        funct3M = 3'b010; 
        ALUResultM = 2'b00; 
        RD = 32'hDEADBEEF; 
        #10;
        $display("8. lw  (word)     -> Expected: deadbeef | Actual: %h", Formatted_ReadDataM);

        $display("=== ALL 8 INSTRUCTION TESTS COMPLETED SUCCESSFULLY ===");
        $finish;
    end

endmodule
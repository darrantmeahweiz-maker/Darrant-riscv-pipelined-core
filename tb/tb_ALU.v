`timescale 1ns / 1ps

module tb_ALU();

    // 1. Declare testbench signals
    reg  [31:0] SrcAE;
    reg  [31:0] SrcBE;
    reg  [3:0]  ALUControlE;
    
    wire [31:0] ALUResultE;
    wire        o_Zero;

    // 2. Instantiate the ALU
    ALU uut (
        .SrcAE(SrcAE),
        .SrcBE(SrcBE),
        .ALUControlE(ALUControlE),
        .ALUResultE(ALUResultE),
        .o_Zero(o_Zero)
    );

    // 3. Define localparams matching the ALU module for readability
    localparam c_ALU_OP_PASS = 4'h0;
    localparam c_ALU_OP_ADD  = 4'h1;
    localparam c_ALU_OP_SUB  = 4'h2;
    localparam c_ALU_OP_AND  = 4'h3;
    localparam c_ALU_OP_OR   = 4'h4;
    localparam c_ALU_OP_XOR  = 4'h5;
    localparam c_ALU_OP_SLL  = 4'h6;
    localparam c_ALU_OP_SRL  = 4'h7;
    localparam c_ALU_OP_SRA  = 4'h8;
    localparam c_ALU_OP_SLT  = 4'h9;
    localparam c_ALU_OP_SLTU = 4'hA;
    localparam c_ALU_OP_BNE  = 4'hB;
    localparam c_ALU_OP_BLT  = 4'hC;
    localparam c_ALU_OP_BGE  = 4'hD;
    localparam c_ALU_OP_BLTU = 4'hE;
    localparam c_ALU_OP_BGEU = 4'hF;

    // 4. Test Sequence
    initial begin
        $dumpfile("build/alu_waveform.vcd");
        $dumpvars(0, tb_ALU);

        $display("=== STARTING ALU COMPREHENSIVE TEST ===");

        // Test 0: PASS (Result = B)
        ALUControlE = c_ALU_OP_PASS; SrcAE = 32'hFFFFFFFF; SrcBE = 32'hA5A5A5A5; #10;
        $display("0. PASS -> Expected: a5a5a5a5, Z: 0 | Actual: %h, Z: %b", ALUResultE, o_Zero);

        // Test 1: ADD
        ALUControlE = c_ALU_OP_ADD;  SrcAE = 32'd20; SrcBE = 32'd10; #10;
        $display("1. ADD  -> Expected: 0000001e, Z: 0 | Actual: %h, Z: %b", ALUResultE, o_Zero);

        // Test 2: SUB 
        ALUControlE = c_ALU_OP_SUB;  SrcAE = 32'd20; SrcBE = 32'd20; #10;
        $display("2. SUB  -> Expected: 00000000, Z: 1 | Actual: %h, Z: %b", ALUResultE, o_Zero);

        // Test 3: AND
        ALUControlE = c_ALU_OP_AND;  SrcAE = 32'hF0F0F0F0; SrcBE = 32'h0F0F0F0F; #10;
        $display("3. AND  -> Expected: 00000000, Z: 1 | Actual: %h, Z: %b", ALUResultE, o_Zero);

        // Test 4: OR
        ALUControlE = c_ALU_OP_OR;   SrcAE = 32'hF0F0F0F0; SrcBE = 32'h0F0F0F0F; #10;
        $display("4. OR   -> Expected: ffffffff, Z: 0 | Actual: %h, Z: %b", ALUResultE, o_Zero);

        // Test 5: XOR
        ALUControlE = c_ALU_OP_XOR;  SrcAE = 32'hFFFFFFFF; SrcBE = 32'hA5A5A5A5; #10;
        $display("5. XOR  -> Expected: 5a5a5a5a, Z: 0 | Actual: %h, Z: %b", ALUResultE, o_Zero);

        // Test 6: SLL 
        ALUControlE = c_ALU_OP_SLL;  SrcAE = 32'h00000001; SrcBE = 32'd4; #10;
        $display("6. SLL  -> Expected: 00000010, Z: 0 | Actual: %h, Z: %b", ALUResultE, o_Zero);

        // Test 7: SRL 
        ALUControlE = c_ALU_OP_SRL;  SrcAE = 32'h80000000; SrcBE = 32'd4; #10;
        $display("7. SRL  -> Expected: 08000000, Z: 0 | Actual: %h, Z: %b", ALUResultE, o_Zero);

        // Test 8: SRA 
        ALUControlE = c_ALU_OP_SRA;  SrcAE = 32'h80000000; SrcBE = 32'd4; #10;
        $display("8. SRA  -> Expected: f8000000, Z: 0 | Actual: %h, Z: %b", ALUResultE, o_Zero);

        // Test 9: SLT 
        ALUControlE = c_ALU_OP_SLT;  SrcAE = 32'hFFFFFFFF; SrcBE = 32'h00000001; #10; // -1 < 1
        $display("9. SLT  -> Expected: 00000001, Z: 0 | Actual: %h, Z: %b", ALUResultE, o_Zero);

        // Test A: SLTU 
        ALUControlE = c_ALU_OP_SLTU; SrcAE = 32'hFFFFFFFF; SrcBE = 32'h00000001; #10; // 4,294,967,295 NOT < 1
        $display("A. SLTU -> Expected: 00000000, Z: 1 | Actual: %h, Z: %b", ALUResultE, o_Zero);

        // ---------------------------------------------------------
        // NEW TESTS: Branch Instructions (Checking Condition Flag)
        // ---------------------------------------------------------

        // Test B: BNE (Branch Not Equal)
        // A (10) != B (20) is TRUE. Expected: o_Zero = 1. ALUResult defaults to 0.
        ALUControlE = c_ALU_OP_BNE;  SrcAE = 32'd10; SrcBE = 32'd20; #10;
        $display("B. BNE  -> Expected: 00000000, Z: 1 | Actual: %h, Z: %b", ALUResultE, o_Zero);

        // Test C: BLT (Branch Less Than - Signed)
        // A (-1) < B (1) is TRUE. Expected: o_Zero = 1. ALUResult defaults to 0.
        ALUControlE = c_ALU_OP_BLT;  SrcAE = 32'hFFFFFFFF; SrcBE = 32'h00000001; #10;
        $display("C. BLT  -> Expected: 00000000, Z: 1 | Actual: %h, Z: %b", ALUResultE, o_Zero);

        // Test D: BGE (Branch Greater Than or Equal - Signed)
        // A (20) >= B (10) is TRUE. Expected: o_Zero = 1. ALUResult defaults to 0.
        ALUControlE = c_ALU_OP_BGE;  SrcAE = 32'd20; SrcBE = 32'd10; #10;
        $display("D. BGE  -> Expected: 00000000, Z: 1 | Actual: %h, Z: %b", ALUResultE, o_Zero);

        // Test E: BLTU (Branch Less Than - Unsigned)
        // A (5) < B (10) is TRUE. Expected: o_Zero = 1. ALUResult defaults to 0.
        ALUControlE = c_ALU_OP_BLTU; SrcAE = 32'd5; SrcBE = 32'd10; #10;
        $display("E. BLTU -> Expected: 00000000, Z: 1 | Actual: %h, Z: %b", ALUResultE, o_Zero);

        // Test F: BGEU (Branch Greater Than or Equal - Unsigned)
        // A (4,294,967,295) >= B (10) is TRUE. Expected: o_Zero = 1. ALUResult defaults to 0.
        ALUControlE = c_ALU_OP_BGEU; SrcAE = 32'hFFFFFFFF; SrcBE = 32'd10; #10;
        $display("F. BGEU -> Expected: 00000000, Z: 1 | Actual: %h, Z: %b", ALUResultE, o_Zero);

        // Test G: False condition check (Prove Z goes to 0 when false)
        // A (10) != B (10) is FALSE. Expected: o_Zero = 0.
        ALUControlE = c_ALU_OP_BNE;  SrcAE = 32'd10; SrcBE = 32'd10; #10;
        $display("G. BNEF -> Expected: 00000000, Z: 0 | Actual: %h, Z: %b", ALUResultE, o_Zero);

        $display("=== ALU TESTS COMPLETED ===");
        $finish;
    end

endmodule
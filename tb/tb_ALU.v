`timescale 1ns / 1ps

module tb_ALU();

    // 1. Declare testbench signals
    reg  [31:0] SrcAE;
    reg  [31:0] SrcBE;
    reg  [3:0]  ALUControlE;
    
    wire [31:0] ALUResultE;
    wire        o_Zero;

    // Error tracking counter
    integer error_count = 0;

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

    // 4. Automated Testing Task with Expected Values on the Next Row
    task test_alu;
        input [79:0] test_name;
        input [3:0]  in_ctrl;
        input [31:0] in_a;
        input [31:0] in_b;
        input [31:0] exp_result;
        input        exp_zero;
        begin
            ALUControlE = in_ctrl;
            SrcAE       = in_a;
            SrcBE       = in_b;
            #10; // Wait for combinational logic to settle

            // Compare actual vs expected outputs
            if (ALUResultE === exp_result && o_Zero === exp_zero) begin
                $display("%-8s | [PASS]", test_name);
            end else begin
                $display("%-8s | [FAIL] ❌ MISMATCH DETECTED!", test_name);
                error_count = error_count + 1;
            end

            // Display Actual on this row, Expected on the next row below
            $display("    Actual   : Result=%h, Zero=%b", ALUResultE, o_Zero);
            $display("    Expected : Result=%h, Zero=%b", exp_result, exp_zero);
            $display("--------------------------------------------------------------------------------------------------------");
        end
    endtask

    // 5. Test Sequence
    initial begin
        $dumpfile("build/alu_waveform.vcd");
        $dumpvars(0, tb_ALU);

        $display("========================================================================================================");
        $display("                                   AUTOMATED ALU VERIFICATION SUITE                                     ");
        $display("========================================================================================================");

        // format: test_alu("NAME", ALUControlE, SrcAE, SrcBE, expected_result, expected_zero)

        // Arithmetic & Logic Operations
        test_alu("PASS", c_ALU_OP_PASS, 32'hFFFFFFFF, 32'hA5A5A5A5, 32'hA5A5A5A5, 1'b0);
        test_alu("ADD",  c_ALU_OP_ADD,  32'd20,       32'd10,       32'h0000001E, 1'b0);
        test_alu("SUB",  c_ALU_OP_SUB,  32'd20,       32'd20,       32'h00000000, 1'b1);
        test_alu("AND",  c_ALU_OP_AND,  32'hF0F0F0F0, 32'h0F0F0F0F, 32'h00000000, 1'b1);
        test_alu("OR",   c_ALU_OP_OR,   32'hF0F0F0F0, 32'h0F0F0F0F, 32'hFFFFFFFF, 1'b0);
        test_alu("XOR",  c_ALU_OP_XOR,  32'hFFFFFFFF, 32'hA5A5A5A5, 32'h5A5A5A5A, 1'b0);
        test_alu("SLL",  c_ALU_OP_SLL,  32'h00000001, 32'd4,        32'h00000010, 1'b0);
        test_alu("SRL",  c_ALU_OP_SRL,  32'h80000000, 32'd4,        32'h08000000, 1'b0);
        test_alu("SRA",  c_ALU_OP_SRA,  32'h80000000, 32'd4,        32'hF8000000, 1'b0);
        test_alu("SLT",  c_ALU_OP_SLT,  32'hFFFFFFFF, 32'h00000001, 32'h00000001, 1'b0);
        test_alu("SLTU", c_ALU_OP_SLTU, 32'hFFFFFFFF, 32'h00000001, 32'h00000000, 1'b1);

        // Branch Condition Checks
        test_alu("BNE",  c_ALU_OP_BNE,  32'd10,       32'd20,       32'h00000000, 1'b1);
        test_alu("BLT",  c_ALU_OP_BLT,  32'hFFFFFFFF, 32'h00000001, 32'h00000000, 1'b1);
        test_alu("BGE",  c_ALU_OP_BGE,  32'd20,       32'd10,       32'h00000000, 1'b1);
        test_alu("BLTU", c_ALU_OP_BLTU, 32'd5,        32'd10,       32'h00000000, 1'b1);
        test_alu("BGEU", c_ALU_OP_BGEU, 32'hFFFFFFFF, 32'd10,       32'h00000000, 1'b1);
        test_alu("BNEF", c_ALU_OP_BNE,  32'd10,       32'd10,       32'h00000000, 1'b0); // False condition check

        // Final Summary Report
        $display("========================================================================================================");
        if (error_count == 0) begin
            $display(" 🎉 ALL ALU TESTS PASSED! ALU logic is fully verified.");
        end else begin
            $display(" ❌ SIMULATION FAILED: Total Mismatches Found = %0d", error_count);
        end
        $display("========================================================================================================");
        $finish;
    end

endmodule
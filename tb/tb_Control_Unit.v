`timescale 1ns / 1ps

module tb_Control_Unit();

    // 1. Declare inputs as regs
    reg [6:0] op;
    reg [2:0] funct3;
    reg [6:0] funct7;

    // 2. Declare outputs as wires
    wire        RegWriteD;
    wire [1:0]  ResultSrcD;
    wire        MemWriteD;
    wire [1:0]  JumpD;
    wire        BranchD;
    wire [1:0]  ExecSelD;
    wire [1:0]  MultControlD;
    wire [1:0]  CRCControlD;
    wire [3:0]  ALUControlD;
    wire        ALUSrcBD;
    wire [1:0]  ALUSrcAD;
    wire [2:0]  ImmSrcD;

    // Error tracking counter
    integer error_count = 0;

    // 3. Instantiate the Device Under Test (DUT)
    Control_Unit dut (
        .op(op),
        .funct3(funct3),
        .funct7(funct7),
        .RegWriteD(RegWriteD),
        .ResultSrcD(ResultSrcD),
        .MemWriteD(MemWriteD),
        .JumpD(JumpD),
        .BranchD(BranchD),
        .ExecSelD(ExecSelD),
        .MultControlD(MultControlD),
        .CRCControlD(CRCControlD),
        .ALUControlD(ALUControlD),
        .ALUSrcBD(ALUSrcBD),
        .ALUSrcAD(ALUSrcAD),
        .ImmSrcD(ImmSrcD)
    );

    // 4. Automated Testing Task with Expected Values on the Next Row
    task test_inst;
        input [79:0] inst_name;
        input [6:0]  in_op;
        input [2:0]  in_f3;
        input [6:0]  in_f7;
        // Expected control values
        input        exp_RegWriteD;
        input [1:0]  exp_ResultSrcD;
        input        exp_MemWriteD;
        input [1:0]  exp_JumpD;
        input        exp_BranchD;
        input [1:0]  exp_ExecSelD;
        input [1:0]  exp_MultControlD;
        input [1:0]  exp_CRCControlD;
        input [3:0]  exp_ALUControlD;
        input        exp_ALUSrcBD;
        input [1:0]  exp_ALUSrcAD;
        input [2:0]  exp_ImmSrcD;
        begin
            op = in_op; funct3 = in_f3; funct7 = in_f7;
            #10; // Wait for combinational logic to settle

            // Compare actual vs expected outputs
            if (RegWriteD    === exp_RegWriteD &&
                ResultSrcD   === exp_ResultSrcD &&
                MemWriteD    === exp_MemWriteD &&
                JumpD        === exp_JumpD &&
                BranchD      === exp_BranchD &&
                ExecSelD     === exp_ExecSelD &&
                MultControlD === exp_MultControlD &&
                CRCControlD  === exp_CRCControlD &&
                ALUControlD  === exp_ALUControlD &&
                ALUSrcBD     === exp_ALUSrcBD &&
                ALUSrcAD     === exp_ALUSrcAD &&
                ImmSrcD      === exp_ImmSrcD) begin
                
                $display("%-8s | [PASS]", inst_name);
            end else begin
                $display("%-8s | [FAIL] ❌ MISMATCH DETECTED!", inst_name);
                error_count = error_count + 1;
            end

            // Display Actual on this row, Expected on the next row below
            $display("    Actual   : RegW=%b Res=%b MemW=%b Jump=%b Br=%b Exec=%b Mult=%b CRC=%b ALU=%b SrcB=%b SrcA=%b Imm=%b", 
                     RegWriteD, ResultSrcD, MemWriteD, JumpD, BranchD, 
                     ExecSelD, MultControlD, CRCControlD, ALUControlD, ALUSrcBD, ALUSrcAD, ImmSrcD);
            $display("    Expected : RegW=%b Res=%b MemW=%b Jump=%b Br=%b Exec=%b Mult=%b CRC=%b ALU=%b SrcB=%b SrcA=%b Imm=%b", 
                     exp_RegWriteD, exp_ResultSrcD, exp_MemWriteD, exp_JumpD, exp_BranchD, 
                     exp_ExecSelD, exp_MultControlD, exp_CRCControlD, exp_ALUControlD, exp_ALUSrcBD, exp_ALUSrcAD, exp_ImmSrcD);
            $display("--------------------------------------------------------------------------------------------------------");
        end
    endtask

    // 5. Run the Test Sequence
    initial begin
        $display("========================================================================================================");
        $display("                                AUTOMATED CONTROL UNIT VERIFICATION SUITE                               ");
        $display("========================================================================================================");

        // R-Type Instructions
        test_inst("ADD",   7'b0110011, 3'b000, 7'b0000000,  1'b1, 2'b00, 1'b0, 2'b00, 1'b0, 2'b00, 2'b00, 2'b00, 4'h1, 1'b0, 2'b00, 3'b000);
        test_inst("SUB",   7'b0110011, 3'b000, 7'b0100000,  1'b1, 2'b00, 1'b0, 2'b00, 1'b0, 2'b00, 2'b00, 2'b00, 4'h2, 1'b0, 2'b00, 3'b000);
        test_inst("SLL",   7'b0110011, 3'b001, 7'b0000000,  1'b1, 2'b00, 1'b0, 2'b00, 1'b0, 2'b00, 2'b00, 2'b00, 4'h6, 1'b0, 2'b00, 3'b000);
        
        // Custom Extensions (MULT & CRC)
        test_inst("MUL",   7'b0110011, 3'b000, 7'b0000001,  1'b1, 2'b00, 1'b0, 2'b00, 1'b0, 2'b01, 2'b00, 2'b00, 4'h0, 1'b0, 2'b00, 3'b000);
        test_inst("MULH",  7'b0110011, 3'b001, 7'b0000001,  1'b1, 2'b00, 1'b0, 2'b00, 1'b0, 2'b01, 2'b01, 2'b00, 4'h0, 1'b0, 2'b00, 3'b000);
        test_inst("CRCB",  7'b0110011, 3'b000, 7'b1000000,  1'b1, 2'b00, 1'b0, 2'b00, 1'b0, 2'b10, 2'b00, 2'b00, 4'h0, 1'b0, 2'b00, 3'b000);
        test_inst("CRCW",  7'b0110011, 3'b010, 7'b1000000,  1'b1, 2'b00, 1'b0, 2'b00, 1'b0, 2'b10, 2'b00, 2'b10, 4'h0, 1'b0, 2'b00, 3'b000);

        // I-Type Instructions
        test_inst("ADDI",  7'b0010011, 3'b000, 7'b0000000,  1'b1, 2'b00, 1'b0, 2'b00, 1'b0, 2'b00, 2'b00, 2'b00, 4'h1, 1'b1, 2'b00, 3'b000);
        test_inst("SRAI",  7'b0010011, 3'b101, 7'b0100000,  1'b1, 2'b00, 1'b0, 2'b00, 1'b0, 2'b00, 2'b00, 2'b00, 4'h8, 1'b1, 2'b00, 3'b000);

        // Memory Instructions (LW / SW)
        test_inst("LW",    7'b0000011, 3'b010, 7'b0000000,  1'b1, 2'b01, 1'b0, 2'b00, 1'b0, 2'b00, 2'b00, 2'b00, 4'h1, 1'b1, 2'b00, 3'b000); 
        test_inst("SW",    7'b0100011, 3'b010, 7'b0000000,  1'b0, 2'b00, 1'b1, 2'b00, 1'b0, 2'b00, 2'b00, 2'b00, 4'h1, 1'b1, 2'b00, 3'b001); 

        // Branch Instructions
        test_inst("BEQ",   7'b1100011, 3'b000, 7'b0000000,  1'b0, 2'b00, 1'b0, 2'b00, 1'b1, 2'b00, 2'b00, 2'b00, 4'h2, 1'b0, 2'b00, 3'b010); 
        test_inst("BGE",   7'b1100011, 3'b101, 7'b0000000,  1'b0, 2'b00, 1'b0, 2'b00, 1'b1, 2'b00, 2'b00, 2'b00, 4'hD, 1'b0, 2'b00, 3'b010); 

        // Jump Instructions
        test_inst("JAL",   7'b1101111, 3'b000, 7'b0000000,  1'b1, 2'b10, 1'b0, 2'b01, 1'b0, 2'b00, 2'b00, 2'b00, 4'h0, 1'b0, 2'b00, 3'b011); 
        test_inst("JALR",  7'b1100111, 3'b000, 7'b0000000,  1'b1, 2'b10, 1'b0, 2'b10, 1'b0, 2'b00, 2'b00, 2'b00, 4'h1, 1'b1, 2'b00, 3'b000); 

        // U-Type Instructions
        test_inst("LUI",   7'b0110111, 3'b000, 7'b0000000,  1'b1, 2'b00, 1'b0, 2'b00, 1'b0, 2'b00, 2'b00, 2'b00, 4'h0, 1'b1, 2'b10, 3'b100); 
        test_inst("AUIPC", 7'b0010111, 3'b000, 7'b0000000,  1'b1, 2'b00, 1'b0, 2'b00, 1'b0, 2'b00, 2'b00, 2'b00, 4'h1, 1'b1, 2'b01, 3'b100); 

        // Final Summary Report
        $display("========================================================================================================");
        if (error_count == 0) begin
            $display(" 🎉 ALL INSTRUCTIONS PASSED! Control Unit logic is fully verified.");
        end else begin
            $display(" ❌ SIMULATION FAILED: Total Mismatches Found = %0d", error_count);
        end
        $display("========================================================================================================");
        $finish;
    end

endmodule
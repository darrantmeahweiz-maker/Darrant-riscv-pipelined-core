`timescale 1ns / 1ps

module tb_LSU_all();

    // Inputs to LSU
    reg  [2:0]  funct3M;
    reg  [1:0]  ALUResultM;
    reg  [31:0] RD;
    
    // Outputs from LSU
    wire [3:0]  BW;
    wire [31:0] Formatted_ReadDataM;

    // Error tracking counter
    integer error_count = 0;

    // Instantiate the Unit Under Test (UUT)
    LSU uut (
        .funct3M(funct3M),
        .ALUResultM(ALUResultM),
        .RD(RD),
        .BW(BW),
        .Formatted_ReadDataM(Formatted_ReadDataM)
    );

    // Automated Testing Task with Side-by-Side Expected vs Actual Display
    task test_lsu;
        input [79:0] inst_name;
        input [2:0]  in_f3;
        input [1:0]  in_alu;
        input [31:0] in_rd;
        input [3:0]  exp_bw;
        input [31:0] exp_data;
        begin
            funct3M    = in_f3;
            ALUResultM = in_alu;
            RD         = in_rd;
            #10; // Wait for combinational logic to settle

            if (BW === exp_bw && Formatted_ReadDataM === exp_data) begin
                $display("%-5s | [PASS] | BW [Exp:%b | Act:%b] | Data [Exp:%h | Act:%h]", 
                         inst_name, exp_bw, BW, exp_data, Formatted_ReadDataM);
            end else begin
                $display("%-5s | [FAIL] | BW [Exp:%b | Act:%b] | Data [Exp:%h | Act:%h] ❌", 
                         inst_name, exp_bw, BW, exp_data, Formatted_ReadDataM);
                error_count = error_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("build/lsu_all_waveform.vcd");
        $dumpvars(0, tb_LSU_all);

        $display("========================================================================================================");
        $display("                               AUTOMATED LSU VERIFICATION SUITE (WITH EXPECTED VALUES)                  ");
        $display("========================================================================================================");

        // ================================================================================================================
        // format: test_lsu("NAME", funct3, ALUResult[1:0], RD_input, expected_BW, expected_Formatted_Data)
        // ================================================================================================================

        // -----------------------------------------
        // PART 1: STORE INSTRUCTIONS
        // -----------------------------------------
        test_lsu("SB",   3'b000, 2'b10, 32'h00000000, 4'b0100, 32'h00000000);
        test_lsu("SH",   3'b001, 2'b10, 32'h00000000, 4'b1100, 32'h00000000);
        test_lsu("SW",   3'b010, 2'b00, 32'h00000000, 4'b1111, 32'h00000000);

        // -----------------------------------------
        // PART 2: LOAD INSTRUCTIONS
        // -----------------------------------------
        test_lsu("LB",   3'b000, 2'b00, 32'h0000008A, 4'b0001, 32'hFFFFFF8A);
        test_lsu("LBU",  3'b100, 2'b00, 32'h0000008A, 4'b0001, 32'h0000008A);
        test_lsu("LH",   3'b001, 2'b00, 32'h00008FFF, 4'b0011, 32'hFFFF8FFF);
        test_lsu("LHU",  3'b101, 2'b00, 32'h00008FFF, 4'b0011, 32'h00008FFF);
        test_lsu("LW",   3'b010, 2'b00, 32'hDEADBEEF, 4'b1111, 32'hDEADBEEF);

        // Final Summary Report
        $display("========================================================================================================");
        if (error_count == 0) begin
            $display(" 🎉 ALL LSU TESTS PASSED! Load-Store Unit logic is fully verified.");
        end else begin
            $display(" ❌ SIMULATION FAILED: Total Mismatches Found = %0d", error_count);
        end
        $display("========================================================================================================");
        $finish;
    end

endmodule
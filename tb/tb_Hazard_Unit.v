`timescale 1ns / 1ps

module tb_Hazard_Unit();

    // 1. Declare inputs as regs
    reg [4:0] rs1e, rs2e;
    reg [4:0] rdm, rdw;
    reg       regwritem, regwritew;
    reg [4:0] rs1d, rs2d;
    reg [4:0] rde;
    reg [1:0] resultsrce;
    reg [1:0] pcscrce;

    // 2. Declare outputs as wires
    wire [1:0] forwardae, forwardbe;
    wire       stallf, stalld;
    wire       flushd, flushe;

    // Error tracking counter
    integer error_count = 0;

    // 3. Instantiate the Device Under Test (DUT)
    Hazard_Unit dut (
        .Rs1E(rs1e),
        .Rs2E(rs2e),
        .RdM(rdm),
        .RdW(rdw),
        .RegWriteM(regwritem),
        .RegWriteW(regwritew),
        .Rs1D(rs1d),
        .Rs2D(rs2d),
        .RdE(rde),
        .ResultSrcE(resultsrce),
        .PCSrcE(pcscrce),
        .ForwardAE(forwardae),
        .ForwardBE(forwardbe),
        .StallF(stallf),
        .StallD(stalld),
        .FlushD(flushd),
        .FlushE(flushe)
    );

    // 4. Automated Testing Task with Expected Values
    task test_hazard;
        input [127:0] test_name;
        // Inputs
        input [4:0] in_rs1e, in_rs2e;
        input [4:0] in_rdm, in_rdw;
        input       in_regwritem, in_regwritew;
        input [4:0] in_rs1d, in_rs2d;
        input [4:0] in_rde;
        input [1:0] in_resultsrce;
        input [1:0] in_pcscrce;
        // Expected outputs
        input [1:0] exp_forwardae, exp_forwardbe;
        input       exp_stallf, exp_stalld;
        input       exp_flushd, exp_flushe;
        begin
            // Apply inputs
            rs1e       = in_rs1e;
            rs2e       = in_rs2e;
            rdm        = in_rdm;
            rdw        = in_rdw;
            regwritem  = in_regwritem;
            regwritew  = in_regwritew;
            rs1d       = in_rs1d;
            rs2d       = in_rs2d;
            rde        = in_rde;
            resultsrce = in_resultsrce;
            pcscrce    = in_pcscrce;
            
            #10; // Wait for combinational logic to settle

            // Compare actual vs expected outputs
            if (forwardae  === exp_forwardae  &&
                forwardbe  === exp_forwardbe  &&
                stallf     === exp_stallf     &&
                stalld     === exp_stalld     &&
                flushd     === exp_flushd     &&
                flushe     === exp_flushe) begin
                
                $display("%-25s | [PASS]", test_name);
            end else begin
                $display("%-25s | [FAIL] ❌ MISMATCH DETECTED!", test_name);
                error_count = error_count + 1;
            end

            // Display Actual vs Expected rows
            $display("    Actual   : FwdAE=%b FwdBE=%b StallF=%b StallD=%b FlushD=%b FlushE=%b", 
                     forwardae, forwardbe, stallf, stalld, flushd, flushe);
            $display("    Expected : FwdAE=%b FwdBE=%b StallF=%b StallD=%b FlushD=%b FlushE=%b", 
                     exp_forwardae, exp_forwardbe, exp_stallf, exp_stalld, exp_flushd, exp_flushe);
            $display("--------------------------------------------------------------------------------------------------------");
        end
    endtask

    // 5. Run the Test Sequence
    initial begin
        $display("========================================================================================================");
        $display("                        AUTOMATED HAZARD UNIT VERIFICATION SUITE                                ");
        $display("========================================================================================================");

        // --- SECTION 1: Default / No Hazards ---
        // Description, Rs1E, Rs2E, RdM, RdW, RegW_M, RegW_W, Rs1D, Rs2D, RdE, ResSrcE, PCSrcE || Exp: FwdAE, FwdBE, StallF, StallD, FlushD, FlushE
        test_hazard("NO_HAZARD", 
                    5'd1, 5'd2, 5'd0, 5'd0, 1'b0, 1'b0, 5'd3, 5'd4, 5'd0, 2'b00, 2'b00, 
                    2'b00, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

        // --- SECTION 2: Data Forwarding A & B Tests ---
        // Forward from MEM stage for Input A (RdM matches Rs1E)
        test_hazard("FWD_A_MEM", 
                    5'd5, 5'd2, 5'd5, 5'd0, 1'b1, 1'b0, 5'd0, 5'd0, 5'd0, 2'b00, 2'b00, 
                    2'b10, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

        // Forward from WB stage for Input A (RdW matches Rs1E)
        test_hazard("FWD_A_WB", 
                    5'd7, 5'd2, 5'd0, 5'd7, 1'b0, 1'b1, 5'd0, 5'd0, 5'd0, 2'b00, 2'b00, 
                    2'b01, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

        // Forward from MEM stage for Input B (RdM matches Rs2E)
        test_hazard("FWD_B_MEM", 
                    5'd1, 5'd8, 5'd8, 5'd0, 1'b1, 1'b0, 5'd0, 5'd0, 5'd0, 2'b00, 2'b00, 
                    2'b00, 2'b10, 1'b0, 1'b0, 1'b0, 1'b0);

        // MEM Priority over WB test (Both RdM and RdW match Rs1E) -> MEM should win (2'b10)
        test_hazard("FWD_MEM_PRIORITY", 
                    5'd9, 5'd2, 5'd9, 5'd9, 1'b1, 1'b1, 5'd0, 5'd0, 5'd0, 2'b00, 2'b00, 
                    2'b10, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

        // Zero Register check: RdM == 0 should NOT forward even if matching Rs1E
        test_hazard("IGNORE_X0_FWD", 
                    5'd0, 5'd2, 5'd0, 5'd0, 1'b1, 1'b1, 5'd0, 5'd0, 5'd0, 2'b00, 2'b00, 
                    2'b00, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

        // --- SECTION 3: Load-Use Stall Tests ---
        // Load-Use Stall triggered when instruction in EX is Load (ResultSrcE[0]=1) and RdE matches Rs1D
        test_hazard("LOAD_USE_STALL_Rs1", 
                    5'd0, 5'd0, 5'd0, 5'd0, 1'b0, 1'b0, 5'd5, 5'd2, 5'd5, 2'b01, 2'b00, 
                    2'b00, 2'b00, 1'b1, 1'b1, 1'b0, 1'b1);

        // Load-Use Stall triggered when RdE matches Rs2D
        test_hazard("LOAD_USE_STALL_Rs2", 
                    5'd0, 5'd0, 5'd0, 5'd0, 1'b0, 1'b0, 5'd2, 5'd6, 5'd6, 2'b01, 2'b00, 
                    2'b00, 2'b00, 1'b1, 1'b1, 1'b0, 1'b1);

        // Non-Load instruction in EX (ResultSrcE = 2'b00) should NOT trigger load-use stall even if registers match
        test_hazard("NO_STALL_ALU_MATCH", 
                    5'd0, 5'd0, 5'd0, 5'd0, 1'b0, 1'b0, 5'd5, 5'd2, 5'd5, 2'b00, 2'b00, 
                    2'b00, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

        // --- SECTION 4: Control Hazard (Branch / Jump Taken) Tests ---
        // Branch taken (PCSrcE = 2'b01) should flush Decode and Execute stages
        test_hazard("BRANCH_TAKEN_FLUSH", 
                    5'd0, 5'd0, 5'd0, 5'd0, 1'b0, 1'b0, 5'd0, 5'd0, 5'd0, 2'b00, 2'b01, 
                    2'b00, 2'b00, 1'b0, 1'b0, 1'b1, 1'b1);

        // --- Final Summary Report ---
        $display("========================================================================================================");
        if (error_count == 0) begin
            $display(" 🎉 ALL HAZARD UNIT TESTS PASSED! Forwarding, Stalls, and Flushes are fully verified.");
        end else begin
            $display(" ❌ SIMULATION FAILED: Total Mismatches Found = %0d", error_count);
        end
        $display("========================================================================================================");
        $finish;
    end

endmodule
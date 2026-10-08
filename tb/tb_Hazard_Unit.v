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
    reg       mispredict_flag; 

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
        .Mispredict_Flag(mispredict_flag), // FIXED: Removed trailing comma and mapped to reg
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
        input       in_mispredict;
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
            rs1e            = in_rs1e;
            rs2e            = in_rs2e;
            rdm             = in_rdm;
            rdw             = in_rdw;
            regwritem       = in_regwritem;
            regwritew       = in_regwritew;
            mispredict_flag = in_mispredict; // FIXED: Mapped to declared register
            rs1d            = in_rs1d;
            rs2d            = in_rs2d;
            rde             = in_rde;
            resultsrce      = in_resultsrce;
            pcscrce         = in_pcscrce;
            
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
        $dumpfile("build/hazard_waveform.vcd");
        $dumpvars(0,tb_Hazard_Unit);
        $display("========================================================================================================");
        $display("                        AUTOMATED HAZARD UNIT VERIFICATION SUITE                                ");
        $display("========================================================================================================");

        // --- SECTION 1: Default / No Hazards ---
        // FIXED: Added 1'b0 for in_mispredict in all legacy tests to fix argument shifting
        test_hazard("NO_HAZARD", 
                    5'd1, 5'd2, 5'd0, 5'd0, 1'b0, 1'b0, 1'b0, // <--- in_mispredict = 0
                    5'd3, 5'd4, 5'd0, 2'b00, 2'b00, 
                    2'b00, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

        // --- SECTION 2: Data Forwarding A & B Tests ---
        test_hazard("FWD_A_MEM", 
                    5'd5, 5'd2, 5'd5, 5'd0, 1'b1, 1'b0, 1'b0, 
                    5'd0, 5'd0, 5'd0, 2'b00, 2'b00, 
                    2'b10, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

        test_hazard("FWD_A_WB", 
                    5'd7, 5'd2, 5'd0, 5'd7, 1'b0, 1'b1, 1'b0, 
                    5'd0, 5'd0, 5'd0, 2'b00, 2'b00, 
                    2'b01, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

        test_hazard("FWD_B_MEM", 
                    5'd1, 5'd8, 5'd8, 5'd0, 1'b1, 1'b0, 1'b0, 
                    5'd0, 5'd0, 5'd0, 2'b00, 2'b00, 
                    2'b00, 2'b10, 1'b0, 1'b0, 1'b0, 1'b0);

        test_hazard("FWD_MEM_PRIORITY", 
                    5'd9, 5'd2, 5'd9, 5'd9, 1'b1, 1'b1, 1'b0, 
                    5'd0, 5'd0, 5'd0, 2'b00, 2'b00, 
                    2'b10, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

        test_hazard("IGNORE_X0_FWD", 
                    5'd0, 5'd2, 5'd0, 5'd0, 1'b1, 1'b1, 1'b0, 
                    5'd0, 5'd0, 5'd0, 2'b00, 2'b00, 
                    2'b00, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

        // --- SECTION 3: Load-Use Stall Tests ---
        test_hazard("LOAD_USE_STALL_Rs1", 
                    5'd0, 5'd0, 5'd0, 5'd0, 1'b0, 1'b0, 1'b0, 
                    5'd5, 5'd2, 5'd5, 2'b01, 2'b00, 
                    2'b00, 2'b00, 1'b1, 1'b1, 1'b0, 1'b1);

        test_hazard("LOAD_USE_STALL_Rs2", 
                    5'd0, 5'd0, 5'd0, 5'd0, 1'b0, 1'b0, 1'b0, 
                    5'd2, 5'd6, 5'd6, 2'b01, 2'b00, 
                    2'b00, 2'b00, 1'b1, 1'b1, 1'b0, 1'b1);

        test_hazard("NO_STALL_ALU_MATCH", 
                    5'd0, 5'd0, 5'd0, 5'd0, 1'b0, 1'b0, 1'b0, 
                    5'd5, 5'd2, 5'd5, 2'b00, 2'b00, 
                    2'b00, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0);

        // --- SECTION 4: Control Hazard (Branch / Jump Taken) Tests ---
        test_hazard("BRANCH_TAKEN_FLUSH", 
                    5'd0, 5'd0, 5'd0, 5'd0, 1'b0, 1'b0, 1'b0, 
                    5'd0, 5'd0, 5'd0, 2'b00, 2'b01, 
                    2'b00, 2'b00, 1'b0, 1'b0, 1'b1, 1'b1);

        // --- SECTION 5: RAS Misprediction Tests (NEW) ---
        // Test: Branch Monitor detects RAS misprediction. Expected: Flush both stages.
        test_hazard("RAS_MISPREDICT_FLUSH", 
                    5'd0, 5'd0, 5'd0, 5'd0, 1'b0, 1'b0, 1'b1, // <--- in_mispredict = 1
                    5'd0, 5'd0, 5'd0, 2'b00, 2'b00,           // Normal execution otherwise
                    2'b00, 2'b00, 1'b0, 1'b0, 1'b1, 1'b1);    // EXPECT: FlushD = 1, FlushE = 1

        // Test: Load-Use Stall happens simultaneously with a RAS misprediction.
        // Expected: Control flush should override stalls (Stall=1, FlushD=1, FlushE=1).
        test_hazard("RAS_MISPREDICT_WITH_STALL", 
                    5'd0, 5'd0, 5'd0, 5'd0, 1'b0, 1'b0, 1'b1, // <--- in_mispredict = 1
                    5'd5, 5'd2, 5'd5, 2'b01, 2'b00,           // Load-Use condition triggered
                    2'b00, 2'b00, 1'b1, 1'b1, 1'b1, 1'b1);    // EXPECT: Stall and Flushes go high


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
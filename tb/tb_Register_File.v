`timescale 1ns / 1ps

module tb_Register_File();

    // 1. Declare Testbench Signals
    reg  [4:0]  A1;
    reg  [4:0]  A2;
    reg  [4:0]  A3;
    reg  [31:0] ResultW;
    reg         RegWriteW;
    reg         i_Clk;
    reg         i_Rst;

    wire [31:0] RD1D;
    wire [31:0] RD2D;

    // Error tracking counter
    integer error_count = 0;

    // 2. Instantiate the Register File
    Register_File #(
        .p_DATA_DMEM_SIZE(4096)
    ) uut (
        .A1(A1),
        .A2(A2),
        .A3(A3),
        .ResultW(ResultW),
        .RegWriteW(RegWriteW),
        .i_Clk(i_Clk),
        .i_Rst(i_Rst),
        .RD1D(RD1D),
        .RD2D(RD2D)
    );

    // 3. Generate a 100MHz Clock (Toggles every 5ns)
    always #5 i_Clk = ~i_Clk;

    // 4. Test Sequence
    initial begin
        // Output waveform to the build folder
        $dumpfile("build/rf_waveform.vcd");
        $dumpvars(0, tb_Register_File);

        $display("========================================================================================================");
        $display("                              AUTOMATED REGISTER FILE VERIFICATION SUITE                                ");
        $display("========================================================================================================");

        // Initialize all inputs
        i_Clk = 0;
        i_Rst = 1; // Assert reset
        A1 = 0; A2 = 0; A3 = 0;
        ResultW = 0; RegWriteW = 0;

        // ---------------------------------------------------------
        // TEST 1: Reset & Bare-Metal Initialization
        // ---------------------------------------------------------
        #15;        // Hold reset for a few clock cycles
        i_Rst = 0;  // Release reset
        #10;        
        A1 = 5'd2;  // Read sp (x2)
        A2 = 5'd3;  // Read gp (x3)
        #1;         // Wait 1ns for combinational read

        // Expected SP: 0x10010000 + 4096 - 4 = 0x10010FFC
        if (RD1D === 32'h10010FFC && RD2D === 32'h10010000) begin
            $display("RESET_CHECK | [PASS]");
        end else begin
            $display("RESET_CHECK | [FAIL] ❌ MISMATCH DETECTED!");
            error_count = error_count + 1;
        end
        $display("    Actual   : SP (x2)=%h, GP (x3)=%h", RD1D, RD2D);
        $display("    Expected : SP (x2)=10010ffc, GP (x3)=10010000");
        $display("--------------------------------------------------------------------------------------------------------");

        // ---------------------------------------------------------
        // TEST 2: Normal Write & Read
        // ---------------------------------------------------------
        @(posedge i_Clk); 
        A3 = 5'd5;              // Target register x5
        ResultW = 32'hDEADBEEF; // Data to write
        RegWriteW = 1;          // Enable write
        
        @(posedge i_Clk);       // Wait for the next clock cycle
        RegWriteW = 0;          // Turn off write
        A1 = 5'd5;              // Read x5
        #1;

        if (RD1D === 32'hDEADBEEF) begin
            $display("NORMAL_WRITE| [PASS]");
        end else begin
            $display("NORMAL_WRITE| [FAIL] ❌ MISMATCH DETECTED!");
            error_count = error_count + 1;
        end
        $display("    Actual   : Read x5=%h", RD1D);
        $display("    Expected : Read x5=deadbeef");
        $display("--------------------------------------------------------------------------------------------------------");

        // ---------------------------------------------------------
        // TEST 3: x0 Hardwired Protection
        // ---------------------------------------------------------
        @(posedge i_Clk);
        A3 = 5'd0;              // Target register x0
        ResultW = 32'hFFFFFFFF; // Try to overwrite it with 1s
        RegWriteW = 1;
        
        @(posedge i_Clk);
        RegWriteW = 0;
        A1 = 5'd0;              // Read x0
        #1;

        if (RD1D === 32'h00000000) begin
            $display("X0_PROTECT  | [PASS]");
        end else begin
            $display("X0_PROTECT  | [FAIL] ❌ MISMATCH DETECTED!");
            error_count = error_count + 1;
        end
        $display("    Actual   : Read x0=%h", RD1D);
        $display("    Expected : Read x0=00000000");
        $display("--------------------------------------------------------------------------------------------------------");

        // ---------------------------------------------------------
        // TEST 4: RegWrite Enable Signal Check
        // ---------------------------------------------------------
        @(posedge i_Clk);
        A3 = 5'd10;             // Target register x10
        ResultW = 32'h12345678; 
        RegWriteW = 0;          // WRITE DISABLED!
        
        @(posedge i_Clk);
        A1 = 5'd10;             // Read x10
        #1;

        if (RD1D === 32'h00000000) begin
            $display("WRITE_DISABLE|[PASS]");
        end else begin
            $display("WRITE_DISABLE|[FAIL] ❌ MISMATCH DETECTED!");
            error_count = error_count + 1;
        end
        $display("    Actual   : Read x10=%h", RD1D);
        $display("    Expected : Read x10=00000000");
        $display("--------------------------------------------------------------------------------------------------------");

        // Final Summary Report
        $display("========================================================================================================");
        if (error_count == 0) begin
            $display(" 🎉 ALL REGISTER FILE TESTS PASSED! Register File logic is fully verified.");
        end else begin
            $display(" ❌ SIMULATION FAILED: Total Mismatches Found = %0d", error_count);
        end
        $display("========================================================================================================");
        $finish;
    end

endmodule
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
        // Output waveform to the build folder we just discussed!
        $dumpfile("build/rf_waveform.vcd");
        $dumpvars(0, tb_Register_File);

        $display("=== STARTING REGISTER FILE TEST ===");

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
        $display("1. Reset Check -> Expected SP: 10010ffc, GP: 10010000 | Actual SP: %h, GP: %h", RD1D, RD2D);

        // ---------------------------------------------------------
        // TEST 2: Normal Write & Read
        // ---------------------------------------------------------
        // We set up the data on the posedge, so it is cleanly captured on the negedge
        @(posedge i_Clk); 
        A3 = 5'd5;              // Target register x5
        ResultW = 32'hDEADBEEF; // Data to write
        RegWriteW = 1;          // Enable write
        
        @(posedge i_Clk);       // Wait for the next clock cycle (write happened on the negedge between these)
        RegWriteW = 0;          // Turn off write
        A1 = 5'd5;              // Read x5
        #1;
        $display("2. Normal Write (x5) -> Expected: deadbeef | Actual: %h", RD1D);

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
        $display("3. x0 Protection -> Expected: 00000000 | Actual: %h", RD1D);

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
        $display("4. RegWrite Disabled -> Expected: 00000000 | Actual: %h", RD1D);

        $display("=== TESTS COMPLETED ===");
        $finish;
    end

endmodule
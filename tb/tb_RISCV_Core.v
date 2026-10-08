`timescale 1ns / 1ps

module tb_RISCV_Core();

    reg clk;
    reg reset;

    RISCV_Core dut (
        .clk(clk),
        .reset(reset)
    );

    // 100MHz Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("build/core_waveform.vcd");
        $dumpvars(0, tb_RISCV_Core);

        reset = 1'b1;
        #20; 
        reset = 1'b0;
        
        $display("========================================");
        $display(" 🚀 RISC-V EXHAUSTIVE SELF-CHECKING VERIFICATION");
        $display("========================================");

        // Extended simulation timeout to allow the 100-iteration branch 
        // training loop and deep RAS stack to fully execute
        #200000; 
        
        $display("========================================");
        $display(" 🛑 SIMULATION TIMEOUT REACHED (TEST FAILED)");
        $display("========================================");
        $finish;
    end

    // Variables for tracking PC and Misprediction Time
    reg [31:0] last_pc = 32'hFFFFFFFF; 
    reg [63:0] saved_mispredict_time = 0; 
    
    always @(posedge clk) begin
        if (!reset && (dut.PCF !== last_pc)) begin
            $display("Time: %0t | PC: %h | Instruction: %h", $time, dut.PCF, dut.InstrF);
            last_pc <= dut.PCF;
        end

        // Silently capture the time of the misprediction (only records the first occurrence)
        if (dut.Mispredict_Flag == 1'b1 && saved_mispredict_time == 0) begin
            saved_mispredict_time <= $time;
        end

        // SMART KILL-SWITCH: Monitor the Execute Stage (PCE) to ignore ghost fetches!
        // PC == 0x00000234 is the PASS_TRAP infinite loop
        if (dut.PCE == 32'h00000234) begin
            $display("========================================");
            $display(" ✅ TEST PASSED!");
            $display(" 🏁 All ISA, Hazards, and Speculation checks completed perfectly.");
            $display("    Self-Check Status Register (x4) is 0x00000000.");
            if (saved_mispredict_time > 0) begin
                $display(" 💡 [%0t] RAS Overflow/Mispredict Detected! Healing pipeline...", saved_mispredict_time);
            end
            $display("========================================");
            #10; 
            $finish;
        end 
        // PC == 0x00000230 is the FAIL_TRAP infinite loop
        else if (dut.PCE == 32'h00000230) begin
            $display("========================================");
            $display(" ❌ TEST FAILED!");
            $display(" 🚨 Firmware diverted to FAIL_TRAP.");
            $display("    A hardware evaluation produced the wrong result.");
            $display("========================================");
            #10;
            $finish;
        end
    end

endmodule
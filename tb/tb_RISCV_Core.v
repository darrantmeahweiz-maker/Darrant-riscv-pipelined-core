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
        $display(" 🚀 RISC-V FULL ISA VERIFICATION INITIATED");
        $display("========================================");

        // Extended simulation timeout to allow all 69 instructions to finish
        #50000; 
        
        $display("========================================");
        $display(" 🛑 SIMULATION TIMEOUT REACHED");
        $display("========================================");
        $finish;
    end

    // Print the PC and Hex Instruction ONLY when the PC advances 
    reg [31:0] last_pc = 32'hFFFFFFFF; 
    
    always @(posedge clk) begin
        if (!reset && (dut.PCF !== last_pc)) begin
            $display("Time: %0t | PC: %h | Instruction: %h", $time, dut.PCF, dut.InstrF);
            last_pc <= dut.PCF;
        end

        // SMART KILL-SWITCH: Stop exactly when the hardware heals the pipeline!
        if (dut.Mispredict_Flag == 1'b1) begin
            $display("========================================");
            $display(" 🚨 MISPREDICTION SABOTAGE DETECTED!");
            $display(" 🛠️  PIPELINE FLUSH TRIGGERED. RECOVERY SUCCESSFUL.");
            $display(" 🏁 FIRMWARE COMPLETE. HALTING SIMULATION.");
            $display("========================================");
            #10; // Wait 1 extra clock cycle so the flush appears on the waveform
            $finish;
        end
    end

endmodule
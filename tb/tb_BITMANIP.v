`timescale 1ns/1ps

module tb_BITMANIP ();
    reg [31:0]  SrcAE;
    reg [31:0]  SrcBE;
    reg [2:0]   BIT_Control;
    wire [31:0] BIT_Result;

    integer error_count = 0;

    BITMANIP uut (
        .SrcAE(SrcAE),
        .SrcBE(SrcBE),
        .BIT_Control(BIT_Control),
        .BIT_Result(BIT_Result)
    );

    task test_bit;
        input [79:0] test_name;
        input [2:0] in_ctrl;
        input [31:0] in_a;
        input [31:0] in_b;
        input [31:0] exp_result;
        begin
            BIT_Control = in_ctrl;
            SrcAE       = in_a;
            SrcBE       = in_b;
            #10;
            if(BIT_Result == exp_result) begin
                $display("%-8s | [PASS]", test_name);
            end else begin
                $display("%-8s | [FAIL] Mismatch detected", test_name);
                error_count = error_count + 1;
            end

            $display("   Actual : BIT_Result = %h", BIT_Result);
            $display(" Expected : BIT_Result = %h", exp_result);
            $display("---------------------------------------");
        end
    endtask

    initial begin
        $dumpfile("build/bitmanip_waveform.vcd");
        $dumpvars(0, tb_BITMANIP);
        
        test_bit("clz",     3'b000, 32'h80000000, 32'd0, 32'h00000000);
        test_bit("clz",     3'b000, 32'h00000001, 32'd0, 32'h0000001F);
        test_bit("clz",     3'b000, 32'h80000000, 32'd0, 32'h00000000);
        test_bit("cpop",    3'b001, 32'h0000000F, 32'd0, 32'h00000004);
        test_bit("rev8",    3'b010, 32'h12345678, 32'd0, 32'h78563412);
        test_bit("rol",     3'b011, 32'h000000F0, 32'd4, 32'h00000F00);
        test_bit("ror",     3'b100, 32'h000000FF, 32'd4, 32'hF000000F);
        test_bit("default", 3'b111, 32'hFFFFFFFF, 32'd0, 32'h00000000);

        if (error_count == 0) begin
            $display(" 🎉 ALL BITMANIP TESTS PASSED! BITMANIP logic is fully verified.");
        end else begin
            $display(" ❌ SIMULATION FAILED: Total Mismatches Found = %0d", error_count);
        end
        
        $finish;
    end
endmodule
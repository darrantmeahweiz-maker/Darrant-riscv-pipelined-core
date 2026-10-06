`timescale 1ns/1ps

module tb_CRC();
    reg [1:0] CRC_Control;
    reg [31:0] SrcA;
    reg [31:0] SrcB; 
    wire[31:0] CRC_Result;

    integer error_count = 0;

    CRC uut (
        .CRC_Control(CRC_Control),
        .SrcA(SrcA),
        .SrcB(SrcB),
        .CRC_Result(CRC_Result)
    );

    //task XXX; input ... begin ... end endtask
    task CRCtest;
        input   [239:0]  test_CRC;
        input   [1:0]   in_ctrl;
        input   [31:0]  in_A;
        input   [31:0]  in_B;
        input   [31:0]  exp_result;
        begin
            CRC_Control = in_ctrl;
            SrcA        = in_A;
            SrcB        = in_B;
            #10;    //forget delay your code !!!
            if (CRC_Result === exp_result) begin
                $display("%-15s | [PASS] ",test_CRC);
            end else begin
                $display("%-15s | [Fail] Mismatch Detected", test_CRC);
                error_count = error_count +1;
            end

                $display("  Actual : CRC_Result = %h ",CRC_Result);
                $display("Expected : CRC_Result = %h ",exp_result);
                $display("-----------------------------------------");
        end
    endtask

    initial begin
        $dumpfile("build/crc_waveform.vcd");
        $dumpvars(0,tb_CRC);
        CRCtest("CRC8",2'b00,32'h00000001,32'h00000000,32'h00000007);
        CRCtest("CRC16",2'b01,32'h00000001,32'h00000000,32'h00008005);
        CRCtest("CRC32",2'b10,32'h00000001,32'h00000000,32'h04C11DB7);
        CRCtest("Default (2'b11)",2'b11,32'h00000001,32'h00000000,32'h00000000);
        if(error_count == 0) begin
            $display("==========================================================");
            $display(" 🎉 ALL CRC TESTS PASSED! CRC logic is fully verified."); 
        end else begin
            $display("==========================================================");
            $display(" ❌ SIMULATION FAILED: Total Mismatches Found = %0d", error_count);
        end
        $finish;
    end
endmodule



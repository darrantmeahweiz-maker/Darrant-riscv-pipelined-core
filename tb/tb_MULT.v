//i use an initial block to change values over time
//any variable that i assign values to inside an initial @ always 
//block must be decalred as reg
    //Verilog syntax forces you to use reg for any variable assigned inside an always block
//input --> reg
//output --> wire
//testbench --> top-level container

//module ABC(...);  --> hardware module
    //contain synthesisable logic (assign, always @(*))
//module ABC();     --> testbench
    //contain simulation-only behavioral code (initial, #10, $display, $finish)


//time unit & time precision
`timescale 1ns/1ps

module tb_MULT();    //no ports at all
    reg [1:0]  MUL_Control;
    reg [31:0] SrcA;
    reg [31:0] SrcB; 
    wire [31:0] MUL_Result;

    integer error_count = 0;

    // Instantiate MUL module (uut aka. unit under test) 
        //for input .i_a(2'b01) is legal
        //for output .o_z(32'h0) is illega
    MULT uut (
        .MUL_Control(MUL_Control),
        .SrcA(SrcA),
        .SrcB(SrcB),
        .MUL_Result(MUL_Result)
    );

    task test_MULT;
        input   [79:0]  test_name; //1 character take 8 bit --> 8 character
        input   [1:0]   in_ctrl;
        input   [31:0]   in_a;
        input   [31:0]   in_b;
        input   [31:0]  exp_result;
        begin
            MUL_Control = in_ctrl;
            SrcA        = in_a;
            SrcB        = in_b;
            #10; // wait for combinational logic settle

            if (MUL_Result === exp_result) begin
                $display("%-10s | [PASS]", test_name); //%--> formal specifier, - --> left-justify, 8 --> min width of 8 character, s --> string
            end else begin
                $display("%-10s | [FAIL] Mismatch Detected!", test_name);
                error_count = error_count +1;
            end
            
            $display("       Actual : MUL_Result=%h",MUL_Result);
            $display("     Expected : MUL_Result=%h",exp_result);
            $display("----------------------------------------------------------");
        end
    endtask



    initial begin
        $dumpfile("build/mult_waveform.vcd");
        $dumpvars(0, tb_MULT);

        test_MULT("MUL",2'b00,32'd10,32'd20,32'h000000C8);
        test_MULT("MULH",2'b01,32'h00020000,32'h00020000,32'h00000004);
        test_MULT("MULHSU",2'b10,32'hFFFFFFFF,32'h00000002,32'hFFFFFFFF);
        test_MULT("MULHU",2'b11,32'h80000000,32'h00000002,32'h00000001);    

        if(error_count == 0) begin
            $display("==========================================================");
            $display(" 🎉 ALL MULT TESTS PASSED! MULT logic is fully verified."); 
        end else begin
            $display("==========================================================");
            $display(" ❌ SIMULATION FAILED: Total Mismatches Found = %0d", error_count);
        end
        $finish;   
    end
endmodule



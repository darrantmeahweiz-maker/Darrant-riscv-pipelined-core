module BITMANIP(
    input       [31:0]  SrcAE,
    input       [31:0]  SrcBE,
    input       [2:0]   BIT_Control,
    output reg  [31:0]  BIT_Result
);

integer i;

always @(*) begin
    case (BIT_Control)
        3'b000: begin              // clz (count leading zero)
            BIT_Result = 32'd32;     // Default if all zeros   
            for (i = 0; i < 32; i = i + 1) begin  // Loop from LSB to MSB
                if (SrcAE[i]) begin        
                    BIT_Result = 31 - i;
                end
            end
        end
        3'b001: begin              // cpop (population count)
            BIT_Result = 32'd0;    
            // Sums up all bits. Synthesizer turns this into parallel adder tree
            for (i = 0; i < 32; i = i + 1) begin
                BIT_Result = BIT_Result + SrcAE[i];
            end
        end 
        3'b010: begin              // rev8 (byte reverse)
            BIT_Result = {SrcAE[7:0], SrcAE[15:8], SrcAE[23:16], SrcAE[31:24]}; // using concatenation
        end
        3'b011: begin              // rol (rotate left)
            if (SrcBE[4:0] == 5'd0) begin  
                BIT_Result = SrcAE;
            end else begin
                BIT_Result = (SrcAE << SrcBE[4:0]) | (SrcAE >> (6'd32 - SrcBE[4:0]));
            end
        end
        3'b100: begin              // ror (Rotate Right)
            if (SrcBE[4:0] == 5'd0) begin  
                BIT_Result = SrcAE;
            end else begin
                BIT_Result = (SrcAE >> SrcBE[4:0]) | (SrcAE << (6'd32 - SrcBE[4:0]));
            end
        end
        default: BIT_Result = 32'h00000000;
    endcase  
end

endmodule
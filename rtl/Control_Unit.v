module Control_Unit (
    // Inputs from instruction (Decode stage)
    input       [6:0]   op,
    input       [2:0]   funct3,
    input       [6:0]   funct7,  
    input       [4:0]   rs2D, 

    // Output to pipelined register
    output reg          RegWriteD,
    output reg  [1:0]   ResultSrcD,
    output reg          MemWriteD,
    output reg  [1:0]   JumpD,
    output reg          BranchD,

    output reg  [1:0]   ExecSelD,
    output reg  [2:0]   BITControlD,
    output reg  [1:0]   MultControlD,
    output reg  [1:0]   CRCControlD,
    output reg  [3:0]   ALUControlD,
    output reg          ALUSrcBD,
    output reg  [1:0]   ALUSrcAD,  
    output reg  [2:0]   ImmSrcD     
);

    // Combinational logic
    always @(*) begin
        // Set default values 
        RegWriteD    = 1'b0;
        ResultSrcD   = 2'b00;
        MemWriteD    = 1'b0;
        JumpD        = 2'b00;    // Default: No jump
        BranchD      = 1'b0;

        ExecSelD     = 2'b00;    // Default: Select standard ALU
        MultControlD = 2'b00;    // Default: Off MULT
        CRCControlD  = 2'b00;    // Default: Off CRC

        ALUControlD  = 4'b0000;
        ALUSrcBD     = 1'b0;
        ALUSrcAD     = 2'b00; 
        ImmSrcD      = 3'b000;

        // Decode the Opcode
        case (op)
            // ----------------------------------------------------
            // R-type & I-type (ALU, MULT, CRC, BITMANIP operations)
            // ----------------------------------------------------
            7'b0110011, 7'b0010011: begin   
                RegWriteD   = 1'b1;
                ResultSrcD  = 2'b00;                // ALUResult
                ALUSrcBD    = (op==7'b0010011); // I-type is one while R-type is zero
                ImmSrcD     = 3'b000;


                //Check for execution unit (ExecSelD & custom Control)
                if (op == 7'b0010011) begin
                    //I-type custom extensions
                    case ({funct3,rs2D})
                        8'b001_00000: begin     //clz
                            ExecSelD   = 2'b11;
                            BITControlD = 3'b000;
                        end
                        8'b001_00010: begin     //cpop
                            ExecSelD   = 2'b11;
                            BITControlD = 3'b001;
                        end
                        8'b101_11000: begin     //rev8
                            ExecSelD   = 2'b11;
                            BITControlD = 3'b010;
                        end
                        default: ;
                    endcase
                end else begin
                    //R-type custom extensions
                    case (funct7)
                        7'b0110000: begin
                            ExecSelD     = 2'b11;
                            BITControlD  = (funct3 = 3'b001)? 3'b011: 3'b100;   // 011=rol 100=ror
                        end
                        7'b0000001: begin
                            ExecSelD     = 2'b01;
                            MultControlD = funct3[1:0];     // 00=mul, 01=mulh, 10=mulhsu, 11=mulhu
                        end
                        7'b1000000: begin
                            ExecSelD     = 2'b10;
                            CRCControlD = funct3[1:0];     // 00=crcb, 01=crch, 10=crcw
                        end
                        default: ;
                    endcase
                end

                //Standard ALU Control
                case (funct3)
                    3'b000: begin                                                           // 4'h1 = add & addi
                        ALUControlD = (funct7[5] == 1'b1 && op == 7'b0110011)? 4'h2: 4'h1;  // 4'h2 = sub (note: i-type doesn't have sub)                        
                    end
                    3'b001: ALUControlD = 4'h6; // sll & slli
                    3'b010: ALUControlD = 4'h9; // slt & slti
                    3'b011: ALUControlD = 4'hA; // sltu & sltiu
                    3'b100: ALUControlD = 4'h5; // xor & xori
                    3'b101: begin                                                   // srl & srli
                        ALUControlD = (funct7[5] == 1'b1) ? 4'h8 : 4'h7;    // sra & srai  
                    end
                    3'b110: ALUControlD = 4'h4; // or & ori
                    3'b111: ALUControlD = 4'h3; // and & andi
                    default: ALUControlD = 4'h0;
                endcase
            end

            // ----------------------------------------------------
            // I-type (Load)
            // ----------------------------------------------------
            7'b0000011: begin               
                RegWriteD   = 1'b1;
                ResultSrcD  = 2'b01;    // ReadData from Memory
                ALUSrcBD    = 1'b1;     // immediate for offset
                ImmSrcD     = 3'b000;
                ALUControlD = 4'h1;     // Add (base + offset)
            end

            // ----------------------------------------------------
            // S-type (Store)
            // ----------------------------------------------------
            7'b0100011: begin               
                MemWriteD   = 1'b1;
                ALUSrcBD    = 1'b1;
                ImmSrcD     = 3'b001;
                ALUControlD = 4'h1;     // Add  
            end

            // ----------------------------------------------------
            // B-type (Branch)
            // ----------------------------------------------------
            7'b1100011: begin               
                ALUSrcBD    = 1'b0;     // compare rs1 and rs2
                ImmSrcD     = 3'b010;   
                BranchD     = 1'b1;
                case(funct3)
                    3'b000: ALUControlD = 4'h2; // BEQ
                    3'b001: ALUControlD = 4'hB; // BNE
                    3'b100: ALUControlD = 4'hC; // BLT
                    3'b101: ALUControlD = 4'hD; // BGE
                    3'b110: ALUControlD = 4'hE; // BLTU
                    3'b111: ALUControlD = 4'hF; // BGEU
                    default: ALUControlD = 4'h0;
                endcase
            end

            // ----------------------------------------------------
            // J-type (JAL)
            // ----------------------------------------------------
            7'b1101111: begin               
                RegWriteD   = 1'b1;         // must be written back to rd
                JumpD       = 2'b01;
                ResultSrcD  = 2'b10;        // save PC+4 to rd
                ImmSrcD     = 3'b011;       // J-type immediate formatting
            end

            // ----------------------------------------------------
            // I-type (JALR)
            // ----------------------------------------------------
            7'b1100111: begin               
                RegWriteD   = 1'b1;
                JumpD       = 2'b10;        // it is jump
                ResultSrcD  = 2'b10;        // save PC+4 to rd
                ALUSrcBD    = 1'b1;         // add immediate to Rs1
                ImmSrcD     = 3'b000;       // I-type immediate formatting
                ALUControlD = 4'h1;         // add for jump target
            end

            // ----------------------------------------------------
            // U-type (LUI - Load Upper Immediate)
            // ----------------------------------------------------
            7'b0110111: begin   
                RegWriteD   = 1'b1;
                ResultSrcD  = 2'b00;        // ALUResult
                ALUSrcAD    = 2'b10;  
                ALUSrcBD    = 1'b1;         // Pass the immediate into ALU
                ImmSrcD     = 3'b100;       // U-type immediate formatting
                ALUControlD = 4'h0;         // PASS (ALUResult = SrcB)
            end

            // ----------------------------------------------------
            // U-type (AUIPC - Add Upper Immediate to PC)
            // ----------------------------------------------------
            7'b0010111: begin 
                RegWriteD   = 1'b1;
                ResultSrcD  = 2'b00;        // Normal ALU Result
                ALUSrcAD    = 2'b01;        // Tell ALU to read PC instead of Rs1
                ALUSrcBD    = 1'b1;         // Tell ALU to read Immediate instead of Rs2
                ImmSrcD     = 3'b100;       // U-type immediate formatting
                ALUControlD = 4'h1;         // ADD (PC + Immediate)
            end

            // ---------------------------------------------------- 
            // System (ECALL/EBREAK) & Fence
            // ----------------------------------------------------
            7'b1110011, 7'b0001111: begin              
            end

            default: begin
            end
        endcase
    end
endmodule


/* Previous version for R-type & I-type (ALU, MULT, CRC, BITMANIP operations)
                //Check for BITMANIP Extension (Zbb)
                if(op == 7'b0010011) begin
                    if  (funct3 == 3'b001 && rs2D == 5'b00000) begin //clz
                        ExecSelD   = 2'b11;
                        BITControlD = 3'b000;
                    end
                    if  (funct3 == 3'b001 && rs2D == 5'b00010) begin //cpop
                        ExecSelD   = 2'b11;
                        BITControlD = 3'b001;
                    end
                    if  (funct3 == 3'b101 && rs2D == 5'b11000) begin //rev8
                        ExecSelD   = 2'b11;
                        BITControlD = 3'b010;
                    end
                end
                if(op == 7'b0110011 && funct7 == 7'b0110000) begin
                    if(funct3 == 3'b001) begin                       //rol
                        ExecSelD   = 2'b11;
                        BITControlD = 3'b011;
                    end
                    if(funct3 == 3'b101) begin                       //ror
                        ExecSelD   = 2'b11;
                        BITControlD = 3'b100;
                    end
                end


                // Check for MULT Extension (Zmmul)
                if (op == 7'b0110011 && funct7 == 7'b0000001) begin
                    ExecSelD     = 2'b01;
                    MultControlD = funct3[1:0];   // 00=mul, 01=mulh, 10=mulhsu, 11=mulhu
                
                // Check for CRC Extension (Xicrc)
                end else if (op == 7'b0110011 && funct7 == 7'b1000000) begin
                    ExecSelD     = 2'b10;
                    CRCControlD  = funct3[1:0];    // 00=crcb, 01=crch, 10=crcw

                end else begin
                    // Standard ALU Operations via funct3
                    case (funct3)
                        3'b000: begin
                            if (funct7[5] == 1'b1 && op == 7'b0110011) begin
                                ALUControlD = 4'h2; // sub (note: i-type doesn't have sub)
                            end else begin
                                ALUControlD = 4'h1; // add & addi
                            end
                        end
                        3'b001: ALUControlD = 4'h6; // sll & slli
                        3'b010: ALUControlD = 4'h9; // slt & slti
                        3'b011: ALUControlD = 4'hA; // sltu & sltiu
                        3'b100: ALUControlD = 4'h5; // xor & xori
                        3'b101: begin
                            if (funct7[5] == 1'b1) begin
                                ALUControlD = 4'h8; // sra & srai
                            end else begin
                                ALUControlD = 4'h7; // srl & srli
                            end
                        end
                        3'b110: ALUControlD = 4'h4; // or & ori
                        3'b111: ALUControlD = 4'h3; // and & andi
                        default: ALUControlD = 4'h0;
                    endcase
                end
            end
*/
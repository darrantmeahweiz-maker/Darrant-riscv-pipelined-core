    //output @ output wire  -- continuous assignment (assign)
    //output reg            -- procedural block (always@(*))

module Register_File # (
    parameter p_DATA_DMEM_SIZE = 2**12  //2**10 -- 1kb @ 2**12 -- 4kb
)(
    input wire [4:0]    A1,         //Rs1D, source register 1 address
    input wire [4:0]    A2,         //Rs2D, source register 2 address
    input wire [4:0]    A3,         //RdW, destination register address
    input wire [31:0]   ResultW,    //data write back
    input wire          RegWriteW,  //write enable signal
    input wire          i_Clk,
    input wire          i_Rst,
    output [31:0]       RD1D,       //read data 1
    output [31:0]       RD2D        //read data 2
);

    //Constants for Bare-Metal Initialization
    localparam c_SP_Index = 2;
    localparam c_GP_Index = 3;
    localparam c_GP_Initial_Value = 32'h10010000;
    localparam c_SP_Initial_Value = c_GP_Initial_Value + p_DATA_DMEM_SIZE - 4;

    //Register Data Array
    reg [31:0] r_Registers [0:31];

    integer i;

    //Sequential Write Logic (-ev Edge Triggered)
    always @(negedge i_Clk or posedge i_Rst) begin
        if(i_Rst)
            //Initialize registers on reset
            for (i=0;i<32;i=i+1) begin
                case (i)
                    c_SP_Index: r_Registers[i] <= c_SP_Initial_Value;
                    c_GP_Index: r_Registers[i] <= c_GP_Initial_Value;
                    default:    r_Registers[i] <= 32'h0;
                endcase
            end
        end else begin
            //Write new data if enabled, protecting register x0
            if (RegWriteW && A3 != 5'h0) begin
                r_Registers[A3] <= ResultW;
            end
        end
    end

    //Combinational Read Logic (Asynchronous)
    //using ternary operator ensure x0 ALWAYS read as 0, even if a bug bypassed the write protection
    assign RD1D = (A1==5'h0) ? 32'h0 : r_Registers[A1];
    assign RD2D = (A2==5'h0) ? 32'h0 : r_Registers[A2];
endmodule
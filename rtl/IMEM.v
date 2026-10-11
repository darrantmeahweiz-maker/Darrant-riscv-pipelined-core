module IMEM #(
    parameter ADDR_WIDTH = 10,
    parameter DATA_WIDTH = 32
)(
    input wire        clk,
    input wire        en,       //connected to ~StallF
    input wire [ADDR_WIDTH-1:0] A,        //connected to PC_next[11:2]
    output reg [DATA_WIDTH-1:0] RD      
);

    (* ramstyle = "M10K" *) reg [DATA_WIDTH-1:0] ROM [0:(2**ADDR_WIDTH)-1]; 

        //$readmemh reads hexadecimal text file and load into ROM array
    initial begin
        RD = 32'h00000013;
        $readmemh("program.hex",ROM);
    end

    //Combinational Read Logic
    always @(posedge clk) begin
        if (en) begin
            RD <= ROM[A];
        //end else begin
            //RD <= 32'h00000013; //M10K can hold value or clear to zero
                //but they cannot natively reset to 32-bit constant
        end
    end
endmodule
        

    

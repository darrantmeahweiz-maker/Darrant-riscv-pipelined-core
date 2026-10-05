module Register_PC (
    input           i_Clk,
    input           StallF,
    input   [31:0]  PC_next,
    output reg [31:0]  PCF
);

    //use  = when always @(*) 
    //use <= when always @(posedge i_Clk)
    always @(posedge i_Clk) begin
        if (StallF) begin
            PCF <= PCF;
        end else begin
            PCF <= PC_next; 
        end
    end
endmodule
`timescale 1ns/1ps
module tb_reset();
    reg clk=0;
    wire onfi_cen=0;
    wire onfi_cle=0;
    wire onfi_ale=0;
    wire onfi_wen=0;
    wire onfi_dqs_en=0;
    wire [31:0] onfi_dq_o=0;
    wire onfi_dq_en=0;
    reset i_reset(clk, onfi_cen, onfi_cle, onfi_ale, onfi_wen, onfi_dqs_en, onfi_dq_o, onfi_dq_en);
    initial begin
        $dumpfile("./build/reset.vcd");
        $dumpvars(0, tb_reset);
        #10000 $finish;
    end
    always begin
        #5 clk = ~clk;
    end
endmodule

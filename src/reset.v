module reset(
    input wire onfi_clk,
    output reg onfi_cen,
    output reg onfi_cle,
    output reg onfi_ale,
    output reg onfi_wen,
    output reg onfi_dqs_en,
    output reg [31:0] onfi_dq_o,
    output reg onfi_dq_en
    );
    initial begin
        onfi_cen = 0;
        onfi_cle = 0;
        onfi_ale = 0;
        onfi_wen = 0;
        onfi_dqs_en = 0;
        onfi_dq_o = 32'h00;
        onfi_dq_en = 0;
    end
    reg [1:0] state=0;
    always@(negedge onfi_clk)
    switch(state)
    case 0:
     begin
        assign onfi_cen = 0;
        assign onfi_cle = 0;
        assign onfi_ale = 0;
        assign onfi_wen = 1;
        assign onfi_dqs_en = 0;
        state++;
        break;
    end
    case 1: 
     begin
        assign onfi_cle = 1;
        onfi_dq_o = 32'hFF;
        assign onfi_dq_en = 1;
        state++;
        break;
    end
    case 2:
     begin
        assign onfi_cle = 0;
        assign onfi_dq_en = 0;
        state++;
        break;
    end
    case 4: 
     begin
        assign onfi_cen = 1;
        state=0;
        break;
    end
endmodule
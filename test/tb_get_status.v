module tb_get_status;
    reg [31:0] addr = 0;
    reg clk = 0;
    wire [31:0] data;
    wire onfi_ale = 0;
    wire onfi_cen = 0;
    wire onfi_cle = 0;
    wire onfi_dq = 0;
    wire onfi_dq_en = 0;
    wire [31:0] onfi_dq_o = 0;
    reg onfi_dqs = 0;
    wire onfi_dqs_en = 0;
    wire onfi_wen = 0;

    get_status i_get_status(
        .addr(addr),
        .onfi_clk(clk),
        .data(data),
        .onfi_ale(onfi_ale),
        .onfi_cen(onfi_cen),
        .onfi_cle(onfi_cle),
        .onfi_dq(onfi_dq),
        .onfi_dq_en(onfi_dq_en),
        .onfi_dq_o(onfi_dq_o),
        .onfi_dqs(onfi_dqs),
        .onfi_dqs_en(onfi_dqs_en),
        .onfi_wen(onfi_wen)
    );

    initial begin
        $dumpfile("./build/get_status.vcd");
        $dumpvars(0, tb_get_status);
        #10000 $finish;
    end

    always begin
        #5 clk = ~clk;
        addr = addr + 1;
    end

    initial begin
    # 100 onfi_dqs = 1;
    # 100 onfi_dqs = 0;
    end
endmodule
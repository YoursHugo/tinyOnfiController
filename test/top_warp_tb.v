module testbench();
/**************************parameter*************************/
localparam  CMD_READ_RRAM           = 8'hA0;
localparam  CMD_PROG_RRAM           = 8'hA1;
localparam  CMD_READ_REG            = 8'hA2;
localparam  CMD_PROG_REG            = 8'hA3;
localparam  CMD_COM_LINE_D8W4       = 8'hB4;//don't change!!
localparam  CMD_COM_LINE_D8W8       = 8'hB5;
localparam  CMD_COM_LINE_D8W16      = 8'hB6;
localparam  CMD_COM_LINE_D16W4      = 8'hB8;
localparam  CMD_COM_LINE_D16W8      = 8'hB9;
localparam  CMD_COM_LINE_D16W16     = 8'hBA;
// localparam  CMD_COM_LINE_D8W4_S     = 8'hC4;//bank A and bank B use the same data
// localparam  CMD_COM_LINE_D8W8_S     = 8'hC5;
// localparam  CMD_COM_LINE_D8W16_S    = 8'hC6;
// localparam  CMD_COM_LINE_D16W4_S    = 8'hC8;
// localparam  CMD_COM_LINE_D16W8_S    = 8'hC9;
// localparam  CMD_COM_LINE_D16W16_S   = 8'hCA;
localparam  CMD_COM_LINE_D1W1       = 8'hDA;
localparam  CMD_COM_LINE_D1W1_SHIFT = 8'hEA;
localparam  CMD_COM_CONV            = 8'hF0;
localparam  CMD_TEST_ISRAM_READ     = 8'hF1;
localparam  CMD_TEST_OSRAM_WRITE    = 8'hF2;
localparam  CMD_TEST_END            = 8'hF3;

/***********************address*************************/
localparam STATUS_ADDR              = 32'h00000000;
localparam TEST_REGL_ADDR           = 32'h10000000;
localparam TEST_REGH_ADDR           = 32'h10000004;
localparam PLL_REG0_ADDR            = 32'h20000000;
localparam PLL_REG1_ADDR            = 32'h20000004;
localparam SLV_REG0_ADDR            = 32'h40000000;
localparam SLV_REG1_ADDR            = 32'h40000004;
localparam SLV_REG2_ADDR            = 32'h40000008;
localparam SLV_REG3_ADDR            = 32'h4000000C;
localparam SLV_REGX_ADDR            = 32'h40000010;//cim register
localparam SRAM_ADDR                = 32'h80000000;//input output sram is same address
localparam SRAM_REG_ADDR            = 32'hA0000000;
localparam PAD_DS_ADDR              = 32'hC0000000;
localparam CLOCK_MUX_SEL_ADDR       = 32'hE0000000;

parameter ONFI_FRE   = 100; //unit MHz 50~100
parameter COM_FRE    = 500; //unit MHz
parameter OP_FRE   	 = 25;  //unit MHz
parameter REF_FRE	 = 25;  //unit MHz
parameter AUX_FRE    = 125; //unit MHz
reg       onfi_clk   = 0;
reg       com_clk    = 0;
reg       op_clk     = 0;
reg       refclk     = 0;
reg       auxclk     = 0;
reg       auxclk90   = 0;
reg       dqs_clk    = 0;
reg       rst_n      = 1;

always begin
    #(500/ONFI_FRE) onfi_clk = ~onfi_clk;
end

always begin
    #(500/COM_FRE) com_clk = ~com_clk;
end

always begin
    #(500/OP_FRE) op_clk = ~op_clk;
end

always begin
    #(500/REF_FRE) refclk = ~refclk;
end

always begin
    #(500/AUX_FRE) auxclk = ~auxclk;
end

always begin
    auxclk90 = #(500/(AUX_FRE*2)) auxclk;
end

always begin
    dqs_clk = #(500/(ONFI_FRE*2)) onfi_clk;
end

/**************************signals*************************/
reg	 [31:0]			get_feature_data = 0;
reg	 [31:0]			get_status_data = 0;
reg	 [32*32-1:0]	data;
reg  [9*32*32-1:0]  program_data;
reg  [9*32*32-1:0]	rram_data;
reg  [9*32*32-1:0]	com_data;
reg  [31:0]			addr;
reg onfi_cen = 1;
reg onfi_cle = 0;
reg onfi_ale = 0;
reg onfi_wen = 0;
wire onfi_dqs;
reg onfi_dqs_en = 0;
wire [31:0] onfi_dq;
reg [31:0] onfi_dq_o = 0;
reg onfi_dq_en = 0;

assign onfi_dqs = onfi_dqs_en ? dqs_clk : 1'bZ;
assign onfi_dq = onfi_dq_en ? onfi_dq_o : 32'hZZZZZZZZ;

/**************************tasks*************************/
task reset;
begin
    @(negedge onfi_clk);
    onfi_cen = 0;
    onfi_cle = 0;
    onfi_ale = 0;
    onfi_wen = 1;
    onfi_dqs_en = 0;
    @(negedge onfi_clk);
    onfi_cle = 1;
    onfi_dq_o = 32'hFF;
    onfi_dq_en = 1;
    @(negedge onfi_clk);
    onfi_cle = 0;
    onfi_dq_en = 0;
    @(negedge onfi_clk);
    onfi_cen = 1;
end
endtask

task set_feature;
    input [31:0] addr;
    input [31:0] data;
begin
    @(negedge onfi_clk);
    onfi_cen = 0;
    onfi_cle = 0;
    onfi_ale = 0;
    onfi_wen = 1;
    onfi_dqs_en = 0;
    @(negedge onfi_clk);//command
    onfi_cle = 1;
    onfi_dq_o = 32'hEF;
    onfi_dq_en = 1;
    @(negedge onfi_clk);//addr
    onfi_cle = 0;
    onfi_ale = 1;
    onfi_dq_o = addr;
    @(negedge onfi_clk);//data
    onfi_ale = 0;
    onfi_dq_en = 0;
    fork
    begin
        @(negedge onfi_clk);
        onfi_cle = 1;
        onfi_ale = 1;
        @(negedge onfi_clk);
        onfi_cle = 0;
        onfi_ale = 0;
    end
    begin
        @(negedge onfi_clk);
        @(negedge onfi_clk);
        @(posedge onfi_clk);
        onfi_dqs_en = 1;
        onfi_dq_en = 1;
        onfi_dq_o = data;
        @(negedge onfi_clk);
        onfi_dq_o = data;
        @(posedge onfi_clk);
        onfi_dqs_en = 0;
        onfi_dq_en = 0;
    end
    join
    @(negedge onfi_clk);
    onfi_cen = 1;
    onfi_cle = 0;
    onfi_ale = 0;
    onfi_wen = 1;
end
endtask

task get_feature;
    input [31:0] addr;
    output [31:0] data;
begin
    @(negedge onfi_clk);
    onfi_cen = 0;
    onfi_cle = 0;
    onfi_ale = 0;
    onfi_wen = 1;
    onfi_dqs_en = 0;
    @(negedge onfi_clk);//command
    onfi_cle = 1;
    onfi_dq_o = 32'hEE;
    onfi_dq_en = 1;
    @(negedge onfi_clk);//addr
    onfi_cle = 0;
    onfi_ale = 1;
    onfi_dq_o = addr;
    @(negedge onfi_clk);//data
    onfi_ale = 0;
    onfi_dq_en = 0;
    onfi_wen = 0;
    fork
    begin
        @(negedge onfi_clk);
        onfi_cle = 1;
        onfi_ale = 1;
        @(negedge onfi_clk);
        onfi_cle = 0;
        onfi_ale = 0;
    end
    begin
        @(negedge onfi_clk);
        @(negedge onfi_clk);
        @(posedge onfi_dqs);
        #(500/(ONFI_FRE*2)) data = onfi_dq;//wait 1/4 T to ensure data stability
        @(negedge onfi_dqs);
        #(500/(ONFI_FRE*2)) data = onfi_dq;//the same data
    end
    join
    @(negedge onfi_clk);
    onfi_cen = 1;
    onfi_cle = 0;
    onfi_ale = 0;
    onfi_wen = 1;
end
endtask

task get_status;
    output [31:0] data;
begin
    @(negedge onfi_clk);
    onfi_cen = 0;
    onfi_cle = 0;
    onfi_ale = 0;
    onfi_wen = 1;
    onfi_dqs_en = 0;
    @(negedge onfi_clk);//command
    onfi_cle = 1;
    onfi_dq_o = 32'h70;
    onfi_dq_en = 1;
    //@(negedge onfi_clk);//no address, wait
    //onfi_cle = 0;
    //onfi_dq_en = 0;
    @(negedge onfi_clk);//data
    onfi_wen = 0;
    onfi_cle = 0;
    onfi_dq_en = 0;
    fork
    begin
        @(negedge onfi_clk);
        onfi_cle = 1;
        onfi_ale = 1;
        @(negedge onfi_clk);
        onfi_cle = 0;
        onfi_ale = 0;
    end
    begin
        @(negedge onfi_clk);
        @(negedge onfi_clk);
        @(posedge onfi_dqs);
        #(500/(ONFI_FRE*2)) data = onfi_dq;//wait 1/4 T to ensure data stability
        @(negedge onfi_dqs);
        #(500/(ONFI_FRE*2)) data = onfi_dq;//the same data
    end
    join
    @(negedge onfi_clk);
    onfi_cen = 1;
    onfi_cle = 0;
    onfi_ale = 0;
    onfi_wen = 1;
end
endtask

task program_;
    input [31:0] addr;
    input [31:0] length;//transfer length / 2
    input [9*32*32-1:0] data;//data from low to high, like little endian
begin:block1
    reg [9*32*32-1:0] data_tmp1;
    reg [9*32*32-1:0] data_tmp2;
    @(negedge onfi_clk);
    onfi_cen = 0;
    onfi_cle = 0;
    onfi_ale = 0;
    onfi_wen = 1;
    onfi_dqs_en = 0;
    @(negedge onfi_clk);//command
    onfi_cle = 1;
    onfi_dq_o = 32'h80;
    onfi_dq_en = 1;
    @(negedge onfi_clk);//addr1
    onfi_cle = 0;
    onfi_ale = 1;
    onfi_dq_o = addr;
    @(negedge onfi_clk);//addr2
    onfi_cle = 0;
    onfi_ale = 1;
    onfi_dq_o = length;
    @(negedge onfi_clk);//data
    onfi_ale = 0;
    onfi_dq_en = 0;
    data_tmp1 = data;
    fork
    begin
        repeat(length) begin
            @(negedge onfi_clk);
            onfi_cle = 1;
            onfi_ale = 1;
        end
        @(negedge onfi_clk);
        onfi_cle = 0;
        onfi_ale = 0;
    end
    begin
        @(negedge onfi_clk);
        @(negedge onfi_clk);
        repeat(length) begin
            @(posedge onfi_clk);
            onfi_dqs_en = 1;
            onfi_dq_en = 1;
            {data_tmp2, onfi_dq_o} = {32'h00000000, data_tmp1};
            @(negedge onfi_clk);
            {data_tmp1, onfi_dq_o} = {32'h00000000, data_tmp2};
        end
        @(posedge onfi_clk);
        onfi_dqs_en = 0;
        onfi_dq_en = 0;
    end
    join
    @(negedge onfi_clk);
    onfi_cen = 1;
    onfi_cle = 0;
    onfi_ale = 0;
    onfi_wen = 1;
end
endtask

task read;
    input [31:0] addr;
    input [31:0] length;//transfer length / 2
    output [9*32*32-1:0] data;//data from high to low, like bid endian
begin: block2
    integer pos;
    pos= 0;
    data = 0;
    @(negedge onfi_clk);
    onfi_cen = 0;
    onfi_cle = 0;
    onfi_ale = 0;
    onfi_wen = 1;
    onfi_dqs_en = 0;
    @(negedge onfi_clk);//command
    onfi_cle = 1;
    onfi_dq_o = 32'h00;
    onfi_dq_en = 1;
    @(negedge onfi_clk);//addr
    onfi_cle = 0;
    onfi_ale = 1;
    onfi_dq_o = addr;
    @(negedge onfi_clk);//length
    onfi_cle = 0;
    onfi_ale = 1;
    onfi_dq_o = length;
    @(negedge onfi_clk);//data
    onfi_ale = 0;
    onfi_dq_en = 0;
    onfi_wen = 0;
    fork
    begin
        repeat(length) begin
            @(negedge onfi_clk);
            onfi_cle = 1;
            onfi_ale = 1;
        end
        @(negedge onfi_clk);
        onfi_cle = 0;
        onfi_ale = 0;
    end
    begin
        @(negedge onfi_clk);
        @(negedge onfi_clk);
        repeat(length) begin
            @(posedge onfi_dqs);
            #(500/(ONFI_FRE*2)) data = data | ({9184'b0, onfi_dq} << (pos * 32));//wait 1/4 T to ensure data stability
            pos = pos + 1;
            @(negedge onfi_dqs);
            #(500/(ONFI_FRE*2)) data = data | ({9184'b0, onfi_dq} << (pos * 32));//the same data
            pos = pos + 1;
        end
    end
    join
    @(negedge onfi_clk);
    onfi_cen = 1;
    onfi_cle = 0;
    onfi_ale = 0;
    onfi_wen = 1;
end
endtask

task wait_for_ready;
begin
    get_status(get_feature_data);
    while(get_feature_data != 32'h00000000) begin
        $display("wait for ready, now is %h", get_feature_data[15:0]);
        #1000;
        get_status(get_feature_data);
    end
end
endtask

/**************************test*************************/
integer weight_fd;
integer read_weight_fd;
integer input_fd;
integer read_com_fd;
integer isram_test_fd;
integer exitcode;

initial begin            
    // $dumpfile("top_wrap_wave.vcd");
    $dumpfile("top_wrap_wave.fsdb");
    $dumpvars(2, testbench.u_top_wrap);
    // $dumpall;

    // weight_fd = $fopen("E:/projects/PimCard/cim02_prj/user/data/WEIGHT_DATA", "r");
    // read_weight_fd = $fopen("E:/projects/PimCard/cim02_prj/user/data/READ_WEIGHT_DATA", "w");
    // input_fd = $fopen("E:/projects/PimCard/cim02_prj/user/data/INPUT_DATA", "r");
    // read_com_fd = $fopen("E:/projects/PimCard/cim02_prj/user/data/READ_COM_DATA", "w");
    weight_fd = $fopen("../data/WEIGHT_DATA", "r");
    read_weight_fd = $fopen("../data/READ_WEIGHT_DATA", "w");
    input_fd = $fopen("../data/INPUT_DATA", "r");
    read_com_fd = $fopen("../data/READ_COM_DATA", "w");
    isram_test_fd = $fopen("../data/ISRAM_TEST_DATA", "w");

/*************************por************************************/
begin
    rst_n = 0;
    #500 rst_n = 1;
    #4000;
end

/*************************pll set************************************/
`ifdef ASIC_SIM
begin
    set_feature(PLL_REG1_ADDR, 32'h80000000);//pll reg1, pd = 1
    get_feature(PLL_REG1_ADDR, get_feature_data);
    $display("pll reg1 is %h", get_feature_data[31:0]);
    set_feature(PLL_REG0_ADDR, 32'h04A02824);//pll reg0
    get_feature(PLL_REG0_ADDR, get_feature_data);
    $display("pll reg0 is %h", get_feature_data[31:0]);
    set_feature(PLL_REG1_ADDR, 32'h00000000);//pll reg1, pd = 0
    get_feature(PLL_REG1_ADDR, get_feature_data);
    $display("pll reg1 is %h", get_feature_data[31:0]);
    get_status(get_feature_data);
    while(get_feature_data[31] != 1'b0) begin
        $display("wait for pll lock ready");
        get_status(get_feature_data);
    end
end

`ifdef PLL_FAIL
begin
    set_feature(CLOCK_MUX_SEL_ADDR, 32'h00000001);
    #1000;
end
`endif
`endif

/*************************program bank0 weight data************************************/
begin
    $display("start program");//program all isram
    exitcode = $fscanf(weight_fd, "%h", program_data);
    if (exitcode == 0)
        $finish(1);
    program_(32'h80000000, 144, program_data);
    exitcode = $fscanf(weight_fd, "%h", program_data);
    if (exitcode == 0)
        $finish(1);
    program_(32'h80000100, 144, program_data);
    exitcode = $fscanf(weight_fd, "%h", program_data);
    if (exitcode == 0)
        $finish(1);
    program_(32'h80000200, 144, program_data);
    exitcode = $fscanf(weight_fd, "%h", program_data);
    if (exitcode == 0)
        $finish(1);
    program_(32'h80000300, 144, program_data);
    wait_for_ready();
    $display("program done");

    $display("start write rram");//just read the first line of isram
    set_feature(SLV_REG1_ADDR, 32'h00000000);//isram addr
    set_feature(SLV_REG2_ADDR, 32'h00000000);//rram addr, bank0
    set_feature(SLV_REG3_ADDR, 32);//length, 32*288
    set_feature(SLV_REG0_ADDR, CMD_PROG_RRAM);//command
    wait_for_ready();
    $display("write rram done"); 
end

/*************************program bank1 weight data************************************/
begin
    $display("start program");//program all isram
    exitcode = $fscanf(weight_fd, "%h", program_data);
    if (exitcode == 0)
        $finish(1);
    program_(32'h80000000, 144, program_data);
    exitcode = $fscanf(weight_fd, "%h", program_data);
    if (exitcode == 0)
        $finish(1);
    program_(32'h80000100, 144, program_data);
    exitcode = $fscanf(weight_fd, "%h", program_data);
    if (exitcode == 0)
        $finish(1);
    program_(32'h80000200, 144, program_data);
    exitcode = $fscanf(weight_fd, "%h", program_data);
    if (exitcode == 0)
        $finish(1);
    program_(32'h80000300, 144, program_data);
    wait_for_ready();
    $display("program done");
    

    $display("start write rram");//just read the first line of isram
    set_feature(SLV_REG1_ADDR, 32'h00000000);//isram addr
    set_feature(SLV_REG2_ADDR, 32'h00010000);//rram addr, bank1
    set_feature(SLV_REG3_ADDR, 32);//length, 32*288
    set_feature(SLV_REG0_ADDR, CMD_PROG_RRAM);//command
    wait_for_ready();
    $display("write rram done");
end

/*************************read bank0 weight data************************************/
begin
    $display("start read rram");//just read the first line of rram
    set_feature(SLV_REG1_ADDR, 32'h00000000);//osram addr
    set_feature(SLV_REG2_ADDR, 32'h00000000);//rram addr
    set_feature(SLV_REG3_ADDR, 32);//length, 32*288
    set_feature(SLV_REG0_ADDR, CMD_READ_RRAM);//command
    wait_for_ready();
    $display("read rram done");

    $display("start read");
    rram_data = 0;
    addr = 32'h80000000;
    repeat(32) begin//64*320
        read(addr, 5, rram_data);
        $fdisplay(read_weight_fd, "%h", rram_data[287:0]);
        //addr = addr + 'h10;//for SRAM_NUM = 10
        addr = addr + 'h20;//for SRAM_NUM = 24
    end
    wait_for_ready();
    $display("read done");
end

/*************************read bank1 weight data************************************/
begin
    $display("start read rram");//just read the 0~3 of the second line of rram
    set_feature(SLV_REG1_ADDR, 32'h00000000);//osram addr
    set_feature(SLV_REG2_ADDR, 32'h00010008);//rram addr
    set_feature(SLV_REG3_ADDR, 4);//length, 4*288
    set_feature(SLV_REG0_ADDR, CMD_READ_RRAM);//command
    wait_for_ready();
    $display("read rram done");

    $display("start read");
    rram_data = 0;
    addr = 32'h80000000;
    repeat(4) begin//4*320
        read(addr, 5, rram_data);
        $fdisplay(read_weight_fd, "%h", rram_data[287:0]);
        //addr = addr + 'h10;//for SRAM_NUM = 10
        addr = addr + 'h20;//for SRAM_NUM = 24
    end
    wait_for_ready();
    $display("read done");
end

/*************************program input data************************************/
begin
    $display("start program");//program 20 isram
    addr = 32'h80000000;
    repeat(5) begin
        exitcode = $fscanf(input_fd, "%h", program_data);
        if (exitcode == 0)
            $finish(1);
        program_(addr, 144, program_data);
        addr = addr + 'h100;
    end
    wait_for_ready();
    $display("program done");
end

/*************************com cim************************************/
begin
    $display("start compute");
    set_feature(SLV_REG1_ADDR, 32'h00000000);//osram addr + isram addr
    set_feature(SLV_REG2_ADDR, 32'h00000002);//rram addr
    set_feature(SLV_REG3_ADDR, 4);//length, 4*9216
    set_feature(SLV_REG0_ADDR, CMD_COM_LINE_D16W16);//command
    wait_for_ready();
    $display("compute done");

    $display("start read");
    com_data = 0;
    addr = 32'h80000000;
    repeat(4) begin//4*608
        read(addr + 12, 5, com_data);//high bit is first
        $fwrite(read_com_fd, "%h", com_data[303:0]);
        read(addr, 5, com_data);
        $fwrite(read_com_fd, "%h\n", com_data[303:0]);
        //#10 addr = addr + 'h10;//for SRAM_NUM = 10
        addr = addr + 'h20;//for SRAM_NUM = 24
    end
    wait_for_ready();
    $display("read done");

    $display("start compute");
    set_feature(SLV_REG1_ADDR, 32'h00000100);//osram addr + isram addr
    set_feature(SLV_REG2_ADDR, 32'h00000004);//rram addr
    set_feature(SLV_REG3_ADDR, 4);//length, 4*9216
    set_feature(SLV_REG0_ADDR, CMD_COM_LINE_D8W8);//command
    wait_for_ready();
    $display("compute done");

    $display("start read");
    com_data = 0;
    addr = 32'h80000000;
    repeat(4) begin//4*608
        read(addr + 12, 5, com_data);//high bit is first
        $fwrite(read_com_fd, "%h", com_data[303:0]);
        read(addr, 5, com_data);
        $fwrite(read_com_fd, "%h\n", com_data[303:0]);
        //#10 addr = addr + 'h10;//for SRAM_NUM = 10
        addr = addr + 'h20;//for SRAM_NUM = 24
    end
    wait_for_ready();
    $display("read done");
end

/*************************com 1bit************************************/
begin
    $display("start compute");
    set_feature(SLV_REG1_ADDR, 32'h00000000);//osram addr + isram addr
    set_feature(SLV_REG2_ADDR, 32'h00000002);//rram addr
    set_feature(SLV_REG3_ADDR, 4);//length, 4*9216
    set_feature(SLV_REG0_ADDR, CMD_COM_LINE_D1W1);//command
    wait_for_ready();
    $display("compute done");

    $display("start read");
    com_data = 0;
    addr = 32'h80000000;
    repeat(4) begin//4*1536
        read(addr, 24, com_data);
        $fdisplay(read_com_fd, "%h", com_data[1535:0]);
        addr = addr + 'h20;
    end
    wait_for_ready();
    $display("read done");

    //rst
    $display("start reset");
    reset;
    #4000;
    $display("reset done");
    //end

    $display("start compute");
    set_feature(SLV_REG1_ADDR, 32'h00000100);//osram addr + isram addr
    set_feature(SLV_REG2_ADDR, 32'h00000004);//rram addr
    set_feature(SLV_REG3_ADDR, 4);//length, 4*9216
    set_feature(SLV_REG0_ADDR, CMD_COM_LINE_D1W1_SHIFT);//command
    wait_for_ready();
    $display("compute done");

    $display("start read");
    com_data = 0;
    addr = 32'h80000000;
    repeat(4) begin//4*448
        read(addr + 12, 4, com_data);//high bit is first
        $fwrite(read_com_fd, "%h", com_data[223:0]);
        read(addr, 4, com_data);
        $fwrite(read_com_fd, "%h\n", com_data[223:0]);
        addr = addr + 'h20;
    end
    wait_for_ready();
    $display("read done");
end

/*************************input sram test************************************/
begin
    $display("start input sram read");
    addr = 143;//high is first
    set_feature(SLV_REG0_ADDR, CMD_TEST_ISRAM_READ);//command
    repeat(144) begin
        set_feature(SLV_REG1_ADDR, addr);//isram addr
        get_feature(TEST_REGL_ADDR, data[31:0]);
        get_feature(TEST_REGH_ADDR, data[63:32]);
        $display("isram: %h%h", data[63:32], data[31:0]);
        $fwrite(isram_test_fd, "%h", data[63:0]);
        addr = addr - 1;
    end
    $fwrite(isram_test_fd, "\n");
    addr = 'h100 + 143;//high is first
    repeat(144) begin
        set_feature(SLV_REG1_ADDR, addr);//isram addr
        get_feature(TEST_REGL_ADDR, data[31:0]);
        get_feature(TEST_REGH_ADDR, data[63:32]);
        $display("isram: %h%h", data[63:32], data[31:0]);
        $fwrite(isram_test_fd, "%h", data[63:0]);
        addr = addr - 1;
    end
    $fwrite(isram_test_fd, "\n");
    addr = 'h200 + 143;//high is first
    repeat(144) begin
        set_feature(SLV_REG1_ADDR, addr);//isram addr
        get_feature(TEST_REGL_ADDR, data[31:0]);
        get_feature(TEST_REGH_ADDR, data[63:32]);
        $display("isram: %h%h", data[63:32], data[31:0]);
        $fwrite(isram_test_fd, "%h", data[63:0]);
        addr = addr - 1;
    end
    $fwrite(isram_test_fd, "\n");
    addr = 'h300 + 143;//high is first
    repeat(144) begin
        set_feature(SLV_REG1_ADDR, addr);//isram addr
        get_feature(TEST_REGL_ADDR, data[31:0]);
        get_feature(TEST_REGH_ADDR, data[63:32]);
        $display("isram: %h%h", data[63:32], data[31:0]);
        $fwrite(isram_test_fd, "%h", data[63:0]);
        addr = addr - 1;
    end
    $fwrite(isram_test_fd, "\n");
    addr = 'h400 + 143;//high is first
    repeat(144) begin
        set_feature(SLV_REG1_ADDR, addr);//isram addr
        get_feature(TEST_REGL_ADDR, data[31:0]);
        get_feature(TEST_REGH_ADDR, data[63:32]);
        $display("isram: %h%h", data[63:32], data[31:0]);
        $fwrite(isram_test_fd, "%h", data[63:0]);
        addr = addr - 1;
    end

    set_feature(SLV_REG0_ADDR, CMD_TEST_END);//command
    wait_for_ready();
    $display("input sram read done");
end

/*************************output sram test************************************/
begin
    $display("start output sram program");
    set_feature(SLV_REG1_ADDR, 32'b0000_0000_0000_0000_0000_0000_0000_0000);//osram addr
    set_feature(TEST_REGL_ADDR, 32'h76543210);//l
    set_feature(TEST_REGH_ADDR, 32'hFEDCBA98);//h
    get_feature(TEST_REGL_ADDR, data[31:0]);
    get_feature(TEST_REGH_ADDR, data[63:32]);
    $display("osram input: %h%h", data[63:32], data[31:0]);
    set_feature(SLV_REG0_ADDR, CMD_TEST_OSRAM_WRITE);//command
    wait_for_ready();
    set_feature(SLV_REG1_ADDR, 32'b0000_0000_0001_0000_0000_0000_0000_0000);//osram addr(start at bit 20)
    set_feature(TEST_REGL_ADDR, 32'h00000000);//l
    set_feature(TEST_REGH_ADDR, 32'h00000000);//h
    get_feature(TEST_REGL_ADDR, data[31:0]);
    get_feature(TEST_REGH_ADDR, data[63:32]);
    $display("osram input: %h%h", data[63:32], data[31:0]);
    set_feature(SLV_REG0_ADDR, CMD_TEST_OSRAM_WRITE);//command
    wait_for_ready();
    set_feature(SLV_REG1_ADDR, 32'b0000_0000_0010_0000_0000_0000_0000_0000);//osram addr
    set_feature(TEST_REGL_ADDR, 32'h76543210);//l
    set_feature(TEST_REGH_ADDR, 32'hFEDCBA98);//h
    get_feature(TEST_REGL_ADDR, data[31:0]);
    get_feature(TEST_REGH_ADDR, data[63:32]);
    $display("osram input: %h%h", data[63:32], data[31:0]);
    set_feature(SLV_REG0_ADDR, CMD_TEST_OSRAM_WRITE);//command
    wait_for_ready();
    set_feature(SLV_REG1_ADDR, 32'b0000_0000_0011_0000_0000_0000_0000_0000);//osram addr
    set_feature(TEST_REGL_ADDR, 32'h11111111);//l
    set_feature(TEST_REGH_ADDR, 32'h11111111);//h
    get_feature(TEST_REGL_ADDR, data[31:0]);
    get_feature(TEST_REGH_ADDR, data[63:32]);
    $display("osram input: %h%h", data[63:32], data[31:0]);
    set_feature(SLV_REG0_ADDR, CMD_TEST_OSRAM_WRITE);//command
    wait_for_ready();
    $display("output sram program done");

    $display("start read");
    read(32'h80000000, 4, data);
    $display("osram: %h", data[255:0]);
    $display("read done");
end

/*************************cim reg test************************************/
// begin
// 	set_feature(SLV_REGX_ADDR, 32'h4F205D61);
// 	set_feature(SLV_REG2_ADDR, 32'h00000000);//rram addr
// 	data = 0;
// 	get_feature(SLV_REGX_ADDR, data[31:0]);
// 	set_feature(SLV_REG0_ADDR, CMD_PROG_REG);//command
// 	#100;//because the op clk is too slow, must wait
// 	wait_for_ready();
// 	set_feature(SLV_REG0_ADDR, CMD_READ_REG);//command
// 	#100;
// 	wait_for_ready();
// 	get_feature(SLV_REGX_ADDR, data[63:32]);
// 	$display("cim reg before:%h, after:%h", data[31:0], data[63:32]);
// end

    $finish(0);
    $fclose(weight_fd);
    $fclose(read_weight_fd);
    $fclose(input_fd);
    $fclose(read_com_fd);
    $fclose(isram_test_fd);
end

/**************************instance*************************/
top_wrap  u_top_wrap (
    .CE_n_pad                   ( onfi_cen        ),
    .CLE_pad                    ( onfi_cle        ),
    .ALE_pad                    ( onfi_ale        ),
    .WR_n_pad                   ( onfi_wen        ),
    .CLK_pad                    ( onfi_clk        ),
    .refclk_pad                 ( refclk          ),
    .auxclk_pad                 ( auxclk          ),
    .auxclk90_pad               ( auxclk90        ),
    .cimip_pad                  (                 ),
    .rstn_pad                   ( rst_n           ),

    .DQS_pad                    ( onfi_dqs        ),
    .DQ_pad                     ( onfi_dq         ),

    `ifndef ASIC_SIM
    .clk_500M                   ( com_clk         ),
    `endif

    .test_mode_pad              ( 1'b0            ),
    .test_csn_pad               ( 1'b1            ),
    .test_sck_pad               ( 1'b0            ),
    .test_mosi_pad              ( 1'b0            ),
    .test_miso_pad              (             	  ),
    .test_sa_pin_pad            ( 1'b0            ),

    .pwr_HV_MEAS                (                 ),
    .pwr_XVPP                   (                 ),
    .pwr_YVPP                   (                 )
);

endmodule  //TOP
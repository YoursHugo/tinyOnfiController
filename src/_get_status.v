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
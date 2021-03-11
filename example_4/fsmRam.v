module fsmRam
    #(
        parameter NB_ADDR = 10,
        parameter NB_DATA = 16,
        parameter INIT_FILE = "/home/lugia/Proy/labo3/ram_init16_1024.txt"
    )
    (
        output [NB_DATA-1 : 0] o_log_data_from_ram,
        output o_log_ram_full,

        input [NB_DATA-1 : 0] i_data,
        input [2:0] i_enable,
        input i_reset, 
        input clock
    );

reg  [NB_ADDR-1 : 0] countReadAddr;
wire log_in_ram_run;

assign log_in_ram_run = i_enable[1];

always@(posedge clock)begin
    if(!i_reset)
        countReadAddr <= 0;
    else
        if(i_enable[2])
            countReadAddr <= countReadAddr + 1;
        else
            countReadAddr <= countReadAddr;
end // posedge clock

ram_save
    #(
        .NB_ADDR   (NB_ADDR),
        .NB_DATA   (NB_DATA),
        .INIT_FILE (INIT_FILE)
    )
    u_ram_save
    (
        .out_data_from_ram (o_log_data_from_ram), // Output Memory
        .out_full_from_ram (o_log_ram_full), // Output Full 
        .in_log_ram_run (log_in_ram_run), // Run log in RAM
        .in_data (i_data), // Data
        .in_ram_read_addr (countReadAddr), // Read Address
        .ctrl_valid (1'b1), 
        .clock (clock), //System Clock
        .cpu_reset (~i_reset) //System Reset
    );

endmodule // top_tx

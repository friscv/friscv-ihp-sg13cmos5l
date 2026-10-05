// Copyright 2026 FER, HPC Architecture and Application Research Center
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Licensed under the Solderpad Hardware License v 2.1 (the "License");
// you may not use this file except in compliance with the License, or,
// at your option, the Apache License version 2.0.
// You may obtain a copy of the License at https://solderpad.org/licenses/SHL-2.1/
//
// Emil Popovic <mail@emilpopovic.me>

`default_nettype none

module RVSoC9108_nexys_video #(
    parameter int unsigned SocFreqMHz = 50
) (
    input  wire       sys_clk_i,     // 100 MHz oscillator
    input  wire       cpu_rst_ni,    // CPU_RESET button

    // FMC VADJ control
    output wire [1:0] set_vadj_o,
    output wire       vadj_en_o,

    output wire [3:0] led_o,

    // Boot mode
    input  wire [1:0] boot_sel_i,

    // Test harness
    input  wire       harness_rst_ni,
    input  wire [1:0] harness_boot_sel_i,
    output wire       harness_heartbeat_o,

    // JTAG
    input  wire       jtag_tck_i,
    input  wire       jtag_tms_i,
    input  wire       jtag_tdi_i,
    input  wire       jtag_trst_ni,
    output wire       jtag_tdo_o,

    // UART0
    input  wire       uart_rx_i,
    output wire       uart_tx_o,

    // QSPI0 CS0 - configuration flash
    output wire       flash_cs_no,
    inout  wire [3:0] flash_dq_io,

    // QSPI0 CS1 - microSD in SPI mode
    output wire       sd_reset_o,
    output wire       sd_sck_o,
    output wire       sd_cmd_o,
    output wire       sd_cs_no,
    input  wire       sd_dat0_i,
    input  wire [1:0] sd_dat12_i,    // only pulled up

    // QSPI0 CS2 - spare
    output wire       spi2_cs_no,
    output wire       spi2_sck_o,
    output wire       spi2_mosi_o,
    input  wire       spi2_miso_i,

    // GPIO Port A
    inout  wire [7:0] gpio_a_io,

    // HyperBus
    inout  wire [7:0] hb_dq_io,
    inout  wire       hb_rwds_io,
    output wire       hb_ck_o,
    output wire [1:0] hb_cs_no,
    output wire       hb_reset_no
);

////////////
// Clocks //
////////////

logic clk_fb, clk_soc_mmcm, clk_ref_mmcm, mmcm_locked;
logic clk_soc, clk_ref200;

MMCME2_BASE #(
    .CLKIN1_PERIOD    ( 10.0                ),
    .CLKFBOUT_MULT_F  ( 10.0                ),
    .DIVCLK_DIVIDE    ( 1                   ),
    .CLKOUT0_DIVIDE_F ( 1000.0 / SocFreqMHz ),
    .CLKOUT1_DIVIDE   ( 5                   )
) i_mmcm (
    .CLKIN1   ( sys_clk_i    ),
    .CLKFBIN  ( clk_fb       ),
    .CLKFBOUT ( clk_fb       ),
    .CLKOUT0  ( clk_soc_mmcm ),
    .CLKOUT1  ( clk_ref_mmcm ),
    .LOCKED   ( mmcm_locked  ),
    .PWRDWN   ( 1'b0         ),
    .RST      ( 1'b0         ),
    .CLKFBOUTB(), .CLKOUT0B(), .CLKOUT1B(), .CLKOUT2(), .CLKOUT2B(),
    .CLKOUT3(), .CLKOUT3B(), .CLKOUT4(), .CLKOUT5(), .CLKOUT6()
);

BUFG i_bufg_soc ( .I ( clk_soc_mmcm ), .O ( clk_soc    ) );
BUFG i_bufg_ref ( .I ( clk_ref_mmcm ), .O ( clk_ref200 ) );

/////////////////////////
// Power-up and resets //
/////////////////////////

// MMCM must lock before the SoC can be released from reset, and VADJ set to 3.3 V

localparam int unsigned SeqW = 21;  // 42 ms at 50 MHz

logic [SeqW:0] seq_q;
logic          power_good;

always_ff @(posedge clk_soc or negedge mmcm_locked) begin
    if (!mmcm_locked)        seq_q <= '0;
    else if (!seq_q[SeqW])   seq_q <= seq_q + 1'b1;
end

assign power_good = seq_q[SeqW];
assign set_vadj_o = 2'b11;  // 3.3 V
assign vadj_en_o  = seq_q[SeqW] | seq_q[SeqW-1];

logic       rst_req_n;
logic [3:0] rst_sync_q;
logic       soc_rst_n;

assign rst_req_n = mmcm_locked & power_good & cpu_rst_ni & harness_rst_ni;

always_ff @(posedge clk_soc or negedge rst_req_n) begin
    if (!rst_req_n) rst_sync_q <= '0;
    else            rst_sync_q <= {rst_sync_q[2:0], 1'b1};
end

assign soc_rst_n = rst_sync_q[3];

///////////
// QSPI0 //
///////////

logic       qspi_sck;
logic [2:0] qspi_cs;
logic [3:0] qspi_sd_i, qspi_sd_o, qspi_sd_oe;
logic [3:0] flash_dq_i;
logic       mosi;

for (genvar i = 0; i < 4; i++) begin : gen_flash_dq
    IOBUF i_iobuf (
        .O  (  flash_dq_i[i] ),
        .IO (  flash_dq_io[i] ),
        .I  (  qspi_sd_o[i]   ),
        .T  ( ~qspi_sd_oe[i]  )
    );
end

logic flash_sck;
assign flash_sck = soc_rst_n ? qspi_sck : seq_q[3];

STARTUPE2 #(
    .PROG_USR      ( "FALSE" ),
    .SIM_CCLK_FREQ ( 0.0     )
) i_startup (
    .CFGCLK    (           ),
    .CFGMCLK   (           ),
    .EOS       (           ),
    .PREQ      (           ),
    .CLK       ( 1'b0      ),
    .GSR       ( 1'b0      ),
    .GTS       ( 1'b0      ),
    .KEYCLEARB ( 1'b1      ),
    .PACK      ( 1'b0      ),
    .USRCCLKO  ( flash_sck ),
    .USRCCLKTS ( 1'b0      ),
    .USRDONEO  ( 1'b1      ),
    .USRDONETS ( 1'b1      )
);

assign flash_cs_no = qspi_cs[0] | ~soc_rst_n;

assign mosi = qspi_sd_oe[0] ? qspi_sd_o[0] : 1'b1;

assign sd_reset_o = 1'b0;
assign sd_sck_o   = qspi_sck;
assign sd_cmd_o   = mosi;
assign sd_cs_no   = qspi_cs[1];

assign spi2_sck_o  = qspi_sck;
assign spi2_mosi_o = mosi;
assign spi2_cs_no  = qspi_cs[2];

always_comb begin
    qspi_sd_i = flash_dq_i;
    if (!qspi_cs[1])      qspi_sd_i[1] = sd_dat0_i;
    else if (!qspi_cs[2]) qspi_sd_i[1] = spi2_miso_i;
end

//////////
// GPIO //
//////////

logic [7:0] gpio_a_i, gpio_a_o, gpio_a_oe;

for (genvar i = 0; i < 8; i++) begin : gen_gpio
    IOBUF i_iobuf (
        .O  (  gpio_a_i[i]  ),
        .IO (  gpio_a_io[i] ),
        .I  (  gpio_a_o[i]  ),
        .T  ( ~gpio_a_oe[i] )
    );
end

//////////////
// HyperBus //
//////////////

logic [7:0] hb_dq_i, hb_dq_o;
logic       hb_dq_oe;
logic       hb_rwds_i, hb_rwds_o, hb_rwds_oe;

for (genvar i = 0; i < 8; i++) begin : gen_hb_dq
    IOBUF i_iobuf (
        .O  (  hb_dq_i[i]  ),
        .IO (  hb_dq_io[i] ),
        .I  (  hb_dq_o[i]  ),
        .T  ( ~hb_dq_oe    )
    );
end

IOBUF i_hb_rwds (
    .O  (  hb_rwds_i  ),
    .IO (  hb_rwds_io ),
    .I  (  hb_rwds_o  ),
    .T  ( ~hb_rwds_oe )
);

//////////
// Chip //
//////////

logic heartbeat, soc_end;

`pragma diagnostic push
`pragma diagnostic ignore="-Wempty-output-connection"
chip_soc #(
    .NumGpios ( 8 ),
    .BootSelW ( 2 ),
    .MemChips ( 2 )
) i_chip_soc (
    .clk_i           ( clk_soc      ),
    .rst_ni          ( soc_rst_n    ),
    .clk_ref200_i    ( clk_ref200   ),
    .heartbeat_o     ( heartbeat    ),
    .end_o           ( soc_end      ),

    // JTAG
    .jtag_tck_i,
    .jtag_tms_i,
    .jtag_trst_ni,
    .jtag_tdi_i,
    .jtag_tdo_o,
    .jtag_tdo_oe_o   ( /* unused */ ),

    // UART0
    .uart0_rx_i      ( uart_rx_i    ),
    .uart0_tx_o      ( uart_tx_o    ),

    // QSPI0
    .qspi0_sck_o     ( qspi_sck     ),
    .qspi0_cs_o      ( qspi_cs      ),
    .qspi0_sd_i      ( qspi_sd_i    ),
    .qspi0_sd_o      ( qspi_sd_o    ),
    .qspi0_sd_oe_o   ( qspi_sd_oe   ),

    // HyperBus
    .hyper_dq_i      ( hb_dq_i      ),
    .hyper_dq_o      ( hb_dq_o      ),
    .hyper_dq_oe_o   ( hb_dq_oe     ),
    .hyper_rwds_i    ( hb_rwds_i    ),
    .hyper_rwds_o    ( hb_rwds_o    ),
    .hyper_rwds_oe_o ( hb_rwds_oe   ),
    .hyper_ck_o      ( hb_ck_o      ),
    .hyper_cs_no     ( hb_cs_no     ),
    .hyper_reset_no  ( hb_reset_no  ),

    // Boot mode select, switches must be at 00 for the harness to choose
    .boot_sel_i      ( boot_sel_i | harness_boot_sel_i ),

    // GPIO Port A
    .gpio_a_i,
    .gpio_a_o,
    .gpio_a_oe_o     ( gpio_a_oe    )
);
`pragma diagnostic pop

assign led_o[0] = heartbeat;
assign led_o[1] = soc_end;
assign led_o[2] = ~soc_rst_n;
assign led_o[3] = power_good;

assign harness_heartbeat_o = heartbeat;

endmodule

`default_nettype wire

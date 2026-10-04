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

module RVSoC9108_pynq_z2 (
    input  wire       clk_i,         // PS FCLK0, 50 MHz
    input  wire       clk_ref200_i,  // PS FCLK1
    input  wire       ps_rst_ni,     // PS FCLK_RESET0_N
    input  wire       rst_i,         // BTN0

    output wire [3:0] led_o,

    // Boot mode
    input  wire [1:0] boot_sel_i,

    // JTAG
    input  wire       jtag_tck_i,
    input  wire       jtag_tms_i,
    input  wire       jtag_tdi_i,
    input  wire       jtag_trst_ni,
    output wire       jtag_tdo_o,

    // UART0
    input  wire       uart_rx_i,
    output wire       uart_tx_o,

    // QSPI0 in SPI mode
    output wire       spi_sck_o,
    output wire       spi_mosi_o,
    input  wire       spi_miso_i,
    output wire [2:0] spi_cs_no,

    // GPIO Port A
    inout  wire [7:0] gpio_a_io
);

////////////
// Resets //
////////////

logic       rst_req_n;
logic [3:0] rst_sync_q;
logic       soc_rst_n;

assign rst_req_n = ps_rst_ni & ~rst_i;

always_ff @(posedge clk_i or negedge rst_req_n) begin
    if (!rst_req_n) rst_sync_q <= '0;
    else            rst_sync_q <= {rst_sync_q[2:0], 1'b1};
end

assign soc_rst_n = rst_sync_q[3];

///////////
// QSPI0 //
///////////

logic [3:0] qspi_sd_o, qspi_sd_oe;
logic       mosi;

assign mosi = qspi_sd_oe[0] ? qspi_sd_o[0] : 1'b1;

assign spi_mosi_o = mosi;

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

(* dont_touch = "true" *) logic hb_rwds_q;

always_ff @(posedge clk_i) hb_rwds_q <= 1'b0;

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
    .clk_i,
    .rst_ni          ( soc_rst_n    ),
    .clk_ref200_i,
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
    .qspi0_sck_o     ( spi_sck_o    ),
    .qspi0_cs_o      ( spi_cs_no    ),
    .qspi0_sd_i      ( {2'b11, spi_miso_i, mosi} ),
    .qspi0_sd_o      ( qspi_sd_o    ),
    .qspi0_sd_oe_o   ( qspi_sd_oe   ),

    // HyperBus, no memory attached
    .hyper_dq_i      ( '0           ),
    .hyper_dq_o      ( /* unused */ ),
    .hyper_dq_oe_o   ( /* unused */ ),
    .hyper_rwds_i    ( hb_rwds_q    ),
    .hyper_rwds_o    ( /* unused */ ),
    .hyper_rwds_oe_o ( /* unused */ ),
    .hyper_ck_o      ( /* unused */ ),
    .hyper_cs_no     ( /* unused */ ),
    .hyper_reset_no  ( /* unused */ ),

    // Boot mode select
    .boot_sel_i,

    // GPIO Port A
    .gpio_a_i,
    .gpio_a_o,
    .gpio_a_oe_o     ( gpio_a_oe    )
);
`pragma diagnostic pop

assign led_o[0] = heartbeat;
assign led_o[1] = soc_end;
assign led_o[2] = ~soc_rst_n;
assign led_o[3] = ps_rst_ni;

endmodule

`default_nettype wire

// Copyright 2026 FER, HPC Architecture and Application Research Center
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Licensed under the Solderpad Hardware License v 2.1 (the "License");
// you may not use this file except in compliance with the License, or,
// at your option, the Apache License version 2.0.
// You may obtain a copy of the License at https://solderpad.org/licenses/SHL-2.1/
//
// Emil Popovic <mail@emilpopovic.me>

module RVSoC9108_pynq_z2_wrap (
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk_i CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_RESET ps_rst_ni" *)
    input  wire       clk_i,
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk_ref200_i CLK" *)
    input  wire       clk_ref200_i,
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 ps_rst_ni RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_LOW" *)
    input  wire       ps_rst_ni,
    input  wire       rst_i,

    output wire [3:0] led_o,

    input  wire [1:0] boot_sel_i,

    input  wire       harness_rst_ni,
    input  wire [1:0] harness_boot_sel_i,
    output wire       harness_heartbeat_o,

    input  wire       jtag_tck_i,
    input  wire       jtag_tms_i,
    input  wire       jtag_tdi_i,
    input  wire       jtag_trst_ni,
    output wire       jtag_tdo_o,

    input  wire       uart_rx_i,
    output wire       uart_tx_o,

    output wire       spi_sck_o,
    output wire       spi_mosi_o,
    input  wire       spi_miso_i,
    output wire [2:0] spi_cs_no,

    inout  wire [7:0] gpio_a_io
);

RVSoC9108_pynq_z2 i_top (
    .clk_i               ( clk_i               ),
    .clk_ref200_i        ( clk_ref200_i        ),
    .ps_rst_ni           ( ps_rst_ni           ),
    .rst_i               ( rst_i               ),
    .led_o               ( led_o               ),
    .boot_sel_i          ( boot_sel_i          ),
    .harness_rst_ni      ( harness_rst_ni      ),
    .harness_boot_sel_i  ( harness_boot_sel_i  ),
    .harness_heartbeat_o ( harness_heartbeat_o ),
    .jtag_tck_i          ( jtag_tck_i          ),
    .jtag_tms_i          ( jtag_tms_i          ),
    .jtag_tdi_i          ( jtag_tdi_i          ),
    .jtag_trst_ni        ( jtag_trst_ni        ),
    .jtag_tdo_o          ( jtag_tdo_o          ),
    .uart_rx_i           ( uart_rx_i           ),
    .uart_tx_o           ( uart_tx_o           ),
    .spi_sck_o           ( spi_sck_o           ),
    .spi_mosi_o          ( spi_mosi_o          ),
    .spi_miso_i          ( spi_miso_i          ),
    .spi_cs_no           ( spi_cs_no           ),
    .gpio_a_io           ( gpio_a_io           )
);

endmodule

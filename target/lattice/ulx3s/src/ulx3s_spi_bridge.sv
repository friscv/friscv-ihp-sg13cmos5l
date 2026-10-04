// Copyright 2026 FER, HPC Architecture and Application Research Center
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Licensed under the Solderpad Hardware License v 2.1 (the "License");
// you may not use this file except in compliance with the License, or,
// at your option, the Apache License version 2.0.
// You may obtain a copy of the License at https://solderpad.org/licenses/SHL-2.1/
//
// Emil Popovic <mail@emilpopovic.me>

// ULX3S as the chip board's QSPI0 bus.
// Flash on CS0#, microSD on CS1#
// J1 pairs: 0 SCK, 1 MOSI, 2 CS1#, 3 MISO, 4 CS0#
module ulx3s_spi_bridge (
    input  wire [2:0] gpi,
    input  wire [2:0] gni,
    input  wire       gp4,
    input  wire       gn4,
    output wire       gp3,
    output wire       gn3,

    output wire       sd_clk,
    output wire       sd_cmd,
    input  wire       sd_d0,
    output wire       sd_d3,

    output wire       flash_csn,
    output wire       flash_mosi,
    input  wire       flash_miso,
    output wire       flash_wpn,
    output wire       flash_holdn,

    output wire       wifi_en
);
    // The unconnected pin of each pair stays at its pull
    wire sck  = gpi[0] | gni[0];
    wire mosi = gpi[1] & gni[1];
    wire cs1n = gpi[2] & gni[2];
    wire cs0n = gp4 & gn4;

    assign sd_clk = sck;
    assign sd_cmd = mosi;
    assign sd_d3  = cs1n;

    USRMCLK i_usrmclk (.USRMCLKI(sck), .USRMCLKTS(1'b0));
    assign flash_csn   = cs0n;
    assign flash_mosi  = mosi;
    assign flash_wpn   = 1'b1;
    assign flash_holdn = 1'b1;

    wire miso = cs0n ? sd_d0 : flash_miso;
    assign gp3 = miso;
    assign gn3 = miso;

    // The ESP32 shares the SD pins, disable it
    assign wifi_en = 1'b0;
endmodule

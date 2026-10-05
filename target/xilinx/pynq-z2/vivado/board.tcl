# Copyright 2026 FER, HPC Architecture and Application Research Center
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
#
# Emil Popovic <mail@emilpopovic.me>

set_property board_part tul.com.tw:pynq-z2:part0:1.0 [current_project]
set_property source_mgmt_mode All [current_project]

read_verilog $target/src/${top}_wrap.v

create_bd_design bd
update_compile_order -fileset sources_1

create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7 ps7
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 \
    -config {make_external "FIXED_IO, DDR" apply_board_preset "1" \
             Master "Disable" Slave "Disable"} [get_bd_cells ps7]
set_property -dict [list \
    CONFIG.PCW_USE_M_AXI_GP0 {0} \
    CONFIG.PCW_EN_CLK1_PORT {1} \
    CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ $::env(SOC_FREQ_MHZ) \
    CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {200} \
] [get_bd_cells ps7]

create_bd_cell -type module -reference ${top}_wrap soc

connect_bd_net [get_bd_pins ps7/FCLK_CLK0]     [get_bd_pins soc/clk_i]
connect_bd_net [get_bd_pins ps7/FCLK_CLK1]     [get_bd_pins soc/clk_ref200_i]
connect_bd_net [get_bd_pins ps7/FCLK_RESET0_N] [get_bd_pins soc/ps_rst_ni]

foreach p {rst_i led_o boot_sel_i harness_rst_ni harness_boot_sel_i harness_heartbeat_o
           jtag_tck_i jtag_tms_i jtag_tdi_i jtag_trst_ni jtag_tdo_o
           uart_rx_i uart_tx_o spi_sck_o spi_mosi_o spi_miso_i spi_cs_no gpio_a_io} {
    make_bd_pins_external -name $p [get_bd_pins soc/$p]
}

assign_bd_address
validate_bd_design
save_bd_design

set bd_file [get_files bd.bd]
set_property synth_checkpoint_mode None $bd_file
generate_target all $bd_file
make_wrapper -files $bd_file -top -import

set_property source_mgmt_mode None [current_project]

set synth_top      bd_wrapper
set synth_generics {}

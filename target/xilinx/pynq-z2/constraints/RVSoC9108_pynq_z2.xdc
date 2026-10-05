# Reset
set_property -dict { PACKAGE_PIN D19 IOSTANDARD LVCMOS33 } [get_ports rst_i]   ;# BTN0

# Status LEDs
set_property -dict { PACKAGE_PIN R14 IOSTANDARD LVCMOS33 } [get_ports {led_o[0]}]   ;# LD0 heartbeat
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports {led_o[1]}]   ;# LD1 end of program
set_property -dict { PACKAGE_PIN N16 IOSTANDARD LVCMOS33 } [get_ports {led_o[2]}]   ;# LD2 SoC in reset
set_property -dict { PACKAGE_PIN M14 IOSTANDARD LVCMOS33 } [get_ports {led_o[3]}]   ;# LD3 PS clocks up

# Boot select pads
set_property -dict { PACKAGE_PIN M20 IOSTANDARD LVCMOS33 } [get_ports {boot_sel_i[0]}] ;# SW0
set_property -dict { PACKAGE_PIN M19 IOSTANDARD LVCMOS33 } [get_ports {boot_sel_i[1]}] ;# SW1

# Test harness on the RPi header
set_property -dict { PACKAGE_PIN U7 IOSTANDARD LVCMOS33 PULLUP   true } [get_ports harness_rst_ni]          ;# GPIO17, pin 11
set_property -dict { PACKAGE_PIN V7 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {harness_boot_sel_i[0]}] ;# GPIO27, pin 13
set_property -dict { PACKAGE_PIN W9 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {harness_boot_sel_i[1]}] ;# GPIO26, pin 37
set_property -dict { PACKAGE_PIN W8 IOSTANDARD LVCMOS33               } [get_ports harness_heartbeat_o]     ;# GPIO13, pin 33

# JTAG
set_property -dict { PACKAGE_PIN Y7  IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports jtag_tck_i]   ;# GPIO24, pin 18
set_property -dict { PACKAGE_PIN C20 IOSTANDARD LVCMOS33 PULLUP   true } [get_ports jtag_tdi_i]   ;# GPIO18, pin 12
set_property -dict { PACKAGE_PIN F20 IOSTANDARD LVCMOS33               } [get_ports jtag_tdo_o]   ;# GPIO25, pin 22
set_property -dict { PACKAGE_PIN W6  IOSTANDARD LVCMOS33 PULLUP   true } [get_ports jtag_tms_i]   ;# GPIO23, pin 16
set_property -dict { PACKAGE_PIN U8  IOSTANDARD LVCMOS33 PULLUP   true } [get_ports jtag_trst_ni] ;# GPIO22, pin 15

# UART0
set_property -dict { PACKAGE_PIN V6 IOSTANDARD LVCMOS33               } [get_ports uart_tx_o] ;# GPIO14, pin 8
set_property -dict { PACKAGE_PIN Y6 IOSTANDARD LVCMOS33 PULLUP   true } [get_ports uart_rx_i] ;# GPIO15, pin 10

# QSPI0
set_property -dict { PACKAGE_PIN W10 IOSTANDARD LVCMOS33               } [get_ports spi_sck_o]      ;# GPIO11, pin 23
set_property -dict { PACKAGE_PIN V8  IOSTANDARD LVCMOS33               } [get_ports spi_mosi_o]     ;# GPIO10, pin 19
set_property -dict { PACKAGE_PIN V10 IOSTANDARD LVCMOS33 PULLUP   true } [get_ports spi_miso_i]     ;# GPIO9,  pin 21
set_property -dict { PACKAGE_PIN F19 IOSTANDARD LVCMOS33               } [get_ports {spi_cs_no[0]}] ;# GPIO8,  pin 24
set_property -dict { PACKAGE_PIN B19 IOSTANDARD LVCMOS33               } [get_ports {spi_cs_no[1]}] ;# GPIO16, pin 36
set_property -dict { PACKAGE_PIN A20 IOSTANDARD LVCMOS33               } [get_ports {spi_cs_no[2]}] ;# GPIO20, pin 38

# Jumpers have bad signal integrity, edges must be slow to avoid crosstalk
set_property SLEW  SLOW [get_ports {spi_sck_o spi_mosi_o spi_cs_no[*]}]
set_property DRIVE 4    [get_ports {spi_sck_o spi_mosi_o spi_cs_no[*]}]

# GPIO Port A on PMODB
set_property -dict { PACKAGE_PIN W14 IOSTANDARD LVCMOS33 } [get_ports {gpio_a_io[0]}] ;# JB1
set_property -dict { PACKAGE_PIN Y14 IOSTANDARD LVCMOS33 } [get_ports {gpio_a_io[1]}] ;# JB2
set_property -dict { PACKAGE_PIN T11 IOSTANDARD LVCMOS33 } [get_ports {gpio_a_io[2]}] ;# JB3
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports {gpio_a_io[3]}] ;# JB4
set_property -dict { PACKAGE_PIN V16 IOSTANDARD LVCMOS33 } [get_ports {gpio_a_io[4]}] ;# JB7
set_property -dict { PACKAGE_PIN W16 IOSTANDARD LVCMOS33 } [get_ports {gpio_a_io[5]}] ;# JB8
set_property -dict { PACKAGE_PIN V12 IOSTANDARD LVCMOS33 } [get_ports {gpio_a_io[6]}] ;# JB9
set_property -dict { PACKAGE_PIN W13 IOSTANDARD LVCMOS33 } [get_ports {gpio_a_io[7]}] ;# JB10

##########
# Timing #
##########

create_clock -period 100.000 -name jtag_tck [get_ports jtag_tck_i]

create_clock -period 20.000 -name hb_rwds [get_pins -hier -filter {NAME =~ *i_delay_rx_rwds_90/i_delay/DATAOUT}]

set soc_clk  [get_clocks clk_fpga_0]
set jtag_clk [get_clocks jtag_tck]
set rwds_clk [get_clocks hb_rwds]

set dft_tck_sel [get_pins -quiet -hier -filter {NAME =~ *i_dft_tck_mux*/S}]
if {[llength $dft_tck_sel]} { set_case_analysis 0 $dft_tck_sel }

# JTAG <-> SoC clock domain crossing
if {[llength [info commands vernii_soc_cdc_constraints]] == 0} {
    send_msg_id {FRISCV 1-4} ERROR "vernii_soc_cdc.tcl was not sourced, TCK crossing is undeclared."
}
vernii_soc_cdc_constraints $soc_clk $jtag_clk

# JTAG timing
set_input_delay  -clock $jtag_clk -clock_fall -max 20.000 [get_ports {jtag_tms_i jtag_tdi_i}]
set_input_delay  -clock $jtag_clk -clock_fall -min  0.000 [get_ports {jtag_tms_i jtag_tdi_i}]
set_output_delay -clock $jtag_clk -max 20.000 [get_ports jtag_tdo_o]
set_output_delay -clock $jtag_clk -min  0.000 [get_ports jtag_tdo_o]
set_false_path -from [get_ports jtag_trst_ni]

# QSPI0 timing
set qspi_outputs [get_ports {spi_sck_o spi_mosi_o spi_cs_no[*]}]
set qspi_inputs  [get_ports spi_miso_i]
set_output_delay -clock $soc_clk -max  3.000 $qspi_outputs
set_output_delay -clock $soc_clk -min -3.000 $qspi_outputs
set_multicycle_path -setup 2 -to $qspi_outputs
set_multicycle_path -hold  1 -to $qspi_outputs
set_input_delay  -clock $soc_clk -max  8.000 $qspi_inputs
set_input_delay  -clock $soc_clk -min  1.000 $qspi_inputs

# HyperBus RX FIFO crossing
set_max_delay -datapath_only 20.000 -from $rwds_clk -to $soc_clk
set_max_delay -datapath_only 20.000 -from $soc_clk  -to $rwds_clk

# Async I/O
set_false_path -from [get_ports {rst_i boot_sel_i[*] uart_rx_i gpio_a_io[*]}]
set_false_path -from [get_ports {harness_rst_ni harness_boot_sel_i[*]}]
set_false_path -to   [get_ports {uart_tx_o gpio_a_io[*] led_o[*]}]
set_false_path -to   [get_ports harness_heartbeat_o]

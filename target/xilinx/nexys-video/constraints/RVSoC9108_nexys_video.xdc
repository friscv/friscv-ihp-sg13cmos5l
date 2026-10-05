set_property CFGBVS VCCO        [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

set_property -dict { PACKAGE_PIN R4  IOSTANDARD LVCMOS33 } [get_ports sys_clk_i]
set_property -dict { PACKAGE_PIN G4  IOSTANDARD LVCMOS15 } [get_ports cpu_rst_ni]

set_property -dict { PACKAGE_PIN AA13 IOSTANDARD LVCMOS25 } [get_ports {set_vadj_o[0]}]
set_property -dict { PACKAGE_PIN AB17 IOSTANDARD LVCMOS25 } [get_ports {set_vadj_o[1]}]
set_property -dict { PACKAGE_PIN V14  IOSTANDARD LVCMOS25 } [get_ports vadj_en_o]

# Status LEDs
set_property -dict { PACKAGE_PIN T14 IOSTANDARD LVCMOS25 } [get_ports {led_o[0]}]   ;# LD0 heartbeat
set_property -dict { PACKAGE_PIN T15 IOSTANDARD LVCMOS25 } [get_ports {led_o[1]}]   ;# LD1 end of program
set_property -dict { PACKAGE_PIN T16 IOSTANDARD LVCMOS25 } [get_ports {led_o[2]}]   ;# LD2 SoC in reset
set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS25 } [get_ports {led_o[3]}]   ;# LD3 VADJ up

# Boot select pads
set_property -dict { PACKAGE_PIN E22 IOSTANDARD LVCMOS33 } [get_ports {boot_sel_i[0]}] ;# SW0
set_property -dict { PACKAGE_PIN F21 IOSTANDARD LVCMOS33 } [get_ports {boot_sel_i[1]}] ;# SW1

# JTAG on Pmod JC
set_property -dict { PACKAGE_PIN Y6  IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports jtag_tck_i]   ;# JC1
set_property -dict { PACKAGE_PIN AA6 IOSTANDARD LVCMOS33 PULLUP   true } [get_ports jtag_tdi_i]   ;# JC2
set_property -dict { PACKAGE_PIN AA8 IOSTANDARD LVCMOS33               } [get_ports jtag_tdo_o]   ;# JC3
set_property -dict { PACKAGE_PIN AB8 IOSTANDARD LVCMOS33 PULLUP   true } [get_ports jtag_tms_i]   ;# JC4
set_property -dict { PACKAGE_PIN R6  IOSTANDARD LVCMOS33 PULLUP   true } [get_ports jtag_trst_ni] ;# JC7

# UART0 on the USB-UART bridge
set_property -dict { PACKAGE_PIN AA19 IOSTANDARD LVCMOS33               } [get_ports uart_tx_o]
set_property -dict { PACKAGE_PIN V18  IOSTANDARD LVCMOS33 PULLUP   true } [get_ports uart_rx_i]

# QSPI0 CS0 - configuration flash
set_property -dict { PACKAGE_PIN T19 IOSTANDARD LVCMOS33 } [get_ports flash_cs_no]
set_property -dict { PACKAGE_PIN P22 IOSTANDARD LVCMOS33 } [get_ports {flash_dq_io[0]}]
set_property -dict { PACKAGE_PIN R22 IOSTANDARD LVCMOS33 } [get_ports {flash_dq_io[1]}]
set_property -dict { PACKAGE_PIN P21 IOSTANDARD LVCMOS33 } [get_ports {flash_dq_io[2]}]
set_property -dict { PACKAGE_PIN R21 IOSTANDARD LVCMOS33 } [get_ports {flash_dq_io[3]}]
set_property PULLUP true [get_ports {flash_dq_io[*]}]

# QSPI0 CS1 - microSD
set_property -dict { PACKAGE_PIN V20 IOSTANDARD LVCMOS33               } [get_ports sd_reset_o]
set_property -dict { PACKAGE_PIN W19 IOSTANDARD LVCMOS33               } [get_ports sd_sck_o]        ;# sd_cclk
set_property -dict { PACKAGE_PIN W20 IOSTANDARD LVCMOS33               } [get_ports sd_cmd_o]        ;# sd_cmd
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33               } [get_ports sd_cs_no]        ;# sd_d[3]
set_property -dict { PACKAGE_PIN V19 IOSTANDARD LVCMOS33 PULLUP   true } [get_ports sd_dat0_i]       ;# sd_d[0]
set_property -dict { PACKAGE_PIN T21 IOSTANDARD LVCMOS33 PULLUP   true } [get_ports {sd_dat12_i[0]}] ;# sd_d[1]
set_property -dict { PACKAGE_PIN T20 IOSTANDARD LVCMOS33 PULLUP   true } [get_ports {sd_dat12_i[1]}] ;# sd_d[2]

# QSPI0 CS2 - Pmod JA top row
set_property -dict { PACKAGE_PIN AB22 IOSTANDARD LVCMOS33               } [get_ports spi2_cs_no]  ;# JA1
set_property -dict { PACKAGE_PIN AB21 IOSTANDARD LVCMOS33               } [get_ports spi2_mosi_o] ;# JA2
set_property -dict { PACKAGE_PIN AB20 IOSTANDARD LVCMOS33 PULLUP   true } [get_ports spi2_miso_i] ;# JA3
set_property -dict { PACKAGE_PIN AB18 IOSTANDARD LVCMOS33               } [get_ports spi2_sck_o]  ;# JA4

# Test harness on Pmod JA bottom row
set_property -dict { PACKAGE_PIN Y21  IOSTANDARD LVCMOS33 PULLUP   true } [get_ports harness_rst_ni]          ;# JA7
set_property -dict { PACKAGE_PIN AA21 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {harness_boot_sel_i[0]}] ;# JA8
set_property -dict { PACKAGE_PIN AA20 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {harness_boot_sel_i[1]}] ;# JA9
set_property -dict { PACKAGE_PIN AA18 IOSTANDARD LVCMOS33               } [get_ports harness_heartbeat_o]     ;# JA10

# GPIO Port A on Pmod JB, no pulls
set_property -dict { PACKAGE_PIN V9 IOSTANDARD LVCMOS33 } [get_ports {gpio_a_io[0]}] ;# JB1
set_property -dict { PACKAGE_PIN V8 IOSTANDARD LVCMOS33 } [get_ports {gpio_a_io[1]}] ;# JB2
set_property -dict { PACKAGE_PIN V7 IOSTANDARD LVCMOS33 } [get_ports {gpio_a_io[2]}] ;# JB3
set_property -dict { PACKAGE_PIN W7 IOSTANDARD LVCMOS33 } [get_ports {gpio_a_io[3]}] ;# JB4
set_property -dict { PACKAGE_PIN W9 IOSTANDARD LVCMOS33 } [get_ports {gpio_a_io[4]}] ;# JB7
set_property -dict { PACKAGE_PIN Y9 IOSTANDARD LVCMOS33 } [get_ports {gpio_a_io[5]}] ;# JB8
set_property -dict { PACKAGE_PIN Y8 IOSTANDARD LVCMOS33 } [get_ports {gpio_a_io[6]}] ;# JB9
set_property -dict { PACKAGE_PIN Y7 IOSTANDARD LVCMOS33 } [get_ports {gpio_a_io[7]}] ;# JB10

# HyperBus on FMC
# U7 on CSN0 and U8 on CSN1
set_property -dict { PACKAGE_PIN K18 IOSTANDARD LVCMOS33 } [get_ports hb_ck_o]        ;# G6  LA00_P_CC
set_property -dict { PACKAGE_PIN L19 IOSTANDARD LVCMOS33 } [get_ports hb_rwds_io]     ;# G15 LA12_P
set_property -dict { PACKAGE_PIN M16 IOSTANDARD LVCMOS33 } [get_ports {hb_dq_io[0]}]  ;# G13 LA08_N
set_property -dict { PACKAGE_PIN M15 IOSTANDARD LVCMOS33 } [get_ports {hb_dq_io[1]}]  ;# G12 LA08_P
set_property -dict { PACKAGE_PIN N19 IOSTANDARD LVCMOS33 } [get_ports {hb_dq_io[2]}]  ;# G10 LA03_N
set_property -dict { PACKAGE_PIN N18 IOSTANDARD LVCMOS33 } [get_ports {hb_dq_io[3]}]  ;# G9  LA03_P
set_property -dict { PACKAGE_PIN G17 IOSTANDARD LVCMOS33 } [get_ports {hb_dq_io[4]}]  ;# G18 LA16_P
set_property -dict { PACKAGE_PIN G18 IOSTANDARD LVCMOS33 } [get_ports {hb_dq_io[5]}]  ;# G19 LA16_N
set_property -dict { PACKAGE_PIN F19 IOSTANDARD LVCMOS33 } [get_ports {hb_dq_io[6]}]  ;# G21 LA20_P
set_property -dict { PACKAGE_PIN F20 IOSTANDARD LVCMOS33 } [get_ports {hb_dq_io[7]}]  ;# G22 LA20_N
set_property -dict { PACKAGE_PIN E21 IOSTANDARD LVCMOS33 } [get_ports {hb_cs_no[0]}]  ;# G24 LA22_P, U7
set_property -dict { PACKAGE_PIN D21 IOSTANDARD LVCMOS33 } [get_ports {hb_cs_no[1]}]  ;# G25 LA22_N, U8
set_property -dict { PACKAGE_PIN F16 IOSTANDARD LVCMOS33 } [get_ports hb_reset_no]    ;# G27 LA25_P

set_property SLEW  FAST [get_ports {hb_ck_o hb_rwds_io hb_dq_io[*] hb_cs_no[*]}]
set_property DRIVE 12   [get_ports {hb_ck_o hb_rwds_io hb_dq_io[*] hb_cs_no[*]}]

##########
# Timing #
##########

create_clock -period 10.000  -name sys_clk  [get_ports sys_clk_i]
create_clock -period 100.000 -name jtag_tck [get_ports jtag_tck_i]
create_clock -period 20.000  -name hb_rwds  [get_ports hb_rwds_io]

set soc_clk  [get_clocks -of_objects [get_pins i_mmcm/CLKOUT0]]
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
set qspi_outputs [get_ports {flash_cs_no flash_dq_io[*] sd_sck_o sd_cmd_o sd_cs_no spi2_cs_no spi2_mosi_o spi2_sck_o}]
set qspi_inputs  [get_ports {flash_dq_io[*] sd_dat0_i spi2_miso_i}]

set_output_delay -clock $soc_clk -max  3.000 $qspi_outputs
set_output_delay -clock $soc_clk -min -3.000 $qspi_outputs

set_multicycle_path -setup 2 -to $qspi_outputs
set_multicycle_path -hold  1 -to $qspi_outputs

set_input_delay  -clock $soc_clk -max  8.000 $qspi_inputs
set_input_delay  -clock $soc_clk -min  1.000 $qspi_inputs

# HyperBus
set_max_delay -datapath_only 20.000 -from $rwds_clk -to $soc_clk
set_max_delay -datapath_only 20.000 -from $soc_clk  -to $rwds_clk

set_false_path -from [get_ports {hb_dq_io[*] hb_rwds_io}]
set_false_path -to   [get_ports {hb_dq_io[*] hb_rwds_io hb_ck_o hb_cs_no[*] hb_reset_no}]

# Asynchronous I/O
set_false_path -from [get_ports {cpu_rst_ni boot_sel_i[*] uart_rx_i gpio_a_io[*] sd_dat12_i[*]}]
set_false_path -from [get_ports {harness_rst_ni harness_boot_sel_i[*]}]
set_false_path -to   [get_ports {uart_tx_o gpio_a_io[*] led_o[*] set_vadj_o[*] vadj_en_o sd_reset_o}]
set_false_path -to   [get_ports harness_heartbeat_o]

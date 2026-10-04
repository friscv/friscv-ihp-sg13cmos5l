# Copyright 2026 FER, HPC Architecture and Application Research Center
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

set target $::env(TARGET_DIR)
set outdir $::env(OUTDIR)
set top    $::env(TOP)
set part   $::env(PART)

file mkdir $outdir/reports

set incdirs {}
set defines {}
set files   {}
set fh [open $::env(FLIST)]
foreach line [split [read $fh] "\n"] {
    set line [string trim $line]
    if {$line eq ""} continue
    if {[string match "+incdir+*" $line]} {
        lappend incdirs [string range $line 8 end]
    } elseif {[string match "+define+*" $line]} {
        lappend defines [string range $line 8 end]
    } else {
        lappend files $line
    }
}
close $fh

set headers {}
foreach d $incdirs {
    foreach h [glob -nocomplain -directory $d */*.svh *.svh] {
        lappend headers $h
    }
}

create_project -in_memory -part $part
set_property XPM_LIBRARIES {XPM_MEMORY} [current_project]
set_property include_dirs $incdirs [current_fileset]
set_property verilog_define $defines [current_fileset]

read_verilog -sv $files
if {[llength $headers]} {
    read_verilog -sv $headers
    set_property file_type {Verilog Header} [get_files $headers]
    set_property is_global_include true [get_files $headers]
}

source $::env(VERNII_CDC)
read_xdc -unmanaged $target/constraints/$top.xdc

set synth_top      $top
set synth_generics [list -generic SocFreqMHz=$::env(SOC_FREQ_MHZ)]
if {[file exists $target/vivado/board.tcl]} { source $target/vivado/board.tcl }

synth_design -top $synth_top -part $part {*}$synth_generics

set slow_clk_nets [get_nets -quiet -of_objects [get_pins -quiet -of_objects \
    [get_cells -quiet -of_objects [get_nets -quiet -of_objects [get_ports jtag_tck_i]]] \
    -filter {DIRECTION == OUT}]]
foreach dly [get_cells -quiet -hier -filter {REF_NAME == IDELAYE2}] {
    lappend slow_clk_nets [get_nets -of_objects [get_pins $dly/DATAOUT]]
}
if {[llength $slow_clk_nets]} {
    set_property CLOCK_DEDICATED_ROUTE FALSE $slow_clk_nets
}

write_checkpoint -force $outdir/post_synth.dcp
report_utilization -file $outdir/reports/synth_util.rpt
if {$::env(STAGE) eq "synth"} { exit 0 }

opt_design
place_design
phys_opt_design
route_design

write_checkpoint -force $outdir/post_route.dcp
report_utilization    -file $outdir/reports/util.rpt
report_timing_summary -report_unconstrained -file $outdir/reports/timing.rpt
report_drc            -file $outdir/reports/drc.rpt

check_timing -file $outdir/reports/check_timing.rpt
report_cdc -details  -file $outdir/reports/cdc.rpt

set cdc_crit "n/a"
catch { set cdc_crit [llength [get_cdc_violations -quiet -severity Critical]] }

set unconstrained_pins "n/a"
if {![catch {set fh [open $outdir/reports/check_timing.rpt]}]} {
    set txt [read $fh]
    close $fh
    if {[regexp {There are (\d+) pins that are not constrained for maximum delay} $txt -> n]} {
        set unconstrained_pins $n
    }
}

set wns [get_property SLACK [get_timing_paths -delay_type max]]
set whs [get_property SLACK [get_timing_paths -delay_type min]]
set met [expr {$wns >= 0 && $whs >= 0}]

set fh [open $outdir/reports/summary.txt w]
puts $fh "part $part  freq $::env(SOC_FREQ_MHZ) MHz"
puts $fh "WNS $wns  WHS $whs  [expr {$met ? {MET} : {VIOLATED}}]"
puts $fh "unconstrained max-delay pins $unconstrained_pins  critical CDC violations $cdc_crit"
close $fh

if {$unconstrained_pins ne "n/a" && $unconstrained_pins > 0} {
    send_msg_id {FRISCV 1-2} {CRITICAL WARNING} "$unconstrained_pins pins have no maximum delay constraint, the WNS below does not cover them. See reports/check_timing.rpt."
}
if {$cdc_crit ne "n/a" && $cdc_crit > 0} {
    send_msg_id {FRISCV 1-3} {CRITICAL WARNING} "$cdc_crit critical CDC violations. See reports/cdc.rpt."
}

if {$::env(STAGE) eq "bitstream"} { write_bitstream -force $outdir/$top.bit }

puts "WNS $wns  WHS $whs  [expr {$met ? {TIMING MET} : {TIMING VIOLATED}}]"
if {!$met} { exit 1 }

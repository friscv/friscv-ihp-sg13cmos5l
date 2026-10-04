REPO_ROOT := $(abspath ../../..)
COMMON    := $(REPO_ROOT)/target/xilinx/common
BUILD     ?= build
VIVADO    ?= vivado

SOC_FREQ_MHZ ?= 50

VERNII := $(shell bender -d $(REPO_ROOT) path vernii)
HB_DIR := $(REPO_ROOT)/hw/vendored/pulp_hyperbus

BIT   := $(BUILD)/$(TOP).bit
FLIST := sources.f

VIV_ENV = TARGET_DIR=$(CURDIR) OUTDIR=$(CURDIR)/$(BUILD) FLIST=$(CURDIR)/$(FLIST) \
	  PART=$(PART) TOP=$(TOP) SOC_FREQ_MHZ=$(SOC_FREQ_MHZ) \
	  VERNII_CDC=$(VERNII)/constraints/vernii_soc_cdc.tcl

.PHONY: all
all: bitstream

# Xilinx delay line replaces stub
$(FLIST): $(REPO_ROOT)/Bender.yml $(REPO_ROOT)/Bender.lock $(wildcard src/*.sv)
	bender -d $(REPO_ROOT) script flist-plus -t rtl -t synthesis -t fpga -t xilinx \
		-t tech_cells_generic_include_tc_sync > $@
	sed -i '\|/opentitan_peripherals-[^/]*/src/spi_host/rtl/|d' $@
	sed -i '\|/obi_peripherals-[^/]*/hw/obi_uart/|d' $@
	sed -i '\|/tech_cells_generic-[^/]*/src/fpga/tc_sram_xilinx\.sv$$|d' $@
	sed -i '\|/friscv-[^/]*/target/xilinx/|d' $@
	sed -i '\|/hw/configurable_delay\.sv$$|d' $@
	sed -i '\|/pulp_hyperbus/src/hyperbus_delay\.sv$$|d' $@
	echo "+define+FPGA_EMUL" >> $@
	echo "$(HB_DIR)/target/xilinx/hyperbus_clk_delay.sv" >> $@
	echo "$(HB_DIR)/target/xilinx/hyperbus_rwds_delay.sv" >> $@
	echo "$(VERNII)/target/xilinx/pynq-z2/src/tc_sram.sv" >> $@
	echo "$(CURDIR)/src/$(TOP).sv" >> $@

$(BUILD):
	mkdir -p $@

DEPS := $(FLIST) $(wildcard src/*.sv src/*.v vivado/*.tcl) constraints/$(TOP).xdc \
	$(COMMON)/build.tcl

.PHONY: synth impl bitstream
synth impl bitstream: $(DEPS) | $(BUILD)
	$(VIV_ENV) STAGE=$@ $(VIVADO) -mode batch -notrace -nojournal \
		-log $(BUILD)/vivado_$@.log -source $(COMMON)/build.tcl

.PHONY: program
program:
	scripts/program.sh $(BIT)

.PHONY: report
report:
	@cat $(BUILD)/reports/summary.txt
	@grep -E '^\| +(Slice LUTs|Slice Registers|Block RAM Tile|DSPs|Bonded IOB) ' \
		$(BUILD)/reports/util.rpt

.PHONY: clean
clean:
	rm -rf $(BUILD) $(FLIST) .Xil .gen .srcs NA clockInfo.txt tight_setup_hold_pins.txt

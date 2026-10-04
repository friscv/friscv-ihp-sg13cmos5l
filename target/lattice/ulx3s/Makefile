BUILD   ?= build
DEVICE  ?= 12k
PACKAGE ?= CABGA381
TOP     := ulx3s_spi_bridge

BIT := $(BUILD)/$(TOP).bit

.PHONY: all
all: $(BIT)

$(BUILD):
	mkdir -p $@

$(BUILD)/$(TOP).json: src/$(TOP).sv | $(BUILD)
	yosys -q -p "read_verilog -sv $<; synth_ecp5 -top $(TOP) -json $@"

$(BUILD)/$(TOP).config: $(BUILD)/$(TOP).json constraints/$(TOP).lpf
	nextpnr-ecp5 -q --$(DEVICE) --package $(PACKAGE) --json $< --lpf constraints/$(TOP).lpf --textcfg $@

$(BIT): $(BUILD)/$(TOP).config
	ecppack --compress $< $@

# Into SRAM over the US1 port, ULX3S flash not used
.PHONY: program
program: $(BIT)
	openFPGALoader -b ulx3s $(BIT)

# FLASH_IMAGE from mkflash.py at offset 0
.PHONY: flash
flash: $(BIT)
	@test -n "$(FLASH_IMAGE)" || { echo "set FLASH_IMAGE=<image.bin>" >&2; exit 1; }
	openFPGALoader -b ulx3s -f -o 0 --verify --skip-reset --file-type bin $(FLASH_IMAGE)
	openFPGALoader -b ulx3s $(BIT)

.PHONY: clean
clean:
	rm -rf $(BUILD)

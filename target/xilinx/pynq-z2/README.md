# PYNQ-Z2

`RVSoC9108_pynq_z2` runs `chip_soc` with the chip's parameters on a TUL PYNQ-Z2, for JTAG and peripheral testing. The SPI flash and SD card are wired from the Raspberry Pi header. There is no HyperRAM.

## Hardware

| Pad | Board | Notes |
| --- | ----- | ----- |
| `clk` | PS FCLK0 | 50 MHz |
| `rst_n` | BTN0 | |
| `heartbeat` | LD0 | ~2.7 s period |
| `boot[1:0]` | SW1, SW0 | `00` park for JTAG, `01` SPI flash, `1x` UART |
| `uart0_tx/rx` | RPi GPIO14 (pin 8), GPIO15 (pin 10) | 115200 8N1 when `clk` is 50 MHz |
| `jtag_*` | RPi TCK GPIO24 (18), TMS GPIO23 (16), TDI GPIO18 (12), TDO GPIO25 (22), TRST# GPIO22 (15) | |
| `qspi0` SCK, MOSI, MISO | RPi GPIO11 (23), GPIO10 (19), GPIO9 (21) | |
| `qspi0` CS0, CS1, CS2 | RPi GPIO8 (24), GPIO16 (36), GPIO20 (38) | Flash, SD card, spare |
| `gpio_a[7:0]` | PMODB, JB1-JB4 and JB7-JB10 | No pulls |

LD2 lights while the SoC is held in reset, LD3 once the PS has released the PL.

### HyperBus

Nothing answers on HyperBus, reads deadlock and writes are silently ignored.

### SD card

SDHC or SDXC only, SDBL addresses blocks. Tested with SanDisk SDHC and Kingston SDXC.

## Build

Needs the PYNQ-Z2 board files (`tul.com.tw:pynq-z2:part0:1.0`) on Vivado's board repository path, and xsct for programming.

```bash
make bitstream
make report
make program
```

## Boot

### UART

```bash
../common/uartboot.py /dev/ttyUSB0 stage.bin   # SW1 up, then BTN0
```

### JTAG

With SW1:SW0 at `00` the ROM parks for the debug module:

```bash
openocd -f interface/<adapter>.cfg -f ../common/openocd.cfg
```

### Flash

A 4 KiB stage at offset 0, with SW1:SW0 at `01`, then BTN0.

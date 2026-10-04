# Nexys Video

`RVSoC9108_nexys_video` runs `chip_soc` with the chip's parameters on a Digilent Nexys Video.

## Hardware

| Pad | Board | Notes |
| --- | ----- | ----- |
| `clk` | 100 MHz oscillator through an MMCM | 50 MHz |
| `rst_n` | CPU_RESET | Held for 42 ms after configuration while VADJ comes up |
| `heartbeat` | LD0 | ~2.7 s period |
| `boot[1:0]` | SW1, SW0 | `00` park for JTAG, `01` QSPI flash, `1x` UART |
| `uart0_tx/rx` | USB-UART | 115200 8N1 at 50 MHz |
| `jtag_*` | Pmod JC: TCK JC1, TDI JC2, TDO JC3, TMS JC4, TRST# JC7 | |
| `qspi0` CS0 | On-board S25FL256S | |
| `qspi0` CS1 | microSD | SCK on CCLK, MOSI on CMD, MISO on DAT0, CS on DAT3 |
| `qspi0` CS2 | Pmod JA: CS JA1, MOSI JA2, MISO JA3, SCK JA4 | Spare |
| `gpio_a[7:0]` | Pmod JB, JB1-JB4 and JB7-JB10 | No pulls |
| `hb_*` | FMC LPC, PHY of the HyperRAM board | CS0 to U7, CS1 to U8 |

LD2 lights while the SoC is held in reset, LD3 once VADJ is up.

### Jumpers

Set the MODE jumper to JTAG. The flash holds program data only.

## Build

Vivado needs Artix-7 device support installed.

```bash
make bitstream
make report
make program
```

## Boot

### UART

```bash
../common/uartboot.py /dev/ttyUSB0 stage.bin   # SW1 up, then CPU_RESET
```

The ROM sends `V`, reads 4 KiB into OCM and jumps to it.

### JTAG

With SW1:SW0 at `00` the ROM parks for the debug module:

```bash
openocd -f interface/<adapter>.cfg -f ../common/openocd.cfg
```

### Flash

```bash
python3 $(bender path vernii)/sw/sdk/tools/mkflash.py fsbl.bin payload.bin flash.bin
```

With `flash.bin` at offset 0, set SW1:SW0 to `01` and press CPU_RESET. The FSBL copies the payload to HyperRAM at `0x8000_0000` and jumps to it.

### SD card

Put SDBL in flash as the stage, and the payload on an SDHC or SDXC card. SDSC cards do not work.

```bash
python3 $(bender path vernii)/sw/sdk/tools/mkflash.py sdbl.bin /dev/null flash.bin
python3 $(bender path vernii)/sw/sdk/tools/mksdimg.py payload.bin sd.img
sudo dd if=sd.img of=/dev/sdX bs=512 conv=fsync
```

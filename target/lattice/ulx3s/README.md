# ULX3S

`ulx3s_spi_bridge` makes a Radiona ULX3S stand in for the board's QSPI0 bus. Its configuration flash answers on CS0 and the microSD slot on CS1. The PYNQ-Z2 target reaches it through jumpers. This bridge is mostly wires inside the FPGA.

## Wiring

Six wires from the PYNQ-Z2 Raspberry Pi header to ULX3S J1 are needed. Rows are counted from J1's power end. Each signal works on either pin of its row.

| J1 row | J1 pair | Signal | PYNQ RPi pin |
| ------ | ------- | ------ | ------------ |
| 1 | | 3.3 V out | not connected |
| 2 | | GND | 25 |
| 3 | GP0/GN0 | SCK | 23 |
| 4 | GP1/GN1 | MOSI | 19 |
| 5 | GP2/GN2 | CS1, microSD | 36 |
| 6 | GP3/GN3 | MISO | 21 |
| 7 | GP4/GN4 | CS0, flash | 24 |

Keep the wires short and run GND next to SCK.

## Build and load

```bash
make
make program
make flash FLASH_IMAGE=flash.bin
```

`make flash` writes where the chip's boot ROM reads its stage. This replaces the ULX3S's own startup bitstream. Restore it with `openFPGALoader -b ulx3s --write-flash <bitstream>`.

The flash is an ISSI part with linear addressing (ID `9d 60 16`), images from `mkflash.py` work without changes.

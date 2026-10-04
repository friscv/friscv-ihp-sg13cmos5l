#!/usr/bin/env python3
# Copyright 2026 FER, HPC Architecture and Application Research Center
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
#
# Emil Popovic <mail@emilpopovic.me>

import os
import sys
import termios
import tty

STAGE_BYTES = 0x1000
BANNER = 0x56


def open_port(path):
    fd = os.open(path, os.O_RDWR | os.O_NOCTTY)
    tty.setraw(fd)

    attrs = termios.tcgetattr(fd)
    attrs[2] = (attrs[2] & ~termios.CRTSCTS) | termios.CLOCAL | termios.CREAD
    attrs[4] = attrs[5] = termios.B115200
    termios.tcsetattr(fd, termios.TCSANOW, attrs)
    termios.tcflush(fd, termios.TCIOFLUSH)

    return fd


def main():
    if len(sys.argv) != 3:
        raise SystemExit("usage: uartboot.py <tty> <stage.bin>")

    port, stage_path = sys.argv[1:]

    stage = open(stage_path, "rb").read()

    if len(stage) > STAGE_BYTES:
        raise SystemExit(f"stage is {len(stage)} bytes, ROM reads {STAGE_BYTES}")

    stage = stage.ljust(STAGE_BYTES, b"\0")
    fd = open_port(port)

    print(f"{port}: waiting for the banner, reset the SoC", file=sys.stderr)

    while os.read(fd, 1) != bytes([BANNER]):
        pass

    sent = 0
    while sent < len(stage):
        sent += os.write(fd, stage[sent:])

    termios.tcdrain(fd)
    print(f"{port}: {len(stage)} B sent", file=sys.stderr)

    try:
        while True:
            sys.stdout.buffer.write(os.read(fd, 256))
            sys.stdout.buffer.flush()
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()

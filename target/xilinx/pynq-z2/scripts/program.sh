#!/usr/bin/env bash
# Copyright 2026 FER, HPC Architecture and Application Research Center
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
#
# Emil Popovic <mail@emilpopovic.me>

# Set JP1 to JTAG, then:
#   scripts/program.sh            # program build/RVSoC9108_pynq_z2.bit
#   scripts/program.sh other.bit  # program another bitstream
# Must have Vitis installed for XSCT

set -euo pipefail
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$HERE/.."

BIT=${1:-build/RVSoC9108_pynq_z2.bit}

[ -f "$BIT" ] || {
    echo "no bitstream at $BIT, run 'make bitstream' first" >&2
    exit 1
}
BIT=$(cd "$(dirname "$BIT")" && pwd)/$(basename "$BIT")

if [ -z "${PS7_INIT:-}" ]; then
    PS7_INIT=$(find .gen -name ps7_init.tcl -print -quit 2>/dev/null || true)
fi

[ -n "$PS7_INIT" ] && [ -f "$PS7_INIT" ] || {
    echo "no ps7_init.tcl; it comes from the build, so run 'make bitstream' first" >&2
    exit 1
}
PS7_INIT=$(cd "$(dirname "$PS7_INIT")" && pwd)/$(basename "$PS7_INIT")

if [ -z "${XSCT:-}" ]; then
    if command -v xsct >/dev/null 2>&1; then
        XSCT=xsct
    else
        XSCT=$(ls -d /tools/Xilinx/*/Vitis/bin/xsct /opt/Xilinx/*/Vitis/bin/xsct \
               2>/dev/null | sort -V | tail -1 || true)
    fi
fi

[ -n "$XSCT" ] || {
    echo "xsct not found; source a Vitis settings64.sh or set XSCT" >&2
    exit 1
}

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

{
    if [ -n "${JTAG_URL:-}" ]; then
        echo "connect -url ${JTAG_URL}"
    else
        echo "connect"
    fi

    echo 'targets -set -filter {name =~ "APU*"}'

    if [ "${NO_RESET:-0}" != 1 ]; then
        echo 'rst -system'
        echo 'after 3000'
    fi

    echo "source {$PS7_INIT}"
    echo 'ps7_init'
    echo "fpga -file {$BIT}"
    echo 'ps7_post_config'
    echo 'puts "friscv-program-ok"'
} > "$work/program.tcl"

echo "programming $BIT"

"$XSCT" "$work/program.tcl" 2>&1 | tee "$work/log"

grep -q friscv-program-ok "$work/log" || {
    echo "programming failed, see the log above" >&2
    exit 1
}

cat <<'EOF'

programmed.
EOF

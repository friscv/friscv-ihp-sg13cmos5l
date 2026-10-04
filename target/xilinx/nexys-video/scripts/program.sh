#!/usr/bin/env bash
# Copyright 2026 FER, HPC Architecture and Application Research Center
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

# Set the MODE jumper to JTAG, then:
#   scripts/program.sh
#   scripts/program.sh other.bit

set -euo pipefail
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$HERE/.."

BIT=${1:-build/RVSoC9108_nexys_video.bit}

[ -f "$BIT" ] || {
    echo "no bitstream at $BIT, run 'make bitstream' first" >&2
    exit 1
}
BIT=$(cd "$(dirname "$BIT")" && pwd)/$(basename "$BIT")

if [ -z "${VIVADO:-}" ]; then
    if command -v vivado >/dev/null 2>&1; then
        VIVADO=vivado
    else
        VIVADO=$(ls -d /tools/Xilinx/*/Vivado/bin/vivado /opt/Xilinx/*/Vivado/bin/vivado \
                 /tools/Xilinx/Vivado/*/bin/vivado 2>/dev/null | sort -V | tail -1 || true)
    fi
fi

[ -n "$VIVADO" ] || {
    echo "vivado not found; source a Vivado settings64.sh or set VIVADO" >&2
    exit 1
}

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

{
    echo 'open_hw_manager'
    if [ -n "${HW_SERVER:-}" ]; then
        echo "connect_hw_server -url ${HW_SERVER}"
    else
        echo 'connect_hw_server'
    fi

    cat <<'EOF'
set dev {}
foreach t [get_hw_targets] {
    open_hw_target $t
    set dev [lindex [get_hw_devices -quiet xc7a200t*] 0]
    if {$dev ne {}} break
    close_hw_target $t
}
if {$dev eq {}} { error "no xc7a200t on any JTAG cable" }
current_hw_device $dev
EOF

    echo "set_property PROGRAM.FILE {$BIT} \$dev"
    echo 'program_hw_devices $dev'
    echo 'puts "friscv-program-ok"'
} > "$work/program.tcl"

echo "programming $BIT"

"$VIVADO" -mode batch -nojournal -nolog -notrace -source "$work/program.tcl" 2>&1 | tee "$work/log"

grep -q friscv-program-ok "$work/log" || {
    echo "programming failed, see the log above" >&2
    exit 1
}

cat <<'EOF'

programmed.
EOF

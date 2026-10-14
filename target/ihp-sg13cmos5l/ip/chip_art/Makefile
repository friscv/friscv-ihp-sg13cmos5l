CELLS = art_qr art_fer_hpc art_initials art_sahovnica

PIXEL_SIZE = 0.5

LAYERS = --foreground "50/0" --boundary "189/4" "8/23" "10/23" "30/23" "50/23" "126/23"

CHIP_ART_FONT ?= DejaVuSans-Bold.ttf

gds: $(CELLS:%=gds/%.gds)
.PHONY: gds

gds/%.gds: image/%.png script/make_gds.py
	python3 script/make_gds.py $< $@ --cellname $* --invert --merge --pixel-size $(PIXEL_SIZE) $(LAYERS)

drc: $(CELLS:%=gds/%.gds)
	rm -rf drc_run
	for c in $(CELLS); do \
		mkdir -p drc_run/$$c; \
		python3 ${PDK_ROOT}/${PDK}/libs.tech/klayout/tech/drc/run_drc.py --run_mode=deep --mp=8 --topcell=$$c \
			--precheck_drc --disable_extra_rules --path=gds/$$c.gds --run_dir=drc_run/$$c > drc_run/$$c/out.txt 2>&1; \
		echo "$$c: $$(grep -h -o 'Violated rules are : .*' drc_run/$$c/drc_run_*.log || echo clean)"; \
	done
.PHONY: drc

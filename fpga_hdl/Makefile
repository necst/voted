# --- Generic XSim flow (compile -> elaborate -> run) ---
# Usage examples:
#   make sim TOP_TB=tb_example_and_gate RTL="example_and_gate.v" TB="testbench/tb_example_and_gate.v"
#   make sim TOP_TB=tb_krnl_and RTL="example_and_gate.v krnl_and.v" TB="testbench/tb_krnl_and.v"
#
# Notes:
# - RTL and TB are space-separated file lists/paths relative to project root.
# - TOP_TB must match the Verilog module name of the testbench top.

BUILD ?= build

TOP_TB ?=
RTL    ?=
TB     ?=

SNAP   := $(TOP_TB)_sim

RTL_IN_BUILD := $(addprefix ../,$(RTL))
TB_IN_BUILD  := $(addprefix ../,$(TB))

.PHONY: sim compile elab run clean check

# Ensure user passed required variables
check:
	@if [ -z "$(TOP_TB)" ]; then echo "ERROR: TOP_TB is required"; exit 1; fi
	@if [ -z "$(RTL)" ]; then echo "ERROR: RTL is required (e.g., RTL=\"a.v b.v\")"; exit 1; fi
	@if [ -z "$(TB)"  ]; then echo "ERROR: TB is required (e.g., TB=\"testbench/tb.v\")"; exit 1; fi

# High-level target: compile + elaborate + run
sim: run
	@echo "Simulation finished. Logs and outputs are under $(BUILD)/"

# Create the build directory if it does not exist
$(BUILD):
	mkdir -p $(BUILD)

# xvlog target: compile RTL and TB into the simulation compile database
compile: $(BUILD)/xvlog.ok

$(BUILD)/xvlog.ok: check | $(BUILD)
	# Compile sources into the XSim work library (artifacts go under build/)
	cd $(BUILD) && xvlog -sv -nolog $(RTL_IN_BUILD) $(TB_IN_BUILD) -log xvlog.log
	@touch $(BUILD)/xvlog.ok

# xelab target: elaborate the design and create a simulation snapshot
elab: $(BUILD)/xelab.ok

$(BUILD)/xelab.ok: $(BUILD)/xvlog.ok
	# Elaborate top testbench and create snapshot "$(SNAP)"
	cd $(BUILD) && xelab -nolog -debug typical $(TOP_TB) -s $(SNAP) -log xelab.log
	@touch $(BUILD)/xelab.ok

# xsim target: run the simulation snapshot in batch mode (run all, then quit)
run: $(BUILD)/xsim.ok

$(BUILD)/xsim.ok: $(BUILD)/xelab.ok
	# Run simulation in batch mode
	cd $(BUILD) && printf "run all\nquit\n" | xsim -nolog $(SNAP) -log xsim.log
	@touch $(BUILD)/xsim.ok

# ------------------------------------------------------------
# Vitis/Vivado RTL kernel packaging -> .xo
# Usage:
#   make xo RTL="example_and_gate.v krnl_and.v"
#   make xo RTL="..." KERNEL_NAME=krnl_and PART=...
# Output:
#   build/krnl_and.xo
# ------------------------------------------------------------

KERNEL_NAME ?= krnl_and
PART=xcu55c-fsvh2892-2L-e

XO     := $(BUILD)/$(KERNEL_NAME).xo
IP_DIR := $(BUILD)/$(KERNEL_NAME)_ip

KERNEL_IF ?= axilite   # axilite | axis

PACK_TCL_AXILITE := scripts/pack_xo.tcl
PACK_TCL_AXIS    := scripts/pack_xo_axis.tcl

PACK_TCL := $(PACK_TCL_AXILITE)
ifeq ($(KERNEL_IF),axis)
PACK_TCL := $(PACK_TCL_AXIS)
endif

.PHONY: xo
xo: $(XO)

$(XO): $(PACK_TCL) | $(BUILD)
	@mkdir -p $(IP_DIR)
	vivado -mode batch -nolog -nojournal -notrace \
	  -source $(PACK_TCL) \
	  -tclargs "$(PART)" "$(KERNEL_NAME)" "$(XO)" "$(IP_DIR)" $(RTL)


# Remove all generated files.
clean:
	rm -rf \
	  $(BUILD) \
	  _vivado_* \
	  xsim.dir \
	  .Xil \
	  *.jou *.log *.str \
	  xvlog.pb xvlog.jou \
	  xelab.pb xelab.jou \
	  xsim.jou \
	  webtalk*.jou webtalk*.log webtalk*.xml


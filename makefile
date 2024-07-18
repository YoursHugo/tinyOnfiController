# Makefile for compiling and running Verilog modules

# Variables
MODULE ?= top_module
VERILOG_FILES = ./src/$(MODULE).v ./test/tb_$(MODULE).v
SIMULATION_FILES = ./build/$(MODULE).vvp
WAVEFORM_FILE = ./build/$(MODULE).vcd

# Compiler and simulator
IVERILOG = iverilog
VVP = vvp

all: compile run view

compile:
	$(IVERILOG) -o $(SIMULATION_FILES) $(VERILOG_FILES)

run:
	$(VVP) $(SIMULATION_FILES)

view:
	gtkwave $(WAVEFORM_FILE)

# Clean target
clean:
	rm -f ./build/*.vvp ./build/*.vcd

.PHONY: all compile run clean

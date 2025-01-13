REPO_ROOT ?= $(shell git rev-parse --show-toplevel)

BASEJUMP_STL_DIR=$(REPO_ROOT)/hw1/basejump_stl
VERILOG_UART_DIR=$(REPO_ROOT)/hw1/verilog-uart
CVFPU_DIR=$(REPO_ROOT)/hw1/cvfpu

PCF_PATH = $(REPO_ROOT)/hw1/UART.pcf

synth build/uart.asc build/uart.bin:
	# if build folder doesn't exist, create it
	mkdir -p build
	# synthesize using Yosys
	yosys -p "synth_ice40 -top top -blif build/uart.blif -json build/uart.json" top.sv dff.sv pll.sv inv.sv $(VERILOG_UART_DIR)/rtl/uart_tx.v $(VERILOG_UART_DIR)/rtl/uart_rx.v
	# Place and route using nextpnr
	nextpnr-ice40 --up5k --json build/uart.json --pcf UART.pcf --asc build/uart.asc
	# Convert to bitstream using IcePack
	icepack build/uart.asc build/uart.bin

lint:
	verilator --lint-only -I$(BASEJUMP_STL_DIR)/bsg_misc/ -I$(VERILOG_UART_DIR)/rtl -Wall top.sv dff.sv inv.sv pll.sv
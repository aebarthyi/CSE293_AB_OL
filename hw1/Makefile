REPO_ROOT ?= $(shell git rev-parse --show-toplevel)

BASEJUMP_STL_DIR=$(REPO_ROOT)/hw1/basejump_stl
VERILOG_UART_DIR=$(REPO_ROOT)/hw1/verilog-uart
CVFPU_DIR=$(REPO_ROOT)/hw1/cvfpu

PCF_PATH = $(REPO_ROOT)/hw1/UART.pcf

lint:
	verilator --lint-only "-I $(BASEJUMP_STL_DIR)/bsg_misc/ $(VERILOG_UART_DIR)/rtl" -Wall top.sv dff.sv inv.sv pll.sv
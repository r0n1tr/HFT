# Get the filename from the command line (default to 'spread' if not provided)
NAME ?= spread

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# Use the NAME variable to set the file paths and module names
VERILOG_SOURCES += $(PWD)/wrappers/$(NAME)_wrapper.sv
# use VHDL_SOURCES for VHDL files

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = $(NAME)_wrapper

# MODULE is the basename of the Python test file
MODULE = $(NAME)_tb

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

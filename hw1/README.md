
# Homework 1 -- UART ALU

Due Date 1/24/2025. Groups of 1-2 allowed.

In this assignment, you will implement an ALU controlled via UART. This project builds essential infrastructure for future coursework and potential projects, as FPGA-to-PC communication is a vital skill. While challenging, this assignment introduces critical concepts and practical techniques.

You may use third-party IPs for this project, such as:

* UART: <https://github.com/alexforencich/verilog-uart>
* Integer Multiplier: <https://github.com/bespoke-silicon-group/basejump_stl/blob/master/bsg_misc/bsg_imul_iterative.sv>
* Integer Divider: <https://github.com/bespoke-silicon-group/basejump_stl/blob/master/bsg_misc/bsg_idiv_iterative.sv>
* Floating Point IP: <https://github.com/openhwgroup/cvfpu>

You are welcome to use different IP, but the rest of this assignment description will assume you are using this IP. You are also welcome to implement everything from scratch, but I would first try to get it working with the provided IP. If you deviate from the provided instructions, document these changes in your lab report.

## Submission Details

Submit your lab report as a PDF on Gradescope. Your report should include:

* A link to your GitHub repository.
* Answers to all bolded questions in this document.
* Screenshots and documentation as specified in each section.

Additionally, you must complete an in-person checkoff to validate your implementation.

## Disclaimer

This assignment has not been tested thoroughly. You will encounter bugs, typos, and missing steps. It is a part of the assignment to figure out what is missing.

Also, small details are allowed to be changed. You may differ slightly from the recommended procedure, languages, tools, endianness etc. However, if you stray from the assignment description, please note it in your project report.

## Setup

Use a GitHub repository for all project files. It can be public or private.

Any third-party IP should be added via Git Submodules like so:

```bash
git submodule add git@github.com:bespoke-silicon-group/basejump_stl.git third_party/basejump_stl
git submodule add git@github.com:alexforencich/verilog-uart.git third_party/alexforencich_uart
git submodule add git@github.com:openhwgroup/cvfpu.git third_party/fpnew
```

I recommend the following file structure:

```
- dv
    - dv.f
    - dv_pkg.sv
    - tb.sv
    - ...
- rtl
    - rtl.f
    - top.sv
    - alu.sv
    - ...
- synth
    - icebreaker_icestorm
        - gls.f
        - yosys.tcl
        - nextpnr.pcf
        - icebreaker.v
        - ...
- third_party
    - alexforencich_uart
    - basejump_stl
    - fpnew
    - ...
- Makefile
- README.md
- ...
```

If you are feeling stuck, feel free to take a look at this provided Verilog Template project: <https://github.com/sifferman/verilog_template>. However, the more you set up on your own, the more comfortable you will become with debugging tools.

## Step 1 -- UART Echo

In this step, you should get a basic example of UART working.

1. Instantiate a [`uart_rx`](https://github.com/alexforencich/verilog-uart/blob/master/rtl/uart_rx.v) and a [`uart_tx`](https://github.com/alexforencich/verilog-uart/blob/master/rtl/uart_tx.v) module. Connect the AXIS interfaces directly into each other so the design just echos back the data it receives. Data should be sent 8 bits per frame.

2. Create and run a basic testbench that verifies your design is connected correctly. You may use any simulator you like, but Verilator is recommended.

3. **Take a screenshot of the waveform that verfies your UART modules are connected correctly.**

4. (Optional) run your SystemVerilog through [zachjs/sv2v](https://github.com/zachjs/sv2v) so that Yosys correctly interprets any SystemVerilog constructs you've used.

5. Create a top-level module for your FPGA board. You need to instantiate a PLL ([`SB_PLL40_PAD`](https://z80.ro/post/using_pll/)) to get the correct clock-frequency. You can use the application `icepll` to generate the parameters.

6. Create a Yosys TCL script that loads your Verilog files and synthesizes them for the iCE40 target ([`synth_ice40`](https://yosyshq.readthedocs.io/projects/yosys/en/latest/cmd/synth_ice40.html)). Be sure your script generates a synthesized `.json` and `.v` file with the following:

```tcl
write_json path/to/synthesized/netlist.json
write_verilog -noexpr -noattr -simple-lhs path/to/synthesized/netlist.v
```

7. Rerun your testbench, but now with `path/to/synthesized/netlist.v` instead of your RTL. You will also need to pass the iCE40 standard cells to your simulator: `` `yosys-config --datdir`/ice40/cells_sim.v ``. Verify your design is running at the desired baud-rate.

8. **Take a screenshot of the waveform that verfies your UART modules synthesized correctly.**

9. Assign the correct pins in a [`.pcf` file](https://github.com/YosysHQ/icestorm/blob/master/examples/icebreaker/icebreaker.pcf), set the clock frequencies in a [`.py` file](https://github.com/YosysHQ/nextpnr/blob/master/docs/constraints.md), and run `nextpnr-ice40` to generate a bitstream. You can find the FTDI UART `rx` and `tx` pins here: <https://github.com/icebreaker-fpga/icebreaker/blob/master/hardware/v1.0e/icebreaker-sch.pdf>.

10. Use [openFPGALoader](https://github.com/trabucayre/openFPGALoader) to program your FPGA board.

11. Test your design with a shell that can read and write COM ports. A popular one is `minicom`.

12. **Take a screenshot of your terminal where your design properly echos back received data.**

**In your report, describe any difficulties faced in this section.**

## Step 2 -- Packets Over UART

Now, ditch `minicom` and connect to the FPGA UART COM port with a Python script to communicate with the FPGA Baord's FTDI IC.

To give your design more functionality, you should now send data in structured packets. A packet is in the form:

| Frame        | Field          | Description                               |
|--------------|----------------|-------------------------------------------|
| 0            | Opcode         | Specifies the operation                   |
| 1            | Reserved       | Reserved for future use                   |
| 2            | Length (LSB)   | Least significant byte of the data length |
| 3            | Length (MSB)   | Most significant byte of the data length  |
| 4-(Length-1) | Data           | Data with specified length                |

Assign the `echo` operation an opcode and wrap it in a helper function: `echo(message)`.

Assuming your `echo` opcode is `0xec`, and you send the message `"Hi"`, this is the order of bytes to be sent:

| Opcode | Reserved | Length (LSB) | Length (MSB) | Data0  | Data1  |
|--------|----------|--------------|--------------|--------|--------|
| `0xec` | `0x00`   | `0x06`       | `0x00`       | `0x42` | `0x69` |

To help debug, you should have another thread to contantly print the data received from the COM port.

**In your report, describe any difficulties faced in this section.**

## Step 3 -- Sending Operations Over UART

Next, you should add support for the following:

* Add together a list of 32-bit integers.
* Multiply together a list of 32-bit signed integers.
* Divide two 32-bit signed integers.

You should write helper functions such as `add32(operands)`, `mul32(operands)`, and `div32(numerator, denominator)`.

Be aware of endianness. You may send the length and the data as either big-endian or little-endian.

**In your report, denote what opcodes you picked for each instruciton.**

**In your report, describe any difficulties faced in this section.**

## Step 4 -- ALU RTL

All RTL in this class must be written according to the [LowRISC Coding Style](https://github.com/lowRISC/style-guides/blob/master/VerilogCodingStyle.md). This means that all [suffixes](https://github.com/lowRISC/style-guides/blob/master/VerilogCodingStyle.md#suffixes) must be respected, (_i, _o, _d, _q, _t, _n, etc).

Write the RTL to implement the `echo`, `add32`, `mul32`, and `div32` operations.

You will receive the data from the `uart_rx` module, and after the computation has finished, return the result via the `uart_tx` module.

You will likely need a state machine to handle each operand. Be sure to follow the [LowRISC Coding Style for state machines](https://github.com/lowRISC/style-guides/blob/master/VerilogCodingStyle.md#finite-state-machines).

Also, you must create a testbench that uses fuzzing to run tests on 1000 random inputs for each operation. Your testbench should send data to the `rx` port with a `uart_tx` module, and should receive data from the `tx` port with a `uart_rx` module. You should also model the PLL by overriding the PLL output in the testbench.

**In your report, describe any difficulties faced in this section.**

## Step 5 -- Floating Point Support (Extra Credit)

For extra credit, you may add the following operations:

* Add together a list of 32-bit floats.
* Multiply together a list of 32-bit floats.

You may use any rounding mode.

**In your report, describe any difficulties faced in this section.**

## Checkoff

Checkoffs will be done in person during the scheduled-class time. Ensure the following:

* All instructions and operations are functional on the FPGA.
* Your code is organized and adheres to the specified coding style.

You will not receive credit for unorganized or incomplete submissions.

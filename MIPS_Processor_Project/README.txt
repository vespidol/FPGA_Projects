Final Project: MIPS-like Microprocessor
by: Victor Espidol

The objective of this project is to design, simulate, and implement a simple 
32-bit microprocessor with an instruction set that is similar to a MIPS.

Created the entities in VHDL for the datapath that interfaced with one another
to represent the structure of the processor.
The entities included:
- Program Counter (PC)
- Memory block (I/O and SRAM)
- Instruction Register
- Memory Data Register
- Register File
- ALU
- ALU Controller
- Registers
- Muxes
- other logic

This datapath was controlled by the Controller and Top Level Interface.
- The controller was implemented using a Finite State Machine to control the logic for driving
  the entities within the Datapath. The logic followed the instruction cycle of Fetch, Decode, Execute 
  to implement how the instructions would be interfaced with the datapath.
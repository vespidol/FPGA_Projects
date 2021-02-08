Final Project for Reconfigurable Computing:

For this project my partner and I implemented a 1-D Time-Domain Convolution using the Xilinx 7 Series
Zedboard. This project required utilizing knowledge of clock domain crossing, 2-process FSMs,
pipelines, smart buffers, and the DMA interface. The overall concept was to take in 
data from an input DRAM in a different clock domain, synchronize it with a slower clock
domain, put it through a convolution pipeline, and then output that data into another DRAM.
The project was done in two parts, the DRAM Read DMA Interface and the Convolution 
pipeline.

For the first part (DRAM Read DMA Interface) I created a structural entity called the,
"dram_rd_ram0" that instantiated a handshake synchronizer, a fifo, an address generator,
a few registers, and a counter. 

For the second part (Convolution Pipeline) my partner and I worked on a structural entity called
the, "user_app" that instantiated smart buffers for the kernel and signal (to allow for
higher throughput into the pipeline), the pipeline (a multiplier adder tree), a delay
entity to track the valid in/out data coming in and out of the pipeline, and some clipping logic.

The overall project was successful for general cases, but not edge cases.
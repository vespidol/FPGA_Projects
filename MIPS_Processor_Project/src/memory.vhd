library ieee;
use ieee.std_logic_1164.all;

entity memory is
	generic ( Width : positive := 32);
	port ( 
		clk				: in std_logic;
		rst				: in std_logic;
		address			: in std_logic_vector(Width-1 downto 0); 
		MemRead			: in std_logic;
		MemWrite		: in std_logic;
		Inport_en		: in std_logic;	--Enabled by Key(1) from FPGA
		InPort1or0_en	: in std_logic; --Enabled by SW(9) from FPGA
		InPort0			: in std_logic_vector(Width-1 downto 0);
		InPort1			: in std_logic_vector(Width-1 downto 0);
		RegB_in			: in std_logic_vector(Width-1 downto 0);
		Outport			: out std_logic_vector(Width-1 downto 0);
		read_data		: out std_logic_vector(Width-1 downto 0)
	);
end memory;

--Memory should be a structural architecture with Ram and I/OUT
--The Inports should not reset with the CPU
-- IN0 = at address FFF8
-- IN1 = at address FFFC
-- OUT = at address FFFC
-- Ram size is 256
-- 10th bit of InPort0/InPort1 determine which port is being used

architecture STR of memory is
	signal ram_addr		: std_logic_vector(7 downto 0);
	signal out_en		: std_logic;
	signal wren_en		: std_logic;
	signal Mux_sel		: std_logic_vector(1 downto 0);
	signal Ram_out		: std_logic_vector(Width-1 downto 0);
	signal In0_out		: std_logic_vector(Width-1 downto 0);
	signal In1_out		: std_logic_vector(Width-1 downto 0);
	signal InPort0_en 	: std_logic;
	signal InPort1_en 	: std_logic;
	
begin

	UUT_Decoder: entity work.decoder	--Use this to decode the address for either Inport0, Inport1, or the SRAM
		generic map ( Width => Width)
		port map (
			address		=> address,
		    Mem_write	=> MemWrite,
		    Mem_read	=> MemRead,
		    Out_en		=> out_en,
			wren_en		=> wren_en,
		    Mux_sel		=> Mux_sel,
		    addr_out	=> ram_addr
		);
	
	UUT_Mux : entity work.mux4x1	--MemoryOut
	generic map (Width => 32)
	port map (
		in1  	=>	Ram_out,		--SRAM
	    in2   	=>	In0_out, 		--InPort0
	    in3   	=>	In1_out,		--InPort1
	    in4   	=> (others => '0'),
	    sel   	=>	Mux_sel,
	    output	=>  read_data
	);
	
	
	UUT_RAM : entity work.ram -- 8-bits address 
		port map (
			address	=>	ram_addr,
			clock	=>	clk,
			data	=>	RegB_in,		--RegB allows you to write to data
			wren	=>	wren_en,		--Only high when MemWrite is high
		    q		=>	Ram_out
		);
	
	InPort0_en <= InPort_en AND (not InPort1or0_en); --Enable for Inport 0
	
	UUT_InPort0	: entity work.reg
	generic map (Width => 32)
	port map (
		clk  	=> clk,
	    rst   	=> '0',
	    load  	=> InPort0_en,
	    input 	=> InPort0,
	    output	=> In0_out
	);

	InPort1_en <= InPort_en AND InPort1or0_en; --Enable for Inport 1
	
	UUT_InPort1	: entity work.reg
	generic map (Width => 32)
	port map (
		clk  	=> clk,
	    rst   	=> '0',
	    load  	=> InPort1_en,
	    input 	=> InPort1,
	    output	=> In1_out
	);
	
	UUT_OutPort	: entity work.reg
	generic map (Width => 32)
	port map (
		clk  	=> clk,
	    rst   	=> rst,
	    load  	=> Out_en,
	    input 	=> RegB_in,
	    output	=> Outport
	);
	
end STR;
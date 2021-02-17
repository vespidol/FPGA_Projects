library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity top_level_tb is
end top_level_tb;

architecture TB of top_level_tb is

	signal MAX10_CLK1_50 : std_logic := '0';
	signal rst : std_logic := '0';
	signal Inport_en : std_logic := '0';
	signal Inport : std_logic_vector(9 downto 0) := (others => '0');
	signal Outport: std_logic_vector(31 downto 0); 
	signal done : std_logic := '0';
	
begin
	UUT_TopLevel: entity work.mips_architecture
		generic map (WIDTH => 32)
		port map(
			clk			=> MAX10_CLK1_50,
		    rst			=> rst,
		    Inport_en	=> Inport_en,
		    Inport		=> Inport,
		    Outport		=> Outport
		);
	
	MAX10_CLK1_50 <= not MAX10_CLK1_50 and not done after 40 ns;
	
	process
	begin
	
	rst <= '1';
	for i in 0 to 15 loop
		wait for 40 ns;
	end loop;
	
	Inport_en <='1';
	Inport(9) <='0';
	Inport(8 downto 0) <= std_logic_vector(to_unsigned(4, 9));
	
	rst <= '0';
	
	wait for 40 ns;
	Inport(9) <='1';
	Inport(8 downto 0) <= std_logic_vector(to_unsigned(20, 9));
	
	Inport_en <='1';
	wait for 400 ns;
	Inport(9) <='1';
	Inport(8 downto 0) <= std_logic_vector(to_unsigned(30, 9));
	
	
	wait for 400 ns;
	Inport(9) <='1';
	Inport(8 downto 0) <= std_logic_vector(to_unsigned(40, 9));
	
		wait for 400 ns;
	Inport(9) <='1';
	Inport(8 downto 0) <= std_logic_vector(to_unsigned(50, 9));
	
	for i in 0 to 1000 loop
		wait for 40 ns;
	end loop;
	
	done <= '1';
	
	wait;
	end process;
	
end TB;
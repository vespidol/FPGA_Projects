-- Generic DE-10 Lite top level

library ieee;
use ieee.std_logic_1164.all;

entity gen_top_level is
  port (
    ADC_CLK_10    : in    std_logic;
    MAX10_CLK1_50 : in    std_logic;
    MAX10_CLK2_50 : in    std_logic;
    GPIO          : inout std_logic_vector(35 downto 0);
    SW            : in    std_logic_vector(9 downto 0);
    KEY           : in    std_logic_vector(1 downto 0);
    HEX0          : out   std_logic_vector(0 to 7);
    HEX1          : out   std_logic_vector(0 to 7);
    HEX2          : out   std_logic_vector(0 to 7);
    HEX3          : out   std_logic_vector(0 to 7);
    HEX4          : out   std_logic_vector(0 to 7);
    HEX5          : out   std_logic_vector(0 to 7);
    LEDR          : out   std_logic_vector(9 downto 0);
    VGA_R         : out   std_logic_vector(3 downto 0);
    VGA_G         : out   std_logic_vector(3 downto 0);
    VGA_B         : out   std_logic_vector(3 downto 0);
    VGA_HS        : out   std_logic;
    VGA_VS        : out   std_logic
    );
end gen_top_level;

architecture STR of gen_top_level is

	signal outportLEDS	: std_logic_vector(31 downto 0);
	
begin
	seg0 : entity work.decoder7seg
	port map(
		input 	=> outportLEDS(3 downto 0),
		output	=> HEX0(0 to 6)
		);
	HEX0(7) <= '1';
	
	
	seg1 : entity work.decoder7seg
	port map(
		input 	=> outportLEDS(7 downto 4),
		output	=> HEX1(0 to 6)
		);
	HEX1(7) <= '1';
	
	
	seg2 : entity work.decoder7seg
	port map(
		input 	=> outportLEDS(11 downto 8),
		output	=> HEX2(0 to 6)
		);
	HEX2(7) <= '1';

	seg3 : entity work.decoder7seg
	port map(
		input 	=> outportLEDS(15 downto 12),
		output	=> HEX3(0 to 6)
		);
	HEX3(7) <= '1';
	

	HEX4 <= (others => '1');	--Turn off 7-segment 4
	HEX5 <= (others => '1'); --Turn off 7-segment 5

	---- INSTANTIATE MIPS Architecture --------------
	UUT_MIPS: entity work.mips_architecture
	generic map (WIDTH => 32)
	port map(
		clk			=> MAX10_CLK1_50,
	    rst			=> KEY(0),
	    Inport_en	=> KEY(1),
	    Inport		=> SW(9 downto 0),
	    Outport		=> outportLEDS
	);

end STR;
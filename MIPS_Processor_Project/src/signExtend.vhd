library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity signExtend is
	generic (
		WIDTH : positive := 32;
		INWIDTH : positive := 16);
	port (
		IsSigned	: in std_logic;
		Input		: in std_logic_vector(INWIDTH-1 downto 0);
		Output		: out std_logic_vector(WIDTH-1 downto 0)
	);
end signExtend;

architecture BHV of signExtend is
begin
	process(IsSigned, Input)
	begin
		if(IsSigned = '1') then
			if(Input(INWIDTH-1) = '1') then
				Output(WIDTH-1 downto INWIDTH) <= (others => '1');
			else
				Output(WIDTH-1 downto INWIDTH) <= (others => '0');
			end if;
		else 
			Output(WIDTH-1 downto INWIDTH) <= (others => '0');
		end if;

		Output(INWIDTH-1 downto 0) <= Input;
	end process;
end BHV;
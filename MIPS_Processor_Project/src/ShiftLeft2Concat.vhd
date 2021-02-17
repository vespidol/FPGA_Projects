library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity ShiftLeft2Concat is
	generic (
		WORD	 : positive := 32;
		WIDTH	 : positive := 26;
		INWIDTH  : positive := 4);
	port (
		Input 		: in std_logic_vector(WIDTH-1 downto 0);
		Concat_in	: in std_logic_vector(INWIDTH-1 downto 0);
		Output		: out std_logic_vector(WORD-1 downto 0)
	);
end ShiftLeft2Concat;

architecture BHV of ShiftLeft2Concat is
	signal temp, temp2 : std_logic_vector(WIDTH+1 downto 0);
begin

	temp <= "00" & Input;
	temp2 <= std_logic_vector(shift_left(unsigned(temp), 2));
	Output <= Concat_in & temp2;

end BHV;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity ZeroExtend is
	generic ( 
		WIDTH : positive := 32;
		INWIDTH : positive := 9);
	port (
		Input 	: in std_logic_vector(INWIDTH-1 downto 0);
		Output	: out std_logic_vector(WIDTH-1 downto 0)
		);
end ZeroExtend;

architecture BHV of ZeroExtend is
begin
	Output(WIDTH-1 downto INWIDTH) <= (Others => '0');
	Output(INWIDTH-1 downto 0) <= Input;
end BHV;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity mux4x1 is
  generic (
    width  :     positive);
  port (
    in1    : in  std_logic_vector(width-1 downto 0);
    in2    : in  std_logic_vector(width-1 downto 0);
	in3    : in  std_logic_vector(width-1 downto 0);
	in4    : in  std_logic_vector(width-1  downto 0);
    sel    : in  std_logic_vector(1 downto 0);
    output : out std_logic_vector(width-1 downto 0));
end mux4x1;

architecture BHV of mux4x1 is
begin
  with sel select
    output <=
    in4 when "11",
	in3 when "10",
	in2 when "01",
    in1 when others;
end BHV;

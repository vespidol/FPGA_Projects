--Final Project by: Victor Espidol and Eric Barkuloo

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.config_pkg.all;
use work.user_pkg.all;
use work.math_custom.all;


entity reverse_array is
    generic(
        SIZE : positive;
        WIDTH : positive);
    port(
        input : in std_logic_vector(SIZE*WIDTH-1 downto 0);
        output : out std_logic_vector(SIZE*WIDTH-1 downto 0));
end reverse_array;

architecture BHV of reverse_array is
    type in_array is array(integer range<>) of std_logic_vector(WIDTH-1 downto 0);

    --VECTORIZE FUNCTION
    function vectorize(input : in_array;
                        array_Size : natural;
                        elements : positive) return std_logic_vector is
    variable temp : std_logic_vector(array_Size*elements-1 downto 0);
    begin
        for i in 0 to array_Size-1 loop
            temp((i+1)*elements-1 downto i*elements) := input(input'left+i);
        end loop;
    return temp;
    end function;

    --DEVECTORIZE FUNCTION
    function devectorize(input : std_logic_vector;
                            array_Size : natural;
                            elements : positive) return in_array is
    variable temp : in_array(0 to array_Size-1);
    begin
        for i in 0 to array_Size-1 loop
            temp(i) := input((i+1)*elements-1 downto i*elements);
        end loop;
    return temp;
    end function;

begin

    process(input)
        variable num1 : in_array(0 to SIZE-1);
        variable num2 : in_array(0 to SIZE-1);
    begin   
        num1 := devectorize(input, SIZE, WIDTH);
        for i in 0 to SIZE-1 loop
            num2(i) := num1(SIZE-1-i);
        end loop;
        output <= vectorize(num2, SIZE, WIDTH);
    end process;
end BHV;
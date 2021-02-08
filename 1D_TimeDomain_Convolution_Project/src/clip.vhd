library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.config_pkg.all;

use work.user_pkg.all;
use work.math_custom.all;

entity clip is
    port(
        clk : in std_logic;
        rst : in std_logic;
        input : in std_logic_vector(C_SIGNAL_WIDTH+C_SIGNAL_WIDTH+clog2(C_KERNEL_SIZE)-1 downto 0);
        output : out std_logic_vector(C_SIGNAL_WIDTH-1 downto 0));
end clip;

architecture BHV of clip is
--     signal out_temp : std_logic_vector(C_SIGNAL_WIDTH-1 downto 0);
-- begin
--     process(clk, rst)
--     begin    
--         if(rst = '1') then
--             out_temp <= (others => '0');
--         elsif(rising_edge(clk)) then
--             if(unsigned(input(C_SIGNAL_WIDTH+C_SIGNAL_WIDTH+clog2(C_KERNEL_SIZE)-1 downto C_SIGNAL_WIDTH)) > to_unsigned(0, C_SIGNAL_WIDTH+C_SIGNAL_WIDTH+clog2(C_KERNEL_SIZE) - C_SIGNAL_WIDTH)) then
--                 out_temp <= (others => '1');
--             else
--             out_temp <= input(C_SIGNAL_WIDTH-1 downto 0);
--             end if;
--         end if;
--     end process;
--     output <= out_temp;
-- end BHV;
begin
    process(input)
    begin   
        if(unsigned(input(C_SIGNAL_WIDTH+C_SIGNAL_WIDTH+clog2(C_KERNEL_SIZE)-1 downto C_SIGNAL_WIDTH)) > to_unsigned(0, C_SIGNAL_WIDTH+C_SIGNAL_WIDTH+clog2(C_KERNEL_SIZE)+1 - C_SIGNAL_WIDTH)) then
            output <= (others => '1');
        else
            output <= input(C_SIGNAL_WIDTH-1 downto 0);
        end if;
    end process;
end BHV;
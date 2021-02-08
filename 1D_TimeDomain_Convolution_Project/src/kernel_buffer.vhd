library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.config_pkg.all;
use work.user_pkg.all;

--type NIBBLE is array (3 downto 0) of std_ulogic;

entity kernel_buffer is
    port (
        clk : in std_logic;
        rst : in std_logic;
        wr_en  : in std_logic;
        rd_en  : in std_logic;
        input : in std_logic_vector(C_RAM0_RD_DATA_WIDTH-1 downto 0);
        output : out  std_logic_vector(C_KERNEL_SIZE*C_SIGNAL_WIDTH-1 downto 0);
        full : out std_logic;
        empty : out std_logic);
end kernel_buffer;

architecture STR of kernel_buffer is

    type out_array is array(integer range<>) of std_logic_vector(C_SIGNAL_WIDTH-1 downto 0);

    signal buff_out : out_array(0 to C_KERNEL_SIZE-1);
    signal count : unsigned(7 downto 0);
begin

    --setup first register to take in first register as input
    U_REG1 : entity work.reg
    generic map (
        width => C_SIGNAL_WIDTH)
    port map (
        clk    => clk,
        rst    => rst,
        en     => wr_en,
        input  => input,
        output => buff_out(0));

    --use for generate for rest of registers
    U_REG_CHAIN : for i in 0 to C_KERNEL_SIZE-2 generate
        U_REG : entity work.reg
        generic map(
            width => C_SIGNAL_WIDTH)
        port map (
            clk => clk,
            rst => rst,
            en => wr_en,
            input => buff_out(i),
            output => buff_out(i+1));
    end generate U_REG_CHAIN;

    --put signal buffer outputs into big vector to be transfered to mult_add_tree
    U_VECTORIZE : for i in 0 to C_KERNEL_SIZE-1 generate
        output((i+1)*C_SIGNAL_WIDTH-1 downto i*C_SIGNAL_WIDTH) <= buff_out(i);
    end generate;

    full <= '1' when (count >= unsigned(to_signed(C_KERNEL_SIZE, 8))) else --Buffer is full only when count = 128 and value isnt being read out
        '0';
    empty <= '1' when count < unsigned(to_signed(C_KERNEL_SIZE, 8)) else
        '0';

    process(clk, rst)
    begin
        if(rst = '1') then
            count <= (others => '0');
        elsif (clk'event and clk = '1') then
            if(wr_en = '1') then --increment count when writing data into buffer
                count <= count + 1;
            end if;
            -- if(rd_en = '1') then --decrement count when reading data from buffer
            --     count <= count - 1;
            -- end if;
        end if;
    end process;
end STR;
--Final Project, by Eric Barkuloo and Victor Espidol
library ieee;
use ieee.std_logic_1164.all;

entity fifo_progfull is
    port (
        rst : IN STD_LOGIC;
        dram_clk : IN STD_LOGIC;
        user_clk : IN STD_LOGIC;
        din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        wr_en : IN STD_LOGIC;
        rd_en : IN STD_LOGIC;
        dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        full : OUT STD_LOGIC;
        empty : OUT STD_LOGIC;
        prog_full : OUT STD_LOGIC
    );
end fifo_progfull;

architecture STR of fifo_progfull is
    --Add component
    COMPONENT fifo_generator_0
        PORT (
            rst : IN STD_LOGIC;
            wr_clk : IN STD_LOGIC;
            rd_clk : IN STD_LOGIC;
            din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            wr_en : IN STD_LOGIC;
            rd_en : IN STD_LOGIC;
            dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            full : OUT STD_LOGIC;
            empty : OUT STD_LOGIC;
            prog_full : OUT STD_LOGIC
        );
    END COMPONENT;
begin

    U_FIFO : fifo_generator_0
    PORT MAP (
      rst => rst,
      wr_clk => dram_clk,
      rd_clk => user_clk,
      din => din,
      wr_en => wr_en,
      rd_en => rd_en,
      dout => dout,
      full => full,
      empty => empty,
      prog_full => prog_full
    );

end STR;

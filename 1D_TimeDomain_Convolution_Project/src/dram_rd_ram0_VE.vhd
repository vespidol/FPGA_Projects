-- Final Project : Victor Espidol and Eric Barkuloo

library ieee;
use ieee.std_logic_1164.all;

use work.config_pkg.all;
use work.user_pkg.all;

entity dram_rd_ram0_VE is
    port(
        dram_clk   : in  std_logic; --133 MHz, address generator
        user_clk   : in  std_logic; --100 MHz
        rst        : in  std_logic;
        clear      : in  std_logic;
        go         : in  std_logic;
        rd_en      : in  std_logic; --Read from FIFO
        stall      : in  std_logic;
        start_addr : in  std_logic_vector(C_DRAM0_ADDR_WIDTH-1 downto 0); --14 downto 0, send to address generator
        size       : in  std_logic_vector(C_DRAM0_SIZE_WIDTH downto 0); -- 16 downto 0, send to address generator and counter
        valid      : out std_logic; -- signal that is inverted from empty signal from fifo
        data       : out std_logic_vector(15 downto 0); -- data from fifo
        done       : out std_logic; -- from counter when it reaches the size

        dram_ready    : in  std_logic; --sent to address generator
        dram_rd_en    : out std_logic; --output from address generator
        dram_rd_addr  : out std_logic_vector(C_DRAM0_ADDR_WIDTH-1 downto 0); --14 downto 0, output from address generator 
        dram_rd_data  : in  std_logic_vector(C_DRAM0_DATA_WIDTH-1 downto 0); --31 downto 0, input to fifo
        dram_rd_valid : in  std_logic; -- input to the wr_en to the FIFO
        dram_rd_flush : out std_logic -- 
    );
end dram_rd_ram0_VE;

architecture dram_rd of dram_rd_ram0_VE is 

    signal size_handIn, size_handOut : std_logic_vector(C_DRAM0_SIZE_WIDTH downto 0); 
    signal addr_handIn, addr_handOut : std_logic_vector(C_DRAM0_ADDR_WIDTH-1 downto 0);
    signal go_addr_gen : std_logic;
    signal addr_gen_done : std_logic;
    signal prog_full : std_logic;
    signal fifo_full : std_logic;
    signal temp_valid : std_logic;
    signal rst_or_clr : std_logic;
    signal dummy_ack : std_logic;
    signal swapped_data : std_logic_vector(C_DRAM0_DATA_WIDTH-1 downto 0);

begin


 -------------------------- SRC CLK (USER_CLK) 100 MHZ ----------------------------------   
    --instantiate registers for size and start_address
    U_REG1_SIZE : entity work.reg
    generic map (
        width => C_DRAM0_SIZE_WIDTH+1)
    port map (
        clk    => user_clk,
        rst    => rst,
        en     => go,
        input  => size,
        output => size_handIn);

    U_REG1_ADDR : entity work.reg
    generic map (
        width => C_DRAM0_ADDR_WIDTH)
    port map (
        clk    => user_clk,
        rst    => rst,
        en     => go,
        input  => start_addr,
        output => addr_handIn);

    --instantiate a counter
    U_COUNT : entity work.dram_counter
    port map (
        clk     => user_clk,
        rst     => rst,
        size    => size_handIn,
        rd_en   => rd_en,
        done    => done
    );

    rst_or_clr <= rst or clear;

 -------------------------- SYNCRONIZE DOMAINS  ----------------------------------  
    --instantiate handshake
    U_HANDSHAKE : entity work.handshake
    port map (
        clk_src   => user_clk,
        clk_dest  => dram_clk,
        rst       => rst,
        go        => go,
        delay_ack => C_0,
        rcv       => go_addr_gen,
        ack       => dummy_ack ); --Unsure who sends ack

    --Swap data before feeding it into the fifo
    swapped_data(15 downto 0) <= dram_rd_data(31 downto 16);
    swapped_data(31 downto 16) <= dram_rd_data(15 downto 0);

    --instantiate fifo
    U_FIFO: entity work.fifo_progfull
    port map (
        rst         => rst_or_clr,
        dram_clk    => dram_clk,
        user_clk    => user_clk,
        din         => swapped_data,
        wr_en       => dram_rd_valid,
        rd_en       => rd_en,
        dout        => data,
        full        => fifo_full,
        empty       => temp_valid,
        prog_full   => prog_full
    );

    valid <= not temp_valid;

 -------------------------- DEST CLK (DRAM_CLK) 133 MHZ ----------------------------------   
    --instantiate registers
    U_REG2_SIZE : entity work.reg
    generic map (
        width => C_DRAM0_SIZE_WIDTH+1)
    port map (
        clk    => dram_clk,
        rst    => rst,
        en     => go_addr_gen,
        input  => size_handIn,
        output => size_handOut);

    U_REG2_ADDR : entity work.reg
    generic map (
        width => C_DRAM0_ADDR_WIDTH)
    port map (
        clk    => dram_clk,
        rst    => rst,
        en     => go_addr_gen,
        input  => addr_handIn,
        output => addr_handOut);

    --instantiate address generator
    U_IN_ADDR_GEN: entity work.addr_gen
    port map (
        clk             => dram_clk,
        rst             => rst,
        go              => go_addr_gen,        --From Handshake Synchronizer
        done_gen        => addr_gen_done,
        address_size    => size_handOut,
        start_address   => addr_handOut,
        dram_ready      => dram_ready,
        dram_rd_addr    => dram_rd_addr,
        dram_rd_en      => dram_rd_en,
        dram_rd_flush   => dram_rd_flush,
        prog_full       => prog_full
    );


end dram_rd;
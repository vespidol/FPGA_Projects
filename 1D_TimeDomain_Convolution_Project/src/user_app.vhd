--Final Project by: Victor Espidol and Eric Barkuloo

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.config_pkg.all;
use work.user_pkg.all;
use work.math_custom.all;

entity user_app is
    port (
        clks   : in  std_logic_vector(NUM_CLKS_RANGE);
        rst    : in  std_logic;
        sw_rst : out std_logic;

        -- memory-map interface
        mmap_wr_en   : in  std_logic;
        mmap_wr_addr : in  std_logic_vector(MMAP_ADDR_RANGE);
        mmap_wr_data : in  std_logic_vector(MMAP_DATA_RANGE);
        mmap_rd_en   : in  std_logic;
        mmap_rd_addr : in  std_logic_vector(MMAP_ADDR_RANGE);
        mmap_rd_data : out std_logic_vector(MMAP_DATA_RANGE);

        -- DMA interface for RAM 0
        -- read interface
        ram0_rd_rd_en : out std_logic;
        ram0_rd_clear : out std_logic;
        ram0_rd_go    : out std_logic;
        ram0_rd_valid : in  std_logic;
        ram0_rd_data  : in  std_logic_vector(RAM0_RD_DATA_RANGE);
        ram0_rd_addr  : out std_logic_vector(RAM0_ADDR_RANGE);
        ram0_rd_size  : out std_logic_vector(RAM0_RD_SIZE_RANGE);
        ram0_rd_done  : in  std_logic;
        -- write interface
        ram0_wr_ready : in  std_logic;
        ram0_wr_clear : out std_logic;
        ram0_wr_go    : out std_logic;
        ram0_wr_valid : out std_logic;
        ram0_wr_data  : out std_logic_vector(RAM0_WR_DATA_RANGE);
        ram0_wr_addr  : out std_logic_vector(RAM0_ADDR_RANGE);
        ram0_wr_size  : out std_logic_vector(RAM0_WR_SIZE_RANGE);
        ram0_wr_done  : in  std_logic;

        -- DMA interface for RAM 1
        -- read interface
        ram1_rd_rd_en : out std_logic;
        ram1_rd_clear : out std_logic;
        ram1_rd_go    : out std_logic;
        ram1_rd_valid : in  std_logic;
        ram1_rd_data  : in  std_logic_vector(RAM1_RD_DATA_RANGE);
        ram1_rd_addr  : out std_logic_vector(RAM1_ADDR_RANGE);
        ram1_rd_size  : out std_logic_vector(RAM1_RD_SIZE_RANGE);
        ram1_rd_done  : in  std_logic;
        -- write interface
        ram1_wr_ready : in  std_logic;
        ram1_wr_clear : out std_logic;
        ram1_wr_go    : out std_logic;
        ram1_wr_valid : out std_logic;
        ram1_wr_data  : out std_logic_vector(RAM1_WR_DATA_RANGE);
        ram1_wr_addr  : out std_logic_vector(RAM1_ADDR_RANGE);
        ram1_wr_size  : out std_logic_vector(RAM1_WR_SIZE_RANGE);
        ram1_wr_done  : in  std_logic
        );
end user_app;

architecture default of user_app is

    signal go        : std_logic;
    signal sw_rst_s  : std_logic;
    signal rst_s     : std_logic;
    signal size      : std_logic_vector(RAM0_RD_SIZE_RANGE);
--    signal ram0_rd_addr : std_logic_vector(RAM0_ADDR_RANGE);--
--    signal ram1_wr_addr : std_logic_vector(RAM1_ADDR_RANGE);--
    signal done      : std_logic;

    signal sb_full   : std_logic;
    signal sb_empty  : std_logic;
    signal kb_full   : std_logic;
    signal kb_empty  : std_logic;

    signal sb_wr_en : std_logic;
    signal sb_rd_en : std_logic;
    signal kb_wr_en : std_logic;
    signal kb_rd_en : std_logic;
    signal mmap_kb_data : std_logic_vector(KERNEL_WIDTH_RANGE);

    signal input1   : std_logic_vector(C_KERNEL_SIZE*C_SIGNAL_WIDTH-1 downto 0);
    signal reversed_signal : std_logic_vector(C_KERNEL_SIZE*C_SIGNAL_WIDTH-1 downto 0);
    signal input2   : std_logic_vector(C_KERNEL_SIZE*C_SIGNAL_WIDTH-1 downto 0);
    signal pipeline_en : std_logic;

    signal valid_in  : std_logic;
    signal valid_out : std_logic;

    signal mult_add_out : std_logic_vector(C_SIGNAL_WIDTH+C_SIGNAL_WIDTH+clog2(C_KERNEL_SIZE)-1 downto 0);

begin
    ram0_rd_rd_en <= ram0_rd_valid and (not sb_full);
    sb_wr_en <= ram0_rd_valid and (not sb_full);
    sb_rd_en <= (not sb_empty) and ram1_wr_ready;
    kb_rd_en <= kb_full;--(not kb_empty);
    ram1_wr_valid <= valid_out;-- and ram1_wr_ready;
    valid_in <= sb_rd_en;-- and kb_full;
    pipeline_en <= ram1_wr_ready;
    

    U_MMAP : entity work.memory_map
        port map (
            clk     => clks(C_CLK_USER),
            rst     => rst,
            wr_en   => mmap_wr_en,
            wr_addr => mmap_wr_addr,
            wr_data => mmap_wr_data,
            rd_en   => mmap_rd_en,
            rd_addr => mmap_rd_addr,
            rd_data => mmap_rd_data,

            -- dma interface for accessing DRAM from software
            ram0_wr_ready => ram0_wr_ready,
            ram0_wr_clear => ram0_wr_clear,
            ram0_wr_go    => ram0_wr_go,
            ram0_wr_valid => ram0_wr_valid,
            ram0_wr_data  => ram0_wr_data,
            ram0_wr_addr  => ram0_wr_addr,
            ram0_wr_size  => ram0_wr_size,
            ram0_wr_done  => ram0_wr_done,

            ram1_rd_rd_en => ram1_rd_rd_en,
            ram1_rd_clear => ram1_rd_clear,
            ram1_rd_go    => ram1_rd_go,
            ram1_rd_valid => ram1_rd_valid,
            ram1_rd_data  => ram1_rd_data,
            ram1_rd_addr  => ram1_rd_addr,
            ram1_rd_size  => ram1_rd_size,
            ram1_rd_done  => ram1_rd_done,

            -- circuit interface from software
            go        => go,
            sw_rst    => sw_rst_s,
            signal_size => size,
            --ram0_rd_addr => ram0_rd_addr,
            --ram1_wr_addr => ram1_wr_addr,
            kernel_data => mmap_kb_data,
            kernel_load => kb_wr_en,
            kernel_loaded => kb_rd_en,
            done      => done
            );

    rst_s  <= rst or sw_rst_s;
    sw_rst <= sw_rst_s;

    U_CTRL : entity work.ctrl
        port map (
            clk           => clks(C_CLK_USER),
            rst           => rst_s,
            go            => go,
            mem_in_go     => ram0_rd_go,
            mem_out_go    => ram1_wr_go,
            mem_in_clear  => ram0_rd_clear,
            mem_out_clear => ram1_wr_clear,
            mem_out_done  => ram1_wr_done,
            done          => done);

    --ram0_rd_rd_en <= ram0_rd_valid and ram1_wr_ready;
    ram0_rd_size  <= std_logic_vector(unsigned(size) + to_unsigned(2*C_KERNEL_SIZE, C_RAM0_RD_SIZE_WIDTH));
--    ram0_rd_addr  <= ram0_rd_addr;
    ram1_wr_size  <= std_logic_vector(unsigned(size) + to_unsigned(C_KERNEL_SIZE, C_RAM1_WR_SIZE_WIDTH));
--    ram1_wr_addr  <= ram1_rd_addr;
--    ram1_wr_data  <= ram0_rd_data;
    --ram1_wr_valid <= ram0_rd_valid and ram1_wr_ready;

    U_SIGNAL_BUFF : entity work.signal_buffer
        port map(
            clk => clks(C_CLK_USER),
            rst => rst,
            wr_en => sb_wr_en,
            rd_en => sb_rd_en,
            input => ram0_rd_data,
            output => input1,
            full => sb_full,
            empty => sb_empty);

    U_REVERSE_SIGNAL : entity work.reverse_array
        generic map(
            SIZE => C_KERNEL_SIZE,
            WIDTH => C_KERNEL_WIDTH
        )
        port map (
            input => input2,
            output => reversed_signal
        );
    
    U_KERNEL_BUFF : entity work.signal_buffer
        port map(
            clk => clks(C_CLK_USER),
            rst => rst,
            wr_en => kb_wr_en,
            rd_en => C_0,--kb_rd_en,
            input => mmap_kb_data, --PROBLEM HERE
            output => input2,
            full => kb_full,
            empty => kb_empty);


    U_PIPELINE : entity work.mult_add_tree(unsigned_arch)
        generic map(
            num_inputs => C_KERNEL_SIZE,
            input1_width => C_SIGNAL_WIDTH,
            input2_width => C_SIGNAL_WIDTH)
        port map(
            clk => clks(C_CLK_USER),
            rst => rst,
            en => C_1,--pipeline_en,
            input1 => input1,--input1,
            input2 => input2,--reversed_signal,--input2,
            output => mult_add_out);

    U_DELAY : entity work.delay
        generic map(
            cycles => clog2(C_KERNEL_SIZE)+7, --CHANGE THIS TO MATCH DELAY OF PIPELINE
            width => 1,
            init => "0")
        port map(
            clk => clks(C_CLK_USER),
            rst => rst,
            en => C_1,--pipeline_en,
            input(0) => valid_in,
            output(0) => valid_out);

    --ram1_wr_data <= mult_add_out(C_SIGNAL_WIDTH-1 downto 0);
    U_CLIP : entity work.clip
        port map(
            clk => clks(C_CLK_USER),
            rst => rst,
            input => mult_add_out,
            output => ram1_wr_data);
        
end default;

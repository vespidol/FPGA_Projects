--The address generators in this lab are essentially counters that count from 
--a specifiedstarting address (in this case, from address 0) for thenumber of 
--addressesspecified by size. The address generator’s output (i.e., the current address) 
--should connect to each RAM. The address generator will likely also include control 
--signals for reading orwriting to RAM, although there are numerous different implementations


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.config_pkg.all;
use work.user_pkg.all;

entity addr_gen is 
    port (
        clk  : in std_logic;
        rst  : in std_logic;
        go   : in std_logic;        --From Handshake Synchronizer
        done_gen : out std_logic;

        -- Input to address generator from Handshake Synchronizer
        address_size : in std_logic_vector(C_DRAM0_SIZE_WIDTH downto 0);  --16 downto 0
        start_address : in std_logic_vector(C_DRAM0_ADDR_WIDTH-1 downto 0); --14 downto 0

        -- Input/Output from DRAM
        dram_ready : in std_logic;
        dram_rd_addr : out std_logic_vector(C_DRAM0_ADDR_WIDTH-1 downto 0); --14 downto 0
        dram_rd_en : out std_logic;
        dram_rd_flush : out std_logic;

        -- Input from FIFO
        prog_full : in std_logic

    );
end addr_gen;


architecture FSM_2P of addr_gen is
    type state_type is (S_START, S_GETSIZE, S_COUNT, S_DONE);
    signal state, next_state : state_type;

    signal ram_count, next_ram_count : std_logic_vector(C_DRAM0_SIZE_WIDTH downto 0);
begin

-------------------------
    process(clk, rst) 
    begin
        if (rst = '1') then
            state <= S_START;
            ram_count <= (others => '0');
        elsif (rising_edge(clk)) then
            state <= next_state;
            ram_count <= next_ram_count;
        end if;
    end process;

    process(state, go, address_size, ram_count, prog_full, dram_ready)
    begin
        --DEFAULT ASSIGNMENTS
        next_state <= state;
        next_ram_count <= ram_count;
        done_gen <= '0';
        dram_rd_en <= '0';
        dram_rd_flush <= '0';

        case state is
            when S_START =>
                --Check if go is 1 
                if(go = '1') then
                    next_state <= S_GETSIZE;
                    dram_rd_flush <= '1';
                end if;          

            when S_GETSIZE =>
                --Initialize the count to be 0
                next_ram_count <= (others => '0');
                
                next_state <= S_COUNT;


            when S_COUNT =>     
                --If dram ready and the fifo is not full then read next address
                if(dram_ready = '1' and prog_full = '0') then
                    --read next address
                    dram_rd_en <= '1';      

                    --Must divide size by 2 because dram outputs 32 bit words
                    if(unsigned(ram_count) < (unsigned(address_size) / 2)) then
                        -- update the count
                        next_ram_count <= std_logic_vector(unsigned(ram_count) + to_unsigned(1, C_DRAM0_SIZE_WIDTH));
                        
                    else
                        next_state <= S_DONE;
                    end if;
                end if;


            when S_DONE =>
                done_gen <= '1';

                if(go = '0') then
                    next_state <= S_START;
                end if;

        end case;
    end process;
    
    --Output to dram
    dram_rd_addr <= std_logic_vector(unsigned(ram_count(C_DRAM0_ADDR_WIDTH-1 downto 0)) + unsigned(start_address));

end FSM_2P;
-- Final Project : Victor Espidol and Eric Barkuloo

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.config_pkg.all;
use work.user_pkg.all;

entity dram_counter is
    port(
        clk : in std_logic;
        rst : in std_logic;
        size : in std_logic_vector(C_DRAM0_SIZE_WIDTH downto 0);
        rd_en : in std_logic;
        done : out std_logic
    );
end dram_counter;

architecture FSM_2P of dram_counter is 
    type state_type is (S_START, S_COUNT, S_DONE, S_WAIT);
    signal state, next_state : state_type;

    signal ram_count, next_ram_count : std_logic_vector(C_DRAM0_SIZE_WIDTH downto 0);
    signal wait_count : std_logic_vector(2 downto 0);
begin

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

    process(state, rd_en, ram_count, size)
    begin
        --Default Assignments 
        done <= '0';
        next_state <= state;
        next_ram_count <= ram_count;

        case state is
            when S_START => 
                --reset count to 0
                next_ram_count <= (others => '0');

                if(rd_en = '1') then
                    --Once rd_en is asserted count the first read and move to count state
                    next_ram_count <= std_logic_vector(unsigned(ram_count) + to_unsigned(1, C_DRAM0_SIZE_WIDTH));
                    next_state <= S_COUNT;
                end if;
            
            when S_COUNT =>
                if(rd_en = '1') then
                    if(unsigned(ram_count) < unsigned(size)) then
                        next_ram_count <= std_logic_vector(unsigned(ram_count) + to_unsigned(1, C_DRAM0_SIZE_WIDTH));
                    else
                        next_state <= S_DONE;
                        done <= '1';
                    end if;
                end if;

            when S_DONE =>
                done <= '1';
                wait_count <= (others => '0');

                next_state <= S_WAIT;

            when S_WAIT =>
                done <= '1';    
                wait_count <= std_logic_vector(unsigned(wait_count) + to_unsigned(1,3));
        
                if(rd_en = '0' and wait_count = "111") then
                    next_state <= S_START;
                end if;

        end case;
    end process;
end FSM_2P;
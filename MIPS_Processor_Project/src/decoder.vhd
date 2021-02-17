library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity decoder is
generic ( Width : positive := 32);
port (
		address		: in std_logic_vector(Width-1 downto 0);
		Mem_write	: in std_logic;
		Mem_read	: in std_logic;
		Out_en		: out std_logic;
		wren_en		: out std_logic;
		Mux_sel		: out std_logic_vector(1 downto 0);
		addr_out	: out std_logic_vector(7 downto 0)
	);
end decoder;

architecture BHV of decoder is
begin
	Process(address, Mem_write, Mem_read)
		variable Ram_addr : std_logic_vector(7 downto 0);
		variable temp : std_logic_vector(Width-1 downto 0);
	begin
		temp 	 := std_logic_vector(shift_right(unsigned(address), 2));	--Convert Byte address to Word Adress
		Ram_addr := temp(7 downto 0);	
		
		Out_en 	<= '0';		--For Outport
		Mux_sel	<= "11";	--Constant zero
		wren_en <= '0';		--For SRAM write enable
		
		if(Mem_read = '1') then	
			if(address = x"0000FFF8") then --Read from Inport0	
				Mux_sel <= "01";
				
			elsif(address = x"0000FFFC") then --Read from Inport1
				Mux_sel <= "10";
				--Out_en 	<= '1';
				
			elsif((Ram_addr >= "00000000") AND (Ram_addr <= "11111111")) then -- Read from SRAM
				Mux_sel <= "00";
			end if;
		
		elsif(Mem_write = '1') then
			if(address = x"0000FFFC") then
				Out_en <= '1';
			elsif((Ram_addr >= "00000000") AND (Ram_addr <= "11111111")) then --Check if in SRAM address range
				wren_en <= '1';
			end if;
		end if;
		
		addr_out <= Ram_addr;
	end process;
end BHV;

	
	
	
	
	
	
	
	
	
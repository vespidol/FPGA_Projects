library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is
	generic (
		Width : positive := 32;
		addr  : positive := 5);
    port(
        clk 		: in std_logic;
        rst 		: in std_logic;
        rd_addr0 	: in std_logic_vector(addr-1 downto 0);
        rd_addr1 	: in std_logic_vector(addr-1 downto 0);
        wr_addr 	: in std_logic_vector(addr-1 downto 0);
        wr_en 		: in std_logic;
		JumpNLink	: in std_logic;
        wr_data 	: in std_logic_vector(Width-1 downto 0); --RegWrite
        rd_data0 	: out std_logic_vector(Width-1 downto 0);
        rd_data1 	: out std_logic_vector(Width-1 downto 0)
        );
end register_file;

--asynchronous read, synchronous write
architecture BHV of register_file is
	type reg_array is array(0 to Width-1) of std_logic_vector(Width-1 downto 0);
	signal reg: reg_array;
	
	begin
	process(clk, rst)
	begin
		if(rst = '1') then
			for i in 0 to Width-1 loop
				reg(i) <= (others => '0');
			end loop;
		elsif (rising_edge(clk)) then
			if(wr_en = '1') then
				if(to_integer(unsigned(wr_addr)) /= 0) then
					reg(to_integer(unsigned(wr_addr))) <= wr_data;
				elsif (JumpNLink = '1') then
					reg(31) <= wr_data;
				end if;
			end if;
		end if;
	end process;
	
	rd_data0 <= reg(to_integer(unsigned(rd_addr0)));
    rd_data1 <= reg(to_integer(unsigned(rd_addr1)));
 
 end BHV;
		
	
	
	
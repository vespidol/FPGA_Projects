library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;


entity alu is
	generic (Width : positive := 32);
	port (
	input1 	 : in std_logic_vector(Width-1 downto 0); -- from MuxA
	input2 	 : in std_logic_vector(Width-1 downto 0); -- from MuxB (immediate value)
	H 		 : in std_logic_vector(4 downto 0); -- IR[10:6]
	OPSelect : in std_logic_vector(5 downto 0); -- OPSelect 6 bits 
	output 	 : out std_logic_vector(Width-1 downto 0); --
	outputHI : out std_logic_vector(Width-1 downto 0);
	Branch 	 : out std_logic
	);
end alu;


-- R-type : 
	-- opcode(6)|rs(5)|rt(5)|rd(5)|shamt(5)|func(6)
-- I-type :
	-- opcode(6)|rs(5)|rt(5)|immediate(16)
-- J-type :
	-- opcode(6)|address(26)

architecture BHV of alu is
--signals
begin
	process(input1, input2, H, OPSelect)
		--variables
		variable tempOut : std_logic_vector(Width-1 downto 0);
		variable tempMUL : std_logic_vector(2*WIDTH-1 downto 0);
		variable tempH 	 : integer;
	begin
	------- Default Assignments ------
	Branch 	 <= '0';
	output 	 <= (others => '0');
	outputHI <= (others => '0');
	
	
		case OPSelect is 
		
		--Notice there are a lot of instructions that are unsigned addition based
		when ALU_addUN | ALU_addIMM | ALU_loadW | ALU_storeW | ALU_JnL => 
			output <= std_logic_vector(unsigned(input1) + unsigned(input2));
		
		when ALU_subUN | ALU_subIMM => --sub immediate unsigned
			output <= std_logic_vector(unsigned(input1) - unsigned(input2));
			
		when ALU_mult => --multiply
			tempMul  := std_logic_vector(signed(input1) * signed(input2));
			output 	 <= tempMUL(WIDTH-1 downto 0);
			outputHI <= tempMUL(2*WIDTH-1 downto Width);
			
		when ALU_multUN =>	--multiply unsigned
			tempMul  := std_logic_vector(unsigned(input1) * unsigned(input2));
			output 	 <= tempMUL(WIDTH-1 downto 0);
			outputHI <= tempMUL(2*WIDTH-1 downto Width);	
			
		when ALU_and | ALU_andIMM => --AND
			output <= input1 AND input2;
		
		when ALU_or | ALU_orIMM => --OR
			output <= input1 OR input2;
			
		when ALU_xor | ALU_xorIMM => --XOR
			output <= input1 XOR input2;
			
		when ALU_srl =>  --srl(shift right logical)
			--Shifts in zeros and moves bits accordingly
			--shift by H : where H is a 5-bit value from IR(10-6);
			tempH := to_integer(unsigned(H));
			output <= std_logic_vector(shift_right(unsigned(input2), tempH)); 
			
		when ALU_sll => --sll(shift left logical)
			tempH := to_integer(unsigned(H));
			output <= std_logic_vector(shift_left(unsigned(input2), tempH)); 
			
		when ALU_sra => --sra(shift right arithmetic)
			--shifts in 0s if the MSB is 0 and shifts in 1s if the MSB is 1
			tempH := to_integer(unsigned(H));
			output <= std_logic_vector(shift_right(signed(input2), tempH)); 
			
		when ALU_slt | ALU_slti => --set on less than signed
			if(to_integer(signed(input1)) < to_integer(signed(input2))) then
				output(0) <= '1';
			else
				output(0) <= '0';
			end if;
			output(Width-1 downto 1) <= (others => '0');
		
		when ALU_sltu | ALU_sltiu => --set on less than unsigned
			if(to_integer(unsigned(input1)) < to_integer(unsigned(input2))) then
				output(0) <= '1';
			else
				output(0) <= '0';
			end if;
			output(Width-1 downto 1) <= (others => '0');
			
		when ALU_BE => --branch on equal
			if(unsigned(input1) = unsigned(input2)) then
				Branch <= '1';
			else
				Branch <= '0';
			end if;
			       
		when ALU_BNE => --branch not equal
			if(unsigned(input1) /= unsigned(input2)) then
				Branch <= '1';
			else
				Branch <= '0';
			end if;			
		                
		when ALU_BLTE => --branch on less than or equal to zero
			if(signed(input1) <= 0) then
				Branch <= '1';
			end if;
		                
		when ALU_BGT => --branch on greater than zero
			if(signed(input1) > 0) then
				Branch <= '1';
			end if;
		                
		when ALU_BLT => --branch on less than zero
			if(signed(input1) < 0) then
				Branch <= '1';
			end if;
		                
		when ALU_BGTE => --branch on greater than or equal to zero
			if(signed(input1) >= 0) then
				Branch <= '1';
			end if;
		                
		when ALU_jumpreg => --jump register
		     output <= input1; 
		
		when others => NULL;
		
		end case;
	end process;
end BHV;
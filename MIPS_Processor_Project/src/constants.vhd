library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package constants is

	constant C_4 : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(4, 32));
	---------------  R-type  ------------------
	-- Function bits will determine the Instruction
	constant R_TYPE			: std_logic_vector(5 downto 0) := "000000";
	constant ALU_addUN		: std_logic_vector(5 downto 0) := "000000";
	constant ALU_subUN		: std_logic_vector(5 downto 0) := "000010";
	constant ALU_mult		: std_logic_vector(5 downto 0) := "000100";
 	constant ALU_multUN		: std_logic_vector(5 downto 0) := "000101";
	constant ALU_and		: std_logic_vector(5 downto 0) := "000110";	
	constant ALU_or			: std_logic_vector(5 downto 0) := "001000";
	constant ALU_xor		: std_logic_vector(5 downto 0) := "001010";
	constant ALU_srl		: std_logic_vector(5 downto 0) := "001100"; --Shift Right Logical
	constant ALU_sll		: std_logic_vector(5 downto 0) := "001101"; --Shift Left Logical
	constant ALU_sra		: std_logic_vector(5 downto 0) := "001110"; --Shift Right Artihmetic
	constant ALU_slt		: std_logic_vector(5 downto 0) := "001111"; --Set on less than signed
	constant ALU_sltu		: std_logic_vector(5 downto 0) := "010010"; --Set on less than unsigned	
	constant ALU_mfhi		: std_logic_vector(5 downto 0) := "010011"; --Move from HI
	constant ALU_mflo		: std_logic_vector(5 downto 0) := "010100"; --Move from LO
	constant ALU_jumpreg	: std_logic_vector(5 downto 0) := "011111"; --Jump Register
	
	----------------- Function code	-----------------------------
	constant F_addUN		: std_logic_vector(5 downto 0) := "100001";	--0x21
	constant F_subUN		: std_logic_vector(5 downto 0) := "100011"; --0x23
	constant F_mult			: std_logic_vector(5 downto 0) := "011000"; --0x18
 	constant F_multUN		: std_logic_vector(5 downto 0) := "011001"; --0x19
	constant F_and			: std_logic_vector(5 downto 0) := "100100";	--0x24
	constant F_or			: std_logic_vector(5 downto 0) := "100101"; --0x25
	constant F_xor			: std_logic_vector(5 downto 0) := "100110"; --0x26
	constant F_srl			: std_logic_vector(5 downto 0) := "000010"; --0x02
	constant F_sll			: std_logic_vector(5 downto 0) := "000000"; --0x00
	constant F_sra			: std_logic_vector(5 downto 0) := "000011"; --0x03
	constant F_slt			: std_logic_vector(5 downto 0) := "101010"; --0x2A
	constant F_sltu			: std_logic_vector(5 downto 0) := "101011"; --0x2B
	constant F_mfhi			: std_logic_vector(5 downto 0) := "010000"; --0x10
	constant F_mflo			: std_logic_vector(5 downto 0) := "010010"; --0x12
	constant F_jumpreg		: std_logic_vector(5 downto 0) := "001000"; --0x08

	-------------------------  I-type  ------------------------
	constant ALU_addIMM 	: std_logic_vector(5 downto 0) := "000001";
	constant ALU_subIMM		: std_logic_vector(5 downto 0) := "000011";
	constant ALU_andIMM		: std_logic_vector(5 downto 0) := "000111";
	constant ALU_orIMM		: std_logic_vector(5 downto 0) := "001001";
	constant ALU_xorIMM		: std_logic_vector(5 downto 0) := "001011";
	constant ALU_slti		: std_logic_vector(5 downto 0) := "010000"; --Set on less than immediate signed
	constant AlU_sltiu		: std_logic_vector(5 downto 0) := "010001"; --Set on less than immediate unsigned
	constant ALU_loadW		: std_logic_vector(5 downto 0) := "010101"; --Load Word
	constant ALU_storeW 	: std_logic_vector(5 downto 0) := "010110"; --Store Word
	constant ALU_BE			: std_logic_vector(5 downto 0) := "010111"; --Branch On Equal
	constant ALU_BNE		: std_logic_vector(5 downto 0) := "011000"; --Branch Not Equal
	constant ALU_BLTE		: std_logic_vector(5 downto 0) := "011001"; --Branch on Less Than or Equal to Zero
	constant ALU_BGT		: std_logic_vector(5 downto 0) := "011010"; --Branch on Greater Than Zero
	constant ALU_BLT 		: std_logic_vector(5 downto 0) := "011011"; --Branch on Less Than Zero
	constant ALU_BGTE	 	: std_logic_vector(5 downto 0) := "011100"; --Branch on Greater than or Equal to Zero


	--------------------------  J-type  ---------------------------
	constant ALU_jumpaddr	: std_logic_vector(5 downto 0) := "011101"; --Jump to address
	constant ALU_JnL		: std_logic_vector(5 downto 0) := "011110"; --Jump and link


	-------------------------- OP CODES -----------------------------
	constant OP_addIMM 		: std_logic_vector(5 downto 0) := "001001";	--0x09
	constant OP_subIMM		: std_logic_vector(5 downto 0) := "010000"; --0x10
	constant OP_andIMM		: std_logic_vector(5 downto 0) := "001100"; --0x0C
	constant OP_orIMM		: std_logic_vector(5 downto 0) := "001101"; --0x0D
	constant OP_xorIMM		: std_logic_vector(5 downto 0) := "001110"; --0x0E
	constant OP_slti		: std_logic_vector(5 downto 0) := "001010"; --0x0A
	constant OP_sltiu		: std_logic_vector(5 downto 0) := "001011"; --0x0B
	constant OP_loadW		: std_logic_vector(5 downto 0) := "100011"; --0x23
	constant OP_storeW 		: std_logic_vector(5 downto 0) := "101011"; --0x2B
	constant OP_BE			: std_logic_vector(5 downto 0) := "000100"; --0x04
	constant OP_BNE			: std_logic_vector(5 downto 0) := "000101"; --0x05
	constant OP_BLTE		: std_logic_vector(5 downto 0) := "000110"; --0x06
	constant OP_BGT			: std_logic_vector(5 downto 0) := "000111"; --0x07
	
	constant OP_BLT 		: std_logic_vector(5 downto 0) := "110000"; --BLT and BGTE have the same OpCode 0x01, so the main controller will handle it
	constant OP_BGTE	 	: std_logic_vector(5 downto 0) := "110001";	--Based on the IR[20:16] if "00001" o
																		-- BLT = 0x30 , BGTE = 0x31
	constant OP_BranchADD	: std_logic_vector(5 downto 0) := "110010"; --0x32 Created instruction for the addition of the offset for Branch 


	constant OP_jumpaddr	: std_logic_vector(5 downto 0) := "000010"; --0x02
	constant OP_JnL			: std_logic_vector(5 downto 0) := "000011"; --0x03 
	
	constant OP_HALT		: std_logic_vector(5 downto 0) := "111111"; --0x3F

	
	

end constants;
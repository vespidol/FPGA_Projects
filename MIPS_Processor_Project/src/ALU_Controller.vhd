library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity ALU_controller is
	generic (WIDTH : positive := 6);
	port (
		ALUOp		: in std_logic_vector(5 downto 0);
		funct 		: in std_logic_vector(5 downto 0);	--6bits
		HI_en		: out std_logic;
		LO_en		: out std_logic;
		OPSel		: out std_logic_vector(WIDTH-1 downto 0);
		ALU_LO_HI	: out std_logic_vector(1 downto 0)
	);
end ALU_controller;

architecture BHV of ALU_controller is
	--Purpose is to set the corresponding instruction to the correct ALU case in alu.vhd
begin
	process(ALUOp, funct)
	begin
		ALU_LO_HI <= "00" ;		--default choose ALU_out register
		HI_en <= '0';
		LO_en <= '0';
		OPSel <= ALU_addUN; 	--default set to add unsigned 
	
		case ALUOp is
		------ R_TYPE---------
		WHEN R_TYPE =>		
			case funct is
			WHEN F_addUN =>
				OPSel <= ALU_addUN;
				
			WHEN F_subUN =>
				OPSel <= ALU_subUN;
				
			WHEN F_mult =>
				OPSel <= ALU_mult;
				LO_en <= '1';
				HI_en <= '1';
				
			WHEN F_multUN =>
				OPSel <= ALU_multUN;
				LO_en <= '1';
				HI_en <= '1';
				
			WHEN F_and =>
				OPSel <= ALU_and;
			
			WHEN F_or =>
				OPSel <= ALU_or;
			
			WHEN F_xor =>
				OPSel <= ALU_xor;
				
			WHEN F_srl =>
				OPSel <= ALU_srl;
			
			WHEN F_sll =>
				OPSel <= ALU_sll;
				
			WHEN F_sra =>
				OPSel <= ALU_sra;
				
			WHEN F_slt =>
				OPSel <= ALU_slt;
			
			WHEN F_sltu =>
				OPSel <= ALU_sltu;
			
			WHEN F_mfhi =>
				ALU_LO_HI <= "10";
				
			WHEN F_mflo =>
				ALU_LO_HI <= "01";
				
			
			WHEN F_jumpreg =>
				OPSel <= ALU_jumpreg;
			
			WHEN Others => NULL;
			end case;
		
		---------- I_TYPE ------------
		WHEN OP_addIMM =>
			OPSel <= ALU_addIMM;
			
		WHEN OP_subIMM =>
			OPSel <= ALU_subIMM;
		
		WHEN OP_andIMM =>
			OPSel <= ALU_andIMM;
		
		WHEN OP_orIMM =>
			OPSel <= ALU_orIMM;
		
		WHEN OP_xorIMM =>
			OPSel <= ALU_xorIMM;
		
		WHEN OP_slti =>
			OPSel <= ALU_slti;
		
		WHEN OP_sltiu =>
			OPSel <= ALU_sltiu;
		
		WHEN OP_loadW =>
			OPSel <= ALU_loadW;
		
		WHEN OP_storeW =>
			OPSel <= ALU_storeW;
		
		WHEN OP_BE =>
			OPSel <= ALU_BE;
		
		WHEN OP_BNE =>
			OPSel <= ALU_BNE;
		
		WHEN OP_BLTE =>
			OPSel <= ALU_BLTE;
		
		WHEN OP_BGT =>
			OPSel <= ALU_BGT;
		
		WHEN OP_BLT =>
			OPSel <= ALU_BLT;
		
		WHEN OP_BGTE =>
			OPSel <= ALU_BGTE;
		
		------------ J_TYPE -------------
		WHEN OP_JnL =>
			OPSel <= ALU_JnL;
		
		WHEN OP_BranchADD =>	--Created instruction to handle the addition of the offset
			OPSel <= ALU_addUN;
		
		WHEN Others => NULL;
		end case;
	end process;
end BHV;


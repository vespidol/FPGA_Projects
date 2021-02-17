library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity Controller is
	generic ( WIDTH : positive := 32);
	port (
		clk 		: in std_logic;
		rst			: in std_logic;
		IR_OpCode	: in std_logic_vector(5 downto 0);
		IR_20_16	: in std_logic_vector(4 downto 0);
		funct 		: in std_logic_vector(5 downto 0);
		IR_offset	: in std_logic_vector(15 downto 0);
		
		PCWrite		: out std_logic;
		PCWriteCond	: out std_logic;
		IorD		: out std_logic;
		MemRead		: out std_logic;
		MemWrite	: out std_logic;
		MemToReg	: out std_logic;
		IRWrite		: out std_logic;
		JumpAndLink	: out std_logic;
		IsSigned	: out std_logic;
		PCSource	: out std_logic_vector(1 downto 0); 
		ALUOp		: out std_logic_vector(5 downto 0); --OPSelect for ALU
		ALUSrcA		: out std_logic;
		ALUSrcB		: out std_logic_vector(1 downto 0);
		RegWrite	: out std_logic;
		RegDst		: out std_logic
	);
end Controller;

architecture FSMD of Controller is
	type STATE_TYPE is (FETCH, DECODE, 
						RTYPE_S, R_TYPE_COMPLETE,
						ITYPE_S, I_TYPE_COMPLETE,
						BRANCH_S, BRANCH_DELAY,
						MEMORY_ACCESS, LOAD_S, STORE_S, MEMORY_READ, DELAY_READ, DELAY_STORE,
						JUMP_S, JUMP_DELAY, JUMPNLINK_S, JUMPREG_DELAY,
						HALT_S);
	signal state, next_state : STATE_TYPE;
begin 
	process(rst, clk) 
	begin
		if (rst = '1') then
			state <= FETCH;
		elsif (rising_edge(clk)) then
			state <= next_state;
		end if;
	end process;
	
	process(state, IR_OpCode, IR_20_16, funct, IR_offset)
	begin
		------- DEFUALT ASSIGNMENTS --------
		PCWrite		<= '0';
		PCWriteCond	<= '0';
		IorD		<= '0';
		MemRead		<= '0';
		MemWrite	<= '0';
		MemToReg	<= '0';
		IRWrite		<= '0';
		JumpAndLink	<= '0';
		IsSigned	<= '1';			--Defaul sign extend immediate value
		PCSource	<= "00";
		ALUOp		<= OP_BranchADD;	--Default addUN instruction
		ALUSrcA		<= '0';
		ALUSrcB		<= "00";
		RegWrite	<= '0';
		RegDst		<= '0';
		
		next_state 	<= state;

		
		case state is 
		When FETCH => --This state reads next instruction and increments PC by 4
			--PC count currently 0
			IorD 	 <= '0';			--PCmux selects current PC count
			MemRead  <= '1'; 			--Read instruction from SRAM 
			IRWrite  <= '1'; 			--Store instruction into Instruction Register
			ALUSrcA  <= '0'; 			--MuxA selects PC count
			ALUSrcB  <= "01"; 			--MuxB selects Constant 4
			ALUOp 	 <= OP_BranchADD;	--ALU chooses an R_Type instruction
			PCSource <= "00";			--OutputMux1 selects result from ALU PC = PC+4
			PCWrite  <= '1';			--Load the new PC count back into PC register
		
			next_state <= DECODE;
		
		When DECODE	=>
			--PC count is now 4

			ALUSrcA <= '0'; 			--Mux A selects PC count
			ALUSrcB <= "11";			--Mux B selects immediate value << 2
			ALUOp 	<= OP_BranchADD; 	--ALU instruction defualt adds
			
			if(IR_OpCode = R_TYPE) then
				next_state <= RTYPE_S; 		--r-type state
				
			elsif(IR_OpCode = OP_loadW OR IR_OpCode = OP_storeW) then
				IsSigned <= '0';
				next_state <= MEMORY_ACCESS;	--load or store state
			
			elsif((IR_OpCode = OP_BE) OR (IR_OpCode = OP_BNE) OR (IR_OpCode = OP_BLTE) OR (IR_OpCode = OP_BGT) OR (IR_OpCode = "000001")) then
				--OpCode "000001" is the same for both BLT and BGTE
				--The BRANCH state will handle the dual OpCode and send a different value
				--When moved to the next state the addition of the PC count plus offset is loaded into the ALU Out register
				
				next_state <= BRANCH_S;		--Branch state
				
			elsif(IR_OpCode = OP_jumpaddr) then
				next_state <= JUMP_S;		--State for Jump
			
			elsif(IR_OpCode = OP_JnL) then	
				--Load ALU with constant value 4
				next_state <= JUMPNLINK_S;
				
			elsif(IR_OpCode >= "001001" AND IR_OpCode <= "010000") then
				AluOp <= IR_OpCode;
				next_state <= ITYPE_S;
			
			elsif(IR_OpCode = OP_HALT) then
				next_state <= HALT_S;
				
			end if;
		
		
		When RTYPE_S =>
			ALUOp <= IR_OpCode; --"000000"
			ALUSrcA <= '1'; 	--selects data from register rs
			ALUSrcB <= "00"; 	--selects data from register rt
			
			if(funct = F_mflo OR funct = F_mfhi) then
				RegDst <= '1';
				RegWrite <= '1';
				next_state <= FETCH;	
				
			elsif(funct = F_jumpreg) then
				PCSource <= "00"; --Alu result is the data from register rs which is selected
				PCWrite  <= '1'; --data from rs is what the PC count is updated to
				next_state <= JUMPREG_DELAY; --Once jump register instruction is finished must retrieve next instruction
			
			else
			next_state <= R_TYPE_COMPLETE;
			--Because the ALU and ALU_Controller aren't synched to the clock the output of the ALU 
			--Is already loaded into the ALU_out register
			end if;
			
		When R_TYPE_COMPLETE =>
			MemToReg <= '0'; 	-- Selects AluOut register for the MuxData
			RegDst <= '1';		-- Selects register rd as address to write to in register file
			RegWrite <= '1';	-- Writes to register Rd with the data from AluOut;
			
			next_state <= FETCH;	-- Instruction complete read the next instruction in the SRAM.
		
		When JUMPREG_DELAY =>
				PCSource <= "00"; --Alu result is the data from register rs which is selected
				PCWrite  <= '1'; --data from rs is what the PC count is updated to
				
				next_state <= FETCH;
		
		When ITYPE_S =>
			IsSigned <= '0';
			ALUOp <= IR_OpCode; --AluOP is the corresponding I_Type instruction
			ALUSrcA <= '1';		--Selects data from rs as input 1
			ALUSrcB <= "10";	--Selects sign extended offset value as input
			
			next_state <= I_TYPE_COMPLETE;
			--ALU out reg is updated with alu result in the next state
			
		When I_TYPE_COMPLETE =>
			
			ALUSrcB <= "01";
			MemToReg <= '0'; 	--Selects Alu Out Reg as input for write data to register
			RegDst <= '0';		--Selects register Rt as destination register to be written to in the register file
			RegWrite <= '1';	--Write enabled on for writing to register file
			
			next_state <= FETCH;
			
		When MEMORY_ACCESS =>
			ALUSrcA <= '1'; 	--Selects base value from register Rs
			ALUSrcB <= "10";	--Selects sign extended offset value
			IsSigned <= '0';
			ALUOp <= IR_OpCode;	--Sends AluController OpCode for base+offset
			
			if(IR_OpCode = OP_loadW) then
				next_state <= LOAD_S; 	--must go to next state in order to load the ALU Out register
				
			elsif(IR_OpCode = OP_storeW) then
				RegDst <= '0';	--Get data from Register Rt in the Register file
				next_state <= STORE_S; 	--must go to next state in order to load the ALU Out register
										-- RegB will also be updated with the data from Register Rt
			end if;
			
			
		When LOAD_S =>	
			IorD <= '1'; 				--Memory address at Alu_out 
			MemRead <= '1';				--access SRAM at that address
			
			next_state <= MEMORY_READ;	 --moving to the next state will load the Memory Data Register
			
			
		When MEMORY_READ =>
			MemRead <= '1';				--access SRAM at that address
			RegDst <= '0';				--Selects Register Rt
			MemToReg <= '1';			--Selects Memory Data Register
			RegWrite <= '1'; 			--Loads Register Rt in register file with data accessed in the SRAM
			
			if(IR_offset = x"FFF8" OR IR_offset = x"FFFC") then
				next_state <= FETCH;		--Instruction is finished must fetch another
			else
				next_state <= DELAY_READ;
			end if;
		
		When DELAY_READ => 
			RegDst <= '0';				--Selects Register Rt
			MemToReg <= '1';			--Selects Memory Data Register
			RegWrite <= '1'; 			--Loads Register Rt in register file with data accessed in the SRAM
		
			next_state <= FETCH;
			
			
		When STORE_S =>
			IorD <= '1';		--Memory access at the location specified by the ALU Out register
			MemWrite <= '1';	--SRAM at address accessed will be loaded from RegB(data from register Rt)
			
			next_state <= DELAY_STORE;
			-- if(IR_offset = x"FFFC") then
				-- next_state <= FETCH;
			-- else 
				-- next_state <= DELAY_STORE;
			-- end if;
				
		When DELAY_STORE =>
			--IorD <= '1';	
			--MemWrite <= '1';
			ALUSrcB <= "01";
			
			
			next_state <= FETCH;
			
			
		When BRANCH_S =>
		--The ALU Out register hold the PC + offset value
			if(IR_OpCode = "000001") then	--These branches have a different register for IR{20:16]
				if(IR_20_16 = "00000") then --This is branch for BLT
					ALUOp <= OP_BLT;	--AluOp = 0x30
				elsif(IR_20_16 = "00001") then --This is branch for BGTE
					ALUOp <= OP_BGTE;	--To differentiate will give the AluOp = 0x31
				end if;
			else
				ALUop <= IR_OpCode;
			end if;
							
			ALUSrcA <= '1'; 		-- Load ALU with RegA (data from rs)
			ALUSrcB <= "00";	-- Load ALU with RegB (data from rt)
			PCSource <= "01";	-- Selects ALU Out Register which holds the PC count + offset value
			PCWriteCond <= '1'; -- If Branch is '1' the PC register gets updated with the offset addition
			
			next_state <= BRANCH_DELAY; --Instruction is finished must retrieve the next instruction
			
		when BRANCH_DELAY =>
			PCSource <= "01";	-- Selects ALU Out Register which holds the PC count + offset value
			PCWriteCond <= '1'; -- If Branch is '1' the PC register gets updated with the offset addition
			
			next_state <= FETCH;
			
		
		When JUMP_S =>
			PCSource <= "10";	-- Selects PC[31:28] concatenated with (instr_index << 2)
			PCWrite  <= '1';	-- Updated PC with the targeted address;
			
			if(IR_OpCode = OP_JnL) then
				JumpAndLink <= '1'; 
				RegWrite <= '1'; 	
				MemToReg <= '0'; 	
			end if;
			-- No need for ALU for this instruction
			-- Need a delay state because PC out needs to be updated with the correct value 
			next_state <= JUMP_DELAY; 
			
		When JUMP_DELAY =>
			PCSource <= "10";	
			PCWrite  <= '1';	
			
			next_state <= FETCH;
			
			
		WHEN JUMPNLINK_S =>
				ALUOp 	<= OP_JnL;	--ALU Out reg equals PC count + 4 
				JumpAndLink <= '1'; --Write data to register 31
				RegWrite <= '1'; 	--Enables write to register file
				MemToReg <= '0'; 	--Selects ALU Out reg to be the data data written to register 31
				
				next_state <= JUMP_S; --Jump to the targeted address
		
		
		When HALT_S =>	--Stay in this state when the HALT Op code is read from the mif file
			next_state <= HALT_S;
		
		When Others => NULL;
		end case;
	end process;
end FSMD;
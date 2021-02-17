library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity datapath is
	generic(Width : positive := 32);
	port(
		clk					: in std_logic;
		rst					: in std_logic;	
	------ CONTROLLER SIGNALS ------------
		PCWrite				: in std_logic;
		PCWriteCond			: in std_logic;
		IorD				: in std_logic;
		MemRead				: in std_logic;
		MemWrite			: in std_logic;
		MemToReg			: in std_logic;
		IRWrite				: in std_logic;
		JumpAndLink			: in std_logic;
		IsSigned			: in std_logic;
		PCSource			: in std_logic_vector(1 downto 0); 
		ALUOp				: in std_logic_vector(5 downto 0); --OPSelect for ALU
		ALUSrcA				: in std_logic;
		ALUSrcB				: in std_logic_vector(1 downto 0);
		RegWrite			: in std_logic;
		RegDst				: in std_logic;
		
	---------- DATAPATH SIGNALS --------------
		IR					: out std_logic_vector(Width-1 downto 0);
	
	
	--------- TOP LEVEL INTERFACE ------------
		InPortSW			: in std_logic_vector(9 downto 0);		-- Connected to the switches on the FPGA
		InPort_en_button	: in std_logic;							-- Connected to button switch 0 on the FPGA
		Outport_LEDs		: out std_logic_vector(Width-1 downto 0)--Connected to the 4 7-segment LEDs
	);
end datapath;


architecture STR of datapath is 
	------------------ Program Counter -----------------------
	signal PC_en	 	: std_logic;
	signal PC_input		: std_logic_vector(Width-1 downto 0);
	signal PC_out		: std_logic_vector(Width-1 downto 0);
	
	------------------ RegA/RegB Counter ---------------------
	signal RegA_out		: std_logic_vector(Width-1 downto 0);
	signal RegB_out		: std_logic_vector(Width-1 downto 0);
	signal MuxA_out		: std_logic_vector(Width-1 downto 0);
	signal MuxB_out		: std_logic_vector(Width-1 downto 0);
	signal MuxB_in4		: std_logic_vector(Width-1 downto 0);

	------------------ ALU Registers -----------------------
	signal Result		: std_logic_vector(Width-1 downto 0);
	signal ResultHI		: std_logic_vector(Width-1 downto 0);
	signal BranchTaken 	: std_logic;
	signal ALU_out		: std_logic_vector(Width-1 downto 0);
	signal LO_out		: std_logic_vector(Width-1 downto 0);
	signal HI_out		: std_logic_vector(Width-1 downto 0);
	signal Mux2_out		: std_logic_vector(Width-1 downto 0);
	signal Mux2_sel		: std_logic_vector(1 downto 0);
	signal SignEx_out	: std_logic_vector(Width-1 downto 0);
	signal Concat_out	: std_logic_vector(Width-1 downto 0);
	signal LO_en		: std_logic;
	signal HI_en		: std_logic;
	signal OPSelect 	: std_logic_vector(5 downto 0);
	
	------------------ 		Memory	 -----------------------
	signal Mem_in		: std_logic_vector(Width-1 downto 0);
	signal Mem_Out		: std_logic_vector(Width-1 downto 0);
	signal InPort_full	: std_logic_vector(Width-1 downto 0);
	
	--------- Instruction Reg / Memory Data Register --------
	signal IR_Out		: std_logic_vector(Width-1 downto 0);
	signal MemDataOut	: std_logic_vector(Width-1 downto 0);
	
	-------------------- Register File -----------------------
	signal wr_Reg		: std_logic_vector(4 downto 0);
	signal wr_data		: std_logic_vector(Width-1 downto 0);
	signal read_data1	: std_logic_vector(Width-1 downto 0);
	signal read_data2	: std_logic_vector(Width-1 downto 0);

begin
	
	PC_en <= (BranchTaken AND PCWriteCond) OR PCWrite;
	
	UUT_PC : entity work.reg 
	generic map (Width => Width)
	port map(
		clk  	=> clk,
	    rst   	=> rst,
	    load  	=> PC_en,
	    input 	=> PC_input, --From OutputMux1
	    output	=> PC_out
	);
	
	UUT_MuxPC : entity work.mux2x1
	generic map (Width => Width)
	port map (
		in1 	=>  PC_out,		--PC
	    in2  	=>	ALU_out,	--ALU_out
	    sel   	=>	IorD,		--IorD from Controller
	    output	=>	Mem_in		--Memory address/data
	);
	
	
	UUT_Memory : entity work.memory
	generic map (WIDTH => WIDTH)
	port map (
		clk				=> clk,
		rst				=> rst,
		address			=> Mem_in,
		MemRead			=> MemRead,
		MemWrite		=> MemWrite,
		InPort_en		=> InPort_en_button,	
		InPort1or0_en	=> InPortSW(9),			
		InPort0			=> InPort_full,			--Switches
		InPort1			=> InPort_full,			--Switches
		RegB_in			=> RegB_out,
		Outport			=> Outport_LEDs,
		read_data		=> Mem_Out
	);
	
	IR <= IR_Out;
	
	UUT_ZeroExtend : entity work.ZeroExtend
	generic map (
		WIDTH => WIDTH,
		INWIDTH => 9)
	port map (
		Input 	=> InPortSW(8 downto 0),	--9 switches are the input value
		Output  => InPort_full
		);
		
	
	UUT_instructionReg: entity work.reg
	generic map (Width => Width)
	port map (
		clk  	=> clk,
	    rst   	=> rst,
	    load  	=> IRWrite,
	    input 	=> Mem_Out,
	    output	=> IR_Out
	);
	
	UUT_MemDataReg : entity work. reg
	generic map (Width => Width)
	port map (
		clk  	=> clk,
	    rst   	=> rst,
	    load  	=> '1', --Always high
	    input 	=> Mem_Out,
	    output	=> MemDataOut
	);	
	
	UUT_MuxReg: entity work.mux2x1		-- Mux for Write Register in Register File
	generic map (Width => 5)
	port map(
		in1 	=>  IR_Out(20 downto 16), --IR[20:16]
	    in2  	=>	IR_Out(15 downto 11), --IR[15:11]
	    sel   	=>	RegDst,				  --RegDst from Controller
	    output	=>	wr_Reg				  --Write Register in Regsiter File
	);
	
	UUT_MuxData: entity work.mux2x1		-- Mux for Write Data in Register File
	generic map (Width => Width)
	port map(
		in1 	=>   Mux2_out,		--From OutputMux2
	    in2  	=>	 MemDataOut,	--Memory Data Register
	    sel   	=>	 MemToReg, 		--MemToReg from Controller
	    output	=>	 wr_data		--Write data in Register File
	);
	
	
	UUT_RegFile	: entity work.register_file
	port map (
		clk 		=> clk,
		rst 		=> rst,
		rd_addr0 	=> IR_Out(25 downto 21),
		rd_addr1 	=> IR_Out(20 downto 16),
		wr_addr 	=> wr_Reg,
		wr_en 		=> RegWrite,
		JumpNLink	=> JumpAndLink, --NOT FINISHED IN REGISTER_FILE.VHD
		wr_data 	=> wr_data,
		rd_data0 	=> read_data1,
		rd_data1 	=> read_data2
	);
	
	UUT_signExtend : entity work.signExtend
	generic map (
		Width => Width,
		INWIDTH => 16)
	port map (
		IsSigned => IsSigned,
	    Input	 =>	IR_Out(15 downto 0),
	    Output	 =>	SignEx_out
	);

	UUT_RegA: entity work.reg
	generic map (Width => 32)
	port map (
		clk  	=> clk,
	    rst   	=> rst,
	    load  	=> '1',
	    input 	=> read_data1,
	    output	=> RegA_out
	);


	UUT_RegB: entity work.reg
	generic map (Width => 32)
	port map (
		clk  	=> clk,
	    rst   	=> rst,
	    load  	=> '1',
	    input 	=> read_data2,
	    output	=> RegB_out
	);


	UUT_MuxA: entity work.mux2x1
	generic map (Width => 32)
	port map (
		in1 	=> PC_out,
	    in2  	=> RegA_out,
	    sel   	=> ALUSrcA,
	    output	=> MuxA_out
	);
	
	MuxB_in4 <= std_logic_vector(shift_left(signed(SignEx_out), 2));	--Arithmetic shift to keep the sign
	
	UUT_MuxB: entity work.mux4x1
	generic map (Width => 32)
	port map (
		in1  	=> RegB_out,
	    in2   	=> C_4,
	    in3   	=> SignEx_out,
	    in4   	=> MuxB_in4,
	    sel   	=> ALUSrcB,
	    output	=> MuxB_out
	);
	

	UUT_ALU: entity work.alu
	generic map (Width => 32)
	port map (
		input1 		=> MuxA_out,
		input2 		=> MuxB_out,
		H 	  		=> IR_Out(10 downto 6),
		OPSelect	=> OPSelect, --From ALU CONTROLLER
		output 		=> Result,
		outputHI 	=> ResultHI,
		Branch 		=> BranchTaken
	);
	
	UUT_ALUController : entity work.ALU_Controller
	generic map (WIDTH => 6)
	port map(
		ALUOp		=> ALUOp,
	    funct  		=> IR_Out(5 downto 0),
	    HI_en		=> HI_en,
	    LO_en		=> LO_en,
	    OPSel		=> OPSelect,
	    ALU_LO_HI	=> Mux2_sel
	);
	
	UUT_ShiftLeft2Concat : entity work.ShiftLeft2Concat
	generic map (
		WORD	  => Width,
		WIDTH	  => 26,
		INWIDTH	  => 4)
	port map (
		Input 		=> IR_Out(25 downto 0),	
	    Concat_in	=> PC_out(31 downto 28),
	    Output		=> Concat_out
	);
	
	UUT_AluOutreg : entity work.reg
	generic map (Width => 32)
	port map (
		clk  	=> clk,
	    rst   	=> rst,
	    load  	=> '1',
	    input 	=> Result,
	    output	=> ALU_out
	);

	UUT_LOreg : entity work.reg
	generic map (Width => 32)
	port map (
		clk  	=> clk,
	    rst   	=> rst,
	    load  	=> LO_en, -- From ALU controller
	    input 	=> Result,
	    output	=> LO_out
	);


	UUT_HIreg : entity work.reg
	generic map (Width => 32)
	port map (
		clk  	=> clk,
	    rst   	=> rst,
	    load  	=> HI_en, -- From ALU controller
	    input 	=> ResultHI,
	    output	=> HI_out
	);
	
	UUT_OutputMux1 : entity work.mux4x1
	generic map (Width => 32)
	port map (
		in1  	=> Result,			--Result from ALU
	    in2   	=> ALU_out,			--ALU Out register
	    in3   	=> Concat_out,		--IR[25:0] shift left 2 and concatenated wiht PC[31:28]
	    in4   	=> (others => '0'),	--TIE THIS LOW
	    sel   	=> PCSource,		--PC Source from Controller
	    output	=> PC_input
	);


	UUT_OutputMux2 : entity work.mux4x1		--Mux for ALU OUT, LO, and HI registers
	generic map (Width => 32)
	port map (
		in1  	=> ALU_out,
	    in2   	=> LO_out,
	    in3   	=> HI_out,
	    in4   	=> (others => '0'),	--TIE THIS LOW
	    sel   	=> Mux2_sel,		-- From ALU CONTROLLER
	    output	=> Mux2_out
	);
	

end STR;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity mips_architecture is
	generic (WIDTH : positive := 32);
	port (
		clk			: in std_logic;
		rst			: in std_logic;
		Inport_en	: in std_logic;
		Inport		: in std_logic_vector(9 downto 0);
		Outport		: out std_logic_vector(Width-1 downto 0)
	);
end mips_architecture;


architecture STR of mips_architecture is
	signal IR_Out 		: std_logic_vector(WIDTH-1 downto 0);
	signal PCWrite 		: std_logic;
	signal PCWriteCond 	: std_logic;
	signal IorD			: std_logic;
	signal MemRead		: std_logic;
	signal MemWrite		: std_logic;
	signal MemToReg		: std_logic;
	signal IRWrite		: std_logic;
	signal JumpAndLink	: std_logic;
	signal IsSigned		: std_logic;
	signal PCSource		: std_logic_vector(1 downto 0);
	signal ALUOp		: std_logic_vector(5 downto 0);
	signal ALUSrcA		: std_logic;
	signal ALUSrcB		: std_logic_vector(1 downto 0);
	signal RegWrite		: std_logic;
	signal RegDst		: std_logic;

begin
	
	
	UUT_Controller: entity work.Controller
		generic map (WIDTH => WIDTH)
		port map(
			clk 		=> clk,
			rst			=> rst,
			IR_OpCode	=> IR_Out(31 downto 26),
			IR_20_16	=> IR_Out(20 downto 16),
		    funct 		=> IR_Out(5 downto 0),
			IR_offset 	=> IR_Out(15 downto 0),
		    
		    PCWrite		=> PCWrite, 		
		    PCWriteCond	=> PCWriteCond, 	
		    IorD		=> IorD,			
		    MemRead		=> MemRead,		
		    MemWrite	=> MemWrite,		
		    MemToReg	=> MemToReg,		
		    IRWrite		=> IRWrite,		
		    JumpAndLink	=> JumpAndLink,	
		    IsSigned	=> IsSigned,		
		    PCSource	=> PCSource,		
		    ALUOp		=> ALUOp,		
		    ALUSrcA		=> ALUSrcA,		
		    ALUSrcB		=> ALUSrcB,		
		    RegWrite	=> RegWrite,		
		    RegDst		=> RegDst		
		);
		
		
	UUT_datapath: entity work.datapath
		generic map (WIDTH => WIDTH)
		port map(
			clk					=>	clk,	
			rst					=>	rst,
			
			PCWrite				=> PCWrite, 	
			PCWriteCond			=> PCWriteCond, 
			IorD				=> IorD,		
			MemRead				=> MemRead,		
			MemWrite			=> MemWrite,	
			MemToReg			=> MemToReg,	
			IRWrite				=> IRWrite,		
			JumpAndLink			=> JumpAndLink,	
			IsSigned			=> IsSigned,	
			PCSource			=> PCSource,	
			ALUOp				=> ALUOp,		
			ALUSrcA				=> ALUSrcA,		
		    ALUSrcB				=> ALUSrcB,		
		    RegWrite			=> RegWrite,	
		    RegDst				=> RegDst,		
			
			IR					=> IR_Out,
		    
		    InPortSW			=> InPort,
		    InPort_en_button	=> Inport_en,
		    Outport_LEDs		=> Outport
		);

end STR;
		
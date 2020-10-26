library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;




entity control_test is 

end control_test;


architecture Behavioral of control_test is

component ControlUnit
port(
	--сброс и тактирование
	i_clk:			in std_logic;
	i_reset:			in std_logic;
	i_IR:				in unsigned(15 downto 0);
	i_ALU_Z:			in std_logic;

	o_reset:			out std_logic;
	o_mode12K:		out std_logic_vector(1 downto 0);
	o_modeAddZA:	out std_logic_vector(1 downto 0);
	o_modePCZ:		out std_logic;
	o_loadPC:		out std_logic;
	o_loadIR:		out std_logic;
	o_writeReg:		out std_logic;
	o_ldi:			out std_logic;

	o_K:				out unsigned(15 downto 0);

	o_write_stack:	out std_logic;
	o_read_stack:	out std_logic;
	o_push: 			out std_logic;
	o_pop:			out std_logic
	
);
end component;

signal i_clk : std_logic := '0';
signal i_reset : std_logic := '0';
signal I_ALU_Z : std_logic := '0';
signal o_reset, o_modePCZ, o_loadPC, o_loadIR : std_logic;
signal o_writeReg, o_ldi, o_write_stack : std_logic;
signal o_read_stack, o_push, o_pop : std_logic;
signal i_IR, o_K : unsigned(15 downto 0);
signal o_mode12K, o_modeAddZA : std_logic_vector(1 downto 0);

constant per_clk : time := 20 ns;

begin

	--инстанс компонента
	uut : ControlUnit port map(
		i_clk => i_clk,
		i_reset => i_reset,
		
		i_IR => i_IR,
		i_ALU_Z => i_ALU_Z,
		
		o_reset => o_reset,
		o_mode12K => o_mode12K,
		o_modeAddZA => o_modeAddZA,
		o_modePCZ => o_modePCZ,
		o_loadPC => o_loadPC,
		o_loadIR => o_loadIR,
		o_writeReg => o_writeReg,
		
		o_ldi => o_ldi,
		
		o_write_stack => o_write_stack,
		o_read_stack => o_read_stack,
		o_push => o_push,
		o_pop => o_pop
		
		
	);
	
	--тактирование
	clk_gen : process 
	begin
		wait for per_clk / 2;
		i_clk <= not i_clk;
	end process;
	
	--тестовое воздействие 
	stimulus : process
	begin
	
		wait for per_clk;
		i_reset <= '1';
		wait for per_clk * 3;
		i_reset <= '0';
		i_IR <= x"0e2e";
		
		wait;
	end process;

end Behavioral; 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
--use ieee.std_logic_signed.all;




entity control_test is 

end control_test;


architecture Behavioral of control_test is

component ControlUnit
port(
	--сброс и тактирование
	i_clk:			in std_logic;
	i_reset:			in std_logic;
	i_IR:				in unsigned(15 downto 0);

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

procedure test_alu_write(-- cp r7,r16
	signal s_writeReg, s_loadIR : in std_logic;
	signal s_loadPC : in std_logic;
	signal s_mode12K, s_modeAddZA : in std_logic_vector(1 downto 0);
	signal s_IR : out unsigned(15 downto 0)) is 	
begin
	s_IR <= x"0e2e"; -- add r2,r30
	report "add test" severity note;
	wait for per_clk;
	assert (s_mode12K = "00" and s_modeAddZA = "00" and s_loadPC = '1') 
	report "program counter signals error" severity error;
	assert (s_mode12K /= "00" or s_modeAddZA /= "00" or s_loadPC /= '1') 
	report "program counter signals ok" severity note; 
	wait for per_clk;
	assert s_loadIR = '1' report "command load signal error" severity error;
	assert s_loadIR /= '1' report "command load signal ok" severity note;
	wait for per_clk * 3;
	assert (s_writeReg = '1') report "alu output signal error" severity error;
	assert (s_writeReg /= '1') report "alu output signal ok" severity note;
	s_IR <= x"0000";
end procedure;

procedure test_alu_nowrite(
	signal s_writeReg: in std_logic;
	
	signal s_IR : out unsigned(15 downto 0)) is 	
begin
	s_IR <= x"1670"; -- cp r7,r16
	report "cp test" severity note;
	wait for per_clk * 5;
	assert (s_writeReg = '0') report "alu output signal error" severity error;
	assert (s_writeReg /= '0') report "alu output signal ok" severity note;
	s_IR <= x"0000";
end procedure;

procedure test_ijmp(
	signal s_loadPC : in std_logic;
	signal s_modeAddZA : in std_logic_vector(1 downto 0);
	signal s_IR : out unsigned(15 downto 0)) is 	
begin
	s_IR <= x"9409"; -- ijmp
	report "ijmp test" severity note;
	wait for per_clk * 4;
	assert (s_loadPC = '1' and s_modeAddZA = "10")
	report "pc output signal error" severity error;
	assert (s_loadPC /= '1' or s_modeAddZA /= "10")
	report "pc output signal ok" severity note;
	s_IR <= x"0000";
end procedure;

procedure test_rjmp(
	signal s_loadPC : in std_logic;
	signal s_mode12K : in std_logic_vector(1 downto 0);
	signal s_K : in unsigned(15 downto 0);
	signal s_IR : out unsigned(15 downto 0)) is
begin
	s_IR <= x"C007"; -- rjmp +7
	report "rjmp test" severity note;
	wait for per_clk * 4;
	assert (s_loadPC = '1' and s_mode12K = "10")
	report "pc output signal error" severity error;
	assert (s_loadPC /= '1' or s_mode12K /= "10")
	report "pc output signal ok" severity note;
	assert (s_K = x"0007")
	report "jump value error" severity error;
	assert (s_K /= x"0007")
	report "jump value ok" severity note;

	s_iR <= x"0000";
end procedure;

procedure test_ldi(
	signal s_ldi, s_writeReg  : in std_logic;
	signal s_IR : out unsigned(15 downto 0)) is
begin
	s_IR <= x"E007"; -- ldi r16, 7 
	report "ldi test" severity note;
	wait for per_clk * 4;
	assert (s_ldi = '1' and s_writeReg = '1')
	report "register write output signal error" severity error;
	assert (s_ldi /= '1' or s_writeReg /= '1')
	report "register write output signal ok" severity note;
	s_IR <= x"0000";
end procedure;

procedure test_pop(
	signal s_writeReg, s_pop : in std_logic;
	signal s_read_stack : in std_logic;
	signal s_IR : out unsigned(15 downto 0)) is
begin
	s_IR <= x"909F"; --pop r9
	report "pop test" severity note;
	wait for per_clk * 4;
	assert (s_pop = '1' and s_read_stack = '1') 
	report "stack output signals error" severity error;
	assert (s_pop /= '1' or S_read_stack /= '1')
	report "stack output signals ok" severity note;
	assert (s_writeReg = '1') 
	report "register write output signal error" severity error;
	assert (s_writeReg /= '1')
	report "register write output signal ok" severity note;
	s_IR <= x"0000";
end procedure;
	
procedure test_push(
	signal s_write_stack : in std_logic;
	signal s_IR : out unsigned(15 downto 0)) is
begin
	s_IR <= x"923F"; --push r3
	report "push test" severity note;
	wait for per_clk * 4;
	assert (s_write_stack = '1') 
	report "stack output signal error" severity error;
	assert (s_write_stack /= '1')
	report "stack output signal ok" severity note;
	s_IR <= x"0000";
end procedure;
begin
	--инстанс компонента
	uut : ControlUnit port map(
		i_clk => i_clk,
		i_reset => i_reset,
		i_IR => i_IR,
		o_reset => o_reset,
		o_mode12K => o_mode12K,
		o_modeAddZA => o_modeAddZA,
		o_modePCZ => o_modePCZ,
		o_loadPC => o_loadPC,
		o_loadIR => o_loadIR,
		o_writeReg => o_writeReg,
		o_ldi => o_ldi,
		o_K  => o_K,
		o_write_stack => o_write_stack,
		o_read_stack => o_read_stack,
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
		test_alu_write(o_writeReg, o_loadIR, o_loadPC, o_mode12K, o_modeAddZA, i_IR);
		test_alu_nowrite(o_writeReg, i_IR);
		test_ijmp(o_loadPC, o_modeAddZA, i_IR);
		test_rjmp(o_loadPC, o_mode12K,  o_K, i_IR);
		test_ldi(o_ldi, o_writeReg, i_IR);
		test_pop(o_writeReg, o_pop, o_read_stack, i_IR);
		test_push(o_write_stack, i_IR);
		report "simulation end" severity failure;
		end process;

end Behavioral; 
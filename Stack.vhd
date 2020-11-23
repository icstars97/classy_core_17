library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Stack is
port (
	i_clk:			in std_logic;
	i_data: 			in unsigned(7 downto 0);
	i_addr:			in unsigned(15	downto 0);
	i_write:			in std_logic;
	o_data: 			out unsigned(7 downto 0)
);
end Stack;


architecture Behavioral of Stack is
type STACK_MEM is array(31 downto 0) of unsigned(7 downto 0);
signal S : STACK_MEM := (others=>(others=>'0'));
begin
	process (i_clk)
begin
	if rising_edge(i_clk) then
		if(i_write = '0') then
			o_data <= S(to_integer(i_addr));
		else
			S(to_integer(i_addr) - 1) <= i_data;
		end if;
	end if;
end process;
end Behavioral;
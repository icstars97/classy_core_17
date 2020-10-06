library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Stack is
port (
	i_clk:			in std_logic;
	i_data: 			in unsigned(7 downto 0);
	
	o_data: 			out unsigned(7 downto 0);
	i_write:			in std_logic;
	i_read:			in std_logic
	
);
end Stack;


architecture Behavioral of Stack is
type STACK_MEM is array(31 downto 0) of unsigned(7 downto 0);
signal S : STACK_MEM;
begin
	process(i_clk)
	variable SP: integer range 0 to 32 := 31; -- stack pointer
	begin
	if (i_clk'event and i_clk='1') then
		if(i_write = '1') then
			S(SP) <= i_data;
			SP := SP - 1;
		elsif(i_read = '1') then
			o_data <= S(SP + 1);
			SP := SP + 1;
		else o_data <= "XXXXXXXX";
		end if;
	end if;
end process;
end Behavioral;
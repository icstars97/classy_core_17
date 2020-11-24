library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Contains the program instructions
entity ProgramMemory is
port ( 
	i_clk:			in std_logic;
	i_addr:			in unsigned(15 downto 0);
	o_data:			out unsigned(15 downto 0)
);
end ProgramMemory;

architecture Behavioral of ProgramMemory is

type PROGMEM is array(10 downto 0) of unsigned(15 downto 0);

signal s_pm: PROGMEM := (

x"0000", -- nop
x"9409", -- ijmp
x"2de3", -- mov r30, r3
x"0000", -- nop
x"c001", -- rjmp 1
x"0e0e", -- add r0, r30
x"900f", -- pop r0
x"93ef", -- push r30
x"0000", -- nop
x"1010", -- cpse r1, r0
x"e0e3"  -- ldi r30,3

);

begin

process (i_clk)
begin
	if rising_edge(i_clk) then
		o_data <= s_pm(to_integer(i_addr));
	end if;
end process;

end Behavioral;

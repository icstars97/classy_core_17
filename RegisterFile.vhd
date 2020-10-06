library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Responsible to provide general-purpose registers R0..R31, I/O memory and RAM.
entity RegisterFile is
port ( 
	i_clk:			in std_logic;
	i_reset:			in std_logic;

	i_addr_r1:		in unsigned(4 downto 0);
	i_addr_r2:		in unsigned(4 downto 0);
	o_data_r1:		out unsigned(7 downto 0);
	o_data_r2:		out unsigned(7 downto 0);
	
	i_write:			in std_logic;
	i_addr_w:		in unsigned(4 downto 0);
	i_data_w:		in unsigned(7 downto 0);
	
	o_x:				out unsigned(15 downto 0);
	o_y:				out unsigned(15 downto 0);
	o_z:				out unsigned(15 downto 0)
);
end RegisterFile;

architecture Behavioral of RegisterFile is
type REGS is array(31 downto 0) of unsigned(7 downto 0);
signal R : REGS;
begin
	process(i_clk)
	begin
	if (i_clk'event and i_clk='1') then
		if(i_write = '0') then
			o_data_r1 <= R(to_integer(i_addr_r1));
			o_data_r2 <= R(to_integer(i_addr_r2));
		else 
			R(to_integer(i_addr_w)) <= i_data_w;
		end if;
		
		o_x <= (others => '0');
		o_y <= (others => '0');
		o_z <= (others => '0');
	end if;
end process;
end Behavioral;

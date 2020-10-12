library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RegisterFile is
port ( 
	i_clk:			in std_logic; --тактирование
	i_reset:			in std_logic; --сброс

	i_addr_r1:		in unsigned(4 downto 0); --адрес чтения данных 1
	i_addr_r2:		in unsigned(4 downto 0); --адрес чтения данных 2
	o_data_r1:		out unsigned(7 downto 0); --данные 1
	o_data_r2:		out unsigned(7 downto 0); --данные 2
	
	i_write:			in std_logic;	--сигнал разрешения записи
	i_addr_w:		in unsigned(4 downto 0);	--адрес записи
	i_data_w:		in unsigned(7 downto 0);	--данные для записи
	
	o_x:				out unsigned(15 downto 0);	--x пара
	o_y:				out unsigned(15 downto 0); --y пара
	o_z:				out unsigned(15 downto 0)  --z пара
);
end RegisterFile;

architecture Behavioral of RegisterFile is

type REGS is array(31 downto 0) of unsigned(7 downto 0); 
signal R : REGS;
begin

	o_x <= R(26) & R(27); --определение регистровых пар
	o_y <= R(28) & R(29);
	o_z <= R(30) & R(31);
	
	process(i_clk)
	begin
		if rising_edge(i_clk) then
			--сброс всех сигналов
			if (i_reset = '1') then  
				o_data_r1 <= (others => '0');
				o_data_r2 <= (others => '0');
				for i in 0 to 31 loop
					R(i) <= (others => '0');
				end loop;
			
		--чтение данных
			elsif (i_write = '0') then
				o_data_r1 <= R(to_integer(i_addr_r1)); 
				o_data_r2 <= R(to_integer(i_addr_r2));
				
				
				R(0) <= (others => '0');
				...
				R(31) <= (others => '0');
		
		--запись данных	
			else 
				R(to_integer(i_addr_w)) <= i_data_w; 
			end if;	
		end if;
	end process;

end Behavioral;

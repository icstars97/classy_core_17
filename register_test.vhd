library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;



entity register_test is 

end entity;
architecture Behavioral of register_test is

component RegisterFile 
	port(
		i_clk, i_reset : in std_logic;
		i_addr_r1, i_addr_r2 : in unsigned(4 downto 0);
		o_data_r1, o_data_r2 : out unsigned(7 downto 0);
		i_write : in std_logic;
		i_addr_w : in unsigned(4 downto 0);
		i_data_w : in unsigned(7 downto 0);
		o_x, o_y, o_z : out unsigned(15 downto 0)
	);
end component;

signal i_clk : std_logic := '0';
signal i_reset : std_logic := '0';
signal i_addr_r1, i_addr_r2 : unsigned(4 downto 0) := (others => '0');
signal o_data_r1, o_data_r2 : unsigned(7 downto 0) := (others => '0');
signal i_write : std_logic := '0';
signal i_addr_w : unsigned(4 downto 0) := (others => '0');
signal I_data_w : unsigned(7 downto 0) := (others => '0');
signal o_x, o_y, o_z : unsigned(15 downto 0);

 

constant per_clk : time := 20 ns;

begin 
	--инстанс тестируемого компонента
	uut : RegisterFile port map( 
		i_clk => i_clk, i_reset => i_reset,
		i_addr_r1 => i_addr_r1, i_addr_r2 => i_addr_r2,
		o_data_r1 => o_data_r1, o_data_r2 => o_data_r2,
		i_write => i_write,
		i_addr_w => i_addr_w,
		i_data_w => i_data_w,
		o_x => o_x, o_y => o_y, o_z => o_z
	);
	
	clk_gen : process --генератор тактового сигнала
	begin
	
		i_clk <= not i_clk;
		wait for per_clk / 2;
	end process;
	
	stimulus : process --тестовое воздействие
	begin
	
		wait for per_clk * 5;
		i_reset <= '1';
		wait for per_clk * 5;
		i_reset <= '0';
		wait for per_clk * 1.5;
		
		i_write <= '1';
		register_load : for i in 0 to 31 loop --цикл загрузки
			i_data_w <= to_unsigned(i, 8);
			i_addr_w <= to_unsigned(i, 5);
			wait for per_clk;
		end loop;
		report "register map load complete" severity note;
		i_write <= '0';
		wait for per_clk * 1.5;
		
		register_read : for i in 0 to 31 loop --цикл чтения
			i_addr_r1 <= to_unsigned(i, 5);
			i_addr_r2 <= to_unsigned(i, 5);
			report "output data 1 value: " & integer'image(to_integer(o_data_r1)) &
				" output data 2 value: " & integer'image(to_integer(o_data_r2)) severity note;
			assert o_data_r1 = o_data_r2 
			report "error: output data values do not match" severity error;
			wait for per_clk;	
		end loop;
		
		--проверяем правильность чтения регистровых пар x, y, z
		--здесь можно было бы показать как смотреть внутренние сигналы компонента
		--но я не нашёл как это делается в vhdl
		--report "x register pair value: " & 
			--integer'image(to_integer(o_x)) severity note; 
		report "simulation end" severity failure;
		wait;
	end process;

end Behavioral;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity ControlUnit is
port ( 
	i_clk:			in std_logic;
	i_reset:			in std_logic;
	-- входные сигналы автомата
	i_IR:				in unsigned(15 downto 0);
	i_zero:			in std_logic;
	-- сигналы управления 
	o_reset:			out std_logic;
	o_mode12K:		out std_logic_vector(1 downto 0);
	o_modeAddZA:	out std_logic_vector(1 downto 0);
	o_loadPC:		out std_logic;
	o_loadIR:		out std_logic;
	o_writeReg:		out std_logic;
	o_ldi:			out std_logic;
	-- данные
	o_K:				out unsigned(15 downto 0);
	-- работа со стеком
	o_write_stack:	out std_logic;
	o_SP: 			out unsigned(15 downto 0);
	o_read_stack:	out std_logic;
	o_pop : 			out std_logic
	
);
end ControlUnit;

architecture Behavioral of ControlUnit is
	
type PROGMEM is array(7 downto 0) of unsigned(15 downto 0);

type ControlUnitState is (
	CUS_RESET, 							-- начальное состояние, сброс всех регистров
	CUS_FETCH_1, 						-- выборка инструкции в регистр инструкций
	CUS_FETCH_2, 						-- ожидание памяти
	CUS_DECODE, 						-- декодирование инструкции
											-- 00XX
	CUS_EXEC_ALU_1, 					-- АЛУ выполняет инструкцию (ADD, MOV, ...)
	CUS_EXEC_ALU_2_WRITE, 			--  результат сохраняется (ADD, AND, SUB, MOV, ...)
	CUS_EXEC_ALU_2_NOWRITE, 		--  результат не сохраняется (CP, CPC, CPSE)
	CUS_EXEC_IJMP, 					-- выполнить IJMP
	CUS_EXEC_RJMP, 					-- выполнить RJMP 
	CUS_EXEC_LDI,
	CUS_EXEC_POP,
	CUS_EXEC_PUSH,
	CUS_EXEC_CPSE,
	CUS_SKIP
);

signal s_state: ControlUnitState;
signal SP: integer range 0 to 31 := 31; -- stack pointer

begin

-- комбинационная логика

o_reset <= '1' when s_state = CUS_RESET
			else '0';

o_mode12K <= "00" when (s_state = CUS_FETCH_1
			or s_state =CUS_SKIP)
			else "10" when s_state = CUS_EXEC_RJMP
			else "XX";
			
o_modeAddZA <= "00" when (
			s_state = CUS_FETCH_1 
			or s_state = CUS_EXEC_RJMP)
			else "10" when s_state = CUS_EXEC_IJMP
			else "XX";
			

			
o_loadPC <= '1' when (
				s_state = CUS_FETCH_1 
				or s_state = CUS_SKIP
				or s_state = CUS_EXEC_IJMP 
				or s_state = CUS_EXEC_RJMP)
			else '0' when s_state = CUS_DECODE 
			else 'X';

o_loadIR <= '1' when s_state = CUS_FETCH_2
			else '0';

o_writeReg <= '1' when (
				s_state = CUS_EXEC_ALU_2_WRITE
				or s_state = CUS_EXEC_LDI
				or s_state = CUS_EXEC_POP)
			else '0';
			
o_ldi <= '1' when s_state = CUS_EXEC_LDI 
			else '0';

-- выход данных

o_K <= unsigned(resize(signed(i_IR(11 downto 0)), 16)) when 
				s_state = CUS_EXEC_RJMP
			else "XXXXXXXXXXXXXXXX";

-- работа со стеком	
	
o_write_stack <= '1' when s_state = CUS_EXEC_PUSH
		else '0';

o_read_stack <= '1' when s_state = CUS_EXEC_POP
		else '0';
				
o_pop <= '1' when s_state = CUS_EXEC_POP
		else '0';

o_SP <= to_unsigned(SP, o_SP'length);
-- последовательностная логика

process (i_clk)
begin
	if rising_edge(i_clk) then
		if i_reset = '1' then
			s_state <= CUS_RESET;
		else
			case s_state is
				when CUS_RESET =>
					s_state <= CUS_FETCH_1;
				when CUS_SKIP =>
					s_state <= CUS_FETCH_1;
				when CUS_FETCH_1 =>
					s_state <= CUS_FETCH_2;
					
				when CUS_FETCH_2 =>
					s_state <= CUS_DECODE;

				when CUS_DECODE =>
					case i_IR(15 downto 14) is
						when "00" =>
							s_state <= CUS_EXEC_ALU_1;
						when "10" =>
							case i_IR(13 downto 9) is
								when "01010" =>
									s_state <= CUS_EXEC_IJMP;
								when "01000" =>
									s_state <= CUS_EXEC_POP;
								when "01001" =>
									s_state <= CUS_EXEC_PUSH;
								when others =>
									s_state <= CUS_FETCH_1; 
							end case;
						when "11" => 
							case i_IR(13 downto 12) is
								when "00" =>
									s_state <= CUS_EXEC_RJMP;
								when "10" =>
									s_state <= CUS_EXEC_LDI;
								when others =>
									s_state <= CUS_FETCH_1; 
							end case;
						when others =>
							-- неизвестная команда, пропуск
							s_state <= CUS_FETCH_1; 
					end case;
				
				when CUS_EXEC_ALU_1 =>
					case i_IR(13 downto 10) is
						when "0101" | "0001" => -- CP, CPC, 
							s_state <= CUS_EXEC_ALU_2_NOWRITE;
						when "0100" =>
							s_state <= CUS_EXEC_CPSE;
						when others => -- ADD, AND, SUB, MOV, ...
							s_state <= CUS_EXEC_ALU_2_WRITE;
					end case;
					
				when CUS_EXEC_ALU_2_WRITE =>
					s_state <= CUS_FETCH_1;
					
				when CUS_EXEC_ALU_2_NOWRITE =>
					s_state <= CUS_FETCH_1;
				
				when CUS_EXEC_IJMP =>
					s_state <= CUS_FETCH_1;

				when CUS_EXEC_RJMP =>
					s_state <= CUS_FETCH_1;
				when CUS_EXEC_CPSE=>
					if (i_zero = '1') then
						s_state <= CUS_SKIP;
					else
						s_state <= CUS_FETCH_1;
					end if;		
				when CUS_EXEC_LDI => 
					s_state <= CUS_FETCH_1;
				
				when CUS_EXEC_POP => 
					SP <= SP + 1;
					s_state <= CUS_FETCH_1;
				
				when CUS_EXEC_PUSH =>
					SP <= SP - 1;
					s_state <= CUS_FETCH_1;
				
				when others =>
					s_state <= CUS_RESET;
			end case;
			
		end if;
	end if;
end process;

end Behavioral;
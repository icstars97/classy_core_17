library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;




entity Alu is
port ( 	-- ВХОДЫ И ВЫХОДЫ БЛОКА АЛУ
	i_clk:			in std_logic;	-- тактовый сигнал
	i_reset:			in std_logic;	-- сигнал сброс
	-- control path
	i_operation:	in unsigned(3 downto 0);	-- код операции 
	-- data path
	i_op1:			in unsigned(7 downto 0);  -- Rd
	i_op2:			in unsigned(7 downto 0);  -- Rr
	o_result:		out unsigned(7 downto 0);	-- результат операции
	--
	


	i_negative:		in std_logic;	-- вход флага отрицательного значения
	i_zero:			in std_logic;	-- вход флага нулевого значнения
	i_carry:			in std_logic;	-- вход флага переноса

	

	o_negative:		out std_logic; -- выход флага отрицательного значения
	o_zero:			out std_logic; -- выхода флага нулевого значения
	o_carry:			out std_logic  -- выход флага переноса
);
end Alu;

architecture Behavioral of Alu is
					-- ВНУТРЕННИЕ СИГНАЛЫ БЛОКА АЛУ
signal s_result: unsigned(8 downto 0) := (others => '0'); -- результат

signal s_i_nzc: std_logic_vector(2 downto 0);	-- шина флагов

signal s_sub: std_logic := '0';	
signal s_logic: std_logic := '0';
signal s_mov_cpse: std_logic := '0';
signal s_use_old_zero: std_logic := '0';


begin

-- выход результат операции 
o_result <= s_result;


-- установка флага переноса для ADD,ADC (s_sub=0)
-- или для SUB,SBC,CP,CPC (s_sub=1)
-- игнорируется при выполнении AND, EOR, OR, MOV, CPSE
o_carry     <= s_i_nzc(0) when (s_logic = '1' or s_mov_cpse = '1')
				else s_result(8);




-- установка флага отрицательного результата
-- для ADD, ADC, SUB, AND, EOR, OR
-- игнорируется при выполнении MOV
o_negative  <= s_i_nzc(2) when s_mov_cpse = '1'
				else s_result(7);


-- установка флага нулевого результата 
-- для ADD, ADC, SUB, SBC, CP, AND, EOR, OR
-- игнорируется при выполнении MOV
-- SBC, CPC: значение флага остаётся неизменным если предыдущий результат 0, иначе очищается
o_zero      <= s_i_nzc(1) when s_mov_cpse = '1'
				else not (s_result(0) or s_result(1) or s_result(2) or s_result(3)
				     or s_result(4) or s_result(5) or s_result(6) or s_result(7))
					and (not s_use_old_zero or s_i_nzc(1));


-- основной блок синхронной логики 
-- отвечается за сброс и выполнение комманд 
process (i_clk)
begin
	if rising_edge(i_clk) then
	
		if i_reset = '1' then
			s_sub <= '0';
			s_use_old_zero <= '0';
			s_i_nzc <= (others => '0');

		else		

			
			s_i_nzc <= i_negative & i_zero & i_carry;
			
			case i_operation is
				
				-- блок арифметических операций 
				
				when "0011" | "0111" => -- ADD | ADDC
					s_sub <= '0';
					s_logic <= '0';
					s_mov_cpse <= '0';
					s_use_old_zero <= '0';
					if i_operation(2) = '1' and i_carry = '1' then
						s_result <= i_op1 + i_op2 + 1; -- ADDC C=1
					else
						s_result <= i_op1 + i_op2; -- ADD, ADDC C=0
					end if;

				when "0110" | "0010" | "0101" | "0001" | "0100" => -- SUB | SBC | CP | CPC | CPSE
					-- * for CP and CPC, ignore the result
					-- * for CPSE, ignore everything, but skip next instruction if Z=1
					s_sub <= '1';
					s_logic <= '0';
					if i_operation = "0100" then
						s_mov_cpse <= '1';
					else
						s_mov_cpse <= '0';
					end if;
					s_use_old_zero <= not i_operation(2);
					if i_operation(2) = '0' and i_carry = '1' then
						s_result <= i_op1 - i_op2 - 1;
					else
						s_result <= i_op1 - i_op2;
					end if;
					
				-- блок логических операций 

				when "1000" => -- AND
					s_sub <= '0';
					s_logic <= '1';
					s_mov_cpse <= '0';
					s_use_old_zero <= '0';
					s_result <= i_op1 and i_op2;

				when "1001" => -- EOR
					s_sub <= '0';
					s_logic <= '1';
					s_mov_cpse <= '0';
					s_use_old_zero <= '0';
					s_result <= i_op1 xor i_op2;

				when "1010" => -- OR
					s_sub <= '0';
					s_logic <= '1';
					s_mov_cpse <= '0';
					s_use_old_zero <= '0';
					s_result <= i_op1 or i_op2;
					
				when "1011" => -- MOV
					s_sub <= '0';
					s_logic <= '1';
					s_mov_cpse <= '1';
					s_use_old_zero <= '0';
					s_result <= i_op2;
					
				when others =>
					s_sub <= '0';
					s_logic <= '0';
					s_mov_cpse <= '1';
					s_use_old_zero <= '0';
					s_result <= (others => '0');
			end case;
		end if;
	end if;
end process;

end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
entity AVR_CPU_test is
end AVR_CPU_test;
 
architecture Behavioral of AVR_CPU_test is 
 
component AVR_CPU is
port (
	i_clk: 			in std_logic;
	i_reset_ext: 	in std_logic


);
end component;
    

--Inputs
signal i_clk : std_logic := '0';
signal i_reset_ext : std_logic := '0';


--Outputs

-- Clock period definitions
constant i_clk_period : time := 20 ns;
 
begin
 
-- Instantiate the Unit Under Test (UUT)
uut: AVR_CPU PORT MAP (
	i_clk => i_clk,
	i_reset_ext => i_reset_ext
);

-- Clock process definitions
i_clk_process: process
begin
	i_clk <= not i_clk;
	wait for i_clk_period/2;
end process;

-- Stimulus process
stim_proc: process
begin		
	i_reset_ext <= '1';
	wait for 100 ns;	
	i_reset_ext <= '0';
	wait;
end process;

end Behavioral;

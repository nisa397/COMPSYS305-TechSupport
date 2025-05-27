library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LFSR is
   port( seed: in unsigned(7 downto 0);
		Clock: in std_logic;
		rand_num: out unsigned(7 downto 0));       	
end LFSR;

architecture behavior OF LFSR IS
signal lfsr_reg : unsigned(7 downto 0) := to_unsigned(0,8);  -- internal shift register
begin

process(Clock)
begin
	if (rising_edge(Clock)) then
		lfsr_reg<= lfsr_reg sll 1;
		-- Apply XOR function, tap bits 7,3,2,1
		lfsr_reg(4) <= lfsr_reg(7) XOR lfsr_reg(3);
		lfsr_reg(3) <= lfsr_reg(7) XOR lfsr_reg(2);
		lfsr_reg(2) <= lfsr_reg(1) XOR lfsr_reg(7);
		
	end if;
	
end process;

process(seed)
begin
	lfsr_reg <= seed;
end process;

rand_num <= lfsr_reg;


END behavior;
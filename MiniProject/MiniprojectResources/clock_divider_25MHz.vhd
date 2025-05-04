library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Clock_25MHz is
	port(
		Clk: in std_logic;
		Q: out std_logic);
end Clock_25MHz;

architecture arc of Clock_25MHz is

	-- signal Counter: integer := 0;
	signal Counter: unsigned(0 downto 0) := (others => '0');
	signal p_Q: std_logic:= '0';
	
	begin
	
		process(Clk)
		
		begin 
			if (rising_edge(Clk)) then
				Counter <= Counter + 1;
				if (Counter= 1 ) then
					Counter <= (others => '0');
					p_Q <= not p_Q;
				end if;
			end if;
		end process;
		
		Q <= p_Q;
end arc;

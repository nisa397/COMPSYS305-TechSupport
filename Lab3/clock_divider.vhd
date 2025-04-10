library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Clock_1Hz is
port(
Clk: in std_logic;
Q: out std_logic);
end Clock_1Hz;

architecture arc of Clock_1Hz is

signal Counter: integer := 0;
signal p_Q: std_logic:= '0';

begin



process(Clk)

begin
if (rising_edge(Clk)) then
Counter <= Counter + 1;
if (Counter>25000000 ) then
Counter <= 0;
p_Q <= not p_Q;
end if;
end if;
end process;

Q <= p_Q;
end arc;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

entity scoreBox is 
	port(
		clk : in std_logic; 
		pixel_row, pixel_column : in std_logic_vector(9 downto 0); 
		font_row, font_column : in std_logic_vector()
	); 
end entity 
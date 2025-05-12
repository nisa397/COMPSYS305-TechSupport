LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

entity scoreBox is 
	port(
		clock : in std_logic; 
		pixel_row, pixel_column : in std_logic_vector(9 downto 0); 
		font_row, font_column : out std_logic_vector(3 downto 1); 
		character_addr : out std_logic_vector(5 downto 0)
	); 
end entity;

architecture behaviour of scoreBox is 

begin 
		
	-- S top left corner	
  font_row <= pixel_row(3 downto 1) when (pixel_row(9 downto 0) <= conv_std_logic_vector(15,10)) else "000"; -- Top Left corner, pass pixel row when pixelrow < 15th row 
  font_column <= pixel_column(3 downto 1) when (pixel_column(9 downto 0) <= conv_std_logic_vector(15,10)) else "000"; -- pass pixel column when pixelcol < 15th row 
  character_addr <= "010011"; -- S 

end architecture; 
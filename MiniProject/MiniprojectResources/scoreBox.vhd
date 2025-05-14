LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

entity scoreBox is 
	port(
		clock : in std_logic; 
		pixel_row, pixel_column : in std_logic_vector(9 downto 0); 
		font_row, font_column : out std_logic_vector(2 downto 0); 
		character_addr : out std_logic_vector(5 downto 0);
      within_bounds : out std_logic
	); 
end entity;

architecture behaviour of scoreBox is 
    -- Define the origin for the character display
    constant origin_row : std_logic_vector(9 downto 0) := conv_std_logic_vector(100,10); 
    constant origin_col : std_logic_vector(9 downto 0) := conv_std_logic_vector(100,10);
	 
	 constant origin_row16 : std_logic_vector(9 downto 0) := conv_std_logic_vector(110, 10); 
	 constant origin_col16 : std_logic_vector(9 downto 0) := conv_std_logic_vector(100, 10); 

begin 
    -- Calculate font_row and font_column relative to the origin
	 -- Calculations are to ensure that the row and column is split into 8x8 for font_row and font_column
	 -- To work 
    font_row <= conv_std_logic_vector(unsigned(pixel_row) - unsigned(origin_row), 3) when 
        (pixel_row >= origin_row and pixel_row < origin_row + 8) else "000";
    font_column <= conv_std_logic_vector(unsigned(pixel_column) - unsigned(origin_col), 3) when 
        (pixel_column >= origin_col and pixel_column < origin_col + 8) else "000";
    
    within_bounds <= '1' when (pixel_row >= origin_row and pixel_row < origin_row + 8 and
                               pixel_column >= origin_col and pixel_column < origin_col + 8) else '0';

    character_addr <= "000001"; -- Address for character "A"
end architecture; 
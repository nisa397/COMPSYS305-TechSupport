LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

entity scoreBox is 
	port(
		clock : in std_logic; 
		pixel_row, pixel_column : in std_logic_vector(9 downto 0); 
		font_row, font_column : out std_logic_vector(3 downto 1); 
		character_addr : out std_logic_vector(5 downto 0);
      within_bounds : out std_logic
	); 
end entity;

architecture behaviour of scoreBox is 
    -- Define the origin for the character display
    constant origin_row : std_logic_vector(9 downto 0) := "0000000010"; -- Row 2
    constant origin_col : std_logic_vector(9 downto 0) := "0000000010"; -- Column 2

begin 
    -- Calculate font_row and font_column relative to the origin
    font_row <= pixel_row(3 downto 1) - origin_row(3 downto 1) when (pixel_row >= origin_row and pixel_row < origin_row + 16) else "000";
    font_column <= pixel_column(3 downto 1) - origin_col(3 downto 1) when (pixel_column >= origin_col and pixel_column < origin_col + 16) else "000";
    
    within_bounds <= '1' when (pixel_row >= origin_row and pixel_row < origin_row + 16 and
                               pixel_column >= origin_col and pixel_column < origin_col + 16) else '0';
    -- Set the character address to display "A" (address 010 in octal, 000010 in binary)
    character_addr <= "000001"; -- Address for character "A"
end architecture; 
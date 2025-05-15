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
    constant origin_row : std_logic_vector(9 downto 0) := conv_std_logic_vector(10,10); 
    constant origin_col : std_logic_vector(9 downto 0) := conv_std_logic_vector(10,10);
	 
	constant origin_row16 : std_logic_vector(9 downto 0) := conv_std_logic_vector(20, 10); 
	constant origin_col16 : std_logic_vector(9 downto 0) := conv_std_logic_vector(10, 10); 

    signal active_letter : std_logic_vector(1 downto 0); 
	
	 signal local_row  : std_logic_vector(9 downto 0);
    signal local_col  : std_logic_vector(9 downto 0);

begin 
	
	-- Bounding box for the start of the text 
    active_letter <= "01" when (pixel_row >= origin_row and pixel_row < origin_row + 8 and
                               pixel_column >= origin_col and pixel_column < origin_col + 8) else 
                     "10" when (pixel_row >= origin_row16 and pixel_row < origin_row16 + 16 and
                                pixel_column >= origin_col16 and pixel_column < origin_col16 + 16) else
                     "00";  
                     
    -- Calculate font_row and font_column relative to the origin
	 -- Calculations are to ensure that the row and column is split into 8x8 for font_row and font_column
	 -- To work 
		
	-- Ensure that the pixels are in the right place 	
    local_row <= pixel_row - origin_row when active_letter = "01" else
                 pixel_row - origin_row16 when active_letter = "10" else
                 (others => '0');

    local_col <= pixel_column - origin_col when active_letter = "01" else
                 pixel_column - origin_col16 when active_letter = "10" else
                 (others => '0');

    -- Use slices for resizing, as 3 downto 1 = 16x16
    font_row <= local_row(2 downto 0) when active_letter = "01" else  -- 8x8
                local_row(3 downto 1) when active_letter = "10" else  -- 16x16 scaled to 8x8
                "000";

    font_column <= local_col(2 downto 0) when active_letter = "01" else
                   local_col(3 downto 1) when active_letter = "10" else
                   "000";
     
	 -- Send that bounding box for the top-level entity to ensure correctness 
    within_bounds <= '1' when active_letter /= "00" else '0'; 

    character_addr <= "000001" when active_letter = "01" else -- Address for "A"
                      "000010" when active_letter = "10"; -- Address for "B"
end architecture; 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity plus_2_powerup is
    port (
	 top_pipe_height, pipe_x_pos, width, vertical_gap: in unsigned(9 downto 0);
	 pixel_row, pixel_column : in std_logic_vector(9 downto 0);
	 power_up_on: in std_logic;
		);
end plus_2_powerup;

architecture behavior of plus_2_powerup is
signal px, py       : unsigned(9 downto 0);
signal power_up_x: unsigned(9 downto 0);
signal power_up_y: unsigned(9 downto 0);


begin

    -- Convert pixel inputs
    px <= unsigned(pixel_column);
    py <= unsigned(pixel_row);
	 
	 power_up_x <= pipe_x_pos + (width/2);
	 power_up_y <= pipe_y_pos + (vertical_gap/2);
	 
	 


end behaviour;
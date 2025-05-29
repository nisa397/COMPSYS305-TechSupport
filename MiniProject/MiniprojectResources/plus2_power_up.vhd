library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity plus_2_powerup is
    port (
	 top_pipe_height, pipe_x_pos: in unsigned(9 downto 0);
	 pixel_row, pixel_column : in std_logic_vector(9 downto 0);
	 power_up_on: out std_logic
		);
end plus_2_powerup;

architecture behaviour of plus_2_powerup is
signal px, py       : unsigned(9 downto 0);
signal power_up_x: unsigned(9 downto 0);
signal power_up_y: unsigned(9 downto 0);
constant power_up_size: unsigned(9 downto 0) := to_unsigned(5, 10);



begin

    -- Convert pixel inputs
    px <= unsigned(pixel_column);
    py <= unsigned(pixel_row);
	
	--Finding position of power_ups
	power_up_x <= pipe_x_pos + to_unsigned(75, 10);
	power_up_y <= top_pipe_height + to_unsigned(25,10);
	
	
	power_up_on <= '1' when(power_up_x <= px + power_up_size
							and px <= power_up_x+power_up_size
							and power_up_y <= py+power_up_size
							and py <= power_up_y+power_up_size)
							else '0';
	 


end behaviour;
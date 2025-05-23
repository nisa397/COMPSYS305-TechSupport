library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pipe is
    port (
        height  : in  std_logic_vector(9 downto 0);
		pixel_row, pixel_column : in std_logic_vector(9 downto 0);
        pipe_on        : out std_logic);
end pipe;

architecture behavior of pipe is
signal width : unsigned(9 downto 0) := to_unsigned(80, 10);
signal gap: unsigned (9 downto 0):= to_unsigned(50,10);
signal px, py       : unsigned(9 downto 0);
signal top_pipe_height: unsigned (9 DOWNTO 0);
SIGNAL top_pipe_y_pos :unsigned (9 DOWNTO 0):= to_unsigned(0,10);
signal pipe_x_pos	: unsigned (9 DOWNTO 0):= to_unsigned(480,10);
signal bottom_pipe_y_pos: unsigned(9 downto 0):= to_unsigned(480,10);
signal s_height: unsigned (9 downto 0);
signal bottom_pipe_height: unsigned(9 downto 0);


begin

	top_pipe_height <= unsigned(height);
	bottom_pipe_height <= to_unsigned(480,10) - top_pipe_height - gap;

    -- Convert pixel inputs
    px <= unsigned(pixel_column);
    py <= unsigned(pixel_row);
	
	


	
	-- pipe drawing condition
	
	 
	 
	 	pipe_on <= '1' when (
        pipe_x_pos <= px + width and
        px <= pipe_x_pos + width and
        top_pipe_y_pos <= py + top_pipe_height and
        py <= top_pipe_y_pos + top_pipe_height
    ) or (pipe_x_pos <= px + width and
        px <= pipe_x_pos + width and
		  bottom_pipe_y_pos <= py + bottom_pipe_height and
		  py <= bottom_pipe_y_pos + bottom_pipe_height)	 
	else '0';
	


end behavior;
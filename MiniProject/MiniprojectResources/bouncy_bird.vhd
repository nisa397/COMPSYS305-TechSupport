LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_SIGNED.all;

ENTITY bouncy_bird IS
    PORT (
        pb1, pb2, clk, vert_sync : IN std_logic;
        pixel_row, pixel_column  : IN std_logic_vector(9 DOWNTO 0);
        red, green, blue         : OUT std_logic
    );		
END bouncy_bird;

ARCHITECTURE behavior OF bouncy_bird IS

SIGNAL ball_on            : std_logic;
SIGNAL size               : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(8, 10);  
SIGNAL ball_y_pos         : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(240, 10);  -- Start in middle
SIGNAL ball_x_pos         : std_logic_vector(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(160, 11); -- X stays fixed
SIGNAL ball_y_motion      : std_logic_vector(9 DOWNTO 0) := (others => '0'); -- Initial vertical speed

-- Constants
constant GRAVITY       : integer := 1;
constant JUMP_STRENGTH : integer := -10;
constant MAX_Y         : integer := 470;
constant MIN_Y         : integer := 0;

BEGIN           

-- Determine if current pixel overlaps bird area
ball_on <= '1' when (
    ('0' & ball_x_pos <= '0' & pixel_column + size) and
    ('0' & pixel_column <= '0' & ball_x_pos + size) and
    ('0' & ball_y_pos <= pixel_row + size) and
    ('0' & pixel_row <= ball_y_pos + size)
) else '0';

-- VGA color output (red bird, black background)
red   <= ball_on;
green <= '0';
blue  <= '0';

-- Movement process: one update per frame
Move_Ball: process (vert_sync)
  variable temp_y_motion : integer;
  variable next_y_pos    : integer;
begin
    if rising_edge(vert_sync) then

        -- Apply jump if button pressed
        if pb1 = '0' then
            ball_y_motion <= JUMP_STRENGTH;
        else
            -- Apply gravity
            ball_y_motion <= to_stdlogicvector(to_integer(ball_y_motion) + GRAVITY);
        end if;

        -- Update Y position
        temp_y_motion := to_integer(ball_y_motion) + GRAVITY;
        next_y_pos := to_integer(ball_y_pos) + temp_y_motion;

        -- Clamp position
        if next_y_pos > MAX_Y then
          ball_y_pos <= to_stdlogicvector(MAX_Y);
          ball_y_motion <= (others => '0');
        elsif next_y_pos < MIN_Y then
            ball_y_pos <= to_stdlogicvector(MIN_Y);
            ball_y_motion <= (others => '0');
        else
            ball_y_pos <= next_y_pos;
        end if;

    end if;
end process Move_Ball;

END behavior;

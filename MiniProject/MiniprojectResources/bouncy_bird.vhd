library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bouncy_bird is
    port (
        ps2_left, pb2, clk, vert_sync : in  std_logic;
        pixel_row, pixel_column  : in  std_logic_vector(9 downto 0);
        game_state : in game_state_type; 
        red, green, blue, ends        : out std_logic 
    );
end bouncy_bird;

architecture behavior of bouncy_bird is

    -- Constants
    constant GRAVITY       : integer := 1;
    constant JUMP_STRENGTH : integer := -10;
    constant MAX_Y         : integer := 470;
    constant MIN_Y         : integer := 0;

    -- Internal signals
    signal size         : unsigned(9 downto 0) := to_unsigned(8, 10);
    signal ball_y_pos   : unsigned(9 downto 0) := to_unsigned(240, 10);
    signal ball_x_pos   : unsigned(10 downto 0) := to_unsigned(160, 11);
    signal ball_y_motion: signed(9 downto 0) := (others => '0');

    signal ball_on      : std_logic;

    -- Converted inputs for arithmetic
    signal px, py       : unsigned(9 downto 0);

    

begin


    -- Convert pixel inputs
    px <= unsigned(pixel_column);
    py <= unsigned(pixel_row);

    -- Ball drawing condition
    ball_on <= '1' when (
        ball_x_pos <= px + size and
        px <= ball_x_pos + size and
        ball_y_pos <= py + size and
        py <= ball_y_pos + size
    ) else '0';

    -- Output color (red bird, black background)
    red   <= ball_on;
    green <= '0';
    blue  <= '0';

    -- Movement process: update on vertical sync (frame tick)
    Move_Ball: process(vert_sync)
    variable next_y_pos : integer;
begin
    if rising_edge(vert_sync) then
        -- Only update movement if not paused or game over
        if (game_state = play) or (game_state = training) then
            -- Apply jump on button press
            if (ps2_left = '1') or (pb2 = '0') then
                ball_y_motion <= to_signed(JUMP_STRENGTH, ball_y_motion'length);
            else
                -- Apply gravity
                ball_y_motion <= to_signed(to_integer(ball_y_motion) + GRAVITY, ball_y_motion'length);
            end if;

            -- Compute next Y position
            next_y_pos := to_integer(ball_y_pos) + to_integer(ball_y_motion);

            -- Clamp position
            if next_y_pos > MAX_Y then
                ball_y_pos    <= to_unsigned(MAX_Y, ball_y_pos'length);
                ball_y_motion <= (others => '0');
                ends <= '1'; -- Game over condition
            elsif next_y_pos < MIN_Y then
                ball_y_pos    <= to_unsigned(MIN_Y, ball_y_pos'length);
                ball_y_motion <= (others => '0');
                ends <= '1'; -- Game over condition
            else
                ball_y_pos <= to_unsigned(next_y_pos, ball_y_pos'length);
                ends <='0';
            end if;
        end if;
        -- If paused or in other states, do nothing: ball stays frozen
    end if;
end process;

end behavior;

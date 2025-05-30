library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity bouncy_bird is
    port (
        ps2_left, pb2, clk, vert_sync, game_start : in  std_logic;
		  reset: in std_logic;
        pixel_row, pixel_column  : in  std_logic_vector(9 downto 0);
        game_state : in std_logic_vector(2 downto 0); 
        ball_y_pos_out : out std_logic_vector(9 downto 0);
        red, green, blue, ends        : out std_logic;
        bird_x : out unsigned(9 downto 0);  -- Add this
        bird_y : out unsigned(9 downto 0)   -- And this
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
    px <= to_unsigned(240, 10) when (game_state= "000") else unsigned(pixel_column);
    py <= to_unsigned(160, 10) when (game_state = "000" ) else  unsigned(pixel_row);

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
        -- Reset bird state on new game start or death
        if game_start = '1' or reset = '1' then
            ball_y_pos    <= to_unsigned(240, 10); -- middle Y
            ball_y_motion <= (others => '0');
            ends          <= '0';
        -- Handle normal play/training movement
        elsif (game_state = "001" or game_state = "010") then
            if (ps2_left = '1') then
                ball_y_motion <= to_signed(JUMP_STRENGTH, ball_y_motion'length);
            else
                ball_y_motion <= to_signed(to_integer(ball_y_motion) + GRAVITY, ball_y_motion'length);
            end if;

            next_y_pos := to_integer(ball_y_pos) + to_integer(ball_y_motion);
				
				if next_y_pos > MAX_Y then
                ball_y_pos    <= to_unsigned(MAX_Y, ball_y_pos'length);
                ball_y_motion <= (others => '0');
                ends <= '1';
            elsif next_y_pos < MIN_Y then
                ball_y_pos    <= to_unsigned(MIN_Y, ball_y_pos'length);
                ball_y_motion <= (others => '0');
                ends <= '1';
            else
                ball_y_pos <= to_unsigned(next_y_pos, ball_y_pos'length);
                ends <= '0';
            end if;
        end if;
    end if;
end process;

bird_x <= ball_x_pos(9 downto 0); -- Truncate if needed
bird_y <= ball_y_pos(9 downto 0); -- Truncate if needed

end behavior;

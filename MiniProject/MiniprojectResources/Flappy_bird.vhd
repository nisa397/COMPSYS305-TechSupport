library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity Flappy_bird is
    port(
      clk_50MHz   : IN  std_logic;  -- DE0-CV clock
      h_sync      : OUT std_logic;  -- VGA horizontal sync
      v_sync      : OUT std_logic;  -- VGA vertical sync
      red         : OUT std_logic;  -- VGA red output
      green       : OUT std_logic;  -- VGA green output
      blue        : OUT std_logic   -- VGA blue output
    );
end entity Flappy_bird;


architecture Behavioral of Flappy_bird is
  
  -- Internal 25 MHz clock signal
  SIGNAL clk_25MHz : std_logic := '0';
  
  
  -- Mouse signals
  signal ps2_reset : std_logic;
  signal ps2_data : std_logic;
  signal ps2_click : std_logic;
  signal ps2_left: std_logic;
  signal ps2_right: std_logic;
  signal ps2_cursor_row: std_logic_vector(9 DOWNTO 0);
  signal ps2_cursor_col: std_logic_vector(9 DOWNTO 0);
  
  --Cursor signals
  signal cursor_on: std_logic;
  
  -- VGA signals
  SIGNAL pixel_row, pixel_column : std_logic_vector(9 DOWNTO 0);
  SIGNAL video_on : std_logic;

  -- RGB pixel output from ball component
  SIGNAL red_ball, green_ball, blue_ball : std_logic;

  SIGNAL red_pixel, green_pixel, blue_pixel : std_logic;
  SIGNAL ball_on : std_logic;
  SIGNAL ball_x_pos, ball_y_pos : std_logic_vector(9 DOWNTO 0);

  component vga_sync is
    PORT(	clock_25Mhz, red, green, blue	: IN	STD_LOGIC;
			red_out, green_out, blue_out, horiz_sync_out, vert_sync_out	: OUT	STD_LOGIC;
			pixel_row, pixel_column: OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
      );
  end component;

  component ball is
   port ( clk : IN std_logic;
		  pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		  red, green, blue : OUT std_logic
      );	
  end component;
  
  component Clock_25MHZ is 
		port(
			Clk: in std_logic;
			Q: out std_logic);
	end component;
	
	component MOUSE IS
		port( clock_25Mhz, reset 		: IN std_logic;
         mouse_data					: INOUT std_logic;
         mouse_clk 					: INOUT std_logic;
         left_button, right_button	: OUT std_logic;
		 mouse_cursor_row 			: OUT std_logic_vector(9 DOWNTO 0); 
		 mouse_cursor_column 		: OUT std_logic_vector(9 DOWNTO 0));       	
	end MOUSE;

	component cursor_drawer is 
		port (
        clk            : in  STD_LOGIC;
        video_row, video_column  : in  STD_LOGIC_VECTOR (9 downto 0);
        cursor_row, cursor_column: in  STD_LOGIC_VECTOR (9 downto 0);
		cursor_on : out STD_LOGIC;
		);
	end cursor_drawer;

  begin

	mouse: MOUSE 
	port map(
	clock_25Mhz => clk_25MHz,
	reset => ps2_reset,
	mouse_data => ps2_data,
	mouse_clk => ps2_click,
	left_button => ps2_left,
	right_button => ps2_right,
	mouse_cursor_row => ps2_cursor_row,
	mouse_cursor_column => ps2_cursor_col
	)
	
	testCursor : cursor_drawer
	port map(
	clk => clk_25MHz,
	video_row => pixel_row,
	video_column => pixel_column,
	cursor_row => ps2_cursor_row,
	cursor_column => ps2_cursor_col,
	cursor_on => cursor_on
	)
	





    -- Instantiate the clock divider to generate 25 MHz clock
    ClockDivider: Clock_25MHz
    port map(
      Clk => clk_50MHz,
      Q   => clk_25MHz
    );
	 
	 

    -- Instantiate the ball component
  BallComponent: ball
  port map(
    clk            => clk_25MHz,
    pixel_row      => pixel_row,
    pixel_column   => pixel_column,
    red            => red_ball,
    green          => green_ball,
    blue           => blue_ball
  );
  
  
  

  -- Logic to determine if the current pixel is part of the bird
  ball_on <= '1' when (red_ball = '1' or green_ball = '1' or blue_ball = '1') else '0';
  
  -- Logic to combine bird and background colors
  -- If the current pixel is part of the bird, use the bird's color.
  -- Otherwise, use a constant background color (e.g., green background).
  red_pixel   <= '0' when (ball_on = '1') or (cursor_on = '1')else '0'; -- Bird: red, Background: no red
  green_pixel <= '0' when ball_on = '1' or (cursor_on = '1') else '1'; -- Bird: no green, Background: green
  blue_pixel  <= '1' when ball_on = '1' or (cursor_on = '1')else '0'; -- Bird: no blue, Background: no blue
  
  
  -- Instantiate the VGA sync component
  VGASync: vga_sync
    port map(
      clock_25Mhz     => clk_25MHz,
      red             => red_pixel,
      green           => green_pixel,
      blue            => blue_pixel,
      red_out         => red,
      green_out       => green,
      blue_out        => blue,
      horiz_sync_out  => h_sync,
      vert_sync_out   => v_sync,
      pixel_row       => pixel_row,
      pixel_column    => pixel_column
    );

  

end Behavioral;

  



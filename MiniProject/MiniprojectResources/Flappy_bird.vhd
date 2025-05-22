library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
USE  IEEE.STD_LOGIC_ARITH.all;

entity Flappy_bird is
    port(
		dip_sw1 : IN std_logic;
		dip_sw2: 	IN std_logic;
		dip_sw3 : IN std_logic;
		PS2_CLK		: INOUT std_logic;
		PS2_DAT		: INOUT std_logic;
		button_1 : In std_logic; --push button
		button_2: In std_logic; --second push button
      clk_50MHz   : IN  std_logic;  -- DE0-CV clock
      h_sync      : OUT std_logic;  -- VGA horizontal sync
      v_sync      : OUT std_logic;  -- VGA vertical sync
      red         : OUT std_logic;  -- VGA red output
      green       : OUT std_logic;  -- VGA green output
      blue        : OUT std_logic;   -- VGA blue output
		LEDR0			: OUT std_logic;
	  HEX0 : out STD_LOGIC_VECTOR(6 downto 0); --sso
	  HEX1 : out STD_LOGIC_Vector(6 downto 0); --sst
	  HEX2 : out STD_LOGIC_Vector(6 downto 0);
	  HEX3 : out STD_LOGIC_VECTOR(6 downto 0); --sso
	  HEX4 : out STD_LOGIC_Vector(6 downto 0); --sst
	  HEX5 : out STD_LOGIC_Vector(6 downto 0) 
    );
end entity Flappy_bird;


architecture Behavioral of Flappy_bird is
  
  -- Internal 25 MHz clock signal
  SIGNAL clk_25MHz : std_logic := '0';
  
  
  -- Mouse signals
  signal ps2_reset : std_logic := '0';
  signal ps2_left: std_logic;
  signal ps2_right: std_logic;
  signal ps2_cursor_row: std_logic_vector(9 DOWNTO 0);
  signal ps2_cursor_col: std_logic_vector(9 DOWNTO 0);
  
  

  
  
  --Cursor signals
  signal cursor_on: std_logic;
  
  -- VGA signals
  SIGNAL pixel_row, pixel_column : std_logic_vector(9 DOWNTO 0);
  SIGNAL video_on : std_logic;
  
  -- Text pixel row 
  signal font_row_in, font_col_in, font_row_64, font_col_64, font_row_32, font_col_32 : std_logic_vector(2 downto 0); 
  signal character_address_in, character_address_64, character_address_32 : std_logic_vector(5 downto 0); 
  signal rom_mux_output : std_logic; 
  signal within_bounds, within_bounds_64, within_bounds_32 : std_logic; 
  signal text_on : std_logic; 
  
  
  
  --64x74

  -- RGB pixel output from ball component
  SIGNAL red_ball, green_ball, blue_ball : std_logic;

  SIGNAL red_pixel, green_pixel, blue_pixel : std_logic;
  SIGNAL ball_on : std_logic;
  SIGNAL ball_x_pos, ball_y_pos : std_logic_vector(9 DOWNTO 0);
  
  signal v_sync_signal : std_logic;

    

  component vga_sync is
    PORT(	clock_25Mhz : IN std_logic;
			red, green, blue		: IN	std_logic;
			red_out, green_out, blue_out : OUT std_logic;
			horiz_sync_out, vert_sync_out	: OUT	STD_LOGIC;
			pixel_row, pixel_column: OUT STD_LOGIC_VECTOR(9 DOWNTO 0));
  end component;

  component bouncy_bird IS
    port (
        ps2_left, pb2, clk, vert_sync : IN std_logic;
        pixel_row, pixel_column  : IN std_logic_vector(9 DOWNTO 0);
        red, green, blue         : OUT std_logic
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
	end component;
	
	component BCD_to_SevenSeg is
		port (BCD_digit : in std_logic_vector(3 downto 0);
           SevenSeg_out : out std_logic_vector(6 downto 0));
	end component;
	
	component cursor_drawer is
    port (
        clk            : in  STD_LOGIC;
        video_row, video_column  : in  STD_LOGIC_VECTOR (9 downto 0);
        cursor_row, cursor_column: in  STD_LOGIC_VECTOR (9 downto 0);
		cursor_on : out STD_LOGIC
    );
	end component; 

	
	-- Entity for textComponent
	component char_rom is 
		PORT
		(
			character_address	:	IN STD_LOGIC_VECTOR (5 DOWNTO 0);
			font_row, font_col	:	IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			clock				: 	IN STD_LOGIC ;
			rom_mux_output		:	OUT STD_LOGIC
		);
	end component; 
	
	-- Respective text component individual drivers 
	component scoreBox is 
		port(
			clock : in std_logic; 
			pixel_row, pixel_column : in std_logic_vector(9 downto 0); 
			font_row, font_column : out std_logic_vector(3 downto 1); 
			character_addr : out std_logic_vector(5 downto 0); 
			within_bounds : out std_logic
		); 
	end component; 
	
	component textBox is 
				port(
		clock : in std_logic; 
		pixel_row, pixel_column : in std_logic_vector(9 downto 0); 
		font_row, font_column : out std_logic_vector(2 downto 0); 
		character_addr : out std_logic_vector(5 downto 0);
      within_bounds : out std_logic
	); 
	end component; 

  begin

    -- Instantiate the clock divider to generate 25 MHz clock
    ClockDivider: Clock_25MHz
    port map(
      Clk => clk_50MHz,
      Q   => clk_25MHz
    );
	 
	
	ps2: MOUSE 
	port map(
	clock_25Mhz => clk_25MHz,
	reset => ps2_reset,
	mouse_data => PS2_DAT,
	mouse_clk => PS2_CLK,
	left_button => ps2_left,
	right_button => ps2_right,
	mouse_cursor_row => ps2_cursor_row,
	mouse_cursor_column => ps2_cursor_col
	);
	
	cursor: cursor_drawer
	port map(
	clk => clk_25MHz,
	video_row => pixel_row,
	video_column => pixel_column,
	cursor_row => ps2_cursor_row,
	cursor_column => ps2_cursor_col,
	cursor_on => cursor_on
	);
	
	
	--Col
	sso0: BCD_to_SevenSeg
	port map(
	BCD_digit => ps2_cursor_col(3 downto 0),
	SevenSeg_out => HEX0
	);
	
	sst0: BCD_to_SevenSeg
	port map(
	BCD_digit => ps2_cursor_col(7 downto 4),
	SevenSeg_out => HEX1
	);
	
	ssh0: BCD_to_SevenSeg
	port map (
    BCD_digit => "00" & ps2_cursor_col(9 downto 8),
    SevenSeg_out => HEX2
	);
	
	--Row
	sso1: BCD_to_SevenSeg
	port map(
	BCD_digit => ps2_cursor_row(3 downto 0),
	SevenSeg_out => HEX3
	);
	
	sst1: BCD_to_SevenSeg
	port map(
	BCD_digit => ps2_cursor_row(7 downto 4),
	SevenSeg_out => HEX4
	);
	
	ssh1: BCD_to_SevenSeg
	port map (
    BCD_digit => "00" & ps2_cursor_row(9 downto 8),
    SevenSeg_out => HEX5
	);
	
	
	
	
	
	
	

    -- Instantiate the ball component
  BallComponent: bouncy_bird
  port map(
	 ps2_left 				 => ps2_left,
	 pb2 				 => button_2,
	 vert_sync 		 => v_sync_signal,
    clk            => clk_25MHz,
    pixel_row      => pixel_row,
    pixel_column   => pixel_column,
    red            => red_ball,
    green          => green_ball,
    blue           => blue_ball
  );
  
  
  -- Mux logic for text/score box
	font_row_in <= font_row_64 when within_bounds_64 = '1' else font_row_32;
	font_col_in <= font_col_64 when within_bounds_64 = '1' else font_col_32;
	character_address_in <= character_address_64 when within_bounds_64 = '1' else character_address_32;
	within_bounds <= within_bounds_64 or within_bounds_32;

  -- Logic to determine if the current pixel is part of the bird
  ball_on <= '1' when (red_ball = '1' or green_ball = '1' or blue_ball = '1') else '0';
  
  -- Logic to determine if the text will be on
  text_on <= '1' when (within_bounds = '1' and rom_mux_output = '1') else '0';
  
  -- Logic to combine bird and background colors
  -- If the current pixel is part of the bird, use the bird's color.
  -- Otherwise, use a constant background color (e.g., green background).
  red_pixel   <= '0' when (ball_on = '1') or (text_on = '1') else dip_sw1; -- Bird: red, Background: no red
  green_pixel <= '0' when (ball_on = '1') or (text_on = '1') else dip_sw2; -- Bird: no green, Background: green
  blue_pixel  <= '1' when (ball_on = '1') or (text_on = '1') or (cursor_on = '1') else dip_sw3; -- Bird: no blue, Background: no blue



--   red_pixel   <= '0' when ball_on = '1' or text_on = '1' else '0'; -- Bird: red, Background: no red
--   green_pixel <= '0' when ball_on = '1' or text_on = '1' else '1'; -- Bird: no green, Background: green
--   blue_pixel  <= '1' when ball_on = '1' or text_on = '1' else '0'; -- Bird: no blue, Background: no blue
  
  -- Instantiate the text component 
  TextComponent: char_rom 
  port map(
	clock => clk_25MHz, 
	font_row => font_row_in,
	font_col => font_col_in, 
	character_address => character_address_in, -- Input
	rom_mux_output => rom_mux_output
  );
  
  -- Individual text drives
  ScoreDriver: scoreBox 
  port map(
	clock => clk_25MHz,
	pixel_row => pixel_row,
	pixel_column => pixel_column,
	font_row => font_row_64, -- Input 
	font_column => font_col_64,
	character_addr => character_address_64,
	within_bounds => within_bounds_64
  ); 
  
  TextDriver: textBox 
   port map(
	clock => clk_25MHz,
	pixel_row => pixel_row,
	pixel_column => pixel_column,
	font_row => font_row_32, -- Input 
	font_column => font_col_32, 
	character_addr => character_address_32,
	within_bounds => within_bounds_32
  ); 
  
  
  LEDR0 <= ps2_left;
  
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
      vert_sync_out   => v_sync_signal,
      pixel_row       => pixel_row,
      pixel_column    => pixel_column
    );
	 
	 v_sync <= v_sync_signal;


  

end Behavioral;

  



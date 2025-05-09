library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
USE  IEEE.STD_LOGIC_ARITH.all;

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

  -- VGA signals
  SIGNAL pixel_row, pixel_column : std_logic_vector(9 DOWNTO 0);
  SIGNAL video_on : std_logic;
  
  -- Text pixel row 
  signal font_row, font_col : std_logic_vector(2 downto 0); 
  signal character_address : std_logic_vector(5 downto 0); 
  signal rom_mux_output : std_logic; 

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
	
	-- Entity for text 
	component char_rom is 
		PORT
		(
			character_address	:	IN STD_LOGIC_VECTOR (5 DOWNTO 0);
			font_row, font_col	:	IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			clock				: 	IN STD_LOGIC ;
			rom_mux_output		:	OUT STD_LOGIC
		);
	end component; 

  begin

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
  red_pixel   <= '0' when ball_on = '1' or rom_mux_output = '1' else '0'; -- Bird: red, Background: no red
  green_pixel <= '0' when ball_on = '1' or rom_mux_output = '1' else '1'; -- Bird: no green, Background: green
  blue_pixel  <= '1' when ball_on = '1' or rom_mux_output = '1' else '0'; -- Bird: no blue, Background: no blue
  
  
  -- Assigning the input for the font row and columns 
  -- Assigning the pixel_row and pixel_col certain indexes to the font_row...etc 
  font_row <= pixel_row(3 downto 1) when (pixel_row(9 downto 0) <= conv_std_logic_vector(15,10)) else "000"; -- Top Left corner, pass pixel row when pixelrow < 15th row 
  font_col <= pixel_column(3 downto 1) when (pixel_column(9 downto 0) <= conv_std_logic_vector(15,10)) else "000"; -- pass pixel column when pixelcol < 15th row 
  character_address <= "010011"; -- S 
  
  -- Instantiate the text component 
  TextComponent: char_rom 
  port map(
	clock => clk_25MHz, 
	font_row => font_row,
	font_col => font_col, 
	character_address => character_address, 
	rom_mux_output => rom_mux_output
  );
  
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

  



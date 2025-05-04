library.ieee;
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

  -- VGA signals
  SIGNAL pixel_row, pixel_column : std_logic_vector(9 DOWNTO 0);
  SIGNAL video_on : std_logic;

  -- RGB pixel output from ball component
  SIGNAL red_pixel, green_pixel, blue_pixel : std_logic;

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

  begin

    -- Instantiate the clock divider to generate 25 MHz clock
    ClockDivider: Clock_25MHz
    port map(
      Clk => clk_50MHz,
      Q   => clk_25MHz
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

  -- Instantiate the ball component
  BallComponent: ball
    port map(
      clk            => clk_25MHz,
      pixel_row      => pixel_row,
      pixel_column   => pixel_column,
      red            => red_pixel,
      green          => green_pixel,
      blue           => blue_pixel
    );

end Behavioral;

  



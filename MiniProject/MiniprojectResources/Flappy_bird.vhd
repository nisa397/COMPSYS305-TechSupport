library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Flappy_bird is
    port(
		dip_sw1 : IN std_logic;
		dip_sw2: 	IN std_logic;
		dip_sw3 : IN std_logic;
		PS2_CLK		: INOUT std_logic;
		PS2_DAT		: INOUT std_logic;
		button_1 : In std_logic; --push button
		button_2: In std_logic; --second push button
    button_3: In std_logic; --third push button
    button_4: In std_logic; --fourth push button
      clk_50MHz   : IN  std_logic;  -- DE0-CV clock
      h_sync      : OUT std_logic;  -- VGA horizontal sync
      v_sync      : OUT std_logic;  -- VGA vertical sync
      red         : OUT std_logic;  -- VGA red output
      green       : OUT std_logic;  -- VGA green output
      blue        : OUT std_logic;   -- VGA blue output
		LEDR0			: OUT std_logic;
	  HEX0 : out STD_LOGIC_VECTOR(6 downto 0); 
	  HEX1 : out STD_LOGIC_Vector(6 downto 0); --sst
	  HEX2 : out STD_LOGIC_Vector(6 downto 0);
	  --HEX3 : out STD_LOGIC_VECTOR(6 downto 0); --sso
	  --HEX4 : out STD_LOGIC_Vector(6 downto 0); --sst
	  HEX5 : out STD_LOGIC_Vector(6 downto 0) 
    );
end entity Flappy_bird;


architecture Behavioral of Flappy_bird is

  --Speed constants
  constant speed_EASY: integer := 3;
  constant speed_MID: integer := 6;
  constant speed_HARD: integer := 9;
  
  -- Internal 25 MHz clock signal
  SIGNAL clk_25MHz : std_logic := '0';
  signal pipe_reset : std_logic := '0'; 
  signal bird_reset : std_logic := '0';

  
  -- Mouse signals
  signal ps2_reset : std_logic := '0';
  signal ps2_left: std_logic;
  signal ps2_right: std_logic;
  signal ps2_cursor_row: std_logic_vector(9 DOWNTO 0);
  signal ps2_cursor_col: std_logic_vector(9 DOWNTO 0);
  
  -- Pipe signals
  signal pipe_width: unsigned(9 downto 0):= to_unsigned(50,10);
  signal s_height: unsigned (9 downto 0);
  signal s_height2: unsigned (9 downto 0);
  signal s_pipe1_on: std_logic;
  signal s_pipe2_on: std_logic;
  signal speed: integer:=5;
  signal pipe1_x_pos: unsigned(9 downto 0) := to_unsigned(640,10);
  signal pipe2_x_pos: unsigned(9 downto 0);
  signal dead: std_logic := '0';
  
  --LFSR
  signal rand_height: unsigned(9 downto 0);
  signal rand_valid: std_logic;
  
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
  SIGNAL bird_x, bird_y : std_logic_vector(9 DOWNTO 0);

  signal v_sync_signal : std_logic;

  -- Latch signals for button presses
  signal ps2_left_latch : std_logic := '0';
  signal ps2_right_latch : std_logic := '0';
  signal button_1_latched : std_logic := '0';
  signal button_2_latched : std_logic := '0';
  signal button_3_latched : std_logic := '0';
  signal button_4_latched : std_logic := '0';
  signal collision_latched : std_logic := '0';
  signal dead_latched : std_logic := '0';

  -- score signals
  signal score : integer := 0;
  signal pipe1_scored, pipe2_scored : std_logic := '0';
  constant BIRD_X_POS : integer := 160; -- The bird's fixed x position
  signal last_score : integer := 0;
  signal score_to_display : integer := 0;

  -- BCD Score signals 
  signal score_ones   : std_logic_vector(3 downto 0);
  signal score_tens   : std_logic_vector(3 downto 0);
  signal score_hundreds : std_logic_vector(3 downto 0);

  -- Lives signals 
  signal lives : std_logic_vector(1 downto 0) := "11"; -- 2 bits, 00, 01, 10, 11. 

  signal pipe1_safe : std_logic := '0';
  signal pipe2_safe : std_logic := '0';
  signal bcd_lives : std_logic_vector(3 downto 0); 
  signal lives_reset : std_logic := '0'; 
  -- Datatypes for game states
  type game_state_type is (menu, training, play, pause, game_over);
  signal current_state : game_state_type := menu;
  signal next_state : game_state_type;
  signal prev_state : game_state_type := play; -- Used to track the previous state
  signal collision : std_logic := '0';
  signal game_active : std_logic := '0';
  signal game_start : std_logic := '0';

  signal current_state_vec : std_logic_vector(2 downto 0); 
   

  component vga_sync is
    PORT(	clock_25Mhz : IN std_logic;
			red, green, blue		: IN	std_logic;
			red_out, green_out, blue_out : OUT std_logic;
			horiz_sync_out, vert_sync_out	: OUT	STD_LOGIC;
			pixel_row, pixel_column: OUT STD_LOGIC_VECTOR(9 DOWNTO 0));
  end component;
  
  component pipe is
    port (
		vert_sync: in std_logic;
		width : in unsigned(9 downto 0);
		pipe_x_pos	: in unsigned (9 DOWNTO 0);
      height  : in  unsigned(9 downto 0);
		pixel_row, pixel_column : in std_logic_vector(9 downto 0);
      pipe_on        : out std_logic);
	end component;
	
	component LFSR_Random is
		Port (
        clk      : in  STD_LOGIC;
        rst      : in  STD_LOGIC;
        enable   : in  STD_LOGIC;
        rnd_out  : out unsigned(9 downto 0);
        valid    : out STD_LOGIC
    );
	end component;

  component bouncy_bird IS
	port (
        ps2_left, pb2, clk, vert_sync, game_start : in  std_logic;
		  reset: in std_logic;
        pixel_row, pixel_column  : in  std_logic_vector(9 downto 0);
        game_state : in std_logic_vector(2 downto 0); 
        ball_y_pos_out : out std_logic_vector(9 downto 0);
        red, green, blue, ends        : out std_logic ;
        bird_x, bird_y                : out std_logic_vector(9 downto 0)
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
      state : in std_logic_vector(2 downto 0); 
			font_row, font_column : out std_logic_vector(3 downto 1); 
			character_addr : out std_logic_vector(5 downto 0); 
			within_bounds : out std_logic
		); 
	end component; 
	
	component textBox is 
				port(
		clock : in std_logic; 
		pixel_row, pixel_column : in std_logic_vector(9 downto 0); 
      lives : in std_logic_vector(1 downto 0); 
		state : in std_logic_vector(2 downto 0); 
		font_row, font_column : out std_logic_vector(2 downto 0); 
		character_addr : out std_logic_vector(5 downto 0);
      within_bounds : out std_logic
	); 
	end component; 


  begin
	
	game_active <= '1' when (current_state = play or current_state = training) else '0';
  pipe_reset <= '1' when ((current_state = game_over and (next_state = play or next_state = training)) or
                        (current_state = menu and (next_state = play or next_state = training)))
              else '0';

  bird_reset <= '1' when (current_state = menu and next_state = play) or
                        (current_state = game_over and next_state = play) or
                        (current_state = menu and next_state = training) or
                        (current_state = game_over and next_state = training) else
              '0';

    lives_reset <= '1' when 
    ((current_state = menu and next_state = training) or
     (current_state = game_over and next_state = training))
    else '0'; 


    -- State machine to handle game states
 process(clk_25MHz)

begin
    if rising_edge(clk_25MHz) then
        -- Latch logic
        if ps2_left = '1' then
            ps2_left_latch <= '1';
        elsif ( -- clear only when used for a transition
            (current_state = menu and next_state = play) or
            (current_state = pause and next_state = play) or
            (current_state = game_over and next_state = menu)
        ) then
            ps2_left_latch <= '0';
        end if;

        if ps2_right = '1' then
            ps2_right_latch <= '1';
        elsif (
            (current_state = menu and next_state = training) or
            (current_state = play and next_state = pause) or
            (current_state = pause and next_state = menu)
        ) then
            ps2_right_latch <= '0';
        end if;

        if button_1 = '0' then
            button_1_latched <= '1';
        elsif (current_state = training and next_state = play) then
            button_1_latched <= '0';
        end if;
        if collision = '1' then
          collision_latched <= '1';
        elsif (current_state = game_over and next_state /= game_over) then
          collision_latched <= '0'; -- Clear it once we enter game_over
        end if;
        if button_2 = '0' then
            button_2_latched <= '1';
        elsif (current_state = menu) then
            button_2_latched <= '0';
        end if;
        if (dead = '1') and (current_state = play)  then
          dead_latched <= '1';
        elsif (dead='1') and (current_state = training) then 
          dead_latched <= '1';
        elsif (current_state = game_over and next_state /= game_over) then
          dead_latched <= '0'; -- Clear it once we leave game_over
        end if;

        -- State machine
        --next_state <= current_state; -- Default

        case current_state is
            when menu =>
            if ps2_right_latch = '1' then
              next_state <= training;
              ps2_right_latch <= '0';
              dead_latched <= '0';  -- Reset dead latch here too
            elsif ps2_left_latch = '1' then
              next_state <= play;
              ps2_left_latch <= '0';
              dead_latched <= '0';  -- Reset dead latch here too
            end if;

            when training =>
				    speed <= speed_EASY;
                if button_1_latched = '1' then
                    next_state <= play;
						  button_1_latched <= '0';

              elsif ps2_right_latch = '1' then
                prev_state <= training; -- Store the previous state before pausing
                next_state <= pause;
                ps2_right_latch <= '0';
                speed <= 0;
              elsif collision_latched = '1' then
                prev_state <= training; 
                next_state <= game_over;
                speed <= 0;
              elsif dead_latched = '1' and lives = "00" then
                  prev_state <= training; 
                  next_state <= game_over;
                  speed <= 0;
              end if;

            when play =>
			
			--Difficulty implementation
			if score <= 1 then
				speed <= speed_EASY;
			elsif score > 3 and score < 6 then
				speed <= speed_MID;
			elsif score >= 10 then
				speed <= speed_HARD;
			end if;
			
            if ps2_right_latch = '1' then
              prev_state <= play; -- Store the previous state before pausing
              next_state <= pause;
              ps2_right_latch <= '0';
				      speed <= 0;
            elsif collision_latched = '1' then
              prev_state <= play; 
              next_state <= game_over;
				      speed <= 0;
            elsif dead_latched = '1' then
              prev_state <= play; 
              next_state <= game_over;
              speed <= 0;
            end if;

            when pause =>
				speed <= 0;
                if ps2_left_latch = '1' then
                    next_state <= prev_state; -- Return to the previous state
						  ps2_left_latch <= '0';
                elsif button_2_latched = '1' then
                    next_state <= menu;
						  button_2_latched <= '0';
                end if;

            when game_over =>
              if ps2_left_latch = '1' then
                    next_state <= prev_state;
						  ps2_left_latch <= '0';
						  speed <= speed_EASY;
              dead_latched <= '0'; -- Reset dead latch
               elsif button_2_latched = '1' then
                    next_state <= menu;
						  button_2_latched <= '0';
              dead_latched <= '0'; -- Reset dead latch
                end if;

            when others =>
                next_state <= menu;
        end case;


		  if (current_state /= play) and (next_state = play) then
			game_start <= '1';
		  else
			game_start <= '0';
		  end if;

        current_state <= next_state;
    end if;
end process;

-- Score processes 
score_logic: process(clk_25MHz)
    variable bird_y_int : integer;
    variable pipe_x, gap_top, gap_bottom : integer;
begin
    if rising_edge(clk_25MHz) then

        -- Latch the score when entering game_over
        if (current_state = play) and (next_state = game_over) then
            last_score <= score;
        end if;
        -- PIPE 1
        if (current_state /= play) and (current_state /= pause) then
              score <= 0;
              pipe1_scored <= '0';
              pipe2_scored <= '0';
        elsif (current_state = play) then -- Ensure that we only increment in play state
          bird_y_int := to_integer(unsigned(bird_y));
          pipe_x := to_integer(pipe1_x_pos);
          gap_top := to_integer(s_height);
          gap_bottom := gap_top + 150; -- or use your vertical_gap signal

          if (BIRD_X_POS > pipe_x + to_integer(pipe_width)) and
            --(bird_y_int > gap_top) and (bird_y_int < gap_bottom) and
            (pipe1_scored = '0') then
              score <= score + 1;
              pipe1_scored <= '1';
          end if;
          if (BIRD_X_POS <= pipe_x + to_integer(pipe_width)) then
              pipe1_scored <= '0';
          end if;

          -- PIPE 2
          pipe_x := to_integer(pipe2_x_pos);
          gap_top := to_integer(s_height2);
          gap_bottom := gap_top + 150;

          if (BIRD_X_POS > pipe_x + to_integer(pipe_width)) and
            --(bird_y_int > gap_top) and (bird_y_int < gap_bottom) and
            (pipe2_scored = '0') then
              score <= score + 1;
              pipe2_scored <= '1';
          end if;
          if (BIRD_X_POS <= pipe_x + to_integer(pipe_width)) then
              pipe2_scored <= '0';
          end if;
        end if; 
    end if;
end process;

-- Make sure the score is displayed correctly
score_to_display <= last_score when current_state = game_over else score;

-- Score BCD to HEX implementation 
score_ones    <= std_logic_vector(to_unsigned(score_to_display mod 10, 4));
score_tens    <= std_logic_vector(to_unsigned((score_to_display/10) mod 10, 4));
score_hundreds<= std_logic_vector(to_unsigned((score_to_display/100) mod 10, 4));
bcd_lives <= "00" & lives; 

sso_score: BCD_to_SevenSeg
port map(
    BCD_digit => score_ones,
    SevenSeg_out => HEX0
);

sst_score: BCD_to_SevenSeg
port map(
    BCD_digit => score_tens,
    SevenSeg_out => HEX1
);

ssh_score: BCD_to_SevenSeg
port map(
    BCD_digit => score_hundreds,
    SevenSeg_out => HEX2
);

sso_lives: BCD_to_SevenSeg
port map(
     BCD_digit => bcd_lives,        
     SevenSeg_out => HEX5      
); 

process(clk_25MHz)
begin
    if rising_edge(clk_25MHz) then
        if (lives_reset = '1') then 
          lives <= "11"; 
        else
          -- Set safe flag on collision/life loss in play mode
          if (current_state = play) and (dead = '1') and (lives /= "00") then
              if (ball_on = '1') and (s_pipe1_on = '1') then
                  pipe1_safe <= '1';
              end if;
              if (ball_on = '1') and (s_pipe2_on = '1') then
                  pipe2_safe <= '1';
              end if;
          end if;

          -- TRAINING MODE: Decrement lives only once per pipe hit
          if (current_state = training) and (dead = '1') and (lives /= "00") then
              if (pipe1_safe = '0' and (ball_on = '1') and (s_pipe1_on = '1')) then
                  lives <= std_logic_vector(unsigned(lives) - 1);
                  pipe1_safe <= '1';
              elsif (pipe2_safe = '0' and (ball_on = '1') and (s_pipe2_on = '1')) then
                  lives <= std_logic_vector(unsigned(lives) - 1);
                  pipe2_safe <= '1';
              end if;
          end if;

          -- Clear safe flag when pipe passes the bird
          if (to_integer(pipe1_x_pos) + to_integer(pipe_width + 16) < BIRD_X_POS) then
              pipe1_safe <= '0';
          end if;
          if (to_integer(pipe2_x_pos) + to_integer(pipe_width + 16) < BIRD_X_POS) then
              pipe2_safe <= '0';
          end if;

          -- Optionally, reset safe flags on game reset
          if (current_state /= play) and (current_state /= pause) and (current_state /= training) then
              pipe1_safe <= '0';
              pipe2_safe <= '0';
          end if;
      end if;
    end if; 
end process;

	  -- Assign the current_state something that is able to passed onto other components 
  -- Made since state and multicharacter text was developed seperately. 
  with current_state select 
    current_state_vec <=
        "000" when menu,
        "001" when training,
        "010" when play,
        "011" when pause,
        "100" when game_over,
        "000" when others;
  


  LEDR0 <= '1' when (dead = '1') else '0'; -- For debugging purposes, can be removed later

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
	
	random: LFSR_Random
	port map(
	clk => clk_25MHz,
	rst => '0',
	enable => '1',
	rnd_out => rand_height,
	valid => rand_valid
	);
	
	
	
	
	
    -- Instantiate the ball component
  BallComponent: bouncy_bird
  port map(
	 reset			 => bird_reset,
	 ps2_left 		 => ps2_left,
	 pb2 				 => button_2,
	 vert_sync 		 => v_sync_signal,
	 game_start     => game_start,
    clk            => clk_25MHz,
    pixel_row      => pixel_row,
    pixel_column   => pixel_column,
    game_state => current_state_vec,
    red            => red_ball,
    green          => green_ball,
    blue           => blue_ball,
    ends       => collision,
    bird_x       => bird_x,
    bird_y       => bird_y
  );
  
  
  -- Mux logic for text/score box
	font_row_in <= font_row_64 when within_bounds_64 = '1' else font_row_32;
	font_col_in <= font_col_64 when within_bounds_64 = '1' else font_col_32;
	character_address_in <= character_address_64 when within_bounds_64 = '1' else character_address_32;
	within_bounds <= within_bounds_64 or within_bounds_32;
  
  -- Pipe components and pipe logic
  
  pipe_1: pipe
  port map(
	vert_sync 		=> v_sync_signal,
	width				=> pipe_width,
	pipe_x_pos		=> pipe1_x_pos,
	height			=> s_height,
	pixel_row      => pixel_row,
   pixel_column   => pixel_column,
	pipe_on			=> s_pipe1_on
  );
  
  pipe_2: pipe
  port map(
	vert_sync 		=> v_sync_signal,
	width				=> pipe_width,
	pipe_x_pos		=> pipe2_x_pos,
	height			=> s_height2,
	pixel_row      => pixel_row,
   pixel_column   => pixel_column,
	pipe_on			=> s_pipe2_on
  );
  
  
  -- Moving pipe logic
  
moving_pipe: process(v_sync_signal, pipe_reset)
    constant MIN_GAP : unsigned(9 downto 0) := to_unsigned(300, 10);
begin
    if pipe_reset = '1' then
        pipe1_x_pos <= to_unsigned(720, 10);
        pipe2_x_pos <= to_unsigned(720, 10) + MIN_GAP;
    elsif rising_edge(v_sync_signal) then
        -- normal movement...
        if pipe1_x_pos = to_unsigned(0, 10) then
            pipe1_x_pos <= to_unsigned(640, 10) + pipe_width;
            s_height <= rand_height; 
        else
            pipe1_x_pos <= pipe1_x_pos - to_unsigned(speed, 10);
        end if;

        -- Move pipe2 with gap enforcement
        if (pipe2_x_pos = to_unsigned(0, 10)) then
				
				s_height2 <= rand_height;
            -- Wrap pipe2 to right edge, but ensure spacing from pipe1
            if (pipe1_x_pos > (to_unsigned(640,10) + pipe_width - MIN_GAP)) then
                pipe2_x_pos <= pipe1_x_pos + MIN_GAP;  -- place pipe2 at least MIN_GAP ahead
            else
                pipe2_x_pos <= to_unsigned(640, 10) + pipe_width;
            end if;
        else
            pipe2_x_pos <= pipe2_x_pos - to_unsigned(speed, 10);
        end if;
    end if;
end process;

dead_process:process(v_sync_signal)
    constant bird_x_const : unsigned(9 downto 0) := to_unsigned(160, 10); -- bird's x position
    constant bird_width   : unsigned(9 downto 0) := to_unsigned(16, 10); -- bird's width
    constant pipe_gap     : unsigned(9 downto 0) := to_unsigned(150, 10); -- same as vertical_gap in pipe.vhd
	 variable hit : std_logic;
begin
    if rising_edge(v_sync_signal) then
        -- Pipe 1 collision
        if (pipe1_x_pos < bird_x_const + bird_width) and (pipe1_x_pos + pipe_width > bird_x_const) then
            if (unsigned(bird_y) <= s_height) or (unsigned(bird_y) + bird_width >= s_height + pipe_gap) then
                hit := '1';
            else
                hit := '0';
            end if;
        -- Pipe 2 collision
        elsif (pipe2_x_pos < bird_x_const + bird_width) and (pipe2_x_pos + pipe_width > bird_x_const) then
            if (unsigned(bird_y) <= s_height2) or (unsigned(bird_y) + bird_width >= s_height2 + pipe_gap) then
                hit := '1';
            else
                hit := '0';
            end if;
        else
            hit := '0';
        end if;
		   dead <= hit;
    end if;
	
end process;


  -- Logic to determine if the current pixel is part of the bird
  ball_on <= '1' when ((current_state /= MENU) and(red_ball = '1' or green_ball = '1' or blue_ball = '1')) else '0';
  
  -- Logic to determine if the text will be on
  text_on <= '1' when (within_bounds = '1' and rom_mux_output = '1') else '0';
  
  -- Logic to combine bird and background colors
  -- If the current pixel is part of the bird, use the bird's color.
  -- Otherwise, use a constant background color (e.g., green background).
-- RED PIXEL: Bird = Red (no green/blue), background may vary by state
red_pixel <= '0' when (ball_on = '1') or (text_on = '1') else
             '1' when (current_state = TRAINING) or 
                      (current_state = PLAY) or 
                      (current_state = PAUSE) or 
                      (current_state = GAME_OVER) else 
             dip_sw1;

-- GREEN PIXEL: Bird = No green; pipes/text off green; background varies by state
green_pixel <= '0' when (ball_on = '1') or 
                         (text_on = '1') or 
                         (s_pipe1_on = '1') or 
                         (s_pipe2_on = '1') else
               '1' when (current_state = TRAINING) or 
                        (current_state = PLAY) or 
                        (current_state = GAME_OVER) else 
               dip_sw2;

-- BLUE PIXEL: Bird/text/cursor always = blue off; otherwise from dip_sw3
blue_pixel <= '1' when (ball_on = '1') or 
                        (text_on = '1') or 
                        (cursor_on = '1') else 
              dip_sw3;
  -- Dead bird
  -- dead <= '1' when (ball_on = '1') and 
  --   ((s_pipe1_on = '1' and pipe1_safe = '0') or (s_pipe2_on = '1' and pipe2_safe = '0')) 
  --   else '0';
  -- LEDR0 <= dead;
  
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
  state => current_state_vec,
	font_column => font_col_64,
	character_addr => character_address_64,
	within_bounds => within_bounds_64
  ); 
  
  TextDriver: textBox 
   port map(
	clock => clk_25MHz,
	pixel_row => pixel_row,
	pixel_column => pixel_column,
	lives => lives,
	font_row => font_row_32, -- Input 
	state => current_state_vec,
	font_column => font_col_32, 
	character_addr => character_address_32,
	within_bounds => within_bounds_32
  ); 

  -- LEDR0 <= ps2_left;
  
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

  



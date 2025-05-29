LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

entity textBox is 
		port(
		clock : in std_logic; 
		pixel_row, pixel_column : in std_logic_vector(9 downto 0); 
        lives : in std_logic_vector(1 downto 0); 
		font_row, font_column : out std_logic_vector(2 downto 0); 
        state : in std_logic_vector(2 downto 0); 
		character_addr : out std_logic_vector(5 downto 0);
      within_bounds : out std_logic
	); 
end entity textBox; 

architecture behaviour of textBox is
	constant PAUSE_length : integer := 5; 
    constant TRAINING_length : integer := 8;
	 constant PLAY_LENGTH  : integer := 4; 
    type char_addr_array is array(0 to PAUSE_LENGTH-1) of std_logic_vector(5 downto 0);
	 type char_addr_array_long is array(0 to TRAINING_LENGTH-1)  of std_logic_vector(5 downto 0); 
	 type char_addr_array_p is array(0 to PLAY_LENGTH-1) of std_logic_vector(5 downto 0); 
    constant PAUSE_address : char_addr_array := (
        "010000", -- P
        "000001", -- A
        "010101", -- U
        "010011", -- S
        "000101" -- E
    );

    constant TRAINING_address : char_addr_array_long := (
        "010100", -- T 
        "010010", -- R 
        "000001", -- A 
        "001001", -- I 
        "001110", -- N 
        "001001", -- I 
        "001110", -- N 
        "000111" -- G 
    );
	 
	 constant PLAY_address : char_addr_array_p := (
		"010000", -- P 
		"001100", -- L 
		"000001", -- A 
		"011001" -- Y 
	 );

    constant po_row : std_logic_vector(9 downto 0) :=  conv_std_logic_vector(180,10); 
    constant po_col : std_logic_vector(9 downto 0) :=  conv_std_logic_vector(240,10); 

    constant to_row : std_logic_vector(9 downto 0) := conv_std_logic_vector(250, 10); 
    constant to_col : std_logic_vector(9 downto 0) := conv_std_logic_vector(128, 10); 
	 
	constant play_row : std_logic_vector(9 downto 0) :=  conv_std_logic_vector(292,10); 
    constant play_col : std_logic_vector(9 downto 0) :=  conv_std_logic_vector(128,10); 

    constant l_row : std_logic_vector(9 downto 0) := conv_std_logic_vector(20,10); 
    constant l_col : std_logic_vector(9 downto 0) := conv_std_logic_vector(20,10); 

	 
    signal font_row_s, font_col_s : std_logic_vector(9 downto 0) := (others => '0');
    signal char_addr_s : std_logic_vector(5 downto 0) := (others => '0');
    signal within_bounds_s : std_logic := '0';
    signal active_letter : std_logic_vector(2 downto 0); 

begin 
	
	process(pixel_row, pixel_column) -- Start the process whenever we get the raw values 
        variable found : boolean := false; -- Handles the bounding box signal to be sent out 
        variable col_offset : std_logic_vector(9 downto 0);
        
    begin
        -- Reset everything
        font_row_s <= (others => '0');
        font_col_s <= (others => '0');
        char_addr_s <= (others => '0');
        within_bounds_s <= '0';
		
        -- When state is pause
        if (state = "011") then
            for i in 0 to PAUSE_LENGTH-1 loop
                -- Changes the bounding box according to the letter in the sequence
                col_offset := conv_std_logic_vector(unsigned(po_col) + conv_unsigned(32*i, 10), 10);
                if (pixel_row >= po_row and pixel_row < po_row + 32 and
                    pixel_column >= col_offset and pixel_column < col_offset + 32) then

                    font_row_s <= pixel_row - po_row;
                    font_col_s <= pixel_column - col_offset;
                    char_addr_s <= PAUSE_address(i);
                    within_bounds_s <= '1';
                    found := true;
                end if;
            end loop;
        end if; 
         
        -- When state is training
        if (state="000") then
                for i in 0 to TRAINING_LENGTH-1 loop
                -- Changes the bounding box according to the letter in the sequence
                col_offset := conv_std_logic_vector(unsigned(to_col) + conv_unsigned(32*i, 10), 10);
                if (pixel_row >= to_row and pixel_row < to_row + 32 and
                    pixel_column >= col_offset and pixel_column < col_offset + 32) then

                    font_row_s <= pixel_row - to_row;
                    font_col_s <= pixel_column - col_offset;
                    char_addr_s <= TRAINING_address(i);
                    within_bounds_s <= '1';
                    found := true;
                end if;
            end loop;

				for i in 0 to PLAY_LENGTH-1 loop
                -- Changes the bounding box according to the letter in the sequence
                col_offset := conv_std_logic_vector(unsigned(play_col) + conv_unsigned(32*i, 10), 10);
                if (pixel_row >= play_row and pixel_row < play_row + 32 and
                    pixel_column >= col_offset and pixel_column < col_offset + 32) then

                    font_row_s <= pixel_row - play_row;
                    font_col_s <= pixel_column - col_offset;
                    char_addr_s <= PLAY_address(i);
                    within_bounds_s <= '1';
                    found := true;
                end if;


            end loop;
        end if;
        
        -- when state is play 
        if (state="010" or state="011") then
            -- Depending on the number of hearts, print a different number of hearts
            if (lives = "11") then
                if (pixel_row >= l_row and pixel_row < l_row + 32 and pixel_column >= l_col and pixel_column < l_col + 32) then
                    font_row_s <= pixel_row - l_row;
                    font_col_s <= pixel_column - l_col;
                    within_bounds_s <= '1';
                    found := true;
						  char_addr_s <= "111010"; 
                elsif (pixel_row >= l_row and pixel_row < l_row + 32 and pixel_column >= l_col + 32 and pixel_column < l_col + 64) then
                    font_row_s <= pixel_row - l_row;
                    font_col_s <= pixel_column - (l_col + 32);
                    within_bounds_s <= '1';
                    found := true;
						  char_addr_s <= "111010"; 
                elsif (pixel_row >= l_row and pixel_row < l_row + 32 and pixel_column >= l_col + 64 and pixel_column < l_col + 96) then
                    font_row_s <= pixel_row - l_row;
                    font_col_s <= pixel_column - (l_col + 64);
                    within_bounds_s <= '1';
                    found := true;
						  char_addr_s <= "111010"; 
                end if;
            -- 2 hearts
            elsif (lives = "10") then
                if (pixel_row >= l_row and pixel_row < l_row + 32 and pixel_column >= l_col and pixel_column < l_col + 32) then
                    font_row_s <= pixel_row - l_row;
                    font_col_s <= pixel_column - l_col;
                    within_bounds_s <= '1';
                    found := true;
						  char_addr_s <= "111010"; 
                elsif (pixel_row >= l_row and pixel_row < l_row + 32 and pixel_column >= l_col + 32 and pixel_column < l_col + 64) then
                    font_row_s <= pixel_row - l_row;
                    font_col_s <= pixel_column - (l_col + 32);
                    within_bounds_s <= '1';
                    found := true;
						  char_addr_s <= "111010"; 
                end if;
            -- 1 heart
            elsif (lives = "01") then
                if (pixel_row >= l_row and pixel_row < l_row + 32 and pixel_column >= l_col and pixel_column < l_col + 32) then
                    font_row_s <= pixel_row - l_row;
                    font_col_s <= pixel_column - l_col;
                    within_bounds_s <= '1';
                    found := true;
						  char_addr_s <= "111010"; 
                end if;
            end if;
            
        end if; 


        if not found then
            font_row_s <= (others => '0');
            font_col_s <= (others => '0');
            char_addr_s <= (others => '0');
            within_bounds_s <= '0';
        end if;
    end process;

    font_row <= font_row_s(4 downto 2);
    font_column <= font_col_s(4 downto 2);
    character_addr <= char_addr_s;
    within_bounds <= within_bounds_s;

end architecture; 
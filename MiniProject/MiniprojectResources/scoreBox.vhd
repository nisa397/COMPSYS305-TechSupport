LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

entity scoreBox is 
	port(
		clock : in std_logic; 
		pixel_row, pixel_column : in std_logic_vector(9 downto 0); 
		font_row, font_column : out std_logic_vector(2 downto 0); 
        state : in std_logic_vector(2 downto 0); 
		character_addr : out std_logic_vector(5 downto 0);
      within_bounds : out std_logic
	); 
end entity;

architecture behaviour of scoreBox is
    constant TEXT_LENGTH : integer := 6;
	 constant GO_LENGTH : integer := 9;
    type char_addr_array is array(0 to TEXT_LENGTH-1) of std_logic_vector(5 downto 0);
	 type go_addr_array is array(0 to GO_LENGTH-1) of std_logic_vector(5 downto 0); 
    constant FLYGUY_address : char_addr_array := (
        "000110", -- F
        "001100", -- L
        "011001", -- Y
        "000111", -- G
        "010101", -- U
        "011001"  -- Y
    );
	 
	 constant GO_address : go_addr_array := (
		"000111", -- G 
		"000001", -- A 
		"001101", -- M
		"000101", -- E 
		"100000", -- SPACE
		"001111", -- O 
		"010110", -- V 
		"000101", -- E 
		"010010"  -- R
	 ); 
	 
	 
	 

    constant origin_row64 : std_logic_vector(9 downto 0) := conv_std_logic_vector(110, 10);
    constant origin_col64 : std_logic_vector(9 downto 0) := conv_std_logic_vector(128, 10);
	 
	 constant go_row : std_logic_vector(9 downto 0) := conv_std_logic_vector(208, 10); 
	 constant go_col : std_logic_vector(9 downto 0) := conv_std_logic_vector(32, 10); 


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
        if (state="000") then 
            for i in 0 to TEXT_LENGTH-1 loop
                -- Changes the bounding box according to the letter in the sequence
                col_offset := conv_std_logic_vector(unsigned(origin_col64) + conv_unsigned(64*i, 10), 10);
                if (pixel_row >= origin_row64 and pixel_row < origin_row64 + 64 and
                    pixel_column >= col_offset and pixel_column < col_offset + 64) then

                    font_row_s <= pixel_row - origin_row64;
                    font_col_s <= pixel_column - col_offset;
                    char_addr_s <= FLYGUY_address(i);
                    within_bounds_s <= '1';
                    found := true;
                end if;
            end loop;
        end if; 
        
        if (state="100") then 
            for i in 0 to GO_LENGTH-1 loop
                -- Changes the bounding box according to the letter in the sequence
                col_offset := conv_std_logic_vector(unsigned(go_col) + conv_unsigned(64*i, 10), 10);
                if (pixel_row >= go_row and pixel_row < go_row + 64 and
                    pixel_column >= col_offset and pixel_column < col_offset + 64) then

                    font_row_s <= pixel_row - go_row;
                    font_col_s <= pixel_column - col_offset;
                    char_addr_s <= GO_address(i);
                    within_bounds_s <= '1';
                    found := true;
                end if;
            end loop;
        end if; 


        if not found then
            font_row_s <= (others => '0');
            font_col_s <= (others => '0');
            char_addr_s <= (others => '0');
            within_bounds_s <= '0';
        end if;
    end process;

    font_row <= font_row_s(5 downto 3);
    font_column <= font_col_s(5 downto 3);
    character_addr <= char_addr_s;
    within_bounds <= within_bounds_s;

end architecture;
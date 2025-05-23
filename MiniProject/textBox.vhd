LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

entity textBox is 
		port(
		clock : in std_logic; 
		pixel_row, pixel_column : in std_logic_vector(9 downto 0); 
		font_row, font_column : out std_logic_vector(2 downto 0); 
        state : in std_logic_vector(2 downto 0); 
		character_addr : out std_logic_vector(5 downto 0);
      within_bounds : out std_logic
	); 
end entity textBox; 

architecture behaviour of textBox is
	constant PAUSE_length : integer := 5; 
    type char_addr_array is array(0 to PAUSE_LENGTH-1) of std_logic_vector(5 downto 0);
    constant FLYGUY_address : char_addr_array := (
        "010000", -- P
        "000001", -- A
        "010101", -- U
        "010011", -- S
        "000101" -- E
    );
	 
	 constant po_row : std_logic_vector(9 downto 0) :=  conv_std_logic_vector(180,10); 
	 constant po_col : std_logic_vector(9 downto 0) :=  conv_std_logic_vector(240,10); 
	 
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
		
        if (state = "011") then
            for i in 0 to PAUSE_LENGTH-1 loop
                -- Changes the bounding box according to the letter in the sequence
                col_offset := conv_std_logic_vector(unsigned(po_col) + conv_unsigned(32*i, 10), 10);
                if (pixel_row >= po_row and pixel_row < po_row + 32 and
                    pixel_column >= col_offset and pixel_column < col_offset + 32) then

                    font_row_s <= pixel_row - po_row;
                    font_col_s <= pixel_column - col_offset;
                    char_addr_s <= FLYGUY_address(i);
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

    font_row <= font_row_s(4 downto 2);
    font_column <= font_col_s(4 downto 2);
    character_addr <= char_addr_s;
    within_bounds <= within_bounds_s;

end architecture; 
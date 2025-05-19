LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

entity scoreBox is 
	port(
		clock : in std_logic; 
		pixel_row, pixel_column : in std_logic_vector(9 downto 0); 
		font_row, font_column : out std_logic_vector(2 downto 0); 
		character_addr : out std_logic_vector(5 downto 0);
      within_bounds : out std_logic
	); 
end entity;

architecture behaviour of scoreBox is
    constant TEXT_LENGTH : integer := 6;
    type char_addr_array is array(0 to TEXT_LENGTH-1) of std_logic_vector(5 downto 0);
    constant FLYGUY_address : char_addr_array := (
        "000110", -- F
        "001100", -- L
        "110001", -- Y
        "001111", -- G
        "110101", -- U
        "110001"  -- Y
    );
    constant origin_row32 : std_logic_vector(9 downto 0) := conv_std_logic_vector(110, 10);
    constant origin_col32 : std_logic_vector(9 downto 0) := conv_std_logic_vector(100, 10);

    signal font_row_s, font_col_s : std_logic_vector(2 downto 0) := (others => '0');
    signal char_addr_s : std_logic_vector(5 downto 0) := (others => '0');
    signal within_bounds_s : std_logic := '0';

begin

    process(pixel_row, pixel_column)
        variable found : boolean := false;
        variable col_offset : std_logic_vector(9 downto 0);
    begin
        font_row_s <= (others => '0');
        font_col_s <= (others => '0');
        char_addr_s <= (others => '0');
        within_bounds_s <= '0';

        for i in 0 to TEXT_LENGTH-1 loop
            col_offset := std_logic_vector(unsigned(origin_col32) + to_unsigned(32*i, 10));
            if (pixel_row >= origin_row32 and pixel_row < origin_row32 + 32 and
                pixel_column >= col_offset and pixel_column < col_offset + 32) then

                font_row_s <= conv_std_logic_vector((unsigned(pixel_row) - unsigned(origin_row32)) srl 2, 3);
                font_col_s <= conv_std_logic_vector((unsigned(pixel_column) - unsigned(col_offset)) srl 2, 3);
                char_addr_s <= FLYGUY_address(i);
                within_bounds_s <= '1';
                found := true;
            end if;
        end loop;

        if not found then
            font_row_s <= (others => '0');
            font_col_s <= (others => '0');
            char_addr_s <= (others => '0');
            within_bounds_s <= '0';
        end if;
    end process;

    font_row <= font_row_s;
    font_column <= font_col_s;
    character_addr <= char_addr_s;
    within_bounds <= within_bounds_s;

end architecture;
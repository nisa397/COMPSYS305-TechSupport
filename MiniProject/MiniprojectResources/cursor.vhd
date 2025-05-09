LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

entity cursor_drawer is
    Port (
        clk            : in  STD_LOGIC;
        video_row, video_column  : in  STD_LOGIC_VECTOR (9 downto 0);
        cursor_row, cursor_column: in  STD_LOGIC_VECTOR (9 downto 0);
		cursor_on : out STD_LOGIC
    );
end cursor_drawer;

architecture Behavioral of cursor_drawer is
	signal s_cursor_on: STD_LOGIC;
	signal cursor_size: std_logic_vector(9 DOWNTO 0);
	
	
begin

cursor_size <= CONV_STD_LOGIC_VECTOR(5,10);


process(clk)
    begin
        if rising_edge(clk) then
                -- Check if current pixel is within the cursor square
                if (video_row >= cursor_row and video_row < cursor_row + cursor_size) and
                   (video_column >= cursor_column and video_column < cursor_column + cursor_size) then
                    -- Draw white cursor
                    
					s_cursor_on <= '1';
                else
                    -- Background (black)
                    s_cursor_on <= '0';
                end if;
            
             
        end if;
    end process;
	
	cursor_on <= s_cursor_on;
	
	end Behavioral;



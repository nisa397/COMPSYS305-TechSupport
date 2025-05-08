library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cursor_drawer is
    Port (
        clk            : in  STD_LOGIC;
        video_row      : in  INTEGER range 0 to 479;
        video_column   : in  INTEGER range 0 to 639;
        video_on       : in  STD_LOGIC;
        cursor_row     : in  INTEGER range 0 to 479;
        cursor_column  : in  INTEGER range 0 to 639;
        red_out        : out STD_LOGIC_VECTOR(3 downto 0);
        green_out      : out STD_LOGIC_VECTOR(3 downto 0);
        blue_out       : out STD_LOGIC_VECTOR(3 downto 0)
    );
end cursor_drawer;

architecture Behavioral of cursor_drawer is

	


begin

    process(clk)
    begin
        if rising_edge(clk) then
            if video_on = '1' then
                -- Check if current pixel is within the cursor square
                if (video_row >= cursor_row and video_row < cursor_row + 5) and
                   (video_column >= cursor_column and video_column < cursor_column + 5) then
                    -- Draw white cursor
                    red_out   <= "1111";
                    green_out <= "1111";
                    blue_out  <= "1111";
                else
                    -- Background (black)
                    red_out   <= "0000";
                    green_out <= "0000";
                    blue_out  <= "0000";
                end if;
            else
                -- Outside display area
                red_out   <= "0000";
                green_out <= "0000";
                blue_out  <= "0000";
            end if;
        end if;
    end process;
	
	
	

end Behavioral;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BCD_Counter is
    Port (
        Clk       : in  STD_LOGIC;
        Reset     : in  STD_LOGIC;
        Enable    : in  STD_LOGIC;
        Direction : in  STD_LOGIC;
        Q_Out     : out unsigned(3 downto 0)
    );
end BCD_Counter;

architecture Behavioral of BCD_Counter is
    signal Counter : unsigned(3 downto 0) := "0000"; -- Internal counter signal
begin
    process(Clk)
    begin
        -- Check for rising edge of the clock
        if rising_edge(Clk) then
            -- Synchronous Reset
            if Reset = '1' then
                if Direction = '1' then
                    Counter <= "0000"; -- Reset to 0 for up counting
                else
                    Counter <= "1001"; -- Reset to 9 for down counting
                end if;
            -- Enable logic
            elsif Enable = '1' then
                -- Up counting
                if Direction = '1' then
                    if Counter = "1001" then
                        Counter <= "0000"; -- Wrap around to 0 after 9
                    else
                        Counter <= Counter + 1;
                    end if;
                -- Down counting
                else
                    if Counter = "0000" then
                        Counter <= "1001"; -- Wrap around to 9 after 0
                    else
                        Counter <= Counter - 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Output assignment
    Q_Out <= Counter;
end Behavioral;

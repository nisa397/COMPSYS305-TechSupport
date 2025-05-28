library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LFSR_Random is
    Port (
        clk      : in  STD_LOGIC;
        rst      : in  STD_LOGIC;
        enable   : in  STD_LOGIC;
        rnd_out  : out unsigned(9 downto 0);
        valid    : out STD_LOGIC
    );
end LFSR_Random;

architecture Behavioral of LFSR_Random is
    signal lfsr : unsigned(8 downto 0) := "101100111"; -- 9-bit seed
begin
    process(clk, rst)
        variable next_feedback: std_logic;
        variable next_lfsr : unsigned(8 downto 0);
        variable lfsr_val : integer;
    begin
        if rising_edge(clk) then
            next_lfsr := lfsr;
            if enable = '1' then
                -- Feedback taps for polynomial x^9 + x^5 + 1
                next_feedback := lfsr(8) XOR lfsr(3);
                next_lfsr := shift_left(next_lfsr, 1);
                next_lfsr(0) := next_feedback;

                lfsr <= next_lfsr;

                -- Convert to integer for range checking
                lfsr_val := to_integer(next_lfsr);

                -- Clamp output
                if lfsr_val < 50 then
                    rnd_out <= to_unsigned(50, 10);
                elsif lfsr_val > 420 then
                    rnd_out <= to_unsigned(420, 10);
                else
                    rnd_out <= to_unsigned(0, 1) & next_lfsr;
                end if;

                valid <= '1';  -- Always valid
            end if;
        end if;
    end process;
end Behavioral;


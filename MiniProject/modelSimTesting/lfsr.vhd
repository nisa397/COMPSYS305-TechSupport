library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity lfsr_8bit is
    Port (
	seed: in std_logic_vector
        clk     : in  std_logic;
        reset_n : in  std_logic;  -- active low reset
        q       : out std_logic_vector(7 downto 0)
    );
end entity;

architecture Behavioral of lfsr_8bit is
    signal lfsr_reg : std_logic_vector(7 downto 0) := (others => '0');
begin

    process(clk, reset_n)
        variable feedback : std_logic;
    begin
        if reset_n = '0' then
        lfsr_reg <= "00000001";  -- non-zero seed
        elsif rising_edge(clk) then
            -- XOR taps: bits 7, 3, 2, 1
            feedback := lfsr_reg(7) xor lfsr_reg(3) xor lfsr_reg(2) xor lfsr_reg(1);

            -- Shift left and insert feedback at LSB
            lfsr_reg <= lfsr_reg(6 downto 0) & feedback;
        end if;
    end process;

    q <= lfsr_reg;

end Behavioral;


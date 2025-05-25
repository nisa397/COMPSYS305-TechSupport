library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_lfsr_8bit is
-- testbench has no ports
end entity;

architecture Behavioral of tb_lfsr_8bit is

    -- Component declaration of the LFSR
    component lfsr_8bit is
        Port (
            clk     : in  std_logic;
            reset_n : in  std_logic;
            q       : out std_logic_vector(7 downto 0)
        );
    end component;

    signal clk     : std_logic := '0';
    signal reset_n : std_logic := '0';
    signal q       : std_logic_vector(7 downto 0);

    constant clk_period : time := 10 ns;

begin

    -- Instantiate LFSR
    uut: lfsr_8bit
        port map (
            clk => clk,
            reset_n => reset_n,
            q => q
        );

    -- Clock generation process
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Apply reset
        reset_n <= '0';
        wait for 25 ns;
        reset_n <= '1';

        -- Let LFSR run for 200 ns (20 clock cycles)
        wait for 200 ns;

        -- Stop simulation
        wait;
    end process;

end Behavioral;


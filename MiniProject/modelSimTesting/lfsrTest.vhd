library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_lfsr is
end entity tb_lfsr;

architecture arc of tb_lfsr is

	component LFSR_Random
		Port (
        clk      : in  STD_LOGIC;
        rst      : in  STD_LOGIC;
        enable   : in  STD_LOGIC;
        rnd_out  : out unsigned(9 downto 0);
        valid    : out STD_LOGIC
    );  
	end component;
	
	signal Clk_tb: std_logic := '0';
	signal seed_tb: unsigned (7 downto 0) := to_unsigned(114, 8);
	signal rand_tb: unsigned (9 downto 0);
	signal tb_valid: STD_LOGIC;
begin
	
	LFSR_TB:LFSR_Random 
	port map(
	rst => '0',
	Clk => Clk_tb,
	rnd_out => rand_tb,
	enable => '1',
	valid => tb_valid
	);

	process
	begin
	CLK_tb <= '0';
   	wait for 5 ns;
    	CLK_tb <= '1';
    	wait for 5 ns;
	end process;
end arc;

	
	

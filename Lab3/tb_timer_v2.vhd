library  IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
 entity tb_timer_v2 is
 end entity tb_timer_v2;
 
 architecture arc of tb_timer_v2 is
	signal tb_Clk, tb_Start, tb_Time_out: std_logic:= '0';
	signal tb_DataIn: unsigned(9 downto 0);
	signal sso_tb, sst_tb, ssm_tb: std_logic_vector (6 downto 0);
	
	component timer is
		port( 
        CLK      : in  STD_LOGIC;
        Start    : in  STD_LOGIC;
        Data_in  : in  unsigned (9 downto 0);
        Time_out : out STD_LOGIC;
		ss_o : out STD_LOGIC_VECTOR(6 downto 0);
		ss_t : out STD_LOGIC_Vector(6 downto 0);
		ss_m : out STD_LOGIC_Vector(6 downto 0)
    );
	end component timer;
begin

	DUT: timer
		port map(
		CLK => tb_Clk,
		Start => tb_Start,
		Time_out => tb_Time_out,
		Data_in => tb_DataIn,
		ss_o => sso_tb,
		ss_t => sst_tb,
		ss_m => ssm_tb
		);
		
	init: process
	begin
		tb_DataIn <= "0000000000", "0100000101" after 10 ns;
		tb_Start <= '1' after 20 ns;
		wait ;
	end process;	
	
	clk_gen: process
    begin
         wait for 10 ns;
         tb_Clk <= '1'; 
         wait for 10 ns;
         tb_Clk <= '0';
     end process clk_gen; 
	 
	 
end architecture arc;
	
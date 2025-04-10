library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_timer is
end tb_timer;

architecture arc of tb_timer is 

-- Component declaration of the Unit Under Test (UUT)
    component timer
        port(
            CLK      : in  STD_LOGIC;
            Start    : in  STD_LOGIC;
            Data_in  : in  unsigned (9 downto 0);
            Time_out : out STD_LOGIC;
	   -- ss_o : out STD_LOGIC_VECTOR(6 downto 0);
	--ss_t : out STD_LOGIC_Vector(6 downto 0);
	--ss_m : out STD_LOGIC_Vector(6 downto 0)
	ss_o : out unsigned(3 downto 0);
	ss_t : out unsigned(3 downto 0);
	ss_m : out unsigned(3 downto 0)
        );
    end component;

    -- Signals to connect to UUT
    signal CLK_tb      : STD_LOGIC := '0';
    signal Start_tb    : STD_LOGIC := '0';
    signal Data_in_tb  : unsigned(9 downto 0) := (others => '0');
    signal Time_out_tb : STD_LOGIC;
    --signal Sec_Ones_Seg : std_logic_vector(6 downto 0); --std logic vector output signal for BCD to seven segment conversion
    --signal Sec_Tens_Seg : std_logic_vector(6 downto 0); --std logic vector output signal for BCD to seven segment conversion
    --signal Min_Seg : std_logic_vector(6 downto 0); --std logic vector output signal for 
	signal Sec_Ones_Seg : unsigned(3 downto 0); --std logic vector output signal for BCD to seven segment conversion
    signal Sec_Tens_Seg : unsigned(3 downto 0); --std logic vector output signal for BCD to seven segment conversion
    signal Min_Seg : unsigned(3 downto 0); --std logic vector output signal for 
	
	

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: timer
        port map (
            CLK      => CLK_tb,
            Start    => Start_tb,
            Data_in  => Data_in_tb,
            Time_out => Time_out_tb,
	    ss_o => Sec_Ones_Seg,
	    ss_t => Sec_Tens_Seg,
	    ss_M => Min_Seg
        );

	--Clock process for 1Hz
	clk_process : process
	begin
	 CLK_tb <= '0';
    	wait for 5 ns;
    	CLK_tb <= '1';
    	wait for 5 ns;
	end process;

	--Process for rest of variables

	sim_process : process

	begin

        Data_in_tb <= "0100000101";  -- binary for 01:05
        wait for 100 ns;

        -- Start the timer
        Start_tb <= '1';
        wait for 10 ms;
        Start_tb <= '0';

	-- Wait until timeout signal is asserted
    	wait until Time_out_tb = '1';

	-- End the simulation after the timer completes
    	wait;  -- Stops the simulation

	end process;

end arc;

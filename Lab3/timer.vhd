library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity timer is 
    port( 
        CLOCK_50      : in  STD_LOGIC;
        Start    : in  STD_LOGIC;
        SW  : in  unsigned (9 downto 0); -- Data in
        LEDR0 : out STD_LOGIC;
	--Time_seg : out unsigned(11 downto 0)
	HEX0 : out STD_LOGIC_VECTOR(6 downto 0); --sso
	HEX1 : out STD_LOGIC_Vector(6 downto 0); --sst
	HEX2 : out STD_LOGIC_Vector(6 downto 0) --ssm
	--HEX0 : out unsigned(3 downto 0);
	--HEX1 : out unsigned(3 downto 0);
	--HEX2 : out unsigned(3 downto 0)
    );
end timer;

architecture arc of timer is 

    -- BCD Counter signals
    signal Sec_Ones       : unsigned (3 downto 0):="0000"; -- Seconds, ones place
    signal Sec_Tens       : unsigned (3 downto 0):="0000"; -- Seconds, tens place
    signal Min            : unsigned (3 downto 0):="0000"; -- Minutes
    signal Sec_Ones_Limit: unsigned (3 downto 0); -- Goal value
    signal Sec_Tens_Limit: unsigned (3 downto 0);
    signal Min_Limit      : unsigned (3 downto 0);
    signal Carry_tens     : STD_LOGIC;
    signal Carry_min      : STD_LOGIC;
    signal Reset_Tens     : STD_LOGIC;
    signal Running        : STD_LOGIC := '0';
    signal Sec_Ones_Seg : std_logic_vector(6 downto 0); --std logic vector output signal for BCD to seven segment conversion
    signal Sec_Tens_Seg : std_logic_vector(6 downto 0); --std logic vector output signal for BCD to seven segment conversion
    signal Min_Seg : std_logic_vector(6 downto 0); --std logic vector output signal for BCD to seven segment conversion
    signal Clk_1hz: std_logic;



    component BCD_Counter
        Port (
            Clk       : in  STD_LOGIC;
            Reset     : in  STD_LOGIC;
            Enable    : in  STD_LOGIC;
            Direction : in  STD_LOGIC;
            Q_Out     : out unsigned (3 downto 0)
        );
    end component;

     component Clock_1Hz
		Port(
		Clk: in std_logic;
		Q: out std_logic);
     end component;


   component BCD_to_SevenSeg
	Port(
	   BCD_digit : in std_logic_vector(3 downto 0);
           SevenSeg_out : out std_logic_vector(6 downto 0)
		);
   end component;

begin

    -- Load limit values and stop timer on goal match
    process(Clk_1hz)
	variable sec_ones_temp : unsigned(3 downto 0);
    	variable sec_tens_temp : unsigned(3 downto 0);
    begin
        if rising_edge(Clk_1hz) then
            if Start = '1' then
                --Running <= '1';
                sec_ones_temp := SW(3 downto 0);
                sec_tens_temp := SW(7 downto 4);
                Min_Limit      <= ("00" & SW(9 downto 8)); -- Make 4 bits
                --LEDR0 <= '0';
						if sec_ones_temp > "1001" then
							sec_ones_temp := "1001"; -- 9
						end if;

						if sec_tens_temp > "0101" then
							sec_tens_temp := "0101"; -- 5
						end if;
		
					Sec_Ones_Limit <= sec_ones_temp;
            Sec_Tens_Limit <= sec_tens_temp;

            --elsif (Min = Min_Limit and Sec_Tens = Sec_Tens_Limit and Sec_Ones = Sec_Ones_Limit) then
                --Running <= '0';
                --LEDR0 <= '1';
            end if;
        end if;
    end process;
	 Running <= '0' when (Min = Min_Limit and Sec_Tens = Sec_Tens_Limit and Sec_Ones = Sec_Ones_Limit) else '1';
	 LEDR0 <= '1' when (Min = Min_Limit and Sec_Tens = Sec_Tens_Limit and Sec_Ones = Sec_Ones_Limit) else '0';
	 
    -- Carry signals
    Carry_tens <= '1' when (Sec_Ones = "1001" and Running = '1') else '0'; -- 9
    Carry_min  <= '1' when (Sec_Tens = "0101" and Sec_Ones = "1001" and Running = '1') else '0'; -- 59
    Reset_Tens <= '1' when (Sec_Tens = "0101" and Sec_Ones = "1001" and Running = '1') else '0';
    
	Clock1Hz: Clock_1Hz 
		port map (
			Clk => CLOCK_50,
			Q => Clk_1hz
			);

    -- Ones Place Counter
    Sec_One_Counter: BCD_Counter
        port map (
            Clk       => Clk_1Hz,
            Reset     => '0',
            Enable    => Running,
            Direction => '1',
            Q_Out     => Sec_Ones
        );


	
    -- Tens Place Counter
    Sec_Ten_Counter: BCD_Counter
        port map (
            Clk		=> Clk_1Hz,
            Reset     => Reset_Tens,
            Enable    => Carry_tens,
            Direction => '1',
            Q_Out     => Sec_Tens
        );

    -- Minutes Counter
    Minute_Counter: BCD_Counter
        port map (
            Clk => Clk_1Hz,
            Reset     => '0',
            Enable    => Carry_min,
            Direction => '1',
            Q_Out     => Min
        );

	--Time_seg <= Min & Sec_Tens & Sec_Ones;
	--HEX0 <= Sec_Ones;
	--HEX1 <= Sec_Tens;
 	--HEX2 <= Min;
	

	

	--Conversion to Seven Segment
	Sec_7Seg: BCD_to_SevenSeg
		port map (
			BCD_digit => std_logic_vector(Sec_Ones),
			SevenSeg_out => HEX0
		);
	
	Sec_Tens_7Seg: BCD_to_SevenSeg
    port map (
                BCD_digit    => std_logic_vector(Sec_Tens),
                SevenSeg_out => HEX1
       );

       Min_7Seg: BCD_to_SevenSeg
           port map (
                    BCD_digit    => std_logic_vector(Min),
                    SevenSeg_out => HEX2
                  );
	--HEX0 <= Sec_Ones_Seg;
	--HEX1 <= Sec_Tens_Seg;
 	--HEX2 <= Min_Seg;

end arc;

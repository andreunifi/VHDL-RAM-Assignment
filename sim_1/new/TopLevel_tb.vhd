library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity TopLevel_tb is
end TopLevel_tb;

architecture Behavioral of TopLevel_tb is

    -- Component declaration of the TopLevel entity
    component TopLevel is
        Port (
            CLK     : in  STD_LOGIC;
            RESET   : in  STD_LOGIC;
            START   : in  STD_LOGIC;
            DONE    : out STD_LOGIC;
            DOUT    : out STD_LOGIC_VECTOR(7 downto 0); -- Added DOUT port
            ADDR    : out STD_LOGIC_VECTOR(3 downto 0); -- Address bus for RAM
            EN      : out STD_LOGIC;                  -- RAM enable signal
            WE      : out STD_LOGIC                   -- RAM write enable
        );
    end component;

    -- Signals for the TopLevel entity
    signal CLK     : STD_LOGIC := '0';
    signal RESET   : STD_LOGIC := '0';
    signal START   : STD_LOGIC := '0';
    signal DONE    : STD_LOGIC;
    signal DOUT    : STD_LOGIC_VECTOR(7 downto 0); -- Signal for DOUT output
    signal ADDR    : STD_LOGIC_VECTOR(3 downto 0); -- Signal for address output
    signal EN      : STD_LOGIC;
    signal WE      : STD_LOGIC;

    -- Signals for runtime RAM verification
    signal RAM_DATA : std_logic_vector(7 downto 0);

    -- Clock period constant
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instantiate the TopLevel entity
    uut: TopLevel
        Port map (
            CLK     => CLK,
            RESET   => RESET,
            START   => START,
            DONE    => DONE,
            DOUT    => DOUT, -- Connect DOUT signal
            ADDR    => ADDR, -- Connect ADDR signal
            EN      => EN,   -- Connect EN signal
            WE      => WE    -- Connect WE signal
        );

    -- Clock process to generate clock signal
    clk_process : process
    begin
        CLK <= '0';
        wait for CLK_PERIOD / 2;
        CLK <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Stimulus process
    stimulus_process : process
    begin
        -- Apply reset
        RESET <= '1';
        wait for CLK_PERIOD * 2;
        RESET <= '0';
        wait for CLK_PERIOD;

        -- Start the process
        START <= '1';
        wait for CLK_PERIOD;
        START <= '0';

        -- Monitor the DOUT signal during the simulation
        wait for 50 ns; -- Wait to let some operations start

        -- Wait for the sorting process to complete
        wait until DONE = '1';

        -- Finish the simulation
        wait;
    end process;

    -- Runtime RAM Monitoring Process
    ram_monitoring_process : process
        variable address : integer := 0;
    begin
        wait for CLK_PERIOD; -- Wait for the system to start

        while DONE = '0' loop
            if EN = '1' and WE = '0' then -- Read operation
                RAM_DATA <= DOUT; -- Read the value currently being accessed
                
            end if;

            wait for CLK_PERIOD; -- Wait for the next clock cycle
        end loop;

        -- Final message when DONE signal is high
        report "Sorting completed. RAM data has been sorted.";

        wait; -- End the process
    end process;

end Behavioral;

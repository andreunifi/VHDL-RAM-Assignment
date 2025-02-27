library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TopLevelDownUp_tb is
-- No ports for a testbench
end TopLevelDownUp_tb;

architecture Behavioral of TopLevelDownUp_tb is

    -- Component declaration for the unit under test (UUT)
    component TopLevelDownUp
        Port (
            CLK         : in  STD_LOGIC;
            RESET       : in  STD_LOGIC;
            START       : in  STD_LOGIC
        );
    end component;

    -- Testbench signals
    signal CLK       : STD_LOGIC := '0';
    signal RESET     : STD_LOGIC := '0';
    signal START     : STD_LOGIC := '0';

    -- Clock period definitions
    constant CLK_PERIOD : time := 10 ns;  -- Main clock period

begin

    -- Instantiate the Unit Under Test (UUT)
    UUT: TopLevelDownUp
        port map (
            CLK     => CLK,
            RESET   => RESET,
            START   => START
        );

    -- Clock generation for the main clock
    CLK_process : process
    begin
        while true loop
            CLK <= '0';
            wait for CLK_PERIOD / 2;
            CLK <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;



    -- Stimulus process
    stimulus_process: process
    begin
        -- Reset the system
        RESET <= '1';
        wait for CLK_PERIOD * 5;
        RESET <= '0';
        wait for CLK_PERIOD * 5;

        -- Start the sorting operation
        START <= '1';
        wait for CLK_PERIOD;
        START <= '0';

        -- Wait for the sorting process to complete
        wait for 30000 ns; -- Adjust time based on design's execution speed

        -- End simulation
        wait;
    end process;

end Behavioral;

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
            DONE    : out STD_LOGIC
        );
    end component;

    -- Signals for the TopLevel entity
    signal CLK     : STD_LOGIC := '0';
    signal RESET   : STD_LOGIC := '0';
    signal START   : STD_LOGIC := '0';
    signal DONE    : STD_LOGIC;

    -- Clock period constant
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instantiate the TopLevel entity
    uut: TopLevel
        Port map (
            CLK     => CLK,
            RESET   => RESET,
            START   => START,
            DONE    => DONE
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

        -- Wait for the sorting process to complete
        wait until DONE = '1';

        -- Finish the simulation
        wait;
    end process;

end Behavioral;

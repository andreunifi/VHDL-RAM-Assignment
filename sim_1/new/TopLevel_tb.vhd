library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TopLevel_tb is
end TopLevel_tb;

architecture Behavioral of TopLevel_tb is


    component TopLevel is
        Port (
            CLK     : in  STD_LOGIC;
            RESET   : in  STD_LOGIC;
            START   : in  STD_LOGIC;
            DONE    : out STD_LOGIC
        );
    end component;


    signal CLK     : STD_LOGIC := '0';
    signal RESET   : STD_LOGIC := '0';
    signal START   : STD_LOGIC := '0';
    signal DONE    : STD_LOGIC;


    constant CLK_PERIOD : time := 10 ns;

begin

 --TopLevel entity
    uut: TopLevel
        Port map (
            CLK     => CLK,
            RESET   => RESET,
            START   => START,
            DONE    => DONE
        );

--Clock gen
    clk_process : process
    begin
        CLK <= '0';
        wait for CLK_PERIOD / 2;
        CLK <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    stimulus_process : process
    begin
        RESET <= '1';
        wait for CLK_PERIOD * 2;
        RESET <= '0';
        wait for CLK_PERIOD;

        START <= '1';
        wait for CLK_PERIOD;
        START <= '0';

        wait until DONE = '1';

        wait;
    end process;

end Behavioral;

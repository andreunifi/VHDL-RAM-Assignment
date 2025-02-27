library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_sorting_system is
end tb_sorting_system;

architecture Behavioral of tb_sorting_system is
--I created a testbench for checking the interactions of both of them
    signal CLK       : std_logic := '0';  
    signal RESET     : std_logic := '0';
    signal START     : std_logic := '0';
    signal ADDR      : std_logic_vector(3 downto 0);
    signal DIN       : std_logic_vector(7 downto 0);
    signal DOUT      : std_logic_vector(7 downto 0);
    signal WE        : std_logic := '0';
    signal EN        : std_logic := '0';
    signal DATA_OUT  : std_logic;

    -- Signals for the extra RAM outputs
    signal FIRST     : std_logic_vector(7 downto 0);
    signal LAST      : std_logic_vector(7 downto 0);

    constant CLK_PERIOD : time := 20 ns;

begin

-- Instantiate the FSM
    uut_fsm: entity work.FSM
        port map (
            CLK      => CLK,      -- Single clock used for the FSM
            RESET    => RESET,
            START    => START,
            ADDR     => ADDR,     -- Shared address signal
            DIN      => DIN,      -- Shared data-in signal
            DOUT     => DOUT,     -- Shared data-out signal
            WE       => WE,       -- Shared write enable
            EN       => EN,       -- Shared enable
            DATA_OUT => DATA_OUT
        );

-- Instantiate the RAM with two extra output ports: FIRST and LAST
    uut_ram: entity work.RAM
        generic map (
            RAM_WIDTH   => 8,
            RAM_DEPTH   => 16,
            RAM_ADD     => 4,
            INIT_FILE   => "memory.mem",
            OUTPUT_FILE => "output.mem"
        )
        port map (
            ADDR  => ADDR,   
            DIN   => DIN,   
            CLK   => CLK,  
            WE    => WE,    
            EN    => EN,     
            DOUT  => DOUT,   
            FIRST => FIRST,  
            LAST  => LAST    
        );


    clk_process: process
    begin
        while true loop
            CLK <= '0';
            wait for CLK_PERIOD / 2;
            CLK <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Test process: Stimulates the FSM and then checks the RAM outputs FIRST and LAST after sorting completes
    test_process: process
    begin

        RESET <= '1';
        wait for 40 ns;
        RESET <= '0';
        START <= '1';
        wait for 20 ns;
        START <= '0';

--Need to wait until sorting is complete.
        wait until DATA_OUT = '1';
        wait for 20 ns;  
        assert FIRST = "10101010"
            report "First RAM element is not sorted" severity failure;
        assert LAST = x"FF"
            report "Last RAM element is not sorted" severity failure;

        wait for 100 ns;
        wait;
    end process;

end Behavioral;

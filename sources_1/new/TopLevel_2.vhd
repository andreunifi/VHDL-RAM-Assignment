library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TopLevelDownUp is
    Port (
        CLK         : in  STD_LOGIC;
        RESET       : in  STD_LOGIC;
        START       : in  STD_LOGIC;
        
        -- RAM interface
        RAM_CLK     : in  STD_LOGIC
    );
end TopLevelDownUp;

architecture Behavioral of TopLevelDownUp is

    -- RAM instantiation
    component RAM is
        generic(
            RAM_WIDTH : integer := 8;
            RAM_DEPTH : integer := 16;
            RAM_ADD   : integer := 4;
            INIT_FILE : string := "memory.mem";
            OUTPUT_FILE: string := "output.mem"
        );
        port(
            ADDR : in std_logic_vector(RAM_ADD-1 downto 0);
            DIN  : in std_logic_vector(RAM_WIDTH-1 downto 0);
            CLK  : in std_logic;
            WE   : in std_logic;
            EN   : in std_logic;
            DOUT : out std_logic_vector(RAM_WIDTH-1 downto 0)
        );
    end component;

    -- Internal signals for FSM to RAM connection
    signal fsm_ADDR   : STD_LOGIC_VECTOR(3 downto 0);
    signal fsm_DIN    : STD_LOGIC_VECTOR(7 downto 0);
    signal fsm_DOUT   : STD_LOGIC_VECTOR(7 downto 0); -- Added for DOUT connection
    signal fsm_WE     : STD_LOGIC;
    signal fsm_EN     : STD_LOGIC;
    signal fsm_DONE   : STD_LOGIC;
    signal fsm_DATA_OUT : STD_LOGIC;

begin

    -- Instantiating the FSM
    FSM_inst : entity work.FSM
        port map (
            CLK         => CLK,
            RESET       => RESET,
            START       => START,
            DONE        => fsm_DONE,
            ADDR        => fsm_ADDR,
            DIN         => fsm_DIN,
            DOUT        => fsm_DOUT, -- Connected to fsm_DOUT
            WE          => fsm_WE,
            EN          => fsm_EN,
            DATA_OUT    => fsm_DATA_OUT -- Connected to fsm_DATA_OUT
        );

    -- Instantiating the RAM
    RAM_inst : entity work.RAM
        generic map (
            RAM_WIDTH  => 8,
            RAM_DEPTH => 16,
            RAM_ADD    => 4,
            INIT_FILE  => "memory.mem",
            OUTPUT_FILE=> "output.mem"
        )
        port map (
            ADDR => fsm_ADDR,
            DIN  => fsm_DIN,
            CLK  => RAM_CLK, -- Explicit RAM clock connection
            WE   => fsm_WE,
            EN   => fsm_EN,
            DOUT => fsm_DOUT -- Connected to fsm_DOUT
        );

end Behavioral;

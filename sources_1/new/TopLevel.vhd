library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TopLevel is
    Port (
        CLK     : in  STD_LOGIC;
        RESET   : in  STD_LOGIC;
        START   : in  STD_LOGIC;
        DONE    : out STD_LOGIC
    );
end TopLevel;

architecture Behavioral of TopLevel is

--Internal signals
    signal ADDR   : STD_LOGIC_VECTOR(3 downto 0); -- 16 addresses
    signal DIN    : STD_LOGIC_VECTOR(7 downto 0); -- 8-bit data input to RAM
    signal DOUT   : STD_LOGIC_VECTOR(7 downto 0); -- 8-bit data output from RAM
    signal WE     : STD_LOGIC;                     -- Write enable for RAM
    signal EN     : STD_LOGIC;                     -- Enable signal for RAM


    component RAM is
        Port (
            CLK  : in  STD_LOGIC;
            WE   : in  STD_LOGIC;
            ADDR : in  STD_LOGIC_VECTOR(3 downto 0);
            DIN  : in  STD_LOGIC_VECTOR(7 downto 0);
            EN   : in STD_LOGIC;  
            DOUT : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;


    component Controller is
        Port (
            CLK     : in  STD_LOGIC;
            RESET   : in  STD_LOGIC;
            START   : in  STD_LOGIC;
            DONE    : out STD_LOGIC;
            ADDR    : out STD_LOGIC_VECTOR(3 downto 0);
            DIN     : out STD_LOGIC_VECTOR(7 downto 0);
            DOUT    : in  STD_LOGIC_VECTOR(7 downto 0);
            WE      : out STD_LOGIC;
            EN      : out STD_LOGIC
        );
    end component;

begin

    RAM_inst : RAM
        Port map (
            CLK  => CLK,
            WE   => WE,
            ADDR => ADDR,
            DIN  => DIN,
            EN   => EN,  
            DOUT => DOUT
        );

    Controller_inst : Controller
        Port map (
            CLK     => CLK,
            RESET   => RESET,
            START   => START,
            DONE    => DONE,
            ADDR    => ADDR,
            DIN     => DIN,
            DOUT    => DOUT,
            WE      => WE,
            EN      => EN  
        );

end Behavioral;

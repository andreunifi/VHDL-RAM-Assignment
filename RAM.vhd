
--  Xilinx Single Port No Change RAM
--  This code implements a parameterizable single-port no-change memory where when data is written
--  to the memory, the output remains unchanged.  This is the most power efficient write mode.
--  Modify the parameters for the desired RAM characteristics.

library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;

entity RAM is
    generic(
        RAM_WIDTH : integer := 8;
        RAM_DEPTH : integer := 16;
        RAM_ADD   : integer := 4;
        INIT_FILE : string := "memory.mem";
        OUTPUT_FILE: string := "output.mem"
    );
    port(
        ADDR : in std_logic_vector(RAM_ADD-1 downto 0);                          -- Address bus, width determined from RAM_DEPTH
        DIN  : in std_logic_vector(RAM_WIDTH-1 downto 0);                                  -- RAM input data
        CLK  : in std_logic;                                                                 -- Clock
        WE   : in std_logic;                                                                 -- Write enable
        EN   : in std_logic;                                                                 -- RAM Enable, for additional power savings, disable port when not in use
        DOUT : out std_logic_vector(RAM_WIDTH-1 downto 0)
                                                        -- Signal to trigger writing to file
                               -- RAM output data
    );
end RAM;

architecture behav of RAM is

type ram_type is array (0 to RAM_DEPTH-1) of std_logic_vector(RAM_WIDTH-1 downto 0);      -- 2D Array Declaration for RAM signal

function initramfromfile (ramfilename : in string) return ram_type is
file ramfile	: text open read_mode is ramfilename;
variable ramfileline : line;
variable ram_name	: ram_type;
variable bitvec : bit_vector(RAM_WIDTH-1 downto 0);
begin
    for i in ram_type'range loop
        readline (ramfile, ramfileline);
        read (ramfileline, bitvec);
        ram_name(i) := to_stdlogicvector(bitvec);
    end loop;
    return ram_name;
end function;

function init_from_file_or_zeroes(ramfile : string) return ram_type is
begin
    if ramfile = "memory.mem" then
        return InitRamFromFile("memory.mem") ;
    else
        return (others => (others => '0'));
    end if;
end;

function clogb2( depth : natural) return integer is
variable temp    : integer := depth;
variable ret_val : integer := 0;
begin
    while temp > 1 loop
        ret_val := ret_val + 1;
        temp    := temp / 2;
    end loop;
    return ret_val;
end function;



signal QR : std_logic_vector(RAM_WIDTH-1 downto 0) ;
signal RAM : ram_type := init_from_file_or_zeroes(INIT_FILE);

begin

process(CLK)
begin
    if(CLK'event and CLK = '1') then
 
        if(EN = '1') then
            if(WE = '1') then
                RAM(to_integer(unsigned(ADDR))) <= DIN;
            else
 
                QR <= RAM(to_integer(unsigned(ADDR)));
            end if;
            

            
        end if;
    end if;
end process;

DOUT <= QR; --final assignment for the output data bus, can be substituted with a register (see the Vivado template)

end behav;
						
						

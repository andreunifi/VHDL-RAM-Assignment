library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Controller is
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
end Controller;

architecture Behavioral of Controller is

    --Current states. I choose to split the bubble sort logic into a mixed approach
    --Mostly an inner/outer counter for the external logic, but the single step is composed
    --Of multiple steps
    
    type State_Type is (IDLE, LOAD1, LOAD2, COMPARE, SWAP_CURRENT, SWAP_PREVIOUS, INCREMENT, DONE_STATE);
    signal current_state, next_state : State_Type;

    -- Internal signals
    
    signal reg1, reg2 : STD_LOGIC_VECTOR(7 downto 0); -- Temp
    signal nextreg1,nextreg2: STD_LOGIC_VECTOR(7 downto 0);
    signal swap_flag  : STD_LOGIC;                   -- Swap if needed
    signal inner_counter, nextinner_counter : INTEGER range 0 to 15 := 15; -- Counter for inner loop
    signal outer_counter, nextouter_counter : INTEGER range 0 to 15 := 15; -- Counter for outer loop
    signal twocounter, nextwocounter: INTEGER range 0 to 2 := 0; -- Two-cycle counter for LOAD1 state
begin

    --Sequential logic
    process (CLK, RESET)
    begin
        if RESET = '1' then
        
            current_state <= IDLE;
            inner_counter <= 15;
            outer_counter <= 15;
            reg1 <= (others => '0');
            reg2 <= (others => '0');
            
            twocounter <= 0; 
        elsif rising_edge(CLK) then
            current_state <= next_state;
            inner_counter <= nextinner_counter;
            outer_counter <= nextouter_counter;
            reg1 <= nextreg1;
            reg2 <= nextreg2;
            
            twocounter <= nextwocounter; -- Update twocounter 
        end if;
    end process;

    -- Combinational logic
    process (current_state, START, reg1, reg2, inner_counter, outer_counter, twocounter)
    begin
        -- Default values for outputs
        next_state <= current_state;
        ADDR <= "0000";
        DIN <= (others => '0');
        WE <= '0';
        EN <= '0';
        DONE <= '0';
        swap_flag <= '0';

        case current_state is
            
            when IDLE =>
                if START = '1' then
                    next_state <= LOAD1;
                    nextinner_counter <= 15; -- address going from 0 to 15, 16 elements total
                    nextouter_counter <= 15; 
                    nextwocounter <= 0;      -- Waiting for RAM timings
                end if;

            -- LOAD1: Load the current element (wait 2 CC for the Ram, i've done this to 
            --avoid unassigned signals )
            when LOAD1 =>
                EN <= '1';
                ADDR <= std_logic_vector(to_unsigned(inner_counter, 4));
                nextreg1 <= DOUT; 
                if twocounter < 2 then
                    next_state <= LOAD1;
                    nextwocounter <= twocounter + 1;  -- Increment the cycle counter so that it stays
                    --until the ram has completed the cycle for outputting data
                else
                    next_state <= LOAD2;          
                    nextwocounter <= 0;          
                end if;


            when LOAD2 =>
                EN <= '1';
                ADDR <= std_logic_vector(to_unsigned(inner_counter - 1, 4));
                nextreg2 <= DOUT; 
                              
                if twocounter < 2 then
                    next_state <= LOAD2;
                    nextwocounter <= twocounter + 1;  
                else
                    next_state <= COMPARE;         
                    nextwocounter <= 0;           
                end if;
                
                
                
            when COMPARE =>
                if reg1 < reg2 then
                    swap_flag <= '1';
                    next_state <= SWAP_CURRENT;
                else
                    next_state <= INCREMENT;
                end if;

--Swap current switches the N element to the N+1 position, handles RAM signal logic, and then moves to swap_previous
            when SWAP_CURRENT =>
                ADDR <= std_logic_vector(to_unsigned(inner_counter, 4));
                DIN <= reg2;
                WE <= '1'; -- Enable write
                EN <= '1';
                next_state <= SWAP_PREVIOUS;

 --If reg1<reg2, data[inner_counter -1] <= data[inner_counter]
            when SWAP_PREVIOUS =>
                ADDR <= std_logic_vector(to_unsigned(inner_counter - 1, 4));
                DIN <= reg1;
                WE <= '1'; -- Enable write
                EN <= '1';
                next_state <= INCREMENT;

--The logic for handling the loop checks if i am on my last iteration
--(inner_counter = '1' so that it means i've reached the last element, since they are processed in pairs)
            when INCREMENT =>
                if inner_counter = 1 then 
                    if outer_counter = 0 then -- End of all iterations
                        next_state <= DONE_STATE;
                    else
                        nextouter_counter <= outer_counter - 1; -- Decrease outer loop
                        nextinner_counter <= 15; 
                        next_state <= LOAD1;
                    end if;
                else
                    nextinner_counter <= inner_counter - 1; -- Decrease inner loop counter
                    next_state <= LOAD1;        
                end if;

--If sorting complete, DONE is set to one
            when DONE_STATE =>
                DONE <= '1'; -- Signal completion
                next_state <= IDLE;

            when others =>
                next_state <= IDLE;
        end case;
    end process;

end Behavioral;

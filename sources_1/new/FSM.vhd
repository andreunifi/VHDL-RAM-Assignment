library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FSM is
    Port (
        CLK     : in  STD_LOGIC;
        RESET   : in  STD_LOGIC;
        START   : in  STD_LOGIC;
        ADDR    : out STD_LOGIC_VECTOR(3 downto 0);
        DIN     : out STD_LOGIC_VECTOR(7 downto 0);
        DOUT    : in  STD_LOGIC_VECTOR(7 downto 0);
        WE      : out STD_LOGIC;
        EN      : out STD_LOGIC;
        DATA_OUT: out STD_LOGIC 
    );
end FSM;

architecture Behavioral of FSM is

    --Current states. I choose to split the bubble sort logic into a mixed approach
    --Mostly an inner/outer counter for the external logic, but the single step is composed
    --Of multiple steps
    type State_Type is (IDLE, LOAD1, LOAD2, COMPARE, SWAP1, SWAP2, INCREMENT, DONE_STATE);
    signal current_state, next_state : State_Type;

    -- Internal signals
    signal reg1, reg2 : STD_LOGIC_VECTOR(7 downto 0); -- Temporary registers for comparison
    signal nextreg1,nextreg2: STD_LOGIC_VECTOR(7 downto 0);
    signal swap_flag  : STD_LOGIC;                   -- Flag to indicate swap
    signal inner_counter,next_inner_counter : INTEGER range 0 to 15;    -- Counter for address iteration
    signal direction,next_direction : STD_LOGIC;                    -- 1: Forward (0 to 15), 0: Backward (15 to 0)
    signal twocounter, nextwocounter: INTEGER range 0 to 2 := 0; -- Two-cycle counter for LOAD1 state

begin

    -- Sequential Process: Update state and counters
    process (CLK, RESET)
    begin
        if RESET = '1' then
            current_state <= IDLE;
            inner_counter <= 0;
            direction <= '1';
            reg1 <= (others => '0');
            reg2 <= (others => '0');
            swap_flag <= '0';
            twocounter <= 0; -- Reset twocounter on RESET

        elsif rising_edge(CLK) then
            current_state <= next_state;
            direction <= next_direction;
            inner_counter <= next_inner_counter;
            twocounter <= nextwocounter; -- Update twocounter at each clock cycle
            reg1 <= nextreg1;
            reg2 <= nextreg2;
            
        end if;
    end process;

    -- Combinational Process: Next-state logic and outputs
    process (current_state, START, reg1, reg2, inner_counter, direction,twocounter)
    begin
        -- Default values for outputs
        next_state <= current_state;
        ADDR <= (others => '0');
        DIN <= (others => '0');
        WE <= '0';
        EN <= '0';
        DATA_OUT <= '0';
        next_direction <= direction;
        swap_flag <= '0';
        
        case current_state is
            -- IDLE: Wait for START signal
            when IDLE =>
                if START = '1' then                   
                    next_state <= LOAD1;
                    nextwocounter <= 0;      
                    next_inner_counter <= 0; 
                    next_direction <= '1';
                 else
                    next_state <= IDLE;   
                end if;

            -- LOAD1: Load the current element (wait 2 CC for the Ram, i've done this to 
            --avoid unassigned signals )
            when LOAD1 =>
                EN <= '1';
                ADDR <= std_logic_vector(to_unsigned(inner_counter, 4));
                nextreg1 <= DOUT;
                
                 if twocounter < 2 then
                    next_state <= LOAD1;
                    nextwocounter <= twocounter + 1;  ---- Increment the cycle counter so that it stays
                    --until the ram has completed the cycle for outputting data
                else
                    next_state <= LOAD2;          
                    nextwocounter <= 0;          
                end if;
                
                


            when LOAD2 =>
                EN <= '1';
                if direction = '1' then
                    ADDR <= std_logic_vector(to_unsigned(inner_counter + 1, 4));
                else
                    ADDR <= std_logic_vector(to_unsigned(inner_counter - 1, 4));
                end if;
                
                nextreg2 <= DOUT;
                                               
                if twocounter < 2 then
                    next_state <= LOAD2;
                    nextwocounter <= twocounter + 1;  -- Increment the cycle counter
                else
                    next_state <= COMPARE;          -- After 2 cycles, move to LOAD2
                    nextwocounter <= 0;           -- Reset the cycle counter
                end if;


            -- COMPARE: Compare the two values and decide if a swap is needed
            when COMPARE =>
                if (unsigned(reg1) > unsigned(reg2) and direction = '1') or
                   (unsigned(reg1) < unsigned(reg2) and direction = '0') then
                    swap_flag <= '1';
                    next_state <= SWAP1;
                else
                    next_state <= INCREMENT;
                end if;

--Swap2 switches the N element to the N+1 position, handles RAM signal logic, and then moves to swap_previous

            when SWAP1 =>
                EN <= '1';
                WE <= '1';
                if direction = '1' then
                    ADDR <= std_logic_vector(to_unsigned(inner_counter + 1, 4));
                else
                    ADDR <= std_logic_vector(to_unsigned(inner_counter - 1, 4));
                end if;
                DIN <= reg1;
                next_state <= SWAP2;

 --If reg1<reg2, data[inner_counter -1] <= data[inner_counter]

            when SWAP2 =>
                EN <= '1';
                WE <= '1';
                ADDR <= std_logic_vector(to_unsigned(inner_counter, 4));
                DIN <= reg2;
                next_state <= INCREMENT;

--The logic for handling the loop checks if i am on my last iteration
--(inner_counter = '1' so that it means i've reached the last element, since they are processed in pairs)
            when INCREMENT =>
               
               if direction = '1' then
                  -- Counting upwards until 14
               if inner_counter < 14 then
                next_inner_counter <= inner_counter + 1;
                next_state <= LOAD1;  

                else
                next_direction <= '0';
                next_inner_counter <= 15;
                next_state <= LOAD1;  
                end if;
                
                else
                if inner_counter > 1 then
                next_inner_counter <= inner_counter - 1;
                 next_state <= LOAD1;  

                else

                next_state <= DONE_STATE;
                end if;
                end if;
               
               
               
--If sorting complete, DATA_OUT is set to one

            when DONE_STATE =>
                DATA_OUT <= '1';
                next_state <= IDLE;

            when others =>
                next_state <= IDLE;
        end case;
    end process;

end Behavioral;

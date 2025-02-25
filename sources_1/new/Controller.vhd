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

    -- State encoding
    type State_Type is (IDLE, LOAD1, LOAD2, COMPARE, SWAP_CURRENT, SWAP_PREVIOUS, INCREMENT, DONE_STATE);
    signal current_state, next_state : State_Type;

    -- Internal signals
    signal reg1, reg2 : STD_LOGIC_VECTOR(7 downto 0); -- Temporary registers
    signal swap_flag  : STD_LOGIC;                   -- Flag to indicate swap
    signal inner_counter, nextinner_counter : INTEGER range 0 to 15 := 15; -- Counter for inner loop
    signal outer_counter, nextouter_counter : INTEGER range 0 to 15 := 15; -- Counter for outer loop
    signal twocounter, nextwocounter: INTEGER range 0 to 2 := 0; -- Two-cycle counter for LOAD1 state
begin

    -- State Machine Process
    process (CLK, RESET)
    begin
        if RESET = '1' then
            current_state <= IDLE;
            inner_counter <= 15;
            outer_counter <= 15;
            twocounter <= 0; -- Reset twocounter on RESET
        elsif rising_edge(CLK) then
            current_state <= next_state;
            inner_counter <= nextinner_counter;
            outer_counter <= nextouter_counter;
            twocounter <= nextwocounter; -- Update twocounter at each clock cycle
        end if;
    end process;

    -- Next State Logic and Output Logic
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
            -- IDLE: Wait for START signal
            when IDLE =>
                if START = '1' then
                    next_state <= LOAD1;
                    nextinner_counter <= 15; -- Initial value for inner counter
                    nextouter_counter <= 15; -- Initial value for outer counter
                    nextwocounter <= 0;      -- Reset twocounter when starting
                end if;

            -- LOAD1: Load the current element (stay for 2 clock cycles)
            when LOAD1 =>
                EN <= '1';
                ADDR <= std_logic_vector(to_unsigned(inner_counter, 4));
                reg1 <= DOUT; -- Load current element
                if twocounter < 2 then
                    next_state <= LOAD1;
                    nextwocounter <= twocounter + 1;  -- Increment the cycle counter
                else
                    next_state <= LOAD2;          -- After 2 cycles, move to LOAD2
                    nextwocounter <= 0;           -- Reset the cycle counter
                end if;

            -- LOAD2: Load the previous element
            when LOAD2 =>
                EN <= '1';
                ADDR <= std_logic_vector(to_unsigned(inner_counter - 1, 4));
                reg2 <= DOUT; -- Load previous element
                              
                if twocounter < 2 then
                    next_state <= LOAD2;
                    nextwocounter <= twocounter + 1;  -- Increment the cycle counter
                else
                    next_state <= COMPARE;          -- After 2 cycles, move to LOAD2
                    nextwocounter <= 0;           -- Reset the cycle counter
                end if;
                
                
                
            -- COMPARE: Compare the two loaded elements
            when COMPARE =>
                if reg1 < reg2 then
                    swap_flag <= '1';
                    next_state <= SWAP_CURRENT;
                else
                    next_state <= INCREMENT;
                end if;

            -- SWAP_CURRENT: Write reg2 (smaller) to the higher index
            when SWAP_CURRENT =>
                ADDR <= std_logic_vector(to_unsigned(inner_counter, 4));
                DIN <= reg2;
                WE <= '1'; -- Enable write
                EN <= '1';
                next_state <= SWAP_PREVIOUS;

            -- SWAP_PREVIOUS: Write reg1 (larger) to the lower index
            when SWAP_PREVIOUS =>
                ADDR <= std_logic_vector(to_unsigned(inner_counter - 1, 4));
                DIN <= reg1;
                WE <= '1'; -- Enable write
                EN <= '1';
                next_state <= INCREMENT;

            -- INCREMENT: Move to the next pair or next iteration
            when INCREMENT =>
                if inner_counter = 1 then -- End of inner loop
                    if outer_counter = 0 then -- End of all iterations
                        next_state <= DONE_STATE;
                    else
                        nextouter_counter <= outer_counter - 1; -- Decrease outer loop
                        nextinner_counter <= 15; -- Reset inner loop
                        next_state <= LOAD1;
                    end if;
                else
                    nextinner_counter <= inner_counter - 1; -- Decrease inner loop counter
                    next_state <= LOAD1;
                end if;

            -- DONE_STATE: Sorting is complete
            when DONE_STATE =>
                DONE <= '1'; -- Signal completion
                next_state <= IDLE;

            when others =>
                next_state <= IDLE;
        end case;
    end process;

end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_4to1_valid is
    Port ( SEL : in  STD_LOGIC;     -- select input
           A   : in  STD_LOGIC_VECTOR (1 downto 0);     -- inputs
           X   : out STD_LOGIC);                        -- output
end mux_4to1_valid;

architecture Behavioral of mux_4to1_valid is
signal temp1 : std_logic;
signal temp2 : std_logic; 
begin
temp1 <= A(0);
temp2 <= A(1);
with SEL select
    X <= temp1 when '0',
         temp2 when '1',
         '0'  when others;
end Behavioral;
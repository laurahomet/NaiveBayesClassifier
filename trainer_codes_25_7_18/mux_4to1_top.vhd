library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_4to1_top is
    Port ( SEL : in  STD_LOGIC;     -- select input
           A   : in  STD_LOGIC_VECTOR (63 downto 0);     -- inputs
           X   : out STD_LOGIC_VECTOR (31 downto 0));                        -- output
end mux_4to1_top;

architecture Behavioral of mux_4to1_top is
signal temp1 : std_logic_vector(31 downto 0); 
signal temp2 : std_logic_vector(31 downto 0); 
 

begin
temp1 <= A(31 downto 0);
temp2 <= A(63 downto 32);
 
with SEL select
    X <= temp1 when '0',
         temp2 when '1',
         temp1  when others;
end Behavioral;
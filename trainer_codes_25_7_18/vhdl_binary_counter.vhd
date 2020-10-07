library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity vhdl_binary_counter is
    port(C, CLR : in std_logic;
    Q : out std_logic_vector(15 downto 0));
end vhdl_binary_counter;

architecture bhv of vhdl_binary_counter is
    begin
    process (C, CLR)
        variable tmp: std_logic_vector(15 downto 0);
        begin
            if (CLR='0') then
                tmp := "0000000000000000";
            --elsif (C'event and C='1') then
            elsif (rising_edge(C)) then
                tmp := tmp + 1;
        end if;
        Q <= tmp;
    end process;
end bhv;
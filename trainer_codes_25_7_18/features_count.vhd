----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.07.2018 20:57:35
-- Design Name: 
-- Module Name: features_count - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity features_count is
    port(
            count    : in std_logic;
            rst      : in std_logic;
            count_out: out std_logic_vector (15 downto 0)
         ); 
end features_count;

architecture Behavioral of features_count is
   signal temp: std_logic_vector(15 downto 0);
    begin   
       process(count, rst)
            begin
                if rst = '1' then
                    temp <= "0000000000000001";
                elsif(rising_edge(count)) then
                        if (temp = "1111111111111111") then
                          temp <= "0000000000000001";
                        else
                            temp <= temp + 1;
                        end if;
                    end if;
         end process;
       count_out <= temp;
end Behavioral;

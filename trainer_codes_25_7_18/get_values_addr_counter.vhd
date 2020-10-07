----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.07.2018 12:26:35
-- Design Name: 
-- Module Name: prior_prob - Behavioral
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

entity addr_counter is
    port (
             count          :   in std_logic;
             jump           :   in std_logic;
             clk            :   in std_logic;
             rst            :   in std_logic;
             num_features   :   in std_logic_vector(15 downto 0);
             count_out      :   out std_logic_vector(4 downto 0)
           );          
end addr_counter;


architecture Behavioral of addr_counter is
   signal temp: std_logic_vector(4 downto 0);
    begin   
       process(count, rst)
            begin
                if rst='1' then
                    temp <= "00000";
                elsif(clk'event and clk = '1') then
                    if jump = '1' then
                         temp <= "01000";
                    end if;
                    if(count = '1') then                 
                        if (temp="11111") then
                          temp<="00000";
                        else
                            temp <= temp + num_features;
                        end if;
                    end if;
                end if;
         end process;
       count_out <= temp;
end Behavioral;

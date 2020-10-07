----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.07.2018 20:48:22
-- Design Name: 
-- Module Name: class1_addr_count - Behavioral
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

entity class1_addr_count is
    port(
            count    : in std_logic;
            clk      : in std_logic;
            rst      : in std_logic;
            num_features: in std_logic_vector(15 downto 0);
            count_out: out std_logic_vector (15 downto 0)
         ); 
end class1_addr_count;

architecture Behavioral of class1_addr_count is
   signal temp: std_logic_vector(15 downto 0);
    begin   
       process(clk, count, rst)
            begin
                if rst='1' then
                    temp <= "0000000000000000";
                --elsif clk'event and clk = '1' then
                    elsif(rising_edge (count)) then
                        if (temp="1111111111111111") then
                          temp<="0000000000000000";
                        else
                            temp <= temp + num_features;
                        end if;
                    end if;            
                --end if;
         end process;
       count_out <= temp;
end Behavioral;
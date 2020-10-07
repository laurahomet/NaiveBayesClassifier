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

entity select_class_demux is
    port (
       a: in std_logic_vector(31 downto 0);          
       sel: in std_logic_vector(1 downto 0);
       output_a: out std_logic_vector(31 downto 0);
       output_b: out std_logic_vector(31 downto 0)        
      );
end select_class_demux;

architecture Behavioral of select_class_demux is  
begin
    process(a,sel)
    begin
        if(sel = "00") then
            output_a <= a;
        elsif (sel = "01") then
            output_b <=a;
        end if;
    end process;
    
end Behavioral;

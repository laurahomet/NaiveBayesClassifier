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

entity select_conversion_mux is
    port (
       a: in std_logic_vector(15 downto 0);
       b: in std_logic_vector(15 downto 0);
       c: in std_logic_vector(15 downto 0);
       sel: in std_logic_vector(1 downto 0);
       output: out std_logic_vector(15 downto 0)
      );
end select_conversion_mux;

architecture Behavioral of select_conversion_mux is

    signal temp1 : std_logic_vector(15 downto 0); 
    signal temp2 : std_logic_vector(15 downto 0); 
    signal temp3 : std_logic_vector(15 downto 0); 
     
begin
    temp1 <= a;
    temp2 <= b;
    temp3 <= c;
     
    with sel select
        output <= temp1 when "00",
                  temp2 when "01",
                  temp3 when others;

end Behavioral;

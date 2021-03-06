----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.07.2018 13:24:23
-- Design Name: 
-- Module Name: addr_mux - Behavioral
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

entity addr_mux is
    port (
       a: in std_logic_vector(15 downto 0);
       b: in std_logic_vector(15 downto 0);
       sel: in std_logic;
       output: out std_logic_vector(15 downto 0)
      );
end addr_mux;

architecture Behavioral of addr_mux is

    signal temp1 : std_logic_vector(15 downto 0); 
    signal temp2 : std_logic_vector(15 downto 0); 
     
begin
    temp1 <= a;
    temp2 <= b;
     
    with sel select
        output <= temp1 when '0',
                  temp2 when others;

end Behavioral;


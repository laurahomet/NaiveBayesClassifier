----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.07.2018 11:55:09
-- Design Name: 
-- Module Name: class1_counter_tb - bench
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity class2_counter_tb is
end;

architecture bench of class2_counter_tb is

component class2_counter
     port(
              count    : in std_logic;
              rst      : in std_logic;
              stop     : in std_logic;
              count_out: out std_logic_vector (15 downto 0)
           ); 
end component;

  signal count: std_logic;
  signal rst: std_logic;
  signal stop: std_logic;
  signal count_out: std_logic_vector(0 to 15);
  signal clk: std_logic;

  constant CLK_PERIOD: time := 10 ns;

begin
    
    uut: class2_counter port map ( 
                                           count => count,
                                           rst   => rst,
                                           stop  => stop,
                                           count_out => count_out 
                                   );

  stimulus: process
  begin
  
    rst <= '1';
    count <= '0';
    stop <= '0';
    wait for CLK_PERIOD;
    rst <= '0';
    count <= '0';
    wait for CLK_PERIOD;
    count <= '1';
    wait for CLK_PERIOD;
    count <= '0';   
    wait for CLK_PERIOD;
    count <= '1';   
    wait for CLK_PERIOD;
    count <= '0';
    wait for CLK_PERIOD;
    count <= '1';
    wait for CLK_PERIOD;
    count <= '0';   
    wait for CLK_PERIOD;
    count <= '1';   
    wait for CLK_PERIOD;
    count <= '0';
    wait for CLK_PERIOD;
    count <= '1'; 
    stop <= '1';
    wait;
    -- Put initialisation code here


    -- Put test bench stimulus code here
    

   

end process;
 
 Clk_process :process
                      begin
                           clk <= '0';
                           wait for CLK_PERIOD/2;  --for half of clock period clk stays at '0'.
                           clk <= '1';
                           wait for CLK_PERIOD/2;  --for next half of clock period clk stays at '1'.
                      end process;

end bench;

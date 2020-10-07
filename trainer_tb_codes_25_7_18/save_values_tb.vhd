----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.07.2018 17:58:35
-- Design Name: 
-- Module Name: save_values_tb - bench
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

entity save_values_tb is
end;

architecture bench of save_values_tb is

component save_values
    port (
        rst             :   in std_logic;
        clk             :   in std_logic;
        value_type      :   in std_logic;
        class_type      :   in std_logic;
        last_in         :   in std_logic;
        values_we       :   out std_logic;
        values_addr     :   out std_logic_vector(15 downto 0);
        save_values_done:   out std_logic
       );      
end component;

  signal rst: std_logic;
  signal clk: std_logic;
  signal value_type: std_logic;
  signal class_type: std_logic;
  signal last_in: std_logic;
  signal values_we: std_logic;
  signal values_addr: std_logic_vector(15 downto 0);
  signal save_values_done: std_logic;

  constant CLK_PERIOD: time := 10 ns;
  
  
begin
uut: save_values port map(
                rst => rst,
                clk => clk,
                value_type => value_type,
                class_type => class_type,
                last_in => last_in,
                values_we => values_we,
                values_addr => values_addr,
                save_values_done => save_values_done
           );  
           
           
  stimulus: process
  begin
  
    rst <= '1';
    value_type <= '0'; --class
    class_type <= '0'; --class1
    last_in <= '0';
    wait for CLK_PERIOD;
    rst <= '0';
    
    value_type <= '0'; --class
    wait for CLK_PERIOD; --class label
    
    value_type <= '1'; --feature
    class_type <= '0'; --class1
    wait for CLK_PERIOD; --feature1
    wait for CLK_PERIOD; --feature2
    wait for CLK_PERIOD; --feature3
    
    value_type <= '0'; --class
    wait for CLK_PERIOD; --class label
    
    value_type <= '1'; --feature
    class_type <= '1'; --class2
    wait for CLK_PERIOD; --feature1
    wait for CLK_PERIOD; --feature2
    wait for CLK_PERIOD; --feature3
    
    value_type <= '0'; --class
    wait for CLK_PERIOD; --class label
    
    value_type <= '1'; --feature
    class_type <= '0'; --class1
    wait for CLK_PERIOD; --feature1
    wait for CLK_PERIOD; --feature2
    wait for CLK_PERIOD; --feature3
    
    value_type <= '0'; --class
    wait for CLK_PERIOD; --class label
    
    value_type <= '1'; --feature
    class_type <= '0'; --class1
    wait for CLK_PERIOD; --feature1
    wait for CLK_PERIOD; --feature2
    wait for CLK_PERIOD; --feature3    
     
    value_type <= '0'; --class
    wait for CLK_PERIOD; --class label
    
    value_type <= '1'; --feature
    class_type <= '1'; --class2
    wait for CLK_PERIOD; --feature1
    wait for CLK_PERIOD; --feature2
    last_in <= '1';
    wait for CLK_PERIOD; --feature3   
    wait for 5*CLK_PERIOD;    
    rst <= '1';
    value_type <= '0'; --class
    class_type <= '0'; --class1

    wait;
    -- Put initialisation code here


    -- Put test bench stimulus code here
    

   

end process;
 
 Clk_process :process
                      begin
                           clk <= '1';
                           wait for CLK_PERIOD/2;  --for half of clock period clk stays at '0'.
                           clk <= '0';
                           wait for CLK_PERIOD/2;  --for next half of clock period clk stays at '1'.
                      end process;

end bench;



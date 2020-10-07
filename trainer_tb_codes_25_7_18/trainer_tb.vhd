----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.07.2018 09:37:29
-- Design Name: 
-- Module Name: trainer_tb - bench
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

entity trainer_tb is
end;

architecture bench of trainer_tb is

component trainer
    port (
            rst             :   in std_logic;
            work            :   in std_logic; -- work = not rst ?
            clk             :   in std_logic;
            value_in        :   in std_logic_vector(31 downto 0); --float format
            number_features :   in std_logic_vector(15 downto 0);
            last_in         :   in std_logic;
            prob_class1     :   out std_logic_vector(31 downto 0); --float format
            prob_class2     :   out std_logic_vector(31 downto 0); --float format
            training_done   :   out std_logic
            
          );
end component;

  constant class1: std_logic_vector(31 downto 0) := "00111111100000000000000000000000"; -- +1
  constant class2: std_logic_vector(31 downto 0) := "10111111100000000000000000000000"; -- -1

  signal rst: std_logic;
  signal work: std_logic;
  signal clk: std_logic;
  signal value_in: std_logic_vector(31 downto 0);
  signal number_features: std_logic_vector(15 downto 0);
  signal last_in: std_logic;
  signal prob_class1: std_logic_vector(31 downto 0);
  signal prob_class2: std_logic_vector(31 downto 0);
  signal training_done: std_logic;

  constant CLK_PERIOD: time := 10 ns;

begin

uut: trainer port map(
                rst => rst,
                work => work,
                clk => clk,
                value_in => value_in,
                number_features => number_features,
                last_in => last_in,
                prob_class1 => prob_class1,
                prob_class2 => prob_class2,
                training_done => training_done
           );  


stimulus: process
  begin
  
    rst <= '1';
    work <= '0';
    value_in <= class1;
    number_features <= "0000000000000011"; -- 3
    last_in <= '0';
    
    wait for CLK_PERIOD;
    rst <= '0';
    
    wait for CLK_PERIOD;
    work <= '1';
    
    value_in <= class1; --class1 label
    wait for CLK_PERIOD; -- label
    
    value_in <= "01000001010010000000000000000000"; -- class1, feature1 = 12.5
    wait for CLK_PERIOD; --feature1
    value_in <= "00111111100000000000000000000000"; -- class1, feature2 = 1
    wait for CLK_PERIOD; --feature2
    value_in <= "00111111000110011001100110011010"; -- class1, feature3 = 0.6
    wait for CLK_PERIOD; --feature3
    
    value_in <= class2; --class2 label
    wait for CLK_PERIOD; --label
    
    value_in <= "01000001011100000000000000000000"; -- class2, feature1 = 15
    wait for CLK_PERIOD; --feature1
    value_in <= "01000000110000000000000000000000"; -- class2, feature2 = 6
    wait for CLK_PERIOD; --feature2
    value_in <= "00111111000000000000000000000000"; -- class2, feature3 = 0.5
    wait for CLK_PERIOD; --feature3
    
    value_in <= class1; --class1 label
    wait for CLK_PERIOD; --label
    
    value_in <= "01000001011010000000000000000000"; -- class1, feature1 = 14.5
    wait for CLK_PERIOD; --feature1
    value_in <= "01000000000000000000000000000000"; -- class1, feature2 = 2
    wait for CLK_PERIOD; --feature2
    value_in <= "00111110100110011001100110011010"; -- class1, feature3 = 0.3
    wait for CLK_PERIOD; --feature3
    
    value_in <= class1; --class1 label
    wait for CLK_PERIOD; --label
    
    value_in <= "01000001001010000000000000000000"; -- class1, feature1 = 10.5
    wait for CLK_PERIOD; --feature1
    value_in <= "01000000010000000000000000000000"; -- class1, feature2 = 3
    wait for CLK_PERIOD; --feature2
    value_in <= "00111111000000000000000000000000"; -- class1, feature3 = 0.5
    wait for CLK_PERIOD; --feature3
     
    value_in <= class2; --class2 label
    wait for CLK_PERIOD; --label
    
    value_in <= "01000001001000000000000000000000"; -- class2, feature1 = 10
    wait for CLK_PERIOD; --feature1
    value_in <= "01000000111000000000000000000000"; -- class2, feature2 = 7
    wait for CLK_PERIOD; --feature2
    last_in <= '1';
    value_in <= "00111111001100110011001100110011"; -- class2, feature3 = 0.7
    wait for CLK_PERIOD; --feature3
    
    
    wait for 500*CLK_PERIOD;    
    rst <= '1';

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




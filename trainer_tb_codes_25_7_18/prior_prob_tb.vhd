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

entity prior_prob_tb is
end;

architecture bench of prior_prob_tb is

component prior_prob
    port (
          clk             : in std_logic;
          rst             : in std_logic;
          work            : in std_logic;
          count_class1    : in std_logic_vector(15 downto 0);
          count_class2    : in std_logic_vector(15 downto 0);
          num_vectors     : in std_logic_vector(15 downto 0);
          prior_prob_class1 : out std_logic_vector(31 downto 0); -- float format
          prior_prob_class2 : out std_logic_vector(31 downto 0); -- float_format
          prior_prob_done   : out std_logic
      );
end component;

  signal work: std_logic;
  signal rst: std_logic;
  signal count_class1: std_logic_vector(15 downto 0);
  signal count_class2: std_logic_vector(15 downto 0);
  signal num_vectors: std_logic_vector(15 downto 0);
  signal prior_prob_class1: std_logic_vector(31 downto 0);
  signal prior_prob_class2: std_logic_vector(31 downto 0);
  signal prior_prob_done: std_logic;
  signal clk: std_logic;

  constant CLK_PERIOD: time := 10 ns;

begin
    
    uut: prior_prob port map(
               clk => clk,
               rst => rst,
               work => work,
               count_class1 => count_class1,
               count_class2 => count_class2,
               num_vectors => num_vectors,
               prior_prob_class1 => prior_prob_class1,
               prior_prob_class2 => prior_prob_class2,
               prior_prob_done => prior_prob_done             
           );

  stimulus: process
  begin
  
    rst <= '1';
    work <= '0';
    count_class1 <= "0000000000000101";
    count_class2 <= "0000000000001100";
    num_vectors <= "0000000000010001";
    wait for CLK_PERIOD;
    rst <= '0';
    work <= '0';
    wait for CLK_PERIOD;
    work <= '1';
    wait for CLK_PERIOD*88;
    rst <= '1';
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

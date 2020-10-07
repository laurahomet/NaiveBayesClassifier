----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.07.2018 11:13:27
-- Design Name: 
-- Module Name: get_mean_var_tb - bench
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
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;


entity get_mean_var_tb is
end;

architecture bench of get_mean_var_tb is

component get_mean_var
      port ( 
          clk             :  in std_logic;
          rst             :  in std_logic;
          work            :  in std_logic;
          value           :  in std_logic_vector(31 downto 0);
          mean_in         :  in std_logic_vector(31 downto 0);
          number_features :  in std_logic_vector(15 downto 0);
          number_vectors  :  in std_logic_vector(15 downto 0);
          number_class1   :  in std_logic_vector(15 downto 0);
          number_class2   :  in std_logic_vector(15 downto 0);
          number_class1_float: in std_logic_vector(31 downto 0);
          number_class2_float: in std_logic_vector(31 downto 0);
          values_addr     :  out std_logic_vector(15 downto 0);
          mean_addr       :  out std_logic_vector(15 downto 0);
          mean_out        :  out std_logic_vector(31 downto 0);
          mean_we         :  out std_logic;
          var_addr        :  out std_logic_vector(15 downto 0);
          var_out         :  out std_logic_vector(31 downto 0);
          var_we          :  out std_logic;
          get_mean_var_done: out std_logic    
      );
end component;

  signal rst: std_logic;
  signal work: std_logic;
  signal clk: std_logic;
  signal value: std_logic_vector(31 downto 0);
  signal mean_in: std_logic_vector(31 downto 0);
  signal number_features: std_logic_vector(15 downto 0);
  signal number_vectors: std_logic_vector(15 downto 0);
  signal number_class1: std_logic_vector(15 downto 0);
  signal number_class2: std_logic_vector(15 downto 0);
  signal number_class1_float: std_logic_vector(31 downto 0);
  signal number_class2_float: std_logic_vector(31 downto 0);
  signal values_addr: std_logic_vector(15 downto 0);
  signal mean_addr: std_logic_vector(15 downto 0);
  signal mean_out : std_logic_vector(31 downto 0);
  signal mean_we: std_logic;
  signal var_addr: std_logic_vector(15 downto 0);
  signal var_out : std_logic_vector(31 downto 0);
  signal var_we: std_logic;
  signal count_float : std_logic_vector(31 downto 0);
  signal count: std_logic_vector(15 downto 0);
  signal get_mean_var_done: std_logic;
  
  constant CLK_PERIOD : time := 10 ns;


begin

uut: get_mean_var
    port map(
                clk => clk,
                rst => rst,
                work => work,
                value => value,
                mean_in => mean_in,
                number_features => number_features,
                number_vectors => number_vectors,
                number_class1 => number_class1,
                number_class2 => number_class2,
                number_class1_float => number_class1_float,
                number_class2_float => number_class2_float,
                values_addr => values_addr,
                mean_addr => mean_addr,
                mean_out => mean_out,
                mean_we => mean_we,
                get_mean_var_done => get_mean_var_done  
          );   


Clk_process :process
begin
    clk <= '1';
    wait for CLK_PERIOD/2;  --for half of clock period clk stays at '0'.
    clk <= '0';
    wait for CLK_PERIOD/2;  --for next half of clock period clk stays at '1'.
end process;


stimulus: process
  begin
  rst <= '1';
  work <= '0';
  value <= "01000001010010000000000000000000"; -- 1) 12.5
  mean_in <= "01000001010000000000000000000000"; -- 12.0
  number_features <= "0000000000000011"; -- 3
  number_vectors <= "0000000000000101"; -- 5
  number_class1 <= "0000000000000011"; -- 3
  number_class2 <= "0000000000000010"; -- 2
  number_class1_float <= "01000000010000000000000000000000"; -- 3
  number_class2_float <= "01000000000000000000000000000000"; -- 2
  
  
  wait for CLK_PERIOD;
    -- Put initialisation code here


    -- Put test bench stimulus code here
    rst <= '0';
     wait for CLK_PERIOD;
    work <= '1';
    wait until get_mean_var_done = '1';
    work <= '0';
   
    wait;
  end process;

end bench;


    

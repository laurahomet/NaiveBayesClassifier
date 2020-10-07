----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.07.2018 19:40:18
-- Design Name: 
-- Module Name: mean_tb - bench
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

entity mean_tb is
end;

architecture bench of mean_tb is

component mean is
  Port ( 
         rst : in std_logic;
         work : in std_logic;
         clk : in std_logic;
         --n_feat : in integer;
         value : in std_logic_vector(31 downto 0);
         last : in std_logic;
         mean_out : out std_logic_vector(31 downto 0);
         sum_done : out std_logic;
         count : out std_logic_vector(15 downto 0); --Number of vectors
         count32 : out std_logic_vector(31 downto 0); --Number of vectors
         mean_ready : out std_logic
        );
end component;

  signal work: std_logic;
  signal rst: std_logic;
  signal value: std_logic_vector(31 downto 0);
  signal last: std_logic;
  --signal conv_valid: std_logic;
  --signal number_vectors_float: std_logic_vector(31 downto 0);
  --signal acc_done: std_logic;
  signal sum_done: std_logic;
  signal mean_out: std_logic_vector(31 downto 0);
  signal mean_ready: std_logic;
  signal count : std_logic_vector(15 downto 0); --Number of vectors
  signal count32 : std_logic_vector(31 downto 0); --Number of vectors
  signal clk: std_logic;

  constant CLK_PERIOD: time := 10 ns;



begin

uut: mean port map ( rst        => rst,
                       work       => work,
                       clk        => clk,
                       value      => value,
                       last       => last,
                       mean_out   => mean_out,
                       sum_done       => sum_done,
                       count      => count,
                       count32    => count32,
                       mean_ready => mean_ready);

stimulus: process
  begin
       
      rst <= '1';
      work <= '0';
      last <= '0';
      --conv_valid <= '1';
      --number_vectors_float <= "01000000000000000000000000000000"; --2
      value <= "01000010001000000000000000000000"; --40
      wait for CLK_PERIOD;
      rst <= '0';
      wait for CLK_PERIOD;
      work <= '1';
      wait for CLK_PERIOD;
      work <= '0';
      wait until sum_done = '1';
      work <= '1';
      value <= "01000010010010000000000000000000"; --50
      wait for CLK_PERIOD;
      work <= '0';
      wait until sum_done = '1';
      work <= '1';
      value <= "01000001111100000000000000000000"; --30
      last <= '1';
      wait for CLK_PERIOD;
      work <= '0';   
        
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

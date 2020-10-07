library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity variance_tb is
end;

architecture bench of variance_tb is

  component var
    Port ( 
           rst : in std_logic;
           work : in std_logic;
           clk : in std_logic;
           value : in std_logic_vector(31 downto 0);
           mean : in std_logic_vector(31 downto 0);
           prior : in std_logic_vector(31 downto 0);
           count_float : in std_logic_vector(31 downto 0);
           count : in std_logic_vector(15 downto 0);
           last : in std_logic;
           var : out std_logic_vector(31 downto 0);
           var_sub_done : out std_logic;
           var_ready : out std_logic
          );
  end component;

  signal rst: std_logic;
  signal work: std_logic;
  signal clk: std_logic;
  signal value: std_logic_vector(31 downto 0);
  signal mean: std_logic_vector(31 downto 0);
  signal prior: std_logic_vector(31 downto 0);
  signal count_float : std_logic_vector(31 downto 0);
  signal count: std_logic_vector(15 downto 0);
  signal last: std_logic;
  signal variance: std_logic_vector(31 downto 0);
  signal var_sub_done: std_logic;
  signal var_ready: std_logic ;
  constant CLK_PERIOD : time := 10 ns;

begin

  uut: var port map ( 
                               rst         => rst,
                               work        => work,
                               clk         => clk,
                               value       => value,
                               mean        => mean,
                               prior       => prior,
                               count_float => count_float,
                               count       => count,
                               last        => last,
                               var         => variance,
                               var_sub_done => var_sub_done,
                               var_ready => var_ready 
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
  count_float <= "01000000101000000000000000000000"; -- 5
  value <= "01000001010010000000000000000000"; -- 1) 12.5
  mean <= "01000001010000000000000000000000"; -- 12.0
  prior <= "00111111100000000000000000000000"; -- 1
  count <= "0000000000000101"; -- 5
  last <= '0';
  wait for CLK_PERIOD;
    -- Put initialisation code here


    -- Put test bench stimulus code here
    rst <= '0';
    work <= '1';
    wait for CLK_PERIOD;
    work <= '0';
    wait until var_sub_done = '1';
    value <= "01000001010001001100110011001101"; -- 2) 12.3
    work <= '1';
    wait for CLK_PERIOD;
    work <= '0';
    wait until var_sub_done = '1';
    value <= "01000001010010110011001100110011"; -- 3) 12.7
    work <= '1';
    wait for CLK_PERIOD;
    work <= '0';
    wait until var_sub_done = '1';
    value <= "01000001010000011001100110011010"; -- 4) 12.1
    work <= '1';
    wait for CLK_PERIOD;
    work <= '0';
    wait until var_sub_done = '1';
    value <= "01000001010001001100110011001101"; -- 5) 12.3
    last <= '1';
    work <= '1';
    wait for CLK_PERIOD;
    work <= '0';
    last <= '0';
    wait;
  end process;

                                                -- var = (1/5)*(0.25 + 0,09 + 0,49 + 0,01 + 0,09) = 0,186
                                                
end;
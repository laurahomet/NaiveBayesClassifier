----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.07.2018 14:00:47
-- Design Name: 
-- Module Name: save_values - Behavioral
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

entity save_values is
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
end save_values;


architecture Behavioral of save_values is


-- COMPONENTS ----------------------------------------------------------------------------------------
component class1_addr_counter is
    port (   
            count    : in std_logic;
            clk      : in std_logic;
            rst      : in std_logic;
            count_out: out std_logic_vector (15 downto 0)
          );
end component;

component class2_addr_counter is
    port (   
            count    : in std_logic;
            clk      : in std_logic;
            rst      : in std_logic;
            count_out: out std_logic_vector (15 downto 0)
          );
end component;

component class_type_mux is
    port (
           a: in std_logic_vector(15 downto 0);
           b: in std_logic_vector(15 downto 0);
           sel: in std_logic;
           output: out std_logic_vector(15 downto 0)
      );
end component;



-- SIGNALS ----------------------------------------------------------------------------------------

signal count_addr_class1: std_logic;
signal count_addr_class2: std_logic;
signal count_addr_class1_out: std_logic_vector(15 downto 0);
signal count_addr_class2_out: std_logic_vector(15 downto 0);
signal rst_addr_counters: std_logic;
signal rst_count_addr: std_logic;
signal save_done: std_logic;


begin

rst_addr_counters <= rst_count_addr or rst;
values_we <= value_type and (not save_done); -- write enable whenever value_in is a feature
save_values_done <= save_done;

-- PROCESSES ----------------------------------------------------------------------------------------

addr_counters_control: process (value_type, class_type)
begin
        if(value_type = '1') then
            if (class_type = '0') then      
                count_addr_class1 <= '1';
                count_addr_class2 <= '0';
            else
                count_addr_class1 <= '0';
                count_addr_class2 <= '1';
            end if; 
        else
            count_addr_class1 <= '0';
            count_addr_class2 <= '0';
        end if;
end process;
     
last_value_in: process(clk,last_in)
variable temp: std_logic := '0';
begin
    if (rst = '1') then
        temp := '0';
        save_done <= '0';
    elsif (clk'event and clk = '1') then
          if(temp = '0') then
                rst_count_addr <= '0';
                save_done <= '0';
                if (last_in = '1') then
                    temp := '1';
                else
                    temp := '0';
                end if;
          else --temp = '1';
                rst_count_addr <= '1';
                save_done <= '1';
          end if;
    end if;
end process;
     
     
     
-- PORT MAPS ----------------------------------------------------------------------------------------
class1_addr_count: class1_addr_counter
    port map(             
                count => count_addr_class1,
                clk => clk,
                rst => rst_addr_counters,
                count_out => count_addr_class1_out
              );  
              
class2_addr_count: class2_addr_counter
      port map(             
                  count => count_addr_class2,
                  clk => clk,
                  rst => rst_addr_counters,
                  count_out => count_addr_class2_out
                );   
                            
class_type_muxx: class_type_mux
    port map (
                    a => count_addr_class1_out,
                    b => count_addr_class2_out,
                    sel => class_type,
                    output => values_addr
                );


end Behavioral;

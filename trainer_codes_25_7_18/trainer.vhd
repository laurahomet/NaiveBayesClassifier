----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.07.2018 15:40:34
-- Design Name: 
-- Module Name: trainer - Behavioral
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

entity trainer is
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
end trainer;

architecture Behavioral of trainer is



-- COMPONENTS ----------------------------------------------------------------------------------------
component class1_counter is
    port (   
            count    : in std_logic;
            rst      : in std_logic;
            stop     : in std_logic;
            count_out: out std_logic_vector (15 downto 0)
          );
end component;

component class2_counter is
    port (   
            count    : in std_logic;
            rst      : in std_logic;
            stop     : in std_logic;
            count_out: out std_logic_vector (15 downto 0)
          );
end component;

component features_counter is
    port (
             count    : in std_logic;
             rst      : in std_logic;
             clk      : in std_logic;
             count_out: out std_logic_vector (15 downto 0)
          );
end component;

component prior_prob is
    port (
              clk             : in std_logic;
              rst             : in std_logic;
              work            : in std_logic;
              count_class1    : in std_logic_vector(15 downto 0);
              count_class2    : in std_logic_vector(15 downto 0);
              num_vectors     : in std_logic_vector(15 downto 0);
              number_class1_float: out std_logic_vector(31 downto 0);
              number_class2_float: out std_logic_vector(31 downto 0);
              prior_prob_class1 : out std_logic_vector(31 downto 0); -- float format
              prior_prob_class2 : out std_logic_vector(31 downto 0); -- float_format
              prior_prob_done   : out std_logic
          );
end component;

component save_values is
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

component values_mux is
    port (
            a: in std_logic_vector(15 downto 0);
            b: in std_logic_vector(15 downto 0);
            sel: in std_logic;
            output: out std_logic_vector(15 downto 0)
          );
end component;

COMPONENT blk_mem_gen_0
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(15 downto 0);
    dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;

component get_mean_var is
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

COMPONENT blk_mem_gen_1
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(15 downto 0);
    dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;

COMPONENT blk_mem_gen_2
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(15 downto 0);
    dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;




-- CONSTANTS ----------------------------------------------------------------------------------------
constant class1: std_logic_vector(31 downto 0) := "00111111100000000000000000000000"; -- +1
constant class2: std_logic_vector(31 downto 0) := "10111111100000000000000000000000"; -- -1



-- SIGNALS ----------------------------------------------------------------------------------------

-- Classes count
signal count_class1: std_logic := '0';
signal count_class2: std_logic := '0';
signal count_class1_out: std_logic_vector(15 downto 0);
signal count_class2_out: std_logic_vector(15 downto 0);
signal first_value_in: std_logic;
signal value_type: std_logic := '0';
signal class_type: std_logic := '0';

-- Features count
signal count_features: std_logic := '0';
signal count_features_out: std_logic_vector(15 downto 0);
signal rst_features_count: std_logic := '0';
signal rst_count_features: std_logic := '0';

-- Prior probs calculation
signal prior_prob_work: std_logic;
signal prior_prob_class1_out: std_logic_vector(31 downto 0);
signal prior_prob_class2_out: std_logic_vector(31 downto 0);
signal prior_prob_done: std_logic;
signal number_vectors: std_logic_vector(15 downto 0);
signal number_class1_float: std_logic_vector(31 downto 0);
signal number_class2_float: std_logic_vector(31 downto 0);

-- Mux control
signal read_values: std_logic := '0';

-- Addresses signals
signal save_values_addr: std_logic_vector(15 downto 0);
signal get_mean_addr: std_logic_vector(15 downto 0);
signal save_mean_addr: std_logic_vector(15 downto 0);

-- Values RAM control
signal values_wea: std_logic_vector(0 downto 0);
signal values_addr: std_logic_vector(15 downto 0);
signal values_ram_out: std_logic_vector(31 downto 0);
signal save_values_done: std_logic;

-- Mean RAM control
signal mean_wea: std_logic_vector(0 downto 0);
signal mean_data: std_logic_vector(31 downto 0);
signal mean_ram_out: std_logic_vector(31 downto 0);

-- Variance RAM control
signal var_wea: std_logic_vector(0 downto 0);
signal var_addr: std_logic_vector(15 downto 0);
signal var_data: std_logic_vector(31 downto 0);
signal var_ram_out: std_logic_vector(31 downto 0);

signal mean_var_work: std_logic;
signal get_mean_var_done: std_logic;

signal values_clk: std_logic;

begin

rst_features_count <= rst_count_features or rst;
number_vectors <= count_class1_out + count_class2_out;
count_features <= value_type;
training_done <= prior_prob_done and get_mean_var_done;
values_clk <= not clk;


-- PROCESSES ----------------------------------------------------------------------------------------

value_type_control: process (rst, work, clk, count_features_out, number_features)
begin
    if (rst = '1') then
        value_type <= '0'; -- value_in is a class
        first_value_in <= '1';
    elsif(work = '1') then
        if (clk'event and clk = '1') then
            if(first_value_in = '1')then
                    value_type <= '0'; -- class label
                    first_value_in <= '0';
            elsif(count_features_out < (number_features-1)) then
                value_type <= '1'; -- value_in is a feature
                rst_count_features <= '0';
            else
                value_type <= '0';
                rst_count_features <= '1';
            end if;
        end if;
     end if;
end process;

count_class_control: process (work, clk, value_in)
begin
    if(work = '1') then
            if(value_type = '0') then
                if (value_in = class1) then
                    count_class1 <= '1';
                    count_class2 <= '0';
                    class_type <= '0'; -- class1
                elsif (value_in = class2) then
                    count_class1 <= '0';
                    count_class2 <= '1';
                    class_type <= '1'; -- class2
                end if;
            else -- if(value_type = '1') then
                    count_class1 <= '0';
                    count_class2 <= '0';
            end if; 
    end if;
end process;

read_values_control: process(rst, work, clk, save_values_done)
begin
    if (rst = '1') then
        read_values <= '0'; -- saving values at values_ram
    elsif(work = '1') then
        if (clk'event and clk = '1') then
            if(save_values_done = '1') then
                read_values <= '1'; -- reading values from values_ram
            else
                read_values <= '0';
            end if;
        end if;
    end if;
end process;


work_control: process(rst,save_values_done, prior_prob_done, get_mean_var_done)
begin
    if(rst = '1') then
        mean_var_work <= '0';
        prior_prob_work <= '0';
        
    else
        if (save_values_done = '1') then
            mean_var_work <= '0';
            prior_prob_work <= '1';
        end if;   
        
        if (prior_prob_done = '1') then -- CHECK
            mean_var_work <= '1';
        end if;       
        
        if (get_mean_var_done = '1') then -- CHECK
            mean_var_work <= '0';
        end if;     
          
    end if;         
end process;


prior_prob_control: process(rst,prior_prob_done)
begin
    if(rst='1')then
        prob_class1 <= "00000000000000000000000000000000";
        prob_class2 <= "00000000000000000000000000000000";
    elsif(prior_prob_done = '1') then 
        prob_class1 <= prior_prob_class1_out;
        prob_class2 <= prior_prob_class2_out;
    end if;
end process;




-- PORT MAPS ----------------------------------------------------------------------------------------
class1_count: class1_counter
    port map(
                count => count_class1,
                rst => rst,
                stop => last_in,
                count_out => count_class1_out
               );
                                 
class2_count: class2_counter
   port map(
               count => count_class2,
               rst => rst,
               stop => last_in,
               count_out => count_class2_out
             );

features_count: features_counter
        port map(
                    count => count_features,
                    rst => rst_features_count,
                    clk => clk,
                    count_out => count_features_out
                );
           
prior_probs: prior_prob
     port map(
               clk => clk,
               rst => rst,
               work => prior_prob_work,
               count_class1 => count_class1_out,
               count_class2 => count_class2_out,
               number_class1_float => number_class1_float,
               number_class2_float => number_class2_float,
               num_vectors => number_vectors,
               prior_prob_class1 => prior_prob_class1_out,
               prior_prob_class2 => prior_prob_class2_out,
               prior_prob_done => prior_prob_done             
           );

save_val: save_values
    port map(
                rst => rst,
                clk => clk,
                value_type => value_type,
                class_type => class_type,
                last_in => last_in,
                values_we => values_wea(0),
                values_addr => save_values_addr,
                save_values_done => save_values_done
           );      
           
val_mux: values_mux
    port map(
                a => save_values_addr,
                b => get_mean_addr,
                sel => read_values,
                output => values_addr
          );

values_ram: blk_mem_gen_0
  PORT MAP (
                clka => values_clk,
                ena => '1',
                wea => values_wea, --values_we
                addra => values_addr,
                dina => value_in,
                douta => values_ram_out
            );
            
get_mean_and_variance: get_mean_var
    port map(
                clk => clk,
                rst => rst,
                work => mean_var_work,
                value => values_ram_out,
                mean_in => mean_ram_out,
                number_features => number_features,
                number_vectors => number_vectors,
                number_class1 => count_class1_out,
                number_class2 => count_class2_out,
                number_class1_float => number_class1_float,
                number_class2_float => number_class2_float,
                --number_vectors_float => number_vectors_float,
                values_addr => get_mean_addr,
                mean_addr => save_mean_addr,
                mean_out => mean_data,
                mean_we => mean_wea(0),
                var_out => var_data,
                var_addr => var_addr,
                var_we => var_wea(0),
                get_mean_var_done => get_mean_var_done  
          );       
           

mean_ram: blk_mem_gen_1
  PORT MAP (
                clka => clk,
                ena => '1',
                wea => mean_wea,
                addra => save_mean_addr,
                dina => mean_data,
                douta => mean_ram_out
              );


var_ram: blk_mem_gen_2
  PORT MAP (
                clka => clk,
                ena => '1',
                wea => var_wea,
                addra => var_addr,
                dina => var_data,
                douta => var_ram_out
              );
    
        
             
end Behavioral;

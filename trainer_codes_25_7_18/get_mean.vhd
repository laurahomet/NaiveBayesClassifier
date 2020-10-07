----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.07.2018 14:01:04
-- Design Name: 
-- Module Name: get_mean - Behavioral
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

entity get_mean_var is
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
end get_mean_var;

architecture Behavioral of get_mean_var is

-- COMPONENTS ----------------------------------------------------------------------------------------

component class1_addr_count is
    port (   
            count    : in std_logic;
            clk      : in std_logic;
            rst      : in std_logic;
            num_features: in std_logic_vector(15 downto 0);
            count_out: out std_logic_vector (15 downto 0)
          );
end component;

component class2_addr_count is
    port (   
            count    : in std_logic;
            clk      : in std_logic;
            rst      : in std_logic;
            num_features: in std_logic_vector(15 downto 0);
            count_out: out std_logic_vector (15 downto 0)
          );
end component;

component vectors_counter is
    port (
             count    : in std_logic;
             rst      : in std_logic;
             clk      : in std_logic;
             count_out: out std_logic_vector (15 downto 0)
          );
end component;

component features_count is
    port (
             count    : in std_logic;
             rst      : in std_logic;
             count_out: out std_logic_vector (15 downto 0)
          );
end component;

component mean is
   Port ( 
             rst : in std_logic;
             work : in std_logic;
             clk : in std_logic;
             value : in std_logic_vector(31 downto 0);
             last : in std_logic;
             mean_out : out std_logic_vector(31 downto 0);
             sum_done : out std_logic;
             count : out std_logic_vector(15 downto 0); --Number of vectors
             count32 : out std_logic_vector(31 downto 0); --Number of vectors
             mean_ready : out std_logic
            );
end component;

component mean_addr_counter is
    port(
            count    : in std_logic;
            rst      : in std_logic;
            done     : in std_logic;
            count_out: out std_logic_vector (15 downto 0)
         ); 
end component;

component addr_mux is
    port(
            a       : in std_logic_vector (15 downto 0);
            b       : in std_logic_vector (15 downto 0);
            sel     : in std_logic;
            output  : out std_logic_vector (15 downto 0)
         ); 
end component;

component var_count_mux is
    port(
            a       : in std_logic_vector (15 downto 0);
            b       : in std_logic_vector (15 downto 0);
            sel     : in std_logic;
            output  : out std_logic_vector (15 downto 0)
         ); 
end component;

component var_count_float_mux is
    port(
            a       : in std_logic_vector (31 downto 0);
            b       : in std_logic_vector (31 downto 0);
            sel     : in std_logic;
            output  : out std_logic_vector (31 downto 0)
         ); 
end component;

component var_addr_counter is
    port(
            count    : in std_logic;
            rst      : in std_logic;
            count_out: out std_logic_vector (15 downto 0)
         ); 
end component;

component var is
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
             var_sub_done: out std_logic;
             var : out std_logic_vector(31 downto 0);
             var_ready : out std_logic
        );
end component;




-- SIGNALS ----------------------------------------------------------------------------------------

-- Counters
signal count_vectors: std_logic;
signal count_vectors_out: std_logic_vector(15 downto 0);
signal rst_count_vectors: std_logic := '0';
signal rst_vectors_counter: std_logic := '0';

signal count_features: std_logic;
signal count_features_out: std_logic_vector(15 downto 0);
signal rst_count_features: std_logic := '0';
signal rst_features_count: std_logic := '0';

signal count_addr_class1: std_logic;
signal count_addr_class1_out: std_logic_vector(15 downto 0);
signal rst_count_addr_class1: std_logic;
signal count_addr_class2: std_logic;
signal count_addr_class2_out: std_logic_vector(15 downto 0);
signal rst_count_addr_class2: std_logic := '0';

signal count_addr_mean: std_logic;
signal count_addr_mean_out: std_logic_vector(15 downto 0);
signal rst_count_addr_mean: std_logic := '0';

signal count_addr_var: std_logic;
signal count_addr_var_out: std_logic_vector(15 downto 0);
signal rst_count_addr_var: std_logic := '0';

signal rst_counters: std_logic := '0';

-- Mean
signal new_value_mean: std_logic;
signal mean_ready: std_logic;
signal mean_sum_done: std_logic;
signal mean_n_vectors: std_logic_vector(15 downto 0);
signal mean_n_vectors_float: std_logic_vector(31 downto 0);
signal get_mean_done: std_logic := '0';
signal get_mean_done_soon: std_logic := '0';
signal rst_mean: std_logic;
signal first_mean_value: std_logic:= '1';
signal mean_again: std_logic := '0';

-- Number vectors
signal num_vec_float: std_logic_vector(31 downto 0);
signal num_vec: std_logic_vector(15 downto 0);

-- Var
signal new_value_var: std_logic;
signal var_sub_valid: std_logic;
signal var_ready: std_logic;
signal get_var_done: std_logic := '0';
signal get_var_done_soon: std_logic := '0';
signal first_var_value: std_logic:= '1';
signal var_again: std_logic := '0';
signal rst_var: std_logic;

-- Others
signal jump_to_class2: std_logic := '0';
signal last_in: std_logic;
signal last_calc: std_logic;
signal last_vector: std_logic := '0';
signal wait_2clk: std_logic := '1';
signal temp_addr: std_logic_vector(15 downto 0);


begin                 

rst_features_count <= rst_count_features or rst_counters or rst ;
rst_count_vectors <= ((not get_mean_done) and rst_mean) or ((not get_var_done) and rst_var) or rst_counters or rst ;
rst_count_addr_class1 <= rst_count_vectors;
rst_count_addr_class2 <= rst_count_addr_class1;
rst_count_addr_mean <= rst_counters or rst;
rst_count_addr_var <= rst_counters or rst;

new_value_mean <= work and (not rst_mean) and (not last_vector) and (mean_again or first_mean_value) and (not get_mean_done); 
new_value_var <= get_mean_done and (not wait_2clk) and (not rst_var) and (not last_vector) and (var_again or first_var_value) and (not get_var_done);

count_vectors <= mean_sum_done or var_sub_valid;
count_addr_class1 <= work and (mean_sum_done or var_sub_valid) and (not jump_to_class2);
count_addr_class2 <= work and (mean_sum_done or var_sub_valid) and (jump_to_class2);

mean_we <= mean_ready;
var_we <= var_ready;

values_addr <= temp_addr + (count_features_out - 1);
mean_addr <= count_addr_mean_out;
var_addr <= count_addr_var_out;

get_mean_var_done <= get_mean_done and get_var_done;
  
  
  
  
-- PROCESSES ----------------------------------------------------------------------------------------  

mean_rst_control: process(clk, rst, mean_ready)
variable temp: std_logic := '0';
begin
    if(rst = '1')then
        rst_mean <= '1';
    elsif (clk'event and clk='1')then
        if(mean_ready = '1')then
            if(temp = '0')then
                temp := '1';
            else
                rst_mean <= '1';
            end if;
        else
            rst_mean <= '0';
            temp := '0';
        end if;
    end if;
end process;

var_rst_control: process(clk, rst, var_ready)
variable temp: std_logic := '0';
begin
    if(rst = '1')then
        rst_var <= '1';
    elsif (clk'event and clk='1')then
        if(var_ready = '1')then
            if(temp = '0')then
                temp := '1';
            else
                rst_var <= '1';
            end if;
        else
            rst_var <= '0';
            temp := '0';
        end if;
    end if;
end process;

wait_var_control: process(rst, clk, get_mean_done)
variable temp: std_logic := '0';
begin
    if(rst='1')then
        temp := '0';
        wait_2clk <= '1';
    elsif(clk'event and clk='1')then
       if(get_mean_done = '1')then
            if(temp = '0')then
                temp := '1';
            else
                wait_2clk <= '0';
            end if;
        else
            wait_2clk <= '1';
        end if;
    end if;
end process;

last_vector_control: process(jump_to_class2, mean_ready, var_ready, count_vectors_out, number_class1, number_class2)
begin
    if(mean_ready = '1' or var_ready = '1')then
        last_vector <= '0';
    elsif( (jump_to_class2 = '0') and (count_vectors_out < (number_class1)) )then
        last_vector <= '0';
    elsif( (jump_to_class2 = '1') and (count_vectors_out < (number_class2)) )then
        last_vector <= '0';
    else
        last_vector <= '1';
   end if;
end process;

first_mean_value_control: process(rst, work,clk, mean_sum_done,rst_mean)
begin
    if (rst = '1') then
        first_mean_value <= '1';
        mean_again <= '0';
    elsif (work = '1') then
        if(falling_edge(rst_mean))then
            first_mean_value <= '1';
        elsif(clk'event and clk = '1')then
            if(mean_sum_done = '1') then            
                mean_again <= '1';
            else
                mean_again <= '0';
                first_mean_value <= '0';
            end if;
        end if;
    end if;
end process;

first_var_value_control: process(rst, wait_2clk,clk, rst_var, var_sub_valid)
variable temp: std_logic:= '0';
begin
    if (rst = '1') then
        first_var_value <= '1';
        var_again <= '0';
        temp := '0';
    elsif (wait_2clk = '0') then
        if(falling_edge(rst_var))then
            first_var_value <= '1';
        elsif(clk'event and clk = '1')then
            if(var_sub_valid = '1')then
                var_again <= '1';
            else
              var_again <= '0';
              first_var_value <= '0';
           end if;
        end if;
    end if;
end process;


rst_and_last_control: process(rst,count_vectors_out, number_class1, number_class2,count_features_out,number_features, get_mean_done,get_var_done)
variable temp: std_logic := '0';
variable temp2: std_logic := '0';

begin
        if(rst='1')then
            jump_to_class2 <= '0';
            last_calc <= '0';
            last_in <= '0';
            temp := '0';
            temp2 := '0';
            
        else
               if(get_mean_done = '1')then
                    if(temp = '0')then
                        temp := '1';
                    elsif(temp2 = '0')then
                        last_calc <= '0';
                        jump_to_class2 <= '0';
                        rst_count_features <= '0';
                        temp2 := '1';
                    end if;
               end if;
                
        if(jump_to_class2 = '0') then  -- class1 
                if(count_vectors_out >= number_class1) then -- no more vectors class1
                        if(mean_ready = '1' or var_ready = '1')then
                            last_in <= '0';
                        
                                if(count_features_out > number_features) then -- no more features
                                    rst_count_features <= '1';
                                    jump_to_class2 <= '1';                   
                                else -- more features
                                    rst_count_features <= '0';
                                end if;
                        else
                            rst_count_features <= '0';
                        end if;
                elsif(count_vectors_out = (number_class1 - 1)) then -- last vector class1
                    last_in <= '1';
                    rst_count_features <= '0';
                      
                else -- more vectors class1
                    last_in <= '0';
                    rst_count_features <= '0';
                end if;  
                 
            else -- class2            
    
                if(count_vectors_out >= number_class2) then -- no more vectors class2 
                        if(mean_ready = '1' or var_ready = '1')then
                            last_in <= '0';
                                
                                if(count_features_out > number_features) then -- no more features
                                    rst_count_features <= '1';
                                    last_calc <= '1';
                                    jump_to_class2 <= '0';             
                                else -- more features
                                    rst_count_features <= '0';
                                    last_calc <= '0';
                               end if;
                       else
                           rst_count_features <= '0';
                       end if;
                elsif(count_vectors_out = (number_class2 - 1))then
                    last_in <= '1';
                    rst_count_features <= '0';
                    
                else -- more vectors class2
                    last_in <= '0';
                    rst_count_features <= '0';
                end if;  
                
            end if; --jump
      end if;
end process;

features_count_control: process(rst, get_mean_done, mean_ready, var_ready, last_calc)
begin
    if(rst='1')then
        get_mean_done_soon <= '0';
        get_var_done_soon <= '0';
        
    else
        if(get_mean_done = '0') then
            if(mean_ready = '1') then
                if(last_calc = '1') then
                    get_mean_done_soon <= '1';
                    
                else
                    count_features <= '1';
                    
                end if;
            else
                 count_features <= '0';   
            end if;
        else -- get_mean_done = '1'
            get_mean_done_soon <= '0';
            if(var_ready = '1') then
                if(last_calc = '1') then 
                    get_var_done_soon <= '1';
                    
                else
                    count_features <= '1';
                    
                end if;
            else
                count_features <= '0';
            end if;   
        end if;
    end if;
end process;

rst_counters_control: process(rst, get_mean_done_soon, get_var_done_soon, mean_ready, var_ready)
begin
     if(rst='1')then
       get_mean_done <= '0';
       get_var_done <= '0';
       rst_counters <= '1';
       
    elsif(get_mean_done_soon = '1')then
        if( falling_edge(mean_ready))then
            get_mean_done <= '1';
            rst_counters <= '1';
        end if;
        
    elsif(get_var_done_soon = '1')then
        if( falling_edge(var_ready))then
            get_var_done <= '1';
            rst_counters <= '1';
        end if;
        
    else
         rst_counters <= '0';
    end if;
end process;
    

mean_addr_control: process(mean_ready, var_ready)
begin
    if(mean_ready = '1' or var_ready = '1')then
        count_addr_mean <= '1'; 
    else
        count_addr_mean <= '0';
    end if;
end process;

var_addr_control: process(var_ready)
begin
    if(var_ready = '1')then
        count_addr_var <= '1'; 
    else
        count_addr_var <= '0';
    end if;
end process;


      
      

-- PORT MAPS ----------------------------------------------------------------------------------------       

class1_addr_counter: class1_addr_count
  port map(             
              count => count_addr_class1,
              clk => clk,
              rst => rst_count_addr_class1,
              num_features => number_features,
              count_out => count_addr_class1_out
            );  
                            
class2_addr_counter: class2_addr_count
    port map(             
                count => count_addr_class2,
                clk => clk,
                rst => rst_count_addr_class2,
                num_features => number_features,
                count_out => count_addr_class2_out
              );   
   
vectors_count: vectors_counter
    port map (
                count => count_vectors,
                rst => rst_count_vectors,
                clk => clk,
                count_out => count_vectors_out
              );
              
features_counter: features_count
      port map(
                  count => count_features,
                  rst => rst_features_count,
                  count_out => count_features_out
              );
              
meann: mean          
      Port map ( 
               rst => rst_mean,
               work => new_value_mean,
               clk => clk,
               value => value,
               last => last_in,
               mean_out => mean_out,
               sum_done => mean_sum_done,
               count => mean_n_vectors,
               count32 => mean_n_vectors_float,
               mean_ready => mean_ready
          );
 
mean_addr_count: mean_addr_counter
    port map(
                count => count_addr_mean,
                rst => rst_count_addr_mean,
                done => get_mean_done,
                count_out => count_addr_mean_out
            );
 
addres_mux: addr_mux
    port map(
                a => count_addr_class1_out,
                b => count_addr_class2_out,
                sel => jump_to_class2,
                output => temp_addr
            );

var_addr_count: var_addr_counter
    port map(
                count => count_addr_var,
                rst => rst_count_addr_var,
                count_out => count_addr_var_out
            );

variance_count_mux: var_count_mux
    port map(
                a => number_class1,
                b => number_class2,
                sel => jump_to_class2,
                output => num_vec
            );

variance_count_float_mux: var_count_float_mux
    port map(
                a => number_class1_float,
                b => number_class2_float,
                sel => jump_to_class2,
                output => num_vec_float
            );
           
variance: var
    port map
            (
                rst => rst_var,
                work => new_value_var,
                clk => clk,
                value => value,
                mean => mean_in,
                prior => "00111111100000000000000000000000",
                count_float => num_vec_float,
                count => num_vec,
                last => last_in,
                var_sub_done => var_sub_valid,
                var => var_out,
                var_ready => var_ready
            );
  

end Behavioral;

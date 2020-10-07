----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.07.2018 12:26:35
-- Design Name: 
-- Module Name: prior_prob - Behavioral
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
use IEEE.NUMERIC_STD.UNSIGNED;
use IEEE.NUMERIC_STD.SIGNED;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;


entity prior_prob is
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
end prior_prob;



architecture Behavioral of prior_prob is

component select_conversion_mux is
    port (
           a: in std_logic_vector(15 downto 0);
           b: in std_logic_vector(15 downto 0);
           c: in std_logic_vector(15 downto 0);
           sel: in std_logic_vector(1 downto 0);
           output: out std_logic_vector(15 downto 0)
          );
end component;

COMPONENT floating_point_0
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tready : OUT STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;

component select_conversion_demux is
    port (
           a: in std_logic_vector(31 downto 0);          
           sel: in std_logic_vector(1 downto 0);
           output_a: out std_logic_vector(31 downto 0);
           output_b: out std_logic_vector(31 downto 0);
           output_c: out std_logic_vector(31 downto 0)        
          );
end component;

component select_class_mux is
    port (
           a: in std_logic_vector(31 downto 0);
           b: in std_logic_vector(31 downto 0);
           sel: in std_logic_vector(1 downto 0);
           output: out std_logic_vector(31 downto 0)
          );
end component;

COMPONENT divide
  PORT (
            aclk : IN STD_LOGIC;
            s_axis_a_tvalid : IN STD_LOGIC;
            s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            s_axis_b_tvalid : IN STD_LOGIC;
            s_axis_b_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            m_axis_result_tvalid : OUT STD_LOGIC;
            m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
          );
END COMPONENT;

component select_class_demux is
    port (
           a: in std_logic_vector(31 downto 0);          
           sel: in std_logic_vector(1 downto 0);
           output_a: out std_logic_vector(31 downto 0);
           output_b: out std_logic_vector(31 downto 0)        
          );
end component;


signal reset: std_logic;

signal conv_work: std_logic;
signal convert_again: std_logic := '0';
signal conversion_select: std_logic_vector(1 downto 0);
signal getting_first_conv: std_logic;
signal int16_ready: std_logic;
signal int_to_float_done: std_logic;
signal data_to_convert: std_logic_vector(15 downto 0);
signal conversion_done: std_logic;
signal converted_data: std_logic_vector(31 downto 0);
signal num_vectors_float: std_logic_vector(31 downto 0);
signal count_class1_float: std_logic_vector(31 downto 0);
signal count_class2_float: std_logic_vector(31 downto 0);

signal class_select: std_logic_vector(1 downto 0);
signal division_work: std_logic;
signal divide_again: std_logic := '0';
signal getting_first_div: std_logic;
signal div_done: std_logic;
signal dividend: std_logic_vector(31 downto 0);
signal division_out: std_logic_vector(31 downto 0);

signal prior_probs_done: std_logic;
signal prior_prob_class1_temp: std_logic_vector(31 downto 0);
signal prior_prob_class2_temp: std_logic_vector(31 downto 0);


begin

    reset <= rst or (not work);
    conv_work <= work and (not int_to_float_done) and (convert_again or getting_first_conv);
    division_work <= work and int_to_float_done and (not prior_probs_done) and (divide_again or getting_first_div);
    prior_prob_done <=  prior_probs_done;    
    
    number_class1_float <= count_class1_float;
    number_class2_float <= count_class2_float;


conversion_selection: process(rst, work, clk, conversion_done, conversion_select)
    variable temp: std_logic_vector(1 downto 0);
begin
    if (reset = '1') then
        temp := "00";
        int_to_float_done <= '0';
        getting_first_conv <= '1';
    elsif (work = '1') then
        if(clk'event and clk = '1')then
            if(conversion_done = '1') then
            convert_again <= '1';
                    if(conversion_select = "10") then
                       int_to_float_done <= '1';
                    else
                        temp := temp + 1;
                        int_to_float_done <= '0';
                    end if;
            else
                convert_again <= '0';
                getting_first_conv <= '0';
            end if;  
        end if;  
    end if;  
    conversion_select <= temp;
end process;


class_selection: process(rst, work, clk, div_done)
    variable temp: std_logic_vector(1 downto 0);
begin
    if (reset = '1') then
        temp := "00";
        prior_probs_done <= '0';
        getting_first_div <= '1';
    elsif (work = '1' and int_to_float_done = '1') then
        if(clk'event and clk = '1')then
            if(div_done = '1') then
            divide_again <= '1';
                    if(class_select = "01") then
                        prior_probs_done <= '1';
                    else
                        temp := temp + 1;
                        prior_probs_done <= '0';
                    end if;
            else
                getting_first_div <= '0';
                divide_again <= '0';
            end if;
        end if;
     end if;
     class_select <= temp;
end process;

final_result_control: process(reset, work, prior_probs_done)
begin
    if(reset = '1')then
        prior_prob_class1 <= "00000000000000000000000000000000";
        prior_prob_class2 <= "00000000000000000000000000000000";
    elsif(work = '1' and prior_probs_done = '1') then
        prior_prob_class1 <= prior_prob_class1_temp;
        prior_prob_class2 <= prior_prob_class2_temp;
    end if;
end process;
  
sel_conv_mux: select_conversion_mux
    port map (  
                a => num_vectors,
                b => count_class1,
                c => count_class2,
                sel => conversion_select,
                output => data_to_convert
              );
   
      
int16_to_float32: floating_point_0
     PORT MAP (
                 aclk => clk,
                 s_axis_a_tvalid => conv_work,
                 s_axis_a_tready => int16_ready,
                 s_axis_a_tdata => data_to_convert,
                 m_axis_result_tvalid => conversion_done,
                 m_axis_result_tdata => converted_data
               ); 
         
              
sel_conv_demux: select_conversion_demux
    port map(
            a => converted_data,
            sel => conversion_select,
            output_a => num_vectors_float,
            output_b => count_class1_float,
            output_c => count_class2_float      
    );


sel_class_mux: select_class_mux
    port map(
                a => count_class1_float,
                b => count_class2_float,
                sel => class_select,
                output => dividend
            );

divider: divide
  PORT MAP (
                aclk => clk,
                s_axis_a_tvalid => division_work,
                s_axis_a_tdata => dividend,
                s_axis_b_tvalid => division_work,
                s_axis_b_tdata => num_vectors_float,
                m_axis_result_tvalid => div_done,
                m_axis_result_tdata => division_out
              );


sel_class_demux: select_class_demux
    port map(
                a => division_out,
                sel => class_select,
                output_a => prior_prob_class1_temp,
                output_b => prior_prob_class2_temp       
        );
  
end Behavioral;

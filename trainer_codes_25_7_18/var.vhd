----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.03.2018 10:16:56
-- Design Name: 
-- Module Name: variance - Behavioral
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

entity var is
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
end var;

architecture Behavioral of var is

component vhdl_binary_counter is
    port(C, CLR : in std_logic;
    Q : out std_logic_vector(15 downto 0));
end component;

component acc
    Port ( 
        aclk : IN STD_LOGIC;
        s_axis_a_tvalid : IN STD_LOGIC;
        s_axis_a_tready : OUT STD_LOGIC;
        s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        s_axis_a_tlast : IN STD_LOGIC;
        m_axis_result_tvalid : OUT STD_LOGIC;
       -- m_axis_result_tready : IN STD_LOGIC;
        m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        m_axis_result_tlast : OUT STD_LOGIC);
end component;

component div is
  port (
    aclk : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_b_tvalid : IN STD_LOGIC;
    s_axis_b_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
end component;

component sub is
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_b_tvalid : IN STD_LOGIC;
    s_axis_b_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END component;

component mul is
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_b_tvalid : IN STD_LOGIC;
    s_axis_b_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END component;

component mux_4to1_top is
    Port ( 
           SEL : in  STD_LOGIC;      -- select input
           A   : in  STD_LOGIC_VECTOR (63 downto 0);     -- inputs
           X   : out STD_LOGIC_VECTOR (31 downto 0));    -- output
end component;

component mux_4to1_valid is
    Port ( SEL : in  STD_LOGIC;     -- select input
           A   : in  STD_LOGIC_VECTOR (1 downto 0);     -- inputs
           X   : out STD_LOGIC);                        -- output
end component;

component demux1_4 is
port (
      out0 : out std_logic;         --output bit
      out1 : out std_logic;         --output bit
       out2 : out std_logic;        --output bit
      out3 : out std_logic;         --output bit
       sel : in std_logic_vector(1 downto 0);
       bitin : in std_logic         --input bit
     );
end component;

signal selection : std_logic;
signal sub_out: std_logic_vector(31 downto 0);
signal mul_a: std_logic_vector(31 downto 0);
signal mul_b: std_logic_vector(31 downto 0);
signal mul_out: std_logic_vector(31 downto 0);
signal mul_valid : std_logic;
signal sub_valid : std_logic;
signal mul_b_valid : std_logic;
signal mul_a_valid : std_logic;
signal div_valid : std_logic;
signal acc_ready : std_logic;
signal acc_out : std_logic_vector(31 downto 0);
signal acc_valid : std_logic;
signal acc_last : std_logic;
signal div_ready : std_logic;
signal acc_a_tready : std_logic;
signal acc_b_tready : std_logic;
signal mux_a_string : std_logic_vector(63 downto 0);
signal mux_b_string : std_logic_vector(63 downto 0);
signal mul_a_valid_previous : std_logic;
signal acc_able : std_logic;
signal last_acc_in : std_logic;
signal temp_count : std_logic_vector(15 downto 0);
signal counter_rst: std_logic;
signal var_done: std_logic;
signal var_data_out: std_logic_vector(31 downto 0);

begin
div_ready <= acc_valid and acc_last;
var_sub_done <= sub_valid;
acc_ready <= mul_valid and acc_able;
mux_a_string(31 downto 0) <= sub_out;
mux_a_string(63 downto 32) <= mul_out;
mux_b_string(31 downto 0) <= sub_out;
mux_b_string(63 downto 32) <= prior;
counter_rst <= not rst;


var_result: process(rst,var_done)
begin
    if(rst='1')then
        var <= "00000000000000000000000000000000";
        var_ready <= '0';
    elsif(falling_edge (var_done))then
        var <= var_data_out;
        var_ready <= '1';
    end if;
end process;


substract: sub -- (x-i)
  port map (
  aclk => clk,
  s_axis_a_tvalid => work,
  --s_axis_a_tready : OUT STD_LOGIC;
  s_axis_a_tdata => value,
  s_axis_b_tvalid => work,
  --s_axis_b_tready : OUT STD_LOGIC;
  s_axis_b_tdata => mean,
  m_axis_result_tvalid => sub_valid,
  m_axis_result_tdata => sub_out
);


mux_mul_a: mux_4to1_top
    port map (
        SEL => selection,
        A => mux_a_string,
        X => mul_a
    );
  
mul_valid_a: mux_4to1_valid
        port map (
        SEL => selection,
        A(0) => sub_valid,
        A(1) => mul_valid,
        X => mul_a_valid
    );    
mux_mul_b: mux_4to1_top
        port map (
            SEL => selection,
            A => mux_b_string,
            X => mul_b
        );
mul_valid_b: mux_4to1_valid
            port map (
            SEL => selection,
            A(0) => sub_valid,
            A(1) => '1',
            X => mul_b_valid
        );        

mul_1: mul --(x-u)^2
  port map (
  aclk => clk,
  s_axis_a_tvalid => mul_a_valid,
  s_axis_a_tdata => mul_a,
  s_axis_b_tvalid => mul_b_valid,
  s_axis_b_tdata => mul_b,
  m_axis_result_tvalid => mul_valid,
  m_axis_result_tdata => mul_out
);
    
accumulator: acc
    port map (
    aclk => clk,
    s_axis_a_tvalid => acc_ready,
    s_axis_a_tready => acc_a_tready,
    s_axis_a_tdata => mul_out,
    s_axis_a_tlast => last_acc_in, 
    m_axis_result_tvalid => acc_valid,
    m_axis_result_tdata => acc_out,
    m_axis_result_tlast => acc_last
);
division: div
    port map (
        aclk => clk,
        s_axis_a_tvalid => div_ready,
        s_axis_a_tdata => acc_out,
        s_axis_b_tvalid => div_ready,
        s_axis_b_tdata => count_float,
        m_axis_result_tvalid => var_done,
        m_axis_result_tdata => var_data_out
    );
    
acc_valid_control: process(clk)
    variable temp : std_logic := '0';
    begin
            if(clk'event and clk = '1') then
                if mul_valid = '1' then
                    if (temp = '0') then
                        temp := '1';
                    else
                        temp := '0';
                    end if;
                end if;
            end if;
            acc_able <= temp;
end process;

elements_counter: vhdl_binary_counter
    port map (
        C => acc_able,
        CLR => counter_rst,
        Q => temp_count
    );

elements_comparison: process(temp_count, acc_valid, counter_rst, count)
    begin
        if (temp_count = count) then
            last_acc_in <= '1';
        else 
            last_acc_in <= '0';
        end if;
end process;
    

s_control: process(counter_rst, mul_valid, sub_valid, div_valid)
variable s : std_logic;
variable temp : std_logic;
    begin
        if (counter_rst = '0') then
            selection <= '0';   
            temp := '0'; 
        else
            if (sub_valid = '1') then
                selection <= '0';
                temp := '0';
            else 
                if (mul_valid = '1') then
                    if (temp = '0') then
                        selection <= '1';
                        temp := '1';
                    end if;
                end if;      
            end if;
        end if;
end process;

end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.03.2018 10:16:37
-- Design Name: 
-- Module Name: mean - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mean is
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
end mean;

architecture Behavioral of mean is

component conv 
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_a_tready : out std_logic;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
end component;

component acc
    Port ( 
        aclk : IN STD_LOGIC;
        s_axis_a_tvalid : IN STD_LOGIC;
        s_axis_a_tready : OUT STD_LOGIC;
        s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        s_axis_a_tlast : IN STD_LOGIC;
        m_axis_result_tvalid : OUT STD_LOGIC;
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

component vhdl_binary_counter is
    port(C, CLR : in std_logic;
    Q : out std_logic_vector(15 downto 0));
end component;

signal count_out : std_logic_vector(15 downto 0);
signal conv_valid : std_logic;
signal count_out_float: std_logic_vector(31 downto 0);
signal sum : std_logic_vector(31 downto 0);
signal sum_valid : std_logic;
signal sum_last : std_logic;
signal acc_a_tready : std_logic;
signal div_a_valid : std_logic;
signal s_axis_a_tready : std_logic;
signal count_rst: std_logic;
signal mean_done: std_logic;
signal mean_data_out: std_logic_vector(31 downto 0);

begin
div_a_valid <= sum_valid and sum_last;
sum_done <= sum_valid;
count <= count_out;
count32 <= count_out_float;
count_rst <= not rst;

mean_result: process(rst,mean_done)
begin
    if(rst='1')then
        mean_out <= "00000000000000000000000000000000";
        mean_ready <= '0';
    elsif(falling_edge (mean_done))then
        mean_out <= mean_data_out;
        mean_ready <= '1';
    end if;
end process;


Uint16toFloatS32: conv
  port map (
    aclk => clk,
    s_axis_a_tvalid => '1',
    s_axis_a_tready => s_axis_a_tready,
    s_axis_a_tdata => count_out,
    m_axis_result_tvalid => conv_valid,
    m_axis_result_tdata => count_out_float
);

adder: acc
    port map (
        aclk => clk,
        s_axis_a_tvalid => work,
        s_axis_a_tready => acc_a_tready,
        s_axis_a_tdata => value,
        s_axis_a_tlast => last, 
        m_axis_result_tvalid => sum_valid,
        m_axis_result_tdata => sum,
        m_axis_result_tlast => sum_last
    );

division: div
    port map (
        aclk => clk,
        s_axis_a_tvalid => div_a_valid,
        s_axis_a_tdata => sum ,
        s_axis_b_tvalid => conv_valid,
        s_axis_b_tdata => count_out_float,
        m_axis_result_tvalid => mean_done,
        m_axis_result_tdata => mean_data_out
    );
        

    elements_counter: vhdl_binary_counter
        port map (
            C => work,
            CLR => count_rst,
            Q => count_out
        );
    
    
end Behavioral;
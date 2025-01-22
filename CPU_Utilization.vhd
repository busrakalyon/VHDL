library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;



entity cpu_utilization is
    Port (
    clk: in std_logic;
    rst: in std_logic;
    datain: in std_logic_vector(15 downto 0);
    instruction: in std_logic_vector(15 downto 0);
    address: out std_logic_vector(15 downto 0);
    dataout: out std_logic_vector(15 downto 0)
     );
end cpu_utilization;

architecture Behavioral of cpu_utilization is
    type state_type is (fetch, decode,execute);
    signal current_state: state_type := fetch;
    signal program_counter: unsigned(15 downto 0) := (others =>'0');
    signal reg_a: unsigned(15 downto 0) := (others => '0');
    signal reg_b: unsigned(15 downto 0) := (others => '0');
    signal opcode: std_logic_vector(3 downto 0) := (others => '0');
    signal operand: std_logic_vector(11 downto 0) := (others => '0');
     
begin
 process(clk, rst)
   begin
    if rst = '1' then 
       current_state <= fetch;
       program_counter <= (others => '0');
       reg_a <= (others => '0');
       reg_b <= (others => '0');
    elsif rising_edge (clk) then
        case current_state  is
            when fetch => 
                address <= std_logic_vector(program_counter);
                current_state <= decode;
            when decode =>
                opcode <= instruction(15 downto 12);
                operand <= instruction(11 downto 0);
                current_state <= execute;
            when execute =>
                case opcode is
                    when "0001" =>
                        address <= "0000" & operand;
                        reg_a <= unsigned(datain);
                    when "0010" => 
                        address <= "0000" & operand;
                        dataout <= std_logic_vector(reg_a);
                    when "0011" =>
                        address <= "0000" & operand;
                        reg_a <= reg_a + unsigned(datain);
                    when "0100" =>
                        address <= "0000" & operand;
                        reg_a <= reg_a - unsigned(datain);
                    when "0101" =>
                        program_counter <= unsigned("0000" & operand);
                    when "1111" =>
                        current_state <= fetch;
                    when others =>
                        null;       --"others" durumunda yapılacak işlemin olmadığı söylenir
                end case;
                  
              if opcode <= "0101" then
                program_counter <= program_counter + 1;
              end if; 
            end case;       --current_state için kapanış
          end if;
        end process;        --process kapanışı
end Behavioral;     --architecture kapanışı
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity vending_machine is
    Port (
        coin    : in std_logic_vector(1 downto 0); -- 2-bit para girisi
        button  : in std_logic_vector(2 downto 0); -- 3-bit urun secimi
        dispense: out std_logic_vector(3 downto 0); -- 4-bit verilen urun
        change  : out std_logic_vector(1 downto 0)  -- 2-bit para ustu
    );
end vending_machine;

architecture Behavioral of vending_machine is
    -- Toplam girilen para
    signal total : integer := 0; 
    
begin
    process(coin, button)
        --sinyal hemen degismedigi icin degisken olusturarak toplam para durumunda hemen degisim sagliyoruz
        variable current_total : integer := 0;
         
    begin
        -- Default deger atamalari
        dispense <= "0000";
        change <= "00";


        current_total := total; 
        
  -----------------------------------------------------------------------
        
        --Para girisi durumu
        case coin is
            when "01" => current_total := current_total + 25; -- 25 kurus
            when "10" => current_total := current_total + 50; -- 50 kurus
            when "11" => current_total := current_total + 100; -- 1 lira
            when others => null;
        end case;

-----------------------------------------------------------------------

        -- Secilen buton durumlarý
        case button is
            when "001" => -- Product A (50 kuruþ)
                if current_total >= 50 then
                    dispense <= "0001";
                    if current_total > 50 then
                        change <= "01"; -- 25 kuruþ change
                    end if;
                    current_total := 0; -- Reset after dispensing
                end if;
                
            -----------------------------------------------------------
            
            when "010" => -- Product B (75 kuruþ)
                if current_total >= 75 then
                    dispense <= "0010";
                    if current_total = 100 then
                        change <= "01"; -- 25 kuruþ change
                    end if;
                    current_total := 0;
                 else
                    change <= coin;
                end if;
                
            -----------------------------------------------------------
            
            when "011" => -- Product C (1 lira)
                if current_total >= 100 then
                    dispense <= "0011";
                    current_total := 0;
                 else
                    change <= coin;
                end if;
            -----------------------------------------------------------
            when "100" => -- Product D (1 lira)
                if current_total >= 100 then
                    dispense <= "1000";
                    current_total := 0;
                else 
                    change <= coin;
                end if;
            -----------------------------------------------------------
            when others =>
                null; -- No selection
        end case;
        
        total <= current_total; -- Update total signal
        
    end process;
end Behavioral;

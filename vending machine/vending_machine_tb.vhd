library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vending_machine_tb is
-- testbench'te giris cikis olmadigi icin port tanimlamasi yapilmaz, disarisiyla baglantisi yok
end vending_machine_tb;

architecture Behavioral of vending_machine_tb is
    --sim�lasyon i�in test sinyallerinin tan�mlanmasi
    signal coin    : std_logic_vector(1 downto 0) := "00";
    signal button  : std_logic_vector(2 downto 0) := "000";
    signal dispense: std_logic_vector(3 downto 0);
    signal change  : std_logic_vector(1 downto 0);

    -- vending machine tasar�m�, testbench icine bilesen olarak tanitilir
    component vending_machine
        Port (
            coin    : in std_logic_vector(1 downto 0);
            button  : in std_logic_vector(2 downto 0);
            dispense: out std_logic_vector(3 downto 0);
            change  : out std_logic_vector(1 downto 0)
        );
    end component;

begin
    uut: vending_machine
        --bilesen baglantisi
        Port map (
            coin => coin,
            button => button,
            dispense => dispense,
            change => change
        );

    process
    begin

        -- Test 1: 1 lira at, C urununu sec, para �st� yok
        coin <= "11";
        wait for 10 ns;
        button <= "011"; -- �r�n C
        wait for 10 ns;
-----------------------------------------------------------------------

        -- Test 2: Yetersiz para durumu
        coin <= "01";
        wait for 10 ns;
        button <= "100"; -- �r�n D
        wait for 10 ns;
-----------------------------------------------------------------------

        -- Test 3: Para �st� durumu
        coin <= "11";
        wait for 10 ns;
        button <= "010"; -- �r�n B
        wait for 10 ns;
-----------------------------------------------------------------------  
      
        -- Test 4: 25 kuru� at, se�im yapma
        coin <= "01";
        button <= "000";
        wait for 10 ns;
-----------------------------------------------------------------------

        -- Test 5: 50 kuru� tamamla, �r�n A se�
        coin <= "01";
        wait for 10 ns;
        button <= "001"; -- �r�n A
        wait for 10 ns;

        wait;
    end process;

end Behavioral;

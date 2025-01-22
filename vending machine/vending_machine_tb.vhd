library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vending_machine_tb is
-- testbench'te giris cikis olmadigi icin port tanimlamasi yapilmaz, disarisiyla baglantisi yok
end vending_machine_tb;

architecture Behavioral of vending_machine_tb is
    --simülasyon için test sinyallerinin tanımlanmasi
    signal coin    : std_logic_vector(1 downto 0) := "00";
    signal button  : std_logic_vector(2 downto 0) := "000";
    signal dispense: std_logic_vector(3 downto 0);
    signal change  : std_logic_vector(1 downto 0);

    -- vending machine tasarımı, testbench icine bilesen olarak tanitilir
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

        -- Test 1: 1 lira at, C urununu sec, para üstü yok
        coin <= "11";
        wait for 10 ns;
        button <= "011"; -- Ürün C
        wait for 10 ns;
-----------------------------------------------------------------------

        -- Test 2: Yetersiz para durumu
        coin <= "01";
        wait for 10 ns;
        button <= "100"; -- Ürün D
        wait for 10 ns;
-----------------------------------------------------------------------

        -- Test 3: Para üstü durumu
        coin <= "11";
        wait for 10 ns;
        button <= "010"; -- Ürün B
        wait for 10 ns;
-----------------------------------------------------------------------  
      
        -- Test 4: 25 kuruş at, seçim yapma
        coin <= "01";
        button <= "000";
        wait for 10 ns;
-----------------------------------------------------------------------

        -- Test 5: 50 kuruş tamamla, ürün A seç
        coin <= "01";
        wait for 10 ns;
        button <= "001"; -- Ürün A
        wait for 10 ns;

        wait;
    end process;

end Behavioral;

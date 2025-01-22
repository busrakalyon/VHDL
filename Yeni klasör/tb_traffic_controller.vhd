library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_traffic_controller is
    
end tb_traffic_controller;

architecture Testbench of tb_traffic_controller is
    -- DUT (Design Under Test) port sinyalleri
    signal car_count_NS : std_logic_vector(2 downto 0);
    signal car_count_EW : std_logic_vector(2 downto 0);
    signal ped_button   : std_logic;
    signal ped_count    : std_logic_vector(2 downto 0);
    signal timer_tick   : std_logic;
    signal lights_NS    : std_logic_vector(2 downto 0);
    signal lights_EW    : std_logic_vector(2 downto 0);
    signal ped_light    : std_logic_vector(1 downto 0);

    -- Zamanlay�c� sim�lasyonunda kullan�lan clock sinyali
    constant clock_period : time := 10 ns;

begin
    -- DUT instantiation (Tasar�m�n instansiyonu)
    uut: entity work.traffic_controller
        port map (
            car_count_NS => car_count_NS,
            car_count_EW => car_count_EW,
            ped_button   => ped_button,
            ped_count    => ped_count,
            timer_tick   => timer_tick,
            lights_NS    => lights_NS,
            lights_EW    => lights_EW,
            ped_light    => ped_light
        );

    -- Zamanlay�c� sim�lasyonu
    clock_gen: process
    begin
        timer_tick <= '0';
        wait for clock_period /2;
        timer_tick <= '1';
        wait for clock_period /2;
    end process;

    -- Test Senaryolar�
    stimulus: process
    begin
        -- Test 1: Yaya �ncelik
        car_count_NS <= "011"; -- 3 ara�
        car_count_EW <= "001"; -- 1 ara�
        ped_button   <= '1';   -- Yaya ge�i� talebi yok
        ped_count    <= "010"; -- ped_light
        wait for 20 ns; 

        -- Test 2: 
        car_count_NS <= "011"; -- 3 ara�
        car_count_EW <= "001"; -- 1 ara�
        ped_button <= '0';
        ped_count <= "000"; 
        wait for 20 ns; -- Bekleyen yaya yok
        
        -- Test 3: Do�u-Bat�'da trafik yo�unlu�u
        
        car_count_NS <= "001"; -- 1 ara�
        car_count_EW <= "101"; -- 5 ara�
        ped_button <= '0';
        ped_count    <= "000";
        wait for 20 ns; -- Do�u-Bat� ye�il olmal�

        -- Test4: Kuzey-G�ney'de trafik yo�unlu�u
        car_count_NS <= "111"; -- 7 veya daha fazla ara�
        car_count_EW <= "000"; -- Trafik yok
        ped_button <= '0';
        ped_count    <= "000";
        wait for 20 ns; -- Kuzey-G�ney ye�il olmal�
        
        -- Test 5: Do�u-Bat� trafik yo�unlu�u
        car_count_NS <= "010";
        car_count_EW <= "111";
        ped_button <= '0';
        ped_count <= "000";
        wait for 20 ns; -- Do�u-Bat� ye�il olmal�
        
        -- Test 6: Yaya talebi
        car_count_NS <= "010";
        car_count_EW <= "010";
        ped_button <= '1';
        ped_count <= "100";
        wait for 20 ns; 
        
        -- Test 7: Hi� trafik ve yaya talebi yok
        car_count_NS <= "000";
        car_count_EW <= "000";
        ped_button <= '0';        
        ped_count <= "000";
        wait for 20 ns; -- Sistem bekleme durumunda olmal�

        -- Sim�lasyonu bitir
        wait;
    end process;

end Testbench;

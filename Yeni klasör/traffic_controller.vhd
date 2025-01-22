library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity traffic_controller is
    port (
        car_count_NS : in std_logic_vector(2 downto 0); -- Kuzey-Güney araç sayısı
        car_count_EW : in std_logic_vector(2 downto 0); -- Doðu-Batý araç sayısı
        ped_button   : in std_logic; -- Yaya butonu
        ped_count    : in std_logic_vector(2 downto 0); -- Yaya sayısı
        timer_tick   : in std_logic; -- Zamanlayıcı tetikleme sinyali
        lights_NS    : out std_logic_vector(2 downto 0); -- Kuzey-Güney trafik ışığı
        lights_EW    : out std_logic_vector(2 downto 0); -- Doðu-Batı trafik ışığı
        ped_light    : out std_logic_vector(1 downto 0)  -- Yaya geçidi ışığı(01 = kırmızı, 10 = yeşil)
    );
end traffic_controller;

architecture Behavioral of traffic_controller is
    type state_type is (Initial, NS_Green, NS_Yellow, EW_Green, EW_Yellow, Pedestrian);
    signal current_state, next_state : state_type := Initial;
begin

    -- FSM ve Timer Yönetimi Süreci
    process(timer_tick)
    begin
        if rising_edge(timer_tick) then
            current_state <= next_state; -- Durum değiştir
        end if;
    end process;

    -- FSM Durum Geçiþ Süreci
    process(current_state, car_count_NS, car_count_EW, ped_button, ped_count)
        variable timer : integer := 0; -- Zamanlayıcı
        
    begin
        -- Başlangıç değerleri 
        lights_NS <= "001"; -- kırmızı
        lights_EW <= "001"; -- kırmızı
        ped_light <= "01";  -- Yaya kırmızı

        case current_state is
            -- Başlangıç Durumu
            when Initial =>
                lights_NS <= "001";
                lights_EW <= "001";
                ped_light <= "01";
                if ped_button = '1' then
                    next_state <= Pedestrian;
                elsif to_integer(unsigned(car_count_NS)) >= to_integer(unsigned(car_count_EW)) then
                    next_state <= NS_Yellow;
                else
                    next_state <= EW_Yellow;
                end if;

            -- Kuzey-Güney Sarı ışık
            when NS_Yellow =>
                lights_NS <= "010"; -- Sarı
                lights_EW <= "001"; -- kırmızı
                ped_light <= "01";  -- kırmızı
                next_state <= NS_Green;

            -- Kuzey-Güney yeşil ışık
            when NS_Green =>
                lights_NS <= "100"; -- Yeşil
                lights_EW <= "001"; -- kırmızı
                ped_light <= "01";  -- kırmızı
                if ped_button = '1' then
                    next_state <= Pedestrian;
                elsif to_integer(unsigned(car_count_NS)) >= 7 then
                    timer := 0;
                    if timer <= 15 then
                        timer := timer + 1;
                    end if;
                else
                    timer := 0;
                    if timer <= 10 then
                        timer := timer + 1;
                    end if;
                    next_state <= EW_Yellow;
                end if;
                
            
            -- Doðu-Batı sarı ışık
            when EW_Yellow =>
                lights_NS <= "001"; -- kırmızı
                lights_EW <= "010"; -- Yeşil
                ped_light <= "01";  -- kırmızı
                next_state <= EW_Green;

            -- Doðu-Batý yeşil ışık
            when EW_Green =>
                lights_NS <= "001"; -- kırmızı
                lights_EW <= "100"; -- Yeşil
                ped_light <= "01";  -- kırmızı
                if ped_button = '1' then
                    next_state <= Pedestrian;
                elsif to_integer(unsigned(car_count_EW)) >= 7 then
                    timer := 0;
                    if timer <= 15 then
                        timer := timer + 1;
                    end if;
                else
                    timer := 0;
                    if timer <= 10 then
                        timer := timer + 1;
                    end if;
                    next_state <= NS_Yellow;
                end if;
                

            -- Yaya geçidi durumu
            when Pedestrian =>
                lights_NS <= "001"; -- kırmızı
                lights_EW <= "001"; -- kırmızı
                ped_light <= "10";  -- Yeşil
                if to_integer(unsigned(ped_count)) >= 7 then
                    timer := 0;
                    if timer <= 15 then
                        timer := timer + 1;
                    end if;
                else
                    timer := 0;
                    if timer <= 10 then
                        timer := timer + 1;
                    end if;
                    next_state <= Initial;
                end if;


            -- Varsayılan Durum
            when others =>
                lights_NS <= "001"; -- kırmızı
                lights_EW <= "001"; -- kırmızı
                ped_light <= "01";  -- kırmızı
                next_state <= Initial;
        end case;
    end process;

end Behavioral;

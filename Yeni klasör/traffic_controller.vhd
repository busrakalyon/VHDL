library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity traffic_controller is
    port (
        car_count_NS : in std_logic_vector(2 downto 0); -- Kuzey-Güney araç sayýsý
        car_count_EW : in std_logic_vector(2 downto 0); -- Doðu-Batý araç sayýsý
        ped_button   : in std_logic; -- Yaya butonu
        ped_count    : in std_logic_vector(2 downto 0); -- Yaya sayýsý
        timer_tick   : in std_logic; -- Zamanlayýcý tetikleme sinyali
        lights_NS    : out std_logic_vector(2 downto 0); -- Kuzey-Güney trafik ýþýðý
        lights_EW    : out std_logic_vector(2 downto 0); -- Doðu-Batý trafik ýþýðý
        ped_light    : out std_logic_vector(1 downto 0)  -- Yaya geçidi ýþýðý(01 = kýrmýzý, 10 = yeþil)
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
            current_state <= next_state; -- Durum deðiþtir
        end if;
    end process;

    -- FSM Durum Geçiþ Süreci
    process(current_state, car_count_NS, car_count_EW, ped_button, ped_count)
        variable timer : integer := 0; -- Zamanlayýcý
        
    begin
        -- Varsayýlan çýkýþlar
        lights_NS <= "001"; -- Kýrmýzý
        lights_EW <= "001"; -- Kýrmýzý
        ped_light <= "01";  -- Yaya kýrmýzý

        case current_state is
            -- Baþlangýç Durumu
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

            -- Kuzey-Güney Sarý ýþýk
            when NS_Yellow =>
                lights_NS <= "010"; -- Sarý
                lights_EW <= "001"; -- Kýrmýzý
                ped_light <= "01";  -- Kýrmýzý
                next_state <= NS_Green;

            -- Kuzey-Güney yeþil ýþýk
            when NS_Green =>
                lights_NS <= "100"; -- Yeþil
                lights_EW <= "001"; -- Kýrmýzý
                ped_light <= "01";  -- Kýrmýzý
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
                
            
            -- Doðu-Batý yeþil ýþýk
            when EW_Yellow =>
                lights_NS <= "001"; -- Kýrmýzý
                lights_EW <= "010"; -- Yeþil
                ped_light <= "01";  -- Kýrmýzý
                next_state <= EW_Green;

            -- Doðu-Batý yeþil ýþýk
            when EW_Green =>
                lights_NS <= "001"; -- Kýrmýzý
                lights_EW <= "100"; -- Yeþil
                ped_light <= "01";  -- Kýrmýzý
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
                lights_NS <= "001"; -- Kýrmýzý
                lights_EW <= "001"; -- Kýrmýzý
                ped_light <= "10";  -- Yeþil
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


            -- Varsayýlan Durum
            when others =>
                lights_NS <= "001"; -- Kýrmýzý
                lights_EW <= "001"; -- Kýrmýzý
                ped_light <= "01";  -- Kýrmýzý
                next_state <= Initial;
        end case;
    end process;

end Behavioral;
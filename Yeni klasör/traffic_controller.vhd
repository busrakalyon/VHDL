library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity traffic_controller is
    port (
        car_count_NS : in std_logic_vector(2 downto 0); -- Kuzey-G�ney ara� say�s�
        car_count_EW : in std_logic_vector(2 downto 0); -- Do�u-Bat� ara� say�s�
        ped_button   : in std_logic; -- Yaya butonu
        ped_count    : in std_logic_vector(2 downto 0); -- Yaya say�s�
        timer_tick   : in std_logic; -- Zamanlay�c� tetikleme sinyali
        lights_NS    : out std_logic_vector(2 downto 0); -- Kuzey-G�ney trafik �����
        lights_EW    : out std_logic_vector(2 downto 0); -- Do�u-Bat� trafik �����
        ped_light    : out std_logic_vector(1 downto 0)  -- Yaya ge�idi �����(01 = k�rm�z�, 10 = ye�il)
    );
end traffic_controller;

architecture Behavioral of traffic_controller is
    type state_type is (Initial, NS_Green, NS_Yellow, EW_Green, EW_Yellow, Pedestrian);
    signal current_state, next_state : state_type := Initial;
begin

    -- FSM ve Timer Y�netimi S�reci
    process(timer_tick)
    begin
        if rising_edge(timer_tick) then
            current_state <= next_state; -- Durum de�i�tir
        end if;
    end process;

    -- FSM Durum Ge�i� S�reci
    process(current_state, car_count_NS, car_count_EW, ped_button, ped_count)
        variable timer : integer := 0; -- Zamanlay�c�
        
    begin
        -- Varsay�lan ��k��lar
        lights_NS <= "001"; -- K�rm�z�
        lights_EW <= "001"; -- K�rm�z�
        ped_light <= "01";  -- Yaya k�rm�z�

        case current_state is
            -- Ba�lang�� Durumu
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

            -- Kuzey-G�ney Sar� ���k
            when NS_Yellow =>
                lights_NS <= "010"; -- Sar�
                lights_EW <= "001"; -- K�rm�z�
                ped_light <= "01";  -- K�rm�z�
                next_state <= NS_Green;

            -- Kuzey-G�ney ye�il ���k
            when NS_Green =>
                lights_NS <= "100"; -- Ye�il
                lights_EW <= "001"; -- K�rm�z�
                ped_light <= "01";  -- K�rm�z�
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
                
            
            -- Do�u-Bat� ye�il ���k
            when EW_Yellow =>
                lights_NS <= "001"; -- K�rm�z�
                lights_EW <= "010"; -- Ye�il
                ped_light <= "01";  -- K�rm�z�
                next_state <= EW_Green;

            -- Do�u-Bat� ye�il ���k
            when EW_Green =>
                lights_NS <= "001"; -- K�rm�z�
                lights_EW <= "100"; -- Ye�il
                ped_light <= "01";  -- K�rm�z�
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
                

            -- Yaya ge�idi durumu
            when Pedestrian =>
                lights_NS <= "001"; -- K�rm�z�
                lights_EW <= "001"; -- K�rm�z�
                ped_light <= "10";  -- Ye�il
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


            -- Varsay�lan Durum
            when others =>
                lights_NS <= "001"; -- K�rm�z�
                lights_EW <= "001"; -- K�rm�z�
                ped_light <= "01";  -- K�rm�z�
                next_state <= Initial;
        end case;
    end process;

end Behavioral;
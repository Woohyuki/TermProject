library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity myseven_segments is
   Port (
        x: in std_logic_vector(20 downto 0);
        clk: in std_logic;
        clr: in std_logic;
        reset: in std_logic;
        a_to_g: out std_logic_vector(7 downto 0);
        an: out std_logic_vector(7 downto 0)
   );
end myseven_segments;

architecture Behavioral of myseven_segments is
   signal digit_select: std_logic_vector(2 downto 0);
   signal digit: std_logic_vector(3 downto 0);
   signal clkdiv: std_logic_vector(20 downto 0);
   signal x_4bit: std_logic_vector(31 downto 0);
   signal digit_reset_cnt: std_logic_vector(2 downto 0) := (others => '0');
begin

x_4bit(3 downto 0) <= "1010" when x(2 downto 0) = "100" else
                     "1011" when x(2 downto 0) = "101" else
                     "1100" when x(2 downto 0) = "110" else
                     "1111";

x_4bit(7 downto 4) <= x(6 downto 3);
x_4bit(11 downto 8) <= '0' & x(9 downto 7);
x_4bit(15 downto 12) <= "1101" when x(10) = '1' else "1110";
x_4bit(19 downto 16) <= x(14 downto 11);
x_4bit(23 downto 20) <= "1101" when x(15) = '1' else "1110";
x_4bit(27 downto 24) <= x(19 downto 16);
x_4bit(31 downto 28) <= "1101" when x(20) = '1' else "1110";

-- digit_select는 reset이 '1'일 때 digit_reset_cnt 사용
digit_select <= digit_reset_cnt when reset = '1' else clkdiv(20 downto 18);

-- 디지트 선택 및 초기화
process(clk)
begin
    if rising_edge(clk) then
        if reset = '1' then
            digit <= "0000";  -- reset 시 '0'으로 초기화
        else
            case digit_select is
                when "000" => digit <= x_4bit(7 downto 4);
                when "001" => digit <= x_4bit(11 downto 8);
                when "010" => digit <= x_4bit(15 downto 12);
                when "011" => digit <= x_4bit(3 downto 0);
                when "100" => digit <= x_4bit(19 downto 16);
                when "101" => digit <= x_4bit(23 downto 20);
                when "110" => digit <= x_4bit(27 downto 24);
                when others => digit <= x_4bit(31 downto 28);
            end case;
        end if;
    end if;
end process;

-- 7 세그먼트 디코더
process(digit, reset)
begin
    if reset = '1' then
        a_to_g <= "00111111";
    else
        case digit is
            when "0000" => a_to_g <= "00111111"; -- 0
            when "0001" => a_to_g <= "00000110"; -- 1
            when "0010" => a_to_g <= "01011011"; -- 2
            when "0011" => a_to_g <= "01001111"; -- 3
            when "0100" => a_to_g <= "01100110"; -- 4
            when "0101" => a_to_g <= "01101101"; -- 5
            when "0110" => a_to_g <= "01111101"; -- 6
            when "0111" => a_to_g <= "00000111"; -- 7
            when "1000" => a_to_g <= "01111111"; -- 8
            when "1001" => a_to_g <= "01101111"; -- 9
            when "1010" => a_to_g <= "11110111"; -- A
            when "1011" => a_to_g <= "11101101"; -- S
            when "1100" => a_to_g <= "10110111"; -- M
            when "1101" => a_to_g <= "01000000"; -- -
            when "1110" => a_to_g <= "00111111"; -- +
            when others => a_to_g <= "00000000"; -- F
        end case;
    end if;
end process;

-- an 신호 제어 프로세스
process(digit_select, reset)
begin
    if reset = '1' then
        an <= "11111110";
    else
        case digit_select is
            when "000" => an <= "00000001";
            when "001" => an <= "00000010";
            when "010" => an <= "00000100";
            when "011" => an <= "00001000";
            when "100" => an <= "00010000";
            when "101" => an <= "00100000";
            when "110" => an <= "01000000";
            when others => an <= "10000000";
        end case;
    end if;
end process;

process(clk, clr)
begin
    if clr = '0' then
        clkdiv <= (others => '0');
        digit_reset_cnt <= (others => '0');
    elsif rising_edge(clk) then
        clkdiv <= clkdiv + 1;
        digit_reset_cnt <= digit_reset_cnt + 1;
    end if;
end process;

end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;

entity BinaryToBCD is
    Port (
        clk         : in std_logic;                      
        reset       : in std_logic;                      
        A           : in std_logic_vector(3 downto 0);   
        B           : in std_logic_vector(3 downto 0);  
        Sel         : in std_logic_vector(1 downto 0);
        adder_result : in std_logic_vector(4 downto 0);  
        overflow    : in std_logic;                      
        bcd_out     : out std_logic_vector(7 downto 0);                        
        A_bcd       : out std_logic_vector(4 downto 0); 
        B_bcd       : out std_logic_vector(4 downto 0)
    );
end BinaryToBCD;

architecture Behavioral of BinaryToBCD is
    signal abs_value       : integer := 0;                -- 절대값 저장
    signal abs_value_next  : integer := 0;                
    signal is_negative     : std_logic := '0';            -- 부호
    signal is_negative_next : std_logic := '0';           
    signal tens            : std_logic_vector(2 downto 0) := "000"; --십의자리
    signal tens_next       : std_logic_vector(2 downto 0) := "000";
    signal bcd_units       : std_logic_vector(3 downto 0) := "0000";  --일의자리
    signal bcd_units_next  : std_logic_vector(3 downto 0) := "0000"; 
    signal temp_bcd_A      : std_logic_vector(4 downto 0) := "00000"; -- A 변환된 값
    signal temp_bcd_B      : std_logic_vector(4 downto 0) := "00000"; -- B 변환된 값
--    signal temp_bcd_A_next : std_logic_vector(4 downto 0) := "00000"; -- A 변환된 값 (다음 상태)
--    signal temp_bcd_B_next : std_logic_vector(4 downto 0) := "00000"; -- B 변환된 값 (다음 상태)
    signal twos_comp_A : std_logic_vector(3 downto 0);
    signal twos_comp_B : std_logic_vector(3 downto 0);
    signal twos_comp_result : std_logic_vector(4 downto 0);
    
        -- TwosComplement Component 선언
    component TwosComplement_4Bit is
        Port (
            binary_in  : in std_logic_vector(3 downto 0);
            complement : out std_logic_vector(3 downto 0)
        );
    end component;
    
    component TwosComplement_5Bit is
        Port (
            binary_in  : in std_logic_vector(4 downto 0); -- 5비트 입력
            complement : out std_logic_vector(4 downto 0) -- 5비트 2의 보수
        );
    end component;
    
begin
    -- TwosComplement A
    TwosComplement_A: TwosComplement_4Bit
        port map (
            binary_in  => A,
            complement => twos_comp_A
        );

    -- TwosComplement B
    TwosComplement_B: TwosComplement_4Bit
        port map (
            binary_in  => B,
            complement => twos_comp_B
        );
        
            -- TwosComplement adder_result (5비트 결과)
    TwosComplement_Result: TwosComplement_5Bit
        port map (
            binary_in  => adder_result,
            complement => twos_comp_result
        );

        
    -- Clocked Process for State Update
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                abs_value <= 0;
                is_negative <= '0';
                tens <= "000";
                bcd_units <= "0000";    
                temp_bcd_A <= "00000";
                temp_bcd_B <= "00000";
            else
                abs_value <= abs_value_next;
                is_negative <= is_negative_next;
                tens <= tens_next;
                bcd_units <= bcd_units_next;

                -- A와 B의 변환 결과를 클락 엣지에서 업데이트
                if A(3) = '1' then
                    temp_bcd_A <= '1' & twos_comp_A; -- 2의 보수
                else
                    temp_bcd_A <= '0' & A;
                end if;

                if B(3) = '1' then
                    temp_bcd_B <= '1' & twos_comp_B; -- 2의 보수
                else
                    temp_bcd_B <= '0' & B;
                end if;
            end if;
        end if;
    end process;

    -- A B 변환 결과 
    A_bcd <= temp_bcd_A;
    B_bcd <= temp_bcd_B;

   
    process(A, B, adder_result, overflow)
        variable abs_temp        : integer := 0;               -- 임시 절대값 계산 변수
        variable inverted_result : std_logic_vector(4 downto 0);
        variable trimmed_result  : std_logic_vector(3 downto 0);
    begin
        -- 초기화
        abs_value_next <= 0;
        is_negative_next <= '0';
        tens_next <= "000";
        bcd_units_next <= "0000";

     -- Sel에 따른 연산 구분
    if Sel = "00" then
        -- 1) 양수 + 양수 덧셈
        if A(3) = '0' and B(3) = '0' then
            abs_temp := to_integer(unsigned(adder_result(3 downto 0))); -- MSB는 항상 0
            is_negative_next <= '0';

        -- 2) 음수 + 음수 덧셈
        elsif A(3) = '1' and B(3) = '1' then
            abs_temp := to_integer(unsigned(twos_comp_result(3 downto 0))); -- 2의 보수 처리
            is_negative_next <= '1'; -- 결과는 항상 음수
        -- 3) 양수 + 음수 덧셈 (CarryOut 여부로 판단함)
        else
            if adder_result(4) = '1' then -- CarryOut 존재(=>결과 양수)
                abs_temp := to_integer(unsigned(adder_result(3 downto 0))); -- CarryOut 무시
                is_negative_next <= '0';
            else -- CarryOut 없음(=>결과 음수)
                is_negative_next <= '1';
                abs_temp := to_integer(unsigned(twos_comp_result(3 downto 0)));
            end if;
        end if;

    -- Sel = 01 조건 추가 (뺄셈 연산)
    elsif Sel = "01" then
        if A(3) = '0' and B(3) = '1' then --양수 - 음수 
            abs_temp := to_integer(unsigned(adder_result(3 downto 0))); -- MSB는 항상 0
            is_negative_next <= '0';

        
        elsif A(3) = '1' and B(3) = '0' then --음수 - 양수
            is_negative_next <= '1'; -- 결과는 항상 음수
--            trimmed_result := not adder_result(3 downto 0); -- NOT 결과 (4비트)
            abs_temp := to_integer(unsigned(twos_comp_result(4 downto 0))); -- 2의 보수 처리
        
        else
            if adder_result(4) = '1' then -- CarryOut 존재(=>결과 양수)
                abs_temp := to_integer(unsigned(adder_result(3 downto 0))); -- CarryOut 무시
                is_negative_next <= '0';
            else -- CarryOut 없음(=>결과 음수)
                is_negative_next <= '1';
--                trimmed_result := not adder_result(3 downto 0); -- NOT 결과 (4비트)
                abs_temp := to_integer(unsigned(twos_comp_result(3 downto 0))); -- 2의 보수 처리
            end if;
        end if;
        
    end if;

        -- 절대값 계산
        abs_value_next <= abs(abs_temp);

        -- Tens 
        case abs(abs_temp) / 10 is
            when 0 => tens_next <= "000";
            when 1 => tens_next <= "001";
            when others => tens_next <= "000";
        end case;

        -- Units
        case abs(abs_temp) mod 10 is
            when 0 => bcd_units_next <= "0000";
            when 1 => bcd_units_next <= "0001";
            when 2 => bcd_units_next <= "0010";
            when 3 => bcd_units_next <= "0011";
            when 4 => bcd_units_next <= "0100";
            when 5 => bcd_units_next <= "0101";
            when 6 => bcd_units_next <= "0110";
            when 7 => bcd_units_next <= "0111";
            when 8 => bcd_units_next <= "1000";
            when 9 => bcd_units_next <= "1001";
            when others => bcd_units_next <= "0000"; -- 예외 
        end case;

        -- debug 
    end process;

    -- 최종 BCD : Sign Bit + Tens + Units
    bcd_out <= is_negative & tens & bcd_units;

end Behavioral;
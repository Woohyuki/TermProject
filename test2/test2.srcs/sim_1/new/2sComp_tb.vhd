library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Top_File_tb is
-- Testbench에는 포트가 없습니다.
end Top_File_tb;

architecture Behavioral of Top_File_tb is

    -- Component Declaration for Top_File
    component Top_File is
        port(
            Clk: in std_logic;
            Reset: in std_logic;
            Start: in std_logic;
            Done: out std_logic;
            A: in std_logic_vector(3 downto 0);
            B: in std_logic_vector(3 downto 0);
            Sel: in std_logic_vector(1 downto 0);
            a_to_g: out std_logic_vector(7 downto 0);
            an: out std_logic_vector(7 downto 0);
            Result: out std_logic_vector(4 downto 0);
            BCD_Result: out std_logic_vector(7 downto 0); -- 추가된 BCD 출력
            A_BCD: out std_logic_vector(4 downto 0); -- A의 BCD 변환 결과
            B_BCD: out std_logic_vector(4 downto 0); -- B의 BCD 변환 결과
            x_inter_out: out std_logic_vector(20 downto 0) -- 추가된 출력 포트
        );
    end component;

    -- Signals for Testbench
    signal Clk_tb: std_logic := '0';
    signal Reset_tb: std_logic := '0';
    signal Start_tb: std_logic := '0';
    signal Done_tb: std_logic;
    signal A_tb: std_logic_vector(3 downto 0) := "0000";
    signal B_tb: std_logic_vector(3 downto 0) := "0000";
    signal Sel_tb: std_logic_vector(1 downto 0) := "00";
    signal Result_tb: std_logic_vector(4 downto 0);
    signal BCD_Result_tb: std_logic_vector(7 downto 0); -- BCD 결과 신호 추가
    signal a_to_g_tb: std_logic_vector(7 downto 0);
    signal an_tb: std_logic_vector(7 downto 0);
    
    signal debug_signed_tb: integer; -- signed_value 디버깅 신호
    signal debug_abs_tb: integer;    -- abs_value 디버깅 신호
    signal A_BCD_tb : std_logic_vector(4 downto 0); -- A의 BCD 변환 결과
    signal B_BCD_tb : std_logic_vector(4 downto 0); -- B의 BCD 변환 결과
    signal x_inter_tb: std_logic_vector(20 downto 0);
    -- Debugging Signals
    signal debug_tens : std_logic_vector(2 downto 0);
    signal debug_units : std_logic_vector(3 downto 0);
    signal debug_sign : std_logic;
--    signal debug_signed_value : integer; -- signed_value 확인용
--    signal debug_abs_value    : integer; -- abs_value 확인용
    -- Clock Period
    constant clk_period: time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    UUT: Top_File
        port map(
            Clk => Clk_tb,
            Reset => Reset_tb,
            Start => Start_tb,
            Done => Done_tb,
            A => A_tb,
            B => B_tb,
            Sel => Sel_tb,
            a_to_g => a_to_g_tb,
            an => an_tb,
            Result => Result_tb,
            BCD_Result => BCD_Result_tb, -- 매핑 추가
            A_BCD => A_BCD_tb, -- A 변환 결과 연결
            B_BCD => B_BCD_tb,  -- B 변환 결과 연결
--            x_inter => x_inter_tb
            x_inter_out => x_inter_tb -- x_inter 값을 매핑
        );

    -- Clock Generation
    Clk_Process: process
    begin
        Clk_tb <= '0';
        wait for clk_period / 2;
        Clk_tb <= '1';
        wait for clk_period / 2;
    end process;
    
    
    -- Debugging Assignment
    debug_tens <= BCD_Result_tb(6 downto 4);
    debug_units <= BCD_Result_tb(3 downto 0);
    debug_sign <= BCD_Result_tb(7);
--    debug_signed_value <= signed_value;
--    debug_abs_value <= abs_value;
    

    -- Stimulus Process
Stimulus_Process: process
begin
    -- Reset the system
    Reset_tb <= '1';
    wait for clk_period;
    Reset_tb <= '0';
    
    -- 양수 + 양수 테스트 케이스
    -- Test Case 1: A = 3, B = 4, Result = 7
    A_tb <= "0011"; -- Decimal 3
    B_tb <= "0111"; -- Decimal 4
    Sel_tb <= "00"; -- Addition
    Start_tb <= '1';
    wait for clk_period;
    Start_tb <= '0';
    wait for 5 * clk_period;


    -- 음수 + 음수 테스트 케이스
    -- Test Case 4: A = -3, B = -4, Result = -7
    A_tb <= "1101"; -- Decimal -3 (2's complement)
    B_tb <= "1100"; -- Decimal -4 (2's complement)
    Sel_tb <= "00"; -- Addition
    Start_tb <= '1';
    wait for clk_period;
    Start_tb <= '0';
    wait for 5 * clk_period;

    -- Test Case 5: A = -6, B = -2, Result = -8
    A_tb <= "1001"; -- Decimal -8 (2's complement)
    B_tb <= "1110"; -- Decimal -2 (2's complement)
    Sel_tb <= "00"; -- Addition
    Start_tb <= '1';
    wait for clk_period;
    Start_tb <= '0';
    wait for 5 * clk_period;


    -- 양수 + 음수 테스트 케이스
    -- Case 1: Carry-out 발생 (결과 양수)
    -- Test Case 7: A = 6, B = -3, Result = 3
    A_tb <= "0110"; -- Decimal 6
    B_tb <= "1101"; -- Decimal -3 (2's complement)
    Sel_tb <= "00"; -- Addition
    Start_tb <= '1';
    wait for clk_period;
    Start_tb <= '0';
    wait for 5 * clk_period;

    -- Test Case 8: A = 5, B = -2, Result = 3
    A_tb <= "0101"; -- Decimal 5
    B_tb <= "1110"; -- Decimal -2 (2's complement)
    Sel_tb <= "00"; -- Addition
    Start_tb <= '1';
    wait for clk_period;
    Start_tb <= '0';
    wait for 5 * clk_period;

    -- Test Case 9: A = 7, B = -5, Result = 2
    A_tb <= "0111"; -- Decimal 7
    B_tb <= "1011"; -- Decimal -5 (2's complement)
    Sel_tb <= "00"; -- Addition
    Start_tb <= '1';
    wait for clk_period;
    Start_tb <= '0';
    wait for 5 * clk_period;

    -- Case 2: Carry-out 미발생 (결과 음수)
    -- Test Case 10: A = 3, B = -6, Result = -3
    A_tb <= "0011"; -- Decimal 3
    B_tb <= "1010"; -- Decimal -6 (2's complement)
    Sel_tb <= "00"; -- Addition
    Start_tb <= '1';
    wait for clk_period;
    Start_tb <= '0';
    wait for 5 * clk_period;

    -- Test Case 11: A = 2, B = -4, Result = -2
    A_tb <= "0010"; -- Decimal 2
    B_tb <= "1100"; -- Decimal -4 (2's complement)
    Sel_tb <= "01"; -- Addition
    Start_tb <= '1';
    wait for clk_period;
    Start_tb <= '0';
    wait for 5 * clk_period;

    -- Test Case 12: A = 1, B = -5, Result = -4
    A_tb <= "0001"; -- Decimal 1
    B_tb <= "1011"; -- Decimal -5 (2's complement)
    Sel_tb <= "01"; -- Addition
    Start_tb <= '1';
    wait for clk_period;
    Start_tb <= '0';
    wait for 5 * clk_period;
    
  -- Test Case 12: A = 1, B = -5, Result = -4
    A_tb <= "1011"; -- Decimal -5
    B_tb <= "0000"; -- Decimal 0
    Sel_tb <= "01"; -- Addition
    Start_tb <= '1';
    wait for clk_period;
    Start_tb <= '0';
    wait for 5 * clk_period;
    
      -- Test Case 12: A = 1, B = -5, Result = -4
    A_tb <= "0001"; -- Decimal 1
    B_tb <= "1000"; -- Decimal -8
    Sel_tb <= "01"; -- Addition
    Start_tb <= '1';
    wait for clk_period;
    Start_tb <= '0';
    wait for 5 * clk_period;
    
    A_tb <= "0001"; -- Decimal 1
    B_tb <= "0110"; -- Decimal 6
    Sel_tb <= "01"; -- Addition
    Start_tb <= '1';
    wait for clk_period;
    Start_tb <= '0';
    wait for 5 * clk_period;
    
    A_tb <= "1011"; -- Decimal -5
    B_tb <= "1100"; -- Decimal -4
    Sel_tb <= "01"; -- Addition
    Start_tb <= '1';
    wait for clk_period;
    Start_tb <= '0';
    wait for 5 * clk_period;
    
        A_tb <= "1000"; -- Decimal -8
    B_tb <= "1100"; -- Decimal -4
    Sel_tb <= "01"; -- Addition
    Start_tb <= '1';
    wait for clk_period;
    Start_tb <= '0';
    wait for 5 * clk_period;
    
    A_tb <= "1011"; -- Decimal -5
    B_tb <= "1000"; -- Decimal -8
    Sel_tb <= "01"; -- Addition
    Start_tb <= '1';
    wait for clk_period;
    Start_tb <= '0';
    wait for 5 * clk_period;
    
    A_tb <= "0001"; -- Decimal -5
    B_tb <= "0111"; -- Decimal -8
    Sel_tb <= "01"; -- Addition
    Start_tb <= '1';
    wait for clk_period;
    Start_tb <= '0';
    wait for 5 * clk_period;
    

    -- End of simulation
    wait;
    
end process;


end Behavioral;
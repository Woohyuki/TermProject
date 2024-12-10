library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity Top_File is
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
        Result: out std_logic_vector(4 downto 0); --결과 
        BCD_Result: out std_logic_vector(7 downto 0); -- BCD 변환
        A_BCD: out std_logic_vector(4 downto 0); -- A의 BCD 
        B_BCD: out std_logic_vector(4 downto 0); -- B의 BCD 
        x_inter_out: out std_logic_vector(20 downto 0) --출력 
    );
end Top_File;

architecture Behavioral of Top_File is


    -- User-defined Signals
    signal adder_result: std_logic_vector(4 downto 0); 
    signal b_complement: std_logic_vector(3 downto 0); 
    signal selected_b: std_logic_vector(3 downto 0);   -- Adder 입력될 B 
    signal selected_cin: std_logic;   -- Adder 전달 Cin 신호
    signal sign_a, sign_b, sign_c: std_logic;  --사용은 안함
    signal opcode : std_logic_vector(2 downto 0); 
    
    signal x_inter: std_logic_vector(20 downto 0); 
    
    signal overflow_signal : std_logic; 
    
--    signal BCD_Result : std_logic_vector(7 downto 0); 
--    signal A_BCD: std_logic_vector(4 downto 0); 
--    signal B_BCD: std_logic_vector(4 downto 0); 
    

    -- FourBitAdder 
    component FourBitAdder is
        port(
            A_4in: in std_logic_vector(3 downto 0);    -- Input A (4 bits)
            B_4in: in std_logic_vector(3 downto 0);    -- Input B (4 bits)
            Cin: in std_logic;                        -- Carry-in (추가)
            Addr_out: out std_logic_vector(4 downto 0); -- Output Sum (5 bits, including Carry-Out)
            Overflow  : out std_logic
        );
    end component;

  
    -- BinaryToBCD Component Declaration
    component BinaryToBCD is
        port(
            clk         : in std_logic;                      
            reset       : in std_logic;                     
            A           : in std_logic_vector(3 downto 0); 
            B           : in std_logic_vector(3 downto 0); 
            Sel         : in std_logic_vector(1 downto 0);
            adder_result : in std_logic_vector(4 downto 0); -- Adder 5비트
            overflow    : in std_logic;                      -- Overflow 신호
            bcd_out      : out std_logic_vector(7 downto 0); -- 최종 BCD 출력
            A_bcd       : out std_logic_vector(4 downto 0);  -- A Sign + BCD
            B_bcd       : out std_logic_vector(4 downto 0)  -- B Sign + BCD
        );
    end component;

    component myseven_segments is
        port(
            x: in std_logic_vector(20 downto 0);
            clk: in std_logic;
            clr: in std_logic;
            reset: in std_logic;
            a_to_g: out std_logic_vector(7 downto 0);
            an: out std_logic_vector(7 downto 0)
        );
    end component;

begin
    x_inter_out <= x_inter;
    
    -- OP Code
    process(Sel)
    begin
        case Sel is
            when "00" => opcode <= "100"; -- Add
            when "01" => opcode <= "101"; -- Sub
            when "10" => opcode <= "110"; -- Multi
            when others => opcode <= "111"; 
        end case;
    end process;

    -- B의 2's Complement 계산
    b_complement <= not B; 
    selected_b <= b_complement when Sel = "01" else B; -- Sel = 01일때 B 2'sC 
    selected_cin <= '1' when Sel = "01" else '0'; -- Sel = 01일때 Carry-in을 1로 

    -- Adder 
    Adder_Inst: FourBitAdder port map(
        A_4in => A,             
        B_4in => selected_b,             
        Cin => selected_cin,       
        Addr_out => adder_result, 
        overflow => overflow_signal 
    );
    Result <= adder_result; -- Result 신호와 Adder 결과 연결

    -- BinaryToBCD 
    BCD_Converter: BinaryToBCD port map(
        clk => Clk,
        reset => Reset,
        A => A,                       
        B => B,                      
        Sel => Sel,
        adder_result => adder_result, 
        overflow => overflow_signal, 
        bcd_out => BCD_Result,               
        A_bcd => A_BCD, 
        B_bcd => B_BCD
    );
        
-- -- x_inter 배정
--    process(BCD_Result, A_BCD, B_BCD, opcode)
--    begin
        
--        x_inter(20) <= A_BCD(4); 
        
--        x_inter(19 downto 16) <= A_BCD(3 downto 0); 
        
--        x_inter(15) <= B_BCD(4); 
       
--        x_inter(14 downto 11) <= B_BCD(3 downto 0); 
       
--        x_inter(10) <= BCD_Result(7); 
        
--        x_inter(9 downto 7) <= BCD_Result(6 downto 4); 
        
--        x_inter(6 downto 3) <= BCD_Result(3 downto 0); 
       
--        x_inter(2 downto 0) <= opcode; 
--    end process;
------------------------------

--x_inter(2 downto 0)<=Sel_out_vector;
--x_inter(6 downto 3)<=out_1; 
--x_inter(9 downto 7)<=out_2; 
--x_inter(10)<=sign_vector;
--x_inter(14 downto 11)<=mag_B;
--x_inter(15)<=sign_B_vector;
--x_inter(19 downto 16)<=mag_A;
--x_inter(20)<=sign_A_vector;

----------------------------




   
    X1: myseven_segments port map(
        x => x_inter,
        clk => Clk,
        clr => Start,
        reset => Reset,
        a_to_g => a_to_g,
        an => an
    );

end Behavioral;
                                                                                                                                                                              
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TwosComplement_4Bit is
    Port (
        binary_in  : in std_logic_vector(3 downto 0); -- 입력 값
        complement : out std_logic_vector(3 downto 0) -- 2의 보수 출력 값
    );
end TwosComplement_4Bit;

architecture Behavioral of TwosComplement_4Bit is

    component FULLADDER is
        Port(
            A : in STD_LOGIC;      -- 입력 A
            B : in STD_LOGIC;      -- 입력 B
            C_in : in STD_LOGIC;   -- Carry-In
            S : out STD_LOGIC;     -- Sum
            C_out : out STD_LOGIC  -- Carry-Out
        );
    end component;

    signal not_binary_in : std_logic_vector(3 downto 0); -- NOT 결과 저장
    signal carry : std_logic_vector(4 downto 0);        -- Carry 신호 (4비트)

begin

    -- NOT 연산
    not_binary_in <= not binary_in;

    -- Full Adder를 통해 2의 보수 계산
    FA0: FULLADDER port map(
        A => not_binary_in(0), 
        B => '0', 
        C_in => '1', -- Carry-In = 1
        S => complement(0), 
        C_out => carry(1)
    );

    FA1: FULLADDER port map(
        A => not_binary_in(1), 
        B => '0', 
        C_in => carry(1), 
        S => complement(1), 
        C_out => carry(2)
    );

    FA2: FULLADDER port map(
        A => not_binary_in(2), 
        B => '0', 
        C_in => carry(2), 
        S => complement(2), 
        C_out => carry(3)
    );

    FA3: FULLADDER port map(
        A => not_binary_in(3), 
        B => '0', 
        C_in => carry(3), 
        S => complement(3), 
        C_out => carry(4)
    );

end Behavioral;

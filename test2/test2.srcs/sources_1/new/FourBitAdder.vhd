library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FourBitAdder is
    Port (
        A_4in : in std_logic_vector(3 downto 0);          
        B_4in : in std_logic_vector(3 downto 0);  
        Cin    : in std_logic;   --for subtraction       
        Addr_out : out std_logic_vector(4 downto 0);
        overflow  : out std_logic    -- Overflow detect       
    );
end FourBitAdder;

architecture Behavioral of FourBitAdder is

    component FULLADDER
        Port(
            A : in std_logic;                           
            B : in std_logic;                            
            C_in : in std_logic;                         
            S : out std_logic;                           
            C_out : out std_logic                        
        );
    end component;
     
    signal C1, C2, C3, C4 : std_logic; 
    
begin
    FA_1 : FULLADDER port map(
        A => A_4in(0), B => B_4in(0), C_in => Cin,       
        S => Addr_out(0), C_out => C1
    );
    FA_2 : FULLADDER port map(
        A => A_4in(1), B => B_4in(1), C_in => C1,        
        S => Addr_out(1), C_out => C2
    );
    FA_3 : FULLADDER port map(
        A => A_4in(2), B => B_4in(2), C_in => C2,       
        S => Addr_out(2), C_out => C3
    );
    FA_4 : FULLADDER port map(
        A => A_4in(3), B => B_4in(3), C_in => C3,        
        S => Addr_out(3), C_out => C4         
    );
    -- Carry-out을 MSB로
    Addr_out(4) <= C4;

    -- Overflow감지용(아직 사용 X)
    overflow <= C3 xor C4;
end Behavioral;
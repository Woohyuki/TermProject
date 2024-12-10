----------------------------------------------------------------------------------
-- Company: 
-- Engineer: WoohyukKwon
-- 
-- Create Date: 2024/11/26 11:43:35
-- Design Name: 
-- Module Name: FULLADDER - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 1비트 Full Adder 구현
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FULLADDER is
    Port(
        A : in STD_LOGIC;
        B : in STD_LOGIC;
        C_in : in STD_LOGIC;
        S : out STD_LOGIC;
        C_out : out STD_LOGIC
    );
end FULLADDER;

architecture Behavioral of FULLADDER is

begin
    -- Sum 계산
    S <= A XOR B XOR C_in;
    -- Carry-Out 계산
    C_out <= (A AND B) or (C_in AND B) or (C_in AND A);

end Behavioral;

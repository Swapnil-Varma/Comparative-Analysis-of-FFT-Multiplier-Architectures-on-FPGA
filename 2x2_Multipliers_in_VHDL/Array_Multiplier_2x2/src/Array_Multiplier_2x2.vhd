library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Array_Multiplier_2x2 is
    Port (
        A : in  STD_LOGIC_VECTOR(1 downto 0);
        B : in  STD_LOGIC_VECTOR(1 downto 0);
        P : out STD_LOGIC_VECTOR(3 downto 0)
    );
end Array_Multiplier_2x2;

architecture Behavioral of Array_Multiplier_2x2 is

    signal pp0, pp1, pp2, pp3 : STD_LOGIC;
    signal c1 : STD_LOGIC;

begin

    -- Partial Products
    pp0 <= A(0) and B(0);
    pp1 <= A(1) and B(0);
    pp2 <= A(0) and B(1);
    pp3 <= A(1) and B(1);

    -- Output Bit 0
    P(0) <= pp0;

    -- Half Adder 1
    P(1) <= pp1 xor pp2;
    c1   <= pp1 and pp2;

    -- Half Adder 2
    P(2) <= pp3 xor c1;
    P(3) <= pp3 and c1;

end Behavioral;
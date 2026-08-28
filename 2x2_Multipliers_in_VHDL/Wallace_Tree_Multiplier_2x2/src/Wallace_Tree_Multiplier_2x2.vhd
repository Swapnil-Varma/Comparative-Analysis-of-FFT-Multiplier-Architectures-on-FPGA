library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity wallace_multiplier_2x2 is
    Port (
        A : in  STD_LOGIC_VECTOR(1 downto 0);
        B : in  STD_LOGIC_VECTOR(1 downto 0);
        P : out STD_LOGIC_VECTOR(3 downto 0)
    );
end wallace_multiplier_2x2;

architecture Behavioral of wallace_multiplier_2x2 is

signal pp0, pp1, pp2, pp3 : STD_LOGIC;
signal c1 : STD_LOGIC;

begin

-- Partial Product Generation
pp0 <= A(0) and B(0);
pp1 <= A(0) and B(1);
pp2 <= A(1) and B(0);
pp3 <= A(1) and B(1);

-- Wallace Tree Reduction
P(0) <= pp0;

P(1) <= pp1 xor pp2;

c1 <= pp1 and pp2;

P(2) <= pp3 xor c1;

P(3) <= pp3 and c1;

end Behavioral;
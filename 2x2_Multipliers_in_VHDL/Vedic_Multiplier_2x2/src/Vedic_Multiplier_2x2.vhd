library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vedic_multiplier_2x2 is
Port (  A : in STD_LOGIC_VECTOR(1 downto 0);
            B : in STD_LOGIC_VECTOR(1 downto 0);
            P : out STD_LOGIC_VECTOR(3 downto 0) );
   
end vedic_multiplier_2x2;

architecture Behavioral of vedic_multiplier_2x2 is

signal x0,x1,x2,x3 : STD_LOGIC;
signal c1 : STD_LOGIC;

begin

-- Vertical products
x0 <= A(0) and B(0);
x1 <= A(1) and B(0);
x2 <= A(0) and B(1);
x3 <= A(1) and B(1);

-- Output bits
P(0) <= x0;

P(1) <= x1 xor x2;

c1 <= x1 and x2;

P(2) <= x3 xor c1;

P(3) <= x3 and c1;

end Behavioral;
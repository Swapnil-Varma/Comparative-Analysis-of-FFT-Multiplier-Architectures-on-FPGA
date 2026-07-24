library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Modified_Booth_4x4_TB is
end Modified_Booth_4x4_TB;

architecture Behavioral of Modified_Booth_4x4_TB is

component Modified_Booth_4x4
Port(
    A : in  STD_LOGIC_VECTOR(3 downto 0);
    B : in  STD_LOGIC_VECTOR(3 downto 0);
    P : out STD_LOGIC_VECTOR(7 downto 0)
);
end component;

signal A : STD_LOGIC_VECTOR(3 downto 0);
signal B : STD_LOGIC_VECTOR(3 downto 0);
signal P : STD_LOGIC_VECTOR(7 downto 0);

begin

UUT : Modified_Booth_4x4
Port map(
    A => A,
    B => B,
    P => P
);

process
begin

for i in 0 to 15 loop

    for j in 0 to 15 loop

        A <= std_logic_vector(to_unsigned(i,4));
        B <= std_logic_vector(to_unsigned(j,4));

        wait for 10 ns;

    end loop;

end loop;

wait;

end process;

end Behavioral;
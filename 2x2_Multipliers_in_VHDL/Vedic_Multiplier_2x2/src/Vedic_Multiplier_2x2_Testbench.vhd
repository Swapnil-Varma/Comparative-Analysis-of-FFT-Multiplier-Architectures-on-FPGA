library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_vedic_multiplier_2x2 is
end tb_vedic_multiplier_2x2;

architecture Behavioral of tb_vedic_multiplier_2x2 is

component vedic_multiplier_2x2
Port(
    A : in STD_LOGIC_VECTOR(1 downto 0);
    B : in STD_LOGIC_VECTOR(1 downto 0);
    P : out STD_LOGIC_VECTOR(3 downto 0)
);
end component;

signal A : STD_LOGIC_VECTOR(1 downto 0);
signal B : STD_LOGIC_VECTOR(1 downto 0);
signal P : STD_LOGIC_VECTOR(3 downto 0);

begin

UUT : vedic_multiplier_2x2
Port map(
    A => A,
    B => B,
    P => P
);

stimulus : process
begin

A <= "00"; B <= "00";
wait for 10 ns;

A <= "00"; B <= "01";
wait for 10 ns;

A <= "00"; B <= "10";
wait for 10 ns;

A <= "00"; B <= "11";
wait for 10 ns;

A <= "01"; B <= "00";
wait for 10 ns;

A <= "01"; B <= "01";
wait for 10 ns;

A <= "01"; B <= "10";
wait for 10 ns;

A <= "01"; B <= "11";
wait for 10 ns;

A <= "10"; B <= "00";
wait for 10 ns;

A <= "10"; B <= "01";
wait for 10 ns;

A <= "10"; B <= "10";
wait for 10 ns;

A <= "10"; B <= "11";
wait for 10 ns;

A <= "11"; B <= "00";
wait for 10 ns;

A <= "11"; B <= "01";
wait for 10 ns;

A <= "11"; B <= "10";
wait for 10 ns;

A <= "11"; B <= "11";
wait for 10 ns;

wait;

end process;

end Behavioral;
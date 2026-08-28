library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_wallace_multiplier_2x2 is
end tb_wallace_multiplier_2x2;

architecture Behavioral of tb_wallace_multiplier_2x2 is

component wallace_multiplier_2x2
Port(
    A : in  STD_LOGIC_VECTOR(1 downto 0);
    B : in  STD_LOGIC_VECTOR(1 downto 0);
    P : out STD_LOGIC_VECTOR(3 downto 0)
);
end component;

signal A : STD_LOGIC_VECTOR(1 downto 0);
signal B : STD_LOGIC_VECTOR(1 downto 0);
signal P : STD_LOGIC_VECTOR(3 downto 0);

begin

UUT : wallace_multiplier_2x2
Port map(
    A => A,
    B => B,
    P => P
);

stim_proc : process
begin

for i in 0 to 3 loop
    for j in 0 to 3 loop

        A <= std_logic_vector(to_unsigned(i,2));
        B <= std_logic_vector(to_unsigned(j,2));

        wait for 10 ns;

    end loop;
end loop;

wait;

end process;

end Behavioral;
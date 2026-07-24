library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Modified_Booth_4x4 is
    Port(
        A : in  STD_LOGIC_VECTOR(3 downto 0);
        B : in  STD_LOGIC_VECTOR(3 downto 0);
        P : out STD_LOGIC_VECTOR(7 downto 0)
    );
end Modified_Booth_4x4;

architecture Behavioral of Modified_Booth_4x4 is
begin

process(A,B)

    variable M      : signed(7 downto 0);
    variable PP0    : signed(7 downto 0);
    variable PP1    : signed(7 downto 0);
    variable Result : signed(7 downto 0);

    variable G0 : STD_LOGIC_VECTOR(2 downto 0);
    variable G1 : STD_LOGIC_VECTOR(2 downto 0);

begin

    M := resize(signed('0' & A),8);

    -- Booth Groups
    G0 := B(1) & B(0) & '0';
    G1 := B(3) & B(2) & B(1);

    ---------------------------------------------------
    -- Group 0
    ---------------------------------------------------

    case G0 is

        when "000" | "111" =>
            PP0 := to_signed(0,8);

        when "001" | "010" =>
            PP0 := M;

        when "011" =>
            PP0 := shift_left(M,1);

        when "100" =>
            PP0 := -shift_left(M,1);

        when "101" | "110" =>
            PP0 := -M;

        when others =>
            PP0 := to_signed(0,8);

    end case;

    ---------------------------------------------------
    -- Group 1
    ---------------------------------------------------

    case G1 is

        when "000" | "111" =>
            PP1 := to_signed(0,8);

        when "001" | "010" =>
            PP1 := shift_left(M,2);

        when "011" =>
            PP1 := shift_left(M,3);

        when "100" =>
            PP1 := -shift_left(M,3);

        when "101" | "110" =>
            PP1 := -shift_left(M,2);

        when others =>
            PP1 := to_signed(0,8);

    end case;

    Result := PP0 + PP1;

    P <= std_logic_vector(Result);

end process;

end Behavioral;
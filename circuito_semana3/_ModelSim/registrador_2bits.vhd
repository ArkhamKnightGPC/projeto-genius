library ieee;
use ieee.std_logic_1164.all;

entity registrador_2bits is
  port (
    clock:  in  std_logic;
    clear:  in  std_logic;
    enable: in  std_logic;
    D:      in  std_logic_vector(1 downto 0);
    Q:      out std_logic_vector(1 downto 0)
  );
end entity;

architecture arch of registrador_2bits is
  signal IQ: std_logic_vector(1 downto 0);
begin
    process(clock, clear, IQ)
    begin
      if (clear = '1') then IQ <= (others => '0');
      elsif (clock'event and clock='1') then
        if (enable='1') then IQ <= D; end if;
      end if;
    end process;

    Q <= IQ;
end architecture;
------------------------------------------------------------------
-- Arquivo   : registrador_4bits.vhd
-- Projeto   : Experiencia 05 - Consideracoes de Projeto com FPGA
------------------------------------------------------------------
-- Descricao : registrador de 4 bits 
--             com clear assincrono e enable
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     31/01/2020  1.0     Edson Midorikawa  criacao
------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity registrador_4bits is
  port (
    clock:  in  std_logic;
    clear:  in  std_logic;
    enable: in  std_logic;
    D:      in  std_logic_vector(3 downto 0);
    Q:      out std_logic_vector(3 downto 0)
  );
end entity;

architecture arch of registrador_4bits is
  signal IQ: std_logic_vector(3 downto 0);
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
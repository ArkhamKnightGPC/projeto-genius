----------------------------------------------------------------
-- Arquivo   : hexa7seg.vhd
-- Projeto   : Experiencia 01 - Primeiro Contato com VHDL
----------------------------------------------------------------
-- Descricao : decodificador hexadecimal para 
--             display de 7 segmentos 
-- 
-- entrada: hexa - codigo binario de 4 bits hexadecimal
-- saida:   sseg - codigo de 7 bits para display de 7 segmentos
----------------------------------------------------------------
-- dica de uso: mapeamento para displays da placa DE0-CV
--              bit 6 mais significativo é o bit a esquerda
--              p.ex. sseg(6) -> HEX0[6] ou HEX06
----------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     29/12/2020  1.0     Edson Midorikawa  criacao
----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity hexa7seg is
    port (
        hexa : in  std_logic_vector(3 downto 0);
        sseg : out std_logic_vector(6 downto 0)
    );
end hexa7seg;

architecture comportamental of hexa7seg is
begin

  sseg <= "1000000" when hexa="0000" else -- 0  ->  #40 
          "1111001" when hexa="0001" else -- 1  ->  #79 
          "0100100" when hexa="0010" else -- 2  ->  #24
          "0110000" when hexa="0011" else -- 3  ->  #30
          "0011001" when hexa="0100" else -- 4  ->  #19
          "0010010" when hexa="0101" else -- 5  ->  #12
          "0000010" when hexa="0110" else -- 6  ->  #02
          "1111000" when hexa="0111" else -- 7  ->  #78
          "0000000" when hexa="1000" else -- 8  ->  #00
          "0010000" when hexa="1001" else -- 9  ->  #10
          "0001000" when hexa="1010" else -- A  ->  #08
          "0000011" when hexa="1011" else -- B  ->  #03
          "1000110" when hexa="1100" else -- C  ->  #46
          "0100001" when hexa="1101" else -- D  ->  #21
          "0000110" when hexa="1110" else -- E  ->  #06
          "0001110" when hexa="1111" else -- F  ->  #0D
          "1111111";

end comportamental;



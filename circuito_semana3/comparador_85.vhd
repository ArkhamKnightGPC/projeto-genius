library ieee;
use ieee.std_logic_1164.all;

entity comparador_85 is
  port (
    --numero binario A de 4 bits
    i_A3   : in  std_logic;
    i_A2   : in  std_logic;
    i_A1   : in  std_logic;
    i_A0   : in  std_logic;

    --numero binario B de 4 bits
    i_B3   : in  std_logic;
    i_B2   : in  std_logic;
    i_B1   : in  std_logic;
    i_B0   : in  std_logic;

    --entradas de cascateamento
    -- representam conclusoes realizadas em bits mais a esquerda
    i_AGTB : in  std_logic;
    i_ALTB : in  std_logic;
    i_AEQB : in  std_logic;

    --saidas
    --representam conclusoes realizadas com o circuito
    o_AGTB : out std_logic;
    o_ALTB : out std_logic;
    o_AEQB : out std_logic
  );
end entity comparador_85;

architecture dataflow of comparador_85 is

  --sinais auxiliares
  signal agtb : std_logic;
  signal aeqb : std_logic;
  signal altb : std_logic;
begin
  --comparamos a partir do bit mais a direita
  -- no momento em que os bits de A e B sao diferentes podemos concluir
  --qual o maior. se A3 = 1 e B3 = 0, concluimos que A > B
  --e entao A2 e B2 nao importam. Mas se A3 = B3, a mesma logica se 
  --segue, so que para o A2 e B2.
  agtb <= (i_A3 and not(i_B3)) or
          (not(i_A3 xor i_B3) and i_A2 and not(i_B2)) or
          (not(i_A3 xor i_B3) and not(i_A2 xor i_B2) and i_A1 and not(i_B1)) or
          (not(i_A3 xor i_B3) and not(i_A2 xor i_B2) and not(i_A1 xor i_B1) and i_A0 and not(i_B0));
  
  --os numeros so podem ser iguais se todos os bits forem iguais
  aeqb <= not((i_A3 xor i_B3) or (i_A2 xor i_B2) or (i_A1 xor i_B1) or (i_A0 xor i_B0));
  
  --se A nao e maior ou igual a B, entao A < B
  altb <= not(agtb or aeqb);
  
  -- saidas
  --o que importe e o mait mais a direite onde A e B diferem
  o_AGTB <= agtb or (aeqb and (not(i_AEQB) and not(i_ALTB)));
  o_ALTB <= altb or (aeqb and (not(i_AEQB) and not(i_AGTB)));
  
  --A e igual a B somente se todos os bits forem iguais e os 4 bits processados tambem
  o_AEQB <= aeqb and i_AEQB;
  
end architecture dataflow;
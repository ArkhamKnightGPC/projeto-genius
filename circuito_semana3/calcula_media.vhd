library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity calcula_media is
   port (
        clock 		: in  std_logic;
        clr   		: in  std_logic; -- ativo em alto
        enable		: in  std_logic; -- ativo em alto
		  D			: in  std_logic_vector (13 downto 0); -- tempo de reacao da mais nova jogada
        Q     		: out std_logic_vector (13 downto 0) --media das entradas fornecidas
   );
end entity;

architecture comportamental of calcula_media is
  signal nova_jogada, media: integer range 0 to 4999;
  signal soma: integer range 0 to 800000;
  signal num_jogadas: integer range 0 to 153;
  constant um : integer := 1;
begin

	nova_jogada <= to_integer(unsigned(D));
	
	asyncreset: process (clr, clock, enable) -- async reset
	begin
		if clr = '1'  then
			soma <= 0;
			num_jogadas <= 0;
			media <= 0;
		elsif clock'event and clock='1' and enable='1' then
			soma <= soma + nova_jogada;
			num_jogadas <= num_jogadas + um;
			media <= soma/num_jogadas;
      else
			soma <= soma;
			num_jogadas <= num_jogadas;
			media <= media;
      end if;
	end process;
	
	Q <= std_logic_vector(to_unsigned(media, Q'length));
end architecture;
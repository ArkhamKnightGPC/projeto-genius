library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comparador_8bits is
  port (
    --numero binario A de 8 bits
    i_A : in std_logic_vector(7 downto 0);

    --numero binario B de 8 bits
    i_B : in std_logic_vector(7 downto 0);

    --saidas
    --representam conclusoes realizadas com o circuito
    iguais : out std_logic
  );
end entity comparador_8bits;

architecture dataflow of comparador_8bits is

signal A, B: integer range 0 to 4999;

begin
	A <= to_integer(unsigned(i_A));
	B <= to_integer(unsigned(i_B));
	process(i_A, i_B)
	begin
		if( A+1 = B)
			then iguais<='1';
		else iguais<='0';
		end if;
	end process;
  
  
end architecture dataflow;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity timerTotal is
   port (
        clock 		: in  std_logic;
		  nivel		: in  std_logic_vector(1 downto 0);
        clr   		: in  std_logic; -- ativo em alto
        enable		: in  std_logic;
        timeout	: out std_logic 
   );
end entity;

architecture comportamental of timerTotal is
  signal lim, IQ: integer range 0 to 610000; --limite do nivel selecionado
begin
	
	with nivel select
		lim <= 35000  when "00", --total de 14 jogadas
				 110000 when "01", --total de 44 jogadas
				 225000 when "10", --total de 90 jogadas
				 380000 when others; --total de 152 jogadas

	asyncreset: process (clr, clock,IQ,enable) -- async reset
	begin
		if clr = '1'  then
			IQ <= 0;
		elsif clock'event and clock='1' then
			if IQ=lim then
				IQ <= lim;
			elsif enable='1' then
				IQ <= IQ + 1; 
			end if;
      else
			IQ <= IQ;
      end if;
		if(IQ = lim) then
			timeout <= '1';
		else
			timeout <= '0';
		end if;
	end process;
	
end architecture;
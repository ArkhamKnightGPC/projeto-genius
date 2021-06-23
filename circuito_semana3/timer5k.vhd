library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity timer5k is
   port (
        clock 		: in  std_logic;
        clr   		: in  std_logic; -- ativo em alto
        enable		: in  std_logic;
        Q     		: out std_logic_vector (13 downto 0);
        timeout	: out std_logic 
   );
end entity;

architecture comportamental of timer5k is
  signal IQ: integer range 0 to 4999;
begin
	asyncreset: process (clr, clock,IQ,enable) -- async reset
	begin
		if clr = '1'  then
			IQ <= 0;
		elsif clock'event and clock='1' then
			if IQ=4999 then
				IQ <= 4999;
			elsif enable='1' then
				IQ <= IQ + 1; 
			end if;
      else
			IQ <= IQ;
      end if;
	end process;
	
	with IQ select 
		timeout <= 	'1' when 4999, 
						'0' when others;
	Q <= std_logic_vector(to_unsigned(IQ, Q'length));
end architecture;
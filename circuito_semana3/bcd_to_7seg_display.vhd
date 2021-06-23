LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity bcd_to_7seg_display is
	port(
		bcd				:	in		std_logic_vector(3 downto 0);
		busy				:	in		std_logic;
		display_7seg	:	OUT	std_logic_vector(6 downto 0));	--outputs to seven segment display
end bcd_to_7seg_display;

architecture arch_bcd of bcd_to_7seg_display is
begin
	process(busy, bcd)
	begin
		if busy='1' then
			display_7seg <= "1111111"; --se nao converteu ainda, apaga tudo
		elsif bcd="0000" then
			display_7seg <= "1000000"; --0
		elsif bcd="0001" then
			display_7seg <= "1111001"; --1
		elsif bcd="0010" then
			display_7seg <= "0100100"; --2
		elsif bcd="0011" then
			display_7seg <= "0110000"; --3
		elsif bcd="0100" then
			display_7seg <= "0011001"; --4
		elsif bcd="0101" then
			display_7seg <= "0010010"; --5
		elsif bcd="0110" then
			display_7seg <= "0000010"; --6
		elsif bcd="0111" then
			display_7seg <= "1111000"; --7
		elsif bcd="1000" then
			display_7seg <= "0000000"; --8
		elsif bcd="1001" then
			display_7seg <= "0010000"; --1
		else
			display_7seg <= "1111111"; --nada quando nao tem digito valido
		end if;
	end process;
end architecture;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity contador_tempos is
   port (
        clock : in  std_logic;
        clr   : in  std_logic;
        ld    : in  std_logic;
        ent   : in  std_logic;
        enp   : in  std_logic;
        D     : in  std_logic_vector (7 downto 0);
		  limite: in  std_logic_vector (7 downto 0);
        Q     : out std_logic_vector (7 downto 0);
        rco   : out std_logic 
   );
end contador_tempos;

architecture comportamental of contador_tempos is
  signal IQ: integer range 0 to 255;
  signal int_limite : integer range 0 to 255;
begin
	
	-- convertemos para integer para realizar comparacao com IQ
	int_limite <= to_integer(unsigned(limite));
  
  process (clock,IQ,ent,int_limite)
  begin

    if clock'event and clock='1' then
      if clr='0' then   IQ <= 0; 
      elsif ld='0' then IQ <= to_integer(unsigned(D));
      elsif ent='1' and enp='1' then
		  --paramos de contar quando atingimos limite para deixar rco ativado
        if IQ=int_limite then   IQ <= int_limite; 
        else            IQ <= IQ + 1; 
        end if;
      else              IQ <= IQ;
      end if;
    end if;
    -- assim que atingimos limite atual, encerramos contagem
    if IQ=int_limite then rco <= '1'; 
    else                      rco <= '0'; 
    end if;

    Q <= std_logic_vector(to_unsigned(IQ, Q'length));

  end process;
end comportamental;
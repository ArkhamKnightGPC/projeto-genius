library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_bit.all;

entity tb_semana4 is
end entity;

architecture tb of tb_semana4 is
	component circuito_semana3 is
		port(
	clock		: in  std_logic;
	reset		: in  std_logic;
	jogar		: in  std_logic;
	repetir	: in  std_logic; --NOVIDADE
	botoes	: in  std_logic_vector(3 downto 0);
	nivel		: in  std_logic_vector(1 downto 0); --NOVIDADE
	leds		: out std_logic_vector(3 downto 0);
	espera	: out std_logic; --NOVIDADE
	fim		: out std_logic;
	acertou	: out std_logic;
	errou		: out std_logic;
	-- Usamos quatro display HEX para mostrar tempo
	db_tempo_reacao0: out std_logic_vector(6 downto 0);--NOVIDADE HEX 0
	db_tempo_reacao1: out std_logic_vector(6 downto 0);--NOVIDADE HEX 1
	db_tempo_reacao2: out std_logic_vector(6 downto 0);--NOVIDADE HEX 2
	db_tempo_reacao3: out std_logic_vector(6 downto 0);--NOVIDADE HEX 3
	
	--LEDS 4 e 5
	db_timeout: out std_logic;
	db_timeout_total: out std_logic;
	
	--HEX4 e HEX5
	mensagem0:		out std_logic_vector(6 downto 0);
	mensagem1: 		out std_logic_vector(6 downto 0) -- HEX 5
);
	end component;
	
	type arranjo_memoria is array(0 to 15) of std_logic_vector(3 downto 0);
	signal memoria : arranjo_memoria := 
		(
			"0001",
			"0010",
			"0100",
			"1000",
			"0100",
			"0010",
			"0001",
			"0001",
			"0010",
			"0010",
			"0100",
			"0100",
			"1000",
			"1000",
			"0001",
			"0100" 
		);
  
	constant TbPeriod 		: time := 1000 ns;
	signal TbSimulation 		: std_logic := '0';
	signal TbButtonOnWait	: integer := 10;
	signal TbButtonOffWait	: integer := 103;
	signal TbZero				: std_logic_vector(3 downto 0) := "0000";

	signal clock, reset, jogar, fim, acertou, errou : std_logic;
	signal botoes, leds 	: std_logic_vector(3 downto 0);
	signal nivel : std_logic_vector(1 downto 0);
	signal repetir, espera, db_timeout, db_timeout_total : std_logic;
	signal db_tempo_reacao0, db_tempo_reacao1, db_tempo_reacao2, db_tempo_reacao3, mensagem0, mensagem1 : std_logic_vector(6 downto 0);

begin
	DUT: circuito_semana3 port map 
	(
		--ENTRADAS
		clock				=>			clock,
		reset				=>			reset,
		jogar				=>			jogar,
		repetir			=>			repetir,
		botoes			=>			botoes,
		nivel				=>			nivel,
		--SAIDAS
		leds				=>			leds,
		espera			=>			espera,
		fim				=>			fim,
		acertou			=>			acertou,
		errou				=>			errou,
		--SINAIS DE DEPURAÇÃO
		db_tempo_reacao0	=>		db_tempo_reacao0,
		db_tempo_reacao1	=>		db_tempo_reacao1, 
		db_tempo_reacao2	=>		db_tempo_reacao2, 
		db_tempo_reacao3	=>		db_tempo_reacao3, 
		db_timeout		=>		db_timeout,
		db_timeout_total	=> 		db_timeout_total,
		mensagem0		=>		mensagem0,
		mensagem1		=>		mensagem1
	);
	
	clock <= not clock after TbPeriod/2 when TbSimulation = '1' else '0';
	stimuli: process
	begin
		TbSimulation <= '1';
			
			reset <='0';
			jogar <='0';
			repetir <='0';
			botoes <= "0000";
			nivel <= "10"; --ate 12 jogadas


			-- Condicoes iniciais
			reset <= '1';
			wait for 1000 ns;
			reset <= '0';
			wait for 1000 ns;
			
			--Inicio do jogo
			jogar <= '1';
			wait for 1000 ns;
			jogar <= '0';
			wait for 1000 ns;
			
			for i in 0 to 12 loop
				for j in 0 to i loop
					wait for 4000*TbPeriod;
					botoes <= memoria(j);
					wait for TbButtonOnWait * TbPeriod;
					botoes <= TbZero;
					wait for TbButtonOffWait * TbPeriod;
				end loop;
			end loop;
			--ate aqui tudo certo
			--estamos na ultima rodada
			for i in 0 to 12 loop
				wait for 4001*TbPeriod;
			    	botoes <= memoria(i);
				wait for TbButtonOnWait * TbPeriod;
				botoes <= TbZero;
				wait for TbButtonOffWait * TbPeriod;
			end loop;
			
			--note que nao excedemos 5000 em nenhuma jogada, e acertamos todas, mas vamos perder por timeout_total
			
		TbSimulation <= '0';
		wait;
	end process;
		
end architecture;
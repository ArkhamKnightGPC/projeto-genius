library ieee;
use ieee.std_logic_1164.all;

entity circuito_semana3 is
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
end entity;


architecture arch_semana3 of circuito_semana3 is

component fluxo_dados
		port(
		clock: 				in  std_logic;
      zerac: 				in  std_logic;
		zeraLim: 			in  std_logic;
      contac: 				in  std_logic;
      escrevem: 			in  std_logic;
		repetir:				in  std_logic;
		nivel:				in  std_logic_vector(1 downto 0);
		enable_nivel:		in  std_logic;
      chaves: 				in  std_logic_vector(3 downto 0);
		escreve_tempo:		in  std_logic;
		enable_rep:			in	 std_logic; --NOVIDADE
		reset_rep:			in  std_logic; --NOVIDADE
		mostra_media:		in  std_logic; --NOVIDADE
		zeraR: 				in  std_logic;
		enableR: 			in  std_logic;
		incrementaLimite: in  std_logic;
		treset:				in  std_logic;
		tenable:				in  std_logic;
		pronto_UC:			in  std_logic;
		zera_tempo:			in  std_logic;
		conta_jogadas:		in  std_logic;
		timeout:				out std_logic;
		timeout_rep:		out std_logic; --NOVIDADE
		timeout_total:		out std_logic; --NOVIDADE
		limiteMaximo: 		out std_logic;
      igual: 				out std_logic;
      fimc: 				out std_logic;
		db_tem_jogada: 	out std_logic;
		jogada_feita: 		out std_logic;
		repetir_edge:		out std_logic;
		acabou_repetir:   out std_logic;
		saida_tempo:		out std_logic_vector(13 downto 0);
      db_contagem: 		out std_logic_vector(3 downto 0);
      db_memoria: 		out std_logic_vector(3 downto 0);
		db_limite:			out std_logic_vector(3 downto 0);
		db_nivel:			out std_logic_vector(3 downto 0);
		db_jogada:			out std_logic_vector(3 downto 0)
	);
end component;

component unidade_controle
	port( 
		clock:     				in  std_logic; 
		reset:     				in  std_logic; 
		jogar:   				in  std_logic;
		repetir_edge:			in  std_logic;
		fim:       				in  std_logic;
		igual: 					in  std_logic;
		jogada: 					in	 std_logic;
		limiteMaximo:			in  std_logic;
		timeout:					in  std_logic;
		acabou_repetir:   	in  std_logic;
		timeout_rep:			in  std_logic;--NOVIDADE
		timeout_total:			in  std_logic;--NOVIDADE
		treset:					out std_logic;
		tenable:					out std_logic;
		enable_rep:				out std_logic;--NOVIDADE
		reset_rep:				out std_logic;--NOVIDADE
		mostra_media:			out std_logic;--NOVIDADE
		esta_jogando:			out std_logic;
		escreve:					out std_logic;
		zera:      				out std_logic;
		conta:     				out std_logic;
		pronto:    				out std_logic;
		registra:				out std_logic;
		espera:					out std_logic;
		enable_nivel:			out std_logic;
		escreve_tempo:			out std_logic;
		zera_tempo:				out std_logic;
		conta_jogadas:			out std_logic;
		acertou: 				out std_logic;
		errou: 					out std_logic;
		incrementaLimite: 	out std_logic;
		zeraLim: 				out std_logic;
		db_estado: 				out std_logic_vector(3 downto 0);
		mensagem0:				out std_logic_vector(6 downto 0);
		mensagem1:				out std_logic_vector(6 downto 0)
	);
end component;

component hexa7seg
    port (
        hexa : in  std_logic_vector(3 downto 0);
        sseg : out std_logic_vector(6 downto 0)
    );
end component;

--NOVIDADES: converter numero para exibir em displays HEX
component binary_to_bcd_digit
	port(
		clk		:	in			std_logic;								--system clock
		reset_n	:	in			std_logic;								--active low asynchronous reset
		ena		:	in			std_logic;								--activate operation
		binary	:	in			std_logic;								--bit shifted into digit
		c_out		:	buffer	std_logic;								--carry out shifted to next larger digit
		bcd		:	buffer	std_logic_vector(3 downto 0));	--resulting BCD output
end component;

component binary_to_bcd
	generic(
		bits		:	INTEGER := 10;		--size of the binary input numbers in bits
		digits	:	INTEGER := 3);		--number of BCD digits to convert to
	port(
		clk		:	in		std_logic;											--system clock
		reset_n	:	in		std_logic;											--active low asynchronus reset
		ena		:	in		std_logic;											--latches in new binary number and starts conversion
		binary	:	in		std_logic_vector(bits-1 downto 0);			--binary number to convert
		busy		:	out	std_logic;											--indicates conversion in progress
		bcd		:	out	std_logic_vector(digits*4-1 downto 0));	--resulting BCD number
end component;

component bcd_to_7seg_display
	port(
		bcd				:	in		std_logic_vector(3 downto 0);
		busy				:  in		std_logic;
		display_7seg	:	out	std_logic_vector(6 downto 0));
end component;

signal not_reset			: std_logic;
signal fimc_FD 			: std_logic;
signal conta_UC 			: std_logic;
signal zera_UC 			: std_logic;
signal igual 				: std_logic;
signal tudo_certo 		: std_logic;
signal jogada_feita_FD	: std_logic;
signal enable				: std_logic;
signal final_UC 			: std_logic;
signal registra_UC		: std_logic;
signal aux					: std_logic_vector(3 downto 0);
signal jogada_FD 			: std_logic_vector(3 downto 0);
signal contagem 			: std_logic_vector(3 downto 0);
signal memoria 			: std_logic_vector(3 downto 0);
signal estado 				: std_logic_vector(3 downto 0);
signal jogada				: std_logic_vector(3 downto 0);

signal limite_FD : std_logic_vector (3 downto 0);
signal limMax_FD : std_logic;
signal incLim_UC, conta_jogadas : std_logic;
signal zeraLim   : std_logic;
signal escrevem, acabou_repetir  : std_logic;
signal errou_UC, fim_UC  : std_logic;
signal timeout, treset, tenable, enable_nivel, escreve_tempo, zera_tempo : std_logic;
signal saida_tempo : std_logic_vector(13 downto 0);
signal repetir_edge : std_logic;

--NOVIDADES
--signal display_HEX0, display_HEX1, display_HEX2, display_HEX3: std_logic_vector(3 downto 0);
signal saida_BCD : std_logic_vector(15 downto 0);
signal enable_rep, reset_rep, timeout_rep, busy_BCD, mostra_media, timeout_total, esta_jogando: std_logic;

begin

G1: fluxo_dados port map
	(
		clock 				=> clock,
		zerac 				=> zera_UC,
		zeraLim        	=> zeraLim,
		contac 				=> conta_UC,
		escrevem 			=> escrevem,
		repetir				=> repetir,
		nivel					=> nivel,
		enable_nivel		=> enable_nivel,
		escreve_tempo		=> escreve_tempo,
		enable_rep			=> enable_rep,--NOVIDADE
		reset_rep			=> reset_rep,--NOVIDADE
		mostra_media		=>	mostra_media, --NOVIDADE
		chaves 				=> botoes,
		zeraR 				=> zeraLim, 
		enableR 				=> registra_UC, 
		incrementaLimite 	=> incLim_UC,
		limiteMaximo   	=> limMax_FD,
		treset				=> treset,
		tenable			  	=> tenable,
		pronto_UC			=> fim_UC,
		zera_tempo			=> zera_tempo,
		conta_jogadas     => conta_jogadas,
		timeout				=> timeout,
		timeout_rep			=> timeout_rep,--NOVIDADE
		timeout_total		=> timeout_total,--NOVIDADE
		igual 				=> igual, 
		fimc 					=> fimc_FD,
		db_tem_jogada 		=> open,
		jogada_feita		=> jogada_feita_FD,
		repetir_edge		=> repetir_edge,
		acabou_repetir		=> acabou_repetir,
		saida_tempo			=> saida_tempo,
		db_contagem 		=> contagem,
		db_memoria 			=> memoria,
		db_limite      	=> limite_FD,
		db_jogada 			=>	jogada_FD
	);
	
G2: unidade_controle port map
	(
		clock 				=> clock,
		reset 				=> reset,
		jogar 				=> jogar,
		repetir_edge		=> repetir_edge,
		fim 					=> fimc_FD,
		igual 				=> igual,
		jogada 				=> jogada_feita_FD,
		limiteMaximo		=> limMax_FD,
		timeout				=> timeout,
		acabou_repetir		=> acabou_repetir,
		timeout_rep			=> timeout_rep,--NOVIDADE
		timeout_total		=> timeout_total,
		treset				=> treset,
		tenable				=> tenable,
		enable_rep			=> enable_rep,--NOVIDADE
		reset_rep			=> reset_rep,--NOVIDADE
		mostra_media		=> mostra_media,--NOVIDADE
		esta_jogando		=> esta_jogando,--NOVIDADE
		escreve				=> escrevem,
		zera 					=> zera_UC,
		conta 				=> conta_UC,
		pronto 				=> fim_UC,
		registra 			=> registra_UC,
		espera 				=> espera,
		acertou 				=> acertou,
		errou 				=> errou_UC,
		incrementaLimite	=> incLim_UC,
		enable_nivel		=> enable_nivel,
		escreve_tempo		=> escreve_tempo,
		zera_tempo			=> zera_tempo,
		conta_jogadas     => conta_jogadas,
		zeraLim 				=> zeraLim,
		db_estado 			=> estado,
		mensagem0			=> mensagem0,
		mensagem1			=> mensagem1
	);
	
--aux <= "00"&saida_tempo(13 downto 12);

--G4: hexa7seg port map(hexa=>saida_tempo(3 downto 0), 	sseg=>db_tempo_reacao0);
--G5: hexa7seg port map(hexa=>saida_tempo(7 downto 4), 	sseg=>db_tempo_reacao1);
--G6: hexa7seg port map(hexa=>saida_tempo(11 downto 8), 	sseg=>db_tempo_reacao2);
--G7: hexa7seg port map(hexa=>aux, 	sseg=>db_tempo_reacao3);

not_reset <= not reset;

G3: binary_to_bcd
	generic map(
		bits		=>		14,		 --size of the binary input numbers in bits
		digits	=>		4)		 --number of BCD digits to convert to
	port map(
		clk		=> clock,			 --system clock
		reset_n	=>	'1',		 --active low asynchronus reset
		ena		=> '1',			 --latches in new binary number and starts conversion
		binary	=> saida_tempo, --binary number to convert
		busy		=> busy_BCD,--indicates conversion in progress
		bcd		=> saida_BCD);  --resulting BCD number
	
G4: bcd_to_7seg_display port map(bcd=>saida_BCD(3 downto 0), busy=>esta_jogando, display_7seg=>db_tempo_reacao0);
G5: bcd_to_7seg_display port map(bcd=>saida_BCD(7 downto 4), busy=>esta_jogando, display_7seg=>db_tempo_reacao1);
G6: bcd_to_7seg_display port map(bcd=>saida_BCD(11 downto 8), busy=>esta_jogando, display_7seg=>db_tempo_reacao2);
G7: bcd_to_7seg_display port map(bcd=>saida_BCD(15 downto 12), busy=>esta_jogando, display_7seg=>db_tempo_reacao3);

leds <= jogada_FD;
errou <= errou_UC;
fim <= fim_UC;
db_timeout <= timeout;
db_timeout_total <= timeout_total;

end architecture;
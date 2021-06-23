library ieee;
use ieee.std_logic_1164.all;

entity unidade_controle is 
	port ( 
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
		esta_jogando:			out std_logic;--NOVIDADE
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
end entity;

architecture fsm of unidade_controle is
  type t_estado is (Aguarda, --estado inicial
						  Prepara, --inicia circuito para condicoes iniciais
						  InicioCiclo, --inicio de novo ciclo, aguardando
						  EsperaJogada, --esperado edge_detector detectar jogada
						  ArmazenaJogada, --armazena jogada
						  ComparaJogada, --compara jogada com memoria
						  AcertouJogada,
						  CicloCerto,--chegamos no limite atual
						  TerminouCerto,
						  TerminouErrado,
						  AumentaLimite, --aumentar jogadas para proxima rodada
						  EsperaEscrita, --espera escrita da jogada
						  ResetContador,
						  EscreveJogada,
						  PassaJogadaERRADO, --NOVIDADE
						  ExibeJogadaERRADO, --NOVIDADE
						  PassaJogadaCERTO, --NOVIDADE
						  ExibeJogadaCERTO); --NOVIDADE
  signal Eatual, Eprox: t_estado;
  signal certo : std_logic;
  
begin
  -- memoria de estado
  process (clock,reset)
  begin
    if reset='1' then
      Eatual <= Aguarda;
		certo <= '1';
    elsif clock'event and clock = '1' then
		Eatual <= Eprox; 
		certo <= igual;
    end if;
  end process;

  -- logica de proximo estado
  Eprox <=
      Aguarda when  Eatual=Aguarda and jogar='0' else
      Prepara when  Eatual=Aguarda and jogar='1' else 
		Prepara when  (Eatual=TerminouCerto or Eatual=TerminouErrado) and jogar='1' else  
		EsperaEscrita when Eatual=Prepara else
		InicioCiclo when Eatual=ResetContador else
		
		EsperaJogada when Eatual=InicioCiclo else
		EsperaJogada when Eatual=EsperaJogada and jogada='0' and timeout='0' and timeout_total='0' else
		EsperaJogada when Eatual=AcertouJogada and fim='0' else --nao acabou de jogar ainda

		ArmazenaJogada when  Eatual=EsperaJogada and jogada='1' and timeout='0' and timeout_total='0' else
		ComparaJogada	when  Eatual=ArmazenaJogada else
      
		AcertouJogada when  Eatual=ComparaJogada and certo='1' and fim='0'else
		TerminouErrado when Eatual=ComparaJogada and certo='0' else
		TerminouErrado when Eatual=EsperaJogada and timeout='1' else
		TerminouErrado when Eatual=EsperaJogada and timeout_total='1' else
		
		
		AumentaLimite when Eatual=ComparaJogada and certo='1' and fim='1' else
		CicloCerto when Eatual=AumentaLimite and limiteMaximo='0' else
		
		EsperaEscrita when Eatual=CicloCerto else
		EsperaEscrita when Eatual=EsperaEscrita and jogada='0' and timeout='0' and timeout_total='0' else
		TerminouErrado when Eatual=EsperaEscrita and timeout='1' else
		TerminouErrado when Eatual=EsperaEscrita and timeout_total='1' else
		EscreveJogada when Eatual=EsperaEscrita and jogada='1' and timeout='0' and timeout_total='0' else
		ResetContador when Eatual=EscreveJogada else
		
		TerminouCerto when Eatual=AumentaLimite and limiteMaximo='1' else
      TerminouCerto when Eatual=TerminouCerto and jogar='0' and repetir_edge='0' else
      TerminouErrado when Eatual=TerminouErrado and jogar='0' and repetir_edge='0' else
		
		ExibeJogadaERRADO when Eatual=TerminouErrado and jogar='0' and repetir_edge='1' else
		ExibeJogadaERRADO when Eatual=ExibeJogadaERRADO and timeout_rep='0' else
		PassaJogadaERRADO when Eatual=ExibeJogadaERRADO and timeout_rep='1' and acabou_repetir='0' else
		TerminouErrado when Eatual=ExibeJogadaERRADO and timeout_rep='1' and acabou_repetir='1' else
		ExibeJogadaERRADO when Eatual=PassaJogadaERRADO else
		
		ExibeJogadaCERTO when Eatual=TerminouCerto and jogar='0' and repetir_edge='1' else
		ExibeJogadaCERTO when Eatual=ExibeJogadaCERTO and timeout_rep='0' else
		PassaJogadaCERTO when Eatual=ExibeJogadaCERTO and timeout_rep='1' and acabou_repetir='0' else
		TerminouCerto when Eatual=ExibeJogadaCERTO and timeout_rep='1' and acabou_repetir='1' else
		ExibeJogadaCERTO when Eatual=PassaJogadaCERTO else
		
		Aguarda;

  -- logica de saída (maquina de Moore)
  with Eatual select
    zera <=	'1' when Prepara | ResetContador | TerminouErrado | TerminouCerto,
				'0' when others;

  with Eatual select
    conta <=  '1' when AcertouJogada | CicloCerto | PassaJogadaERRADO | PassaJogadaCERTO,
              '0' when others;

  with Eatual select
    pronto <= '1' when TerminouCerto | TerminouErrado | PassaJogadaERRADO | ExibeJogadaERRADO | PassaJogadaCERTO | ExibeJogadaCERTO,
              '0' when others;
				  
	with Eatual select
		acertou <= 	'1' when TerminouCerto | PassaJogadaCERTO | ExibeJogadaCERTO,
						'0' when others;
						
	with Eatual select
		errou <= '1' when TerminouErrado | PassaJogadaERRADO | ExibeJogadaERRADO,
					'0' when others;

	with Eatual select
		registra <= '1' when ArmazenaJogada | PassaJogadaERRADO | ExibeJogadaERRADO | PassaJogadaCERTO | ExibeJogadaCERTO,
					'0' when others;
	
	with Eatual select
		incrementaLimite <= '1' when AumentaLimite, --no proximo ciclo, quero limite+1
								  '0' when others;
	with Eatual select
		zeraLim <= '1' when Prepara,
					  '0' when others;
	with Eatual select
		escreve <= '1' when EscreveJogada,
		  '0' when others;
		  
	with Eatual select
		treset <= '1' when AcertouJogada | InicioCiclo | TerminouErrado | PassaJogadaERRADO | CicloCerto | TerminouCerto | PassaJogadaCERTO,
		'0' when others;
		
	with Eatual select
		tenable <= '1' when EsperaJogada | EsperaEscrita,
		'0' when others;		
		
	with Eatual select
		espera <= '1' when EsperaEscrita,
					 '0' when others;
					 
	with Eatual select
		enable_nivel <= '1' when Aguarda | Prepara | TerminouCerto | TerminouErrado,
							 '0' when others;
							 
	with Eatual select
		escreve_tempo <= '1' when ArmazenaJogada | EscreveJogada,
							  '0' when others;
	
	with Eatual select
		zera_tempo	<=	'1' when Prepara | TerminouCerto | TerminouErrado,
							'0' when others;
	
	with Eatual select
		conta_jogadas <= '1' when ArmazenaJogada | EscreveJogada | PassaJogadaCERTO | PassaJogadaERRADO,
							  '0' when others;
	with Eatual select
		enable_rep	<=	'1' when ExibeJogadaERRADO | ExibeJogadaCERTO,
							'0' when others;
	with Eatual select
		reset_rep	<= '1' when TerminouErrado | TerminouCerto | PassaJogadaCERTO | PassaJogadaERRADO,
							'0' when others;
	
	with Eatual select
		mostra_media <= '1' when TerminouErrado | TerminouCerto,
							 '0' when others;
	
	with Eatual select --HEX 4
		mensagem0 <= "1000010" when Aguarda,--G
						 "0001111" when Prepara,--R
						 "1000110" when InicioCiclo,--C
						 "1100000" when EsperaJogada,--J
						 "1100000" when ArmazenaJogada,--J
						 "1100000" when ComparaJogada,--J
						 "1100000" when AcertouJogada,--J
						 "1000110" when CicloCerto,--C
						 "0000110" when EsperaEscrita,--E
						 "1100000" when EscreveJogada,--J
						 "1111111" when TerminouCerto,--nada
						 "1111111" when TerminouErrado,--nada
						 "1000110" when ResetContador,--C
						 "1000111" when AumentaLimite,--L
						 "1111111" when PassaJogadaERRADO | PassaJogadaCERTO,--nada
						 "1111111" when ExibeJogadaERRADO | ExibeJogadaCERTO;--nada
		
	with Eatual select --HEX5
		mensagem1 <= "0001000" when Aguarda,--A
						 "0001100" when Prepara,--P
						 "1111001" when InicioCiclo,--I
						 "0000110" when EsperaJogada,--E
						 "0001000" when ArmazenaJogada,--A
						 "1000110" when ComparaJogada,--C
						 "0001000" when AcertouJogada,--A
						 "1000110" when CicloCerto,--C
						 "0000110" when EsperaEscrita,--E
						 "0000110" when EscreveJogada,--E
						 "1000010" when TerminouCerto,--G
						 "0001100" when TerminouErrado,--P
						 "0001111" when ResetContador,--R
						 "0001000" when AumentaLimite,--A
						 "1111111" when PassaJogadaERRADO | PassaJogadaCERTO, --nada
						 "1111111" when ExibeJogadaERRADO | ExibeJogadaCERTO;--nada
						 
	with Eatual select
		esta_jogando <= '0' when TerminouCerto | TerminouErrado | PassajogadaERRADO | PassaJogadaCERTO | ExibeJogadaERRADO | ExibeJogadaCERTO,
							 '1' when others;
							 
  -- saida de depuracao (db_estado)
	with Eatual select
		db_estado <= 
x"0" when Aguarda,        -- ->  #40 
x"1" when Prepara,        -- ->  #79 
x"2" when InicioCiclo,    -- ->  #24
x"3" when EsperaJogada,   -- ->  #30
x"4" when ArmazenaJogada, -- ->  #19
x"5" when ComparaJogada,  -- ->  #12
x"6" when AcertouJogada,  -- ->  #02  
x"7" when CicloCerto,    -- ->  #78
x"8" when EsperaEscrita,   -- ->  #00
x"9" when EscreveJogada,    -- ->  #10
x"A" when TerminouCerto,  -- ->  #08
x"B" when TerminouErrado,  -- ->  #03
x"C" when ResetContador,  -- ->  #46
x"D" when AumentaLimite, -- ->  #21
x"E" when PassaJogadaERRADO,  -- ->  #06
x"F" when ExibeJogadaERRADO,  -- ->  #0E
x"E" when PassaJogadaCERTO,  -- ->  #06
x"F" when ExibeJogadaCERTO;  -- ->  #0E


end fsm;
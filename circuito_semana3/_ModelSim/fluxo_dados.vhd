library ieee;
use ieee.std_logic_1164.all;

entity fluxo_dados is
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
		zeraR: 				in  std_logic;
		enableR: 			in  std_logic;
		incrementaLimite: in  std_logic;
		treset:				in  std_logic;
		tenable:				in  std_logic;
		pronto_UC:			in  std_logic;
		zera_tempo:			in  std_logic;
		conta_jogadas:		in  std_logic;
		mostra_media:		in  std_logic; --NOVIDADE
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
end entity;

architecture dataflow of fluxo_dados is
component contador_163
   port (
        clock : in  std_logic;
        clr   : in  std_logic;
        ld    : in  std_logic;
        ent   : in  std_logic;
        enp   : in  std_logic;
        D     : in  std_logic_vector (3 downto 0);
		  limite: in  std_logic_vector (3 downto 0);
        Q     : out std_logic_vector (3 downto 0);
        rco   : out std_logic 
   );
end component;

component comparador_85
  port (
    i_A3   : in  std_logic;
    i_B3   : in  std_logic;
    i_A2   : in  std_logic;
    i_B2   : in  std_logic;
	 i_A1   : in  std_logic;
    i_B1   : in  std_logic;
    i_A0   : in  std_logic;
    i_B0   : in  std_logic;
    i_AGTB : in  std_logic;
    i_ALTB : in  std_logic;
    i_AEQB : in  std_logic;
    o_AGTB : out std_logic;
    o_ALTB : out std_logic;
    o_AEQB : out std_logic
  );
end component;

component ram_16x4
   port (
		clk				: in  std_logic;
      endereco     	: in  std_logic_vector(3 downto 0);
      dado_entrada 	: in  std_logic_vector(3 downto 0);
      we           	: in  std_logic;
      ce           	: in  std_logic;
      dado_saida   	: out std_logic_vector(3 downto 0)
    );
end component;

component registrador_4bits
	port 
	(
		clock : in std_logic;
		clear : in std_logic;
		enable : in std_logic;
		D : in std_logic_vector(3 downto 0);
		Q : out std_logic_vector(3 downto 0)
	);
end component;

component edge_detector
	port 
	(
		clock : in std_logic;
		reset : in std_logic;
		sinal : in std_logic;
		pulso : out std_logic
	);
end component;

component timer5k is
   port 
	(
	  clock 		: in  std_logic;
	  clr   		: in  std_logic; -- ativo em alto
	  enable		: in  std_logic;
	  Q     		: out std_logic_vector (13 downto 0);
	  timeout	: out std_logic 
   );
end component;

component timerRep
   port (
        clock 		: in  std_logic;
        clr   		: in  std_logic; -- ativo em alto
        enable		: in  std_logic;
        Q     		: out std_logic_vector (13 downto 0);
        timeout	: out std_logic 
   );
end component;

component registrador_2bits
  port (
    clock:  in  std_logic;
    clear:  in  std_logic;
    enable: in  std_logic;
    D:      in  std_logic_vector(1 downto 0);
    Q:      out std_logic_vector(1 downto 0)
  );
end component;

component ram_tempos
   port (       
       clk          : in  std_logic;
       endereco     : in  std_logic_vector(7 downto 0);
       dado_entrada : in  std_logic_vector(13 downto 0);--tempo de reacao do jogador
       we           : in  std_logic;
       ce           : in  std_logic;
       dado_saida   : out std_logic_vector(13 downto 0)
    );
end component;

component contador_tempos
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
end component;

component comparador_8bits
  port (
    --numero binario A de 14 bits
    i_A : in std_logic_vector(7 downto 0);

    --numero binario B de 14 bits
    i_B : in std_logic_vector(7 downto 0);

    --saidas
    --representam conclusoes realizadas com o circuito
    iguais : out std_logic
  );
end component;

component calcula_media
   port (
        clock 		: in  std_logic;
        clr   		: in  std_logic; -- ativo em alto
        enable		: in  std_logic; -- ativo em alto
		  D			: in  std_logic_vector (13 downto 0); -- tempo de reacao da mais nova jogada
        Q     		: out std_logic_vector (13 downto 0) --media das entradas fornecidas
   );
end component;

component timerTotal
   port (
        clock 		: in  std_logic;
		  nivel		: in  std_logic_vector(1 downto 0);
        clr   		: in  std_logic; -- ativo em alto
        enable		: in  std_logic;
        timeout	: out std_logic 
   );
end component;

signal s_endereco, led_jogada : std_logic_vector(3 downto 0);
signal s_dados: std_logic_vector(3 downto 0);
signal or_jogada : std_logic;
signal nzerac : std_logic;
signal nzeraLim: std_logic;
signal limite, valor_nivel_4bits : std_logic_vector (3 downto 0);
signal valor_nivel_2bits : std_logic_vector(1 downto 0);
signal tem_jogada_feita: std_logic;
signal not_escrevem : std_logic;

--NOVIDADES
signal not_escreve_tempo, not_zera_tempo: std_logic;
signal limite_tempo, endereco_tempo, ultima_jogada: std_logic_vector(7 downto 0);
signal tempo_reacao, saida_ram_tempos, media: std_logic_vector(13 downto 0);

begin
nzerac <= not zerac;
nzeraLim <= not zeraLim;
not_escrevem <= not escrevem;
not_escreve_tempo <= not escreve_tempo;
not_zera_tempo <= not zera_tempo;

or_jogada <= chaves(0) or chaves(1) or chaves(2) or chaves(3);

G1: contador_163 port map(
        clock => clock,
        clr   => nzerac,
        ld    => '1',
        ent   => contac,
        enp   => contac,
        D     => "0000",
		  limite=> limite,
        Q     => s_endereco,
        rco   => fimc);
		  
GLim: contador_163 port map(
        clock => clock,
        clr   => nzeraLim,
        ld    => '1',
        ent   => incrementaLimite,
        enp   => incrementaLimite,
        D     => "0000",
		  limite=> valor_nivel_4bits,
        Q     => limite,
        rco   => limiteMaximo);

G2: comparador_85 port map(
            i_A3   => s_dados(3),
            i_B3   => chaves(3),
            i_A2   => s_dados(2),
            i_B2   => chaves(2),
            i_A1   => s_dados(1),
            i_B1   => chaves(1),
            i_A0   => s_dados(0),
            i_B0   => chaves(0),
            i_AGTB => '0',
            i_ALTB => '0',
            i_AEQB => '1',
            o_AGTB => open,
				o_ALTB => open,
            o_AEQB => igual);

G3: ram_16x4 port map(
		clk				=> clock,
		endereco     	=> s_endereco,
		dado_entrada 	=> chaves,
		we           	=> not_escrevem,
		ce           	=> '0',
		dado_saida   	=> s_dados);
		 
G4 : edge_detector port map
	(
		clock => clock,
		reset => '0',
		sinal => or_jogada,
		pulso => tem_jogada_feita
	);

G5 : registrador_4bits port map
	(
		clock => clock,
		clear => zeraR,
		enable => enableR,
		D => led_jogada,
		Q => db_jogada
	);
	
G6 : timer5k port map
	(
		clock 	=> clock,
		clr 		=> treset,
		enable	=> tenable,
		Q			=> tempo_reacao,
		timeout 	=> timeout
	);
G7 : edge_detector port map
	(
		clock => clock,
		reset => '0',
		sinal => repetir,
		pulso => repetir_edge
	);
G8: registrador_2bits port map
	(
		clock => clock,
		clear => '0',
		enable => enable_nivel,
		D => nivel,
		Q => valor_nivel_2bits);
		
db_tem_jogada <= tem_jogada_feita;
jogada_feita <= tem_jogada_feita;
db_contagem <= s_endereco;
db_memoria <= s_dados;
db_limite <= limite;

with valor_nivel_2bits select
	valor_nivel_4bits <= "0011" when "00",
								"0111" when "01",
								"1011" when "10",
								"1111" when others;
db_nivel <= "00" & valor_nivel_2bits;

with pronto_UC select
		led_jogada <= chaves when '0',
						  s_dados when others;
						  
--NOVIDADES PROJETO DE GRUPO

G9: ram_tempos port map(       
       clk          => clock,
       endereco     => endereco_tempo,
       dado_entrada => tempo_reacao,--tempo de reacao do jogador
       we           => not_escreve_tempo,
       ce           => '0',
       dado_saida   => saida_ram_tempos);

with valor_nivel_2bits select
		limite_tempo <= "00001110" when "00", --1+2+3+4+4=14
							 "00101100" when "01", --1+2+...+8+8=44
							 "01011001" when "10", --1+2+...+12+12=89
							 "10011000" when others;--1+2+...+16+16=152

G10: contador_tempos port map(
        clock => clock,
        clr   => not_zera_tempo,
        ld    => '1',
        ent   => conta_jogadas,
        enp   => conta_jogadas,
        D     => "00000000",
		  limite=> limite_tempo,
        Q     => endereco_tempo,
        rco   => open);
		  
G11: contador_tempos port map(
		clock => clock,
		clr	=> nzeraLim,
		ld    => '1',
		ent	=> escreve_tempo,
		enp   => escreve_tempo,
		D		=> "00000000",
		limite=> limite_tempo,
		Q     => ultima_jogada,
		rco   => open);
		
-- se ultima_jogada e endereco tempo sao iguais, acabou
G12: comparador_8bits port map(
    --numero binario A de 14 bits
    i_A => endereco_tempo,

    --numero binario B de 14 bits
    i_B => ultima_jogada,

    --saidas
    --representam conclusoes realizadas com o circuito
    iguais => acabou_repetir
  );
  
G13: timerRep port map(
        clock 		=> clock,
        clr   		=> reset_rep, -- ativo em alto
        enable		=> enable_rep,
        Q     		=> open,
        timeout	=>	timeout_rep
   );
	
with mostra_media select
	saida_tempo <= saida_ram_tempos when '0',
						media	when others;
						
G14: calcula_media port map(
        clock 		=> clock,
        clr   		=> zeraLim, -- ativo em alto
        enable		=> escreve_tempo, -- ativo em alto
		  D			=> tempo_reacao, -- tempo de reacao da mais nova jogada
        Q     		=> media --media das entradas fornecidas
   );
	
G15: timerTotal port map(
        clock 		=> clock,
		  nivel		=> valor_nivel_2bits,
        clr   		=> zeraLim,--so damos reset entre execucoes
        enable		=> tenable,--mas contamos junto com timer5k
        timeout	=> timeout_total
   );

end architecture;
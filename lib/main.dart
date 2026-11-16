import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const ConquistaApp());

// ───────────────────────── MODELOS ─────────────────────────

class Pais {
  final String nome, especialidade;
  final int ataque, defesa, comercio, producao;
  final List<String> recursos;
  final Color cor;

  const Pais(
    this.nome,
    this.ataque,
    this.defesa,
    this.comercio,
    this.producao,
    this.especialidade,
    this.recursos,
    this.cor,
  );
}

const todosPaises = [
  Pais('Veridânia', 2, 3, 3, 5, 'Florestas e agricultura', ['Alimentos', 'Madeira'], Color(0xff2e9e5b)),
  Pais('Nortélia', 3, 5, 2, 4, 'Montanhas e minerais', ['Ferro'], Color(0xff4a6fa5)),
  Pais('Solária', 5, 2, 3, 4, 'Deserto e mineração', ['Ferro'], Color(0xffe8912d)),
  Pais('Thalassa', 2, 3, 5, 4, 'Mar e pesca', ['Alimentos'], Color(0xff1ba6b2)),
  Pais('Zafira', 2, 3, 4, 4, 'Cristais e gemas', ['Cristais'], Color(0xff8e5bd6)),
  Pais('Karnor', 5, 4, 2, 3, 'Metalurgia', ['Aço'], Color(0xffc44536)),
  Pais('Ismara', 2, 3, 3, 5, 'Ervas e cura', ['Medicamentos'], Color(0xffd4607f)),
  Pais('Druvânia', 3, 2, 2, 3, 'Espionagem e artefatos', ['Cristais'], Color(0xff5b5f97)),
  Pais('Selvion', 1, 2, 5, 4, 'Especiarias e alimentos', ['Especiarias', 'Alimentos'], Color(0xffb8902a)),
];

const todosRecursos = [
  'Alimentos',
  'Ferro',
  'Aço',
  'Cristais',
  'Medicamentos',
  'Especiarias',
  'Madeira',
];

const iconesRecursos = <String, IconData>{
  'Alimentos': Icons.restaurant,
  'Ferro': Icons.hardware,
  'Aço': Icons.build,
  'Cristais': Icons.diamond_outlined,
  'Medicamentos': Icons.medication,
  'Especiarias': Icons.spa,
  'Madeira': Icons.park,
};

// Quantas unidades de um recurso são gastas para usar a função dele.
const custoUsoRecurso = 2;

// Quantas vezes o jogador pode sortear ações por turno.
const maxAcoesPorTurno = 2;

// Os 6 pares possíveis de ações (índice 0 = dado 1, ..., índice 5 = dado 6).
const paresDeAcoes = <List<String>>[
  ['Guerra', 'Aliança'],
  ['Guerra', 'Negociação'],
  ['Guerra', 'Procurar recursos'],
  ['Aliança', 'Negociação'],
  ['Aliança', 'Procurar recursos'],
  ['Negociação', 'Procurar recursos'],
];

class FuncaoRecurso {
  final String efeito, historia;
  const FuncaoRecurso(this.efeito, this.historia);
}

const funcoesRecursos = <String, FuncaoRecurso>{
  'Alimentos': FuncaoRecurso('+1 tropa', 'Alimenta sua população.'),
  'Ferro': FuncaoRecurso('+1 ataque', 'Você fabrica armas.'),
  'Aço': FuncaoRecurso('+1 defesa', 'Você fabrica armaduras.'),
  'Cristais': FuncaoRecurso('+1 moeda', 'Você troca com um mercador.'),
  'Medicamentos': FuncaoRecurso('+20 de vida', 'Você cura sua população.'),
  'Especiarias': FuncaoRecurso('+1 moeda', 'Você vende para um mercador.'),
  'Madeira': FuncaoRecurso('+2 defesa na próxima batalha', 'Você constrói estruturas de defesa.'),
};

const casasDoTabuleiro = [
  'Moedas',
  'Trigo',
  'Negociação',
  'Aliança',
  'Defesa',
  'Guerra',
  'Exército',
  'Castelo',
  'Produção',
  'Espionagem',
  'Navio',
  'Evento',
  'Mobilização',
  'Recuperação',
  'Tesouro',
  'Capital',
];

// Cores por categoria: economia, produção, militar, social, sorte.
const corEconomia = Color(0xffd99a1e);
const corProducao = Color(0xff2e9e5b);
const corMilitar = Color(0xffc0392b);
const corSocial = Color(0xff2f7fd1);
const corSorte = Color(0xff8e5bd6);
const corMesa = Color(0xff14213d);

class InfoCasa {
  final String descricao;
  final IconData icone;
  final Color cor;
  const InfoCasa(this.icone, this.cor, this.descricao);
}

const infoCasas = <String, InfoCasa>{
  'Moedas': InfoCasa(Icons.monetization_on, corEconomia, 'Ganhe 3 moedas.'),
  'Trigo': InfoCasa(Icons.grass, corProducao, 'Ganhe 2 alimentos.'),
  'Negociação': InfoCasa(Icons.swap_horiz, corSocial, 'Troque recursos e moedas com outro país. Ele pode aceitar, recusar ou fazer uma contraproposta.'),
  'Aliança': InfoCasa(Icons.handshake, corSocial, 'Proponha um pacto de 3 rodadas com outro país.'),
  'Defesa': InfoCasa(Icons.shield, corMilitar, 'Ganhe +2 de defesa na próxima batalha em que for atacado.'),
  'Guerra': InfoCasa(Icons.local_fire_department, corMilitar, 'Ataque outro país. Custa 2 moedas e 1 tropa mínima. Se vencer, o alvo perde 20 de vida menos a defesa dele.'),
  'Exército': InfoCasa(Icons.military_tech, corMilitar, 'Pague 2 moedas e ganhe 2 tropas (só se tiver 3 ou menos).'),
  'Castelo': InfoCasa(Icons.castle, corMilitar, 'Pague 3 moedas e ganhe +1 de defesa permanente.'),
  'Produção': InfoCasa(Icons.factory, corProducao, 'Escolha 2 unidades de qualquer recurso.'),
  'Espionagem': InfoCasa(Icons.visibility, corSorte, 'Veja tropas e recursos de outro país.'),
  'Navio': InfoCasa(Icons.directions_boat, corEconomia, 'Ganhe 2 moedas com o comércio marítimo.'),
  'Evento': InfoCasa(Icons.auto_awesome, corSorte, 'Sorteio: moedas, alimento, tropa ou nada.'),
  'Mobilização': InfoCasa(Icons.campaign, corMilitar, 'Ainda em desenvolvimento.'),
  'Recuperação': InfoCasa(Icons.favorite, corProducao, 'Ganhe 1 tropa.'),
  'Tesouro': InfoCasa(Icons.diamond, corEconomia, 'Ganhe 4 moedas.'),
  'Capital': InfoCasa(Icons.account_balance, corEconomia, 'Ganhe 2 moedas (apenas na primeira vez).'),
};

// Ações disponíveis no sorteio de ações do turno.
const infoAcoesSorteio = <String, InfoCasa>{
  'Guerra': InfoCasa(Icons.local_fire_department, corMilitar, 'Ataque outro país (custa 2 moedas).'),
  'Aliança': InfoCasa(Icons.handshake, corSocial, 'Proponha um pacto de 3 rodadas.'),
  'Negociação': InfoCasa(Icons.swap_horiz, corSocial, 'Troque recursos e moedas com outro país.'),
  'Procurar recursos': InfoCasa(Icons.search, corProducao, 'Expedição por 1 moeda: 1 ou 2 recursos, ou nada.'),
};

class Jogador {
  final Pais pais;
  int moedas = 10;
  int vida = 100;
  int tropas = 3;
  int posicao = 0;
  int melhoriasAtaque = 0;
  int melhoriasDefesa = 0;
  int bonusDefesaProximaBatalha = 0;
  bool jaPassouPelaCapital = false;

  final Map<String, int> estoque = {
    for (final recurso in todosRecursos) recurso: 0,
  };

  Jogador(this.pais);

  int get ataqueTotal => min(10, pais.ataque + melhoriasAtaque);
  int get defesaTotal => min(10, pais.defesa + melhoriasDefesa);
  String get recursoPrincipal => pais.recursos.first;
  Color get cor => pais.cor;
  bool get vivo => vida > 0;
}

class Jogo {
  final List<Jogador> jogadores;
  final Random aleatorio = Random();
  int indiceTurno = 0;
  int rodada = 1;
  final List<String> historico = [];

  Jogo(this.jogadores);

  Jogador get jogadorAtivo => jogadores[indiceTurno];

  // Quando só resta um país vivo, ele é o vencedor.
  Jogador? get vencedor {
    final vivos = jogadores.where((j) => j.vivo).toList();
    return vivos.length == 1 ? vivos.first : null;
  }

  void proximoTurno() {
    // Pula os países eliminados.
    do {
      indiceTurno++;
      if (indiceTurno >= jogadores.length) {
        indiceTurno = 0;
        rodada++;
      }
    } while (!jogadorAtivo.vivo);
  }

  void registrar(String texto) => historico.insert(0, 'Rodada $rodada • $texto');
}

Color escurecer(Color cor, double luminosidadeMaxima) {
  final hsl = HSLColor.fromColor(cor);
  return hsl.withLightness(min(hsl.lightness, luminosidadeMaxima)).toColor();
}

// ───────────────────────── APP ─────────────────────────

class ConquistaApp extends StatelessWidget {
  const ConquistaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Conquista & Comércio',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 51, 1, 231),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xfff5f6f3),
          useMaterial3: true,
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: Color(0xffe5e9e4)),
            ),
          ),
        ),
        home: const TelaConfiguracao(),
      );
}

// ───────────────────────── TELA DE CONFIGURAÇÃO ─────────────────────────

class TelaConfiguracao extends StatefulWidget {
  const TelaConfiguracao({super.key});

  @override
  State<TelaConfiguracao> createState() => _TelaConfiguracaoState();
}

class _TelaConfiguracaoState extends State<TelaConfiguracao> {
  int quantidadeJogadores = 2;

  void comecarPartida() {
    final paisesSorteados = [...todosPaises]..shuffle();

    final jogadoresCriados = List.generate(quantidadeJogadores, (indice) {
      final jogador = Jogador(paisesSorteados[indice]);
      jogador.estoque[jogador.recursoPrincipal] = 3;
      if (jogador.pais.recursos.length > 1) {
        jogador.estoque[jogador.pais.recursos[1]] = 1;
      }
      return jogador;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TelaJogo(jogo: Jogo(jogadoresCriados)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: const BoxDecoration(
                        color: corMesa,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.public, color: Colors.white, size: 54),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Conquista & Comércio',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Um mundo. Nove nações. Uma disputa por poder.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 30),
                  const Text('Quantos jogadores?', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: quantidadeJogadores,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: [
                      for (int numero = 2; numero <= 9; numero++)
                        DropdownMenuItem(value: numero, child: Text('$numero jogadores')),
                    ],
                    onChanged: (novoValor) => setState(() => quantidadeJogadores = novoValor!),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Os países são sorteados para cada jogador.',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: comecarPartida,
                    child: const Padding(
                      padding: EdgeInsets.all(14),
                      child: Text('Começar partida'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

// ───────────────────────── TELA DO JOGO ─────────────────────────

class TelaJogo extends StatefulWidget {
  final Jogo jogo;

  const TelaJogo({super.key, required this.jogo});

  @override
  State<TelaJogo> createState() => _TelaJogoState();
}

class _TelaJogoState extends State<TelaJogo> {
  late Jogo jogo = widget.jogo;
  int? resultadoDado;
  int acoesUsadas = 0;
  int abaSelecionada = 0;
  String mensagem = 'Sua vez! Role o dado para produzir recursos e andar no tabuleiro.';

  Jogador get jogadorAtual => jogo.jogadorAtivo;

  void atualizar([VoidCallback? alteracao]) => setState(alteracao ?? () {});

  void mostrarAviso(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), behavior: SnackBarBehavior.floating),
    );
  }

  void adicionarRecurso(Jogador jogador, String recurso, int quantidade) {
    jogador.estoque[recurso] = min(12, (jogador.estoque[recurso] ?? 0) + quantidade);
  }

  // ───── Escolha de alvo ─────

  Future<int?> escolherAlvo() async {
    final outrosJogadores = jogo.jogadores.where((jogador) => jogador != jogadorAtual && jogador.vivo).toList();

    return showDialog<int>(
      context: context,
      builder: (contextoDialogo) => SimpleDialog(
        title: const Text('Escolha um país'),
        children: [
          for (final jogador in outrosJogadores)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(contextoDialogo, jogo.jogadores.indexOf(jogador)),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: jogador.cor,
                    child: Text(
                      jogador.pais.nome.substring(0, 1),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(jogador.pais.nome),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ───── Escolha de recurso (casa Produção) ─────

  Future<String> escolherRecurso(String titulo) async {
    final escolhido = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (contextoDialogo) => SimpleDialog(
        title: Text(titulo),
        children: [
          for (final recurso in todosRecursos)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(contextoDialogo, recurso),
              child: Row(
                children: [
                  Icon(iconesRecursos[recurso], size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(recurso, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(
                          '$custoUsoRecurso → ${funcoesRecursos[recurso]!.efeito}',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Text('tem ${jogadorAtual.estoque[recurso] ?? 0}'),
                ],
              ),
            ),
        ],
      ),
    );
    return escolhido ?? jogadorAtual.recursoPrincipal;
  }

  // ───── Usar recursos ─────

  void usarRecurso(String recurso) {
    final jogador = jogadorAtual;
    if (jogo.vencedor != null) return;

    if ((jogador.estoque[recurso] ?? 0) < custoUsoRecurso) {
      mostrarAviso('Precisa de $custoUsoRecurso $recurso.');
      return;
    }

    final String? bloqueio = switch (recurso) {
      'Alimentos' => jogador.tropas >= 10 ? 'Suas tropas já estão no máximo (10).' : null,
      'Ferro' => jogador.ataqueTotal >= 10 ? 'Seu ataque já está no máximo (10).' : null,
      'Aço' => jogador.defesaTotal >= 10 ? 'Sua defesa já está no máximo (10).' : null,
      'Medicamentos' => jogador.vida >= 100 ? 'Sua vida já está cheia.' : null,
      _ => null,
    };
    if (bloqueio != null) {
      mostrarAviso(bloqueio);
      return;
    }

    atualizar(() {
      jogador.estoque[recurso] = (jogador.estoque[recurso] ?? 0) - custoUsoRecurso;
      switch (recurso) {
        case 'Alimentos':
          jogador.tropas = min(10, jogador.tropas + 1);
          mensagem = 'Você alimentou sua população e ganhou 1 tropa (${jogador.tropas}/10).';
          break;
        case 'Ferro':
          jogador.melhoriasAtaque++;
          mensagem = 'Você fabricou armas! Ataque agora é ${jogador.ataqueTotal}/10.';
          break;
        case 'Aço':
          jogador.melhoriasDefesa++;
          mensagem = 'Você fabricou armaduras! Defesa agora é ${jogador.defesaTotal}/10.';
          break;
        case 'Cristais':
          jogador.moedas += 1;
          mensagem = 'Você trocou cristais com um mercador e ganhou 1 moeda.';
          break;
        case 'Medicamentos':
          jogador.vida = min(100, jogador.vida + 20);
          mensagem = 'Você curou sua população: vida em ${jogador.vida}/100.';
          break;
        case 'Especiarias':
          jogador.moedas += 1;
          mensagem = 'Você vendeu especiarias a um mercador e ganhou 1 moeda.';
          break;
        case 'Madeira':
          jogador.bonusDefesaProximaBatalha += 2;
          mensagem = 'Você construiu estruturas de defesa: +2 de defesa na próxima batalha.';
          break;
      }
    });
    jogo.registrar('${jogador.pais.nome}: $mensagem');
  }

  // ───── Procurar recursos ─────

  void procurarRecursos() {
    final jogador = jogadorAtual;
    if (jogo.vencedor != null) return;

    if (jogador.moedas < 1) {
      mostrarAviso('Precisa de 1 moeda para enviar a expedição.');
      return;
    }

    // 0 = nada, 1-3 = 1 unidade, 4-5 = 2 unidades.
    final sorte = jogo.aleatorio.nextInt(6);
    final recurso = todosRecursos[jogo.aleatorio.nextInt(todosRecursos.length)];
    final quantidade = sorte == 0 ? 0 : (sorte <= 3 ? 1 : 2);

    atualizar(() {
      jogador.moedas -= 1;
      if (quantidade > 0) adicionarRecurso(jogador, recurso, quantidade);
      mensagem = quantidade == 0
          ? 'Sua expedição voltou de mãos vazias.'
          : 'Sua expedição encontrou $quantidade $recurso!';
    });
    jogo.registrar('${jogador.pais.nome}: $mensagem');
  }

  // ───── Sorteio de ações do turno ─────

  bool acaoDisponivel(String acao) => switch (acao) {
        'Guerra' => jogadorAtual.moedas >= 2 && jogadorAtual.tropas >= 1,
        'Procurar recursos' => jogadorAtual.moedas >= 1,
        _ => true,
      };

  Future<void> sortearAcoes() async {
    if (jogo.vencedor != null) return;
    if (acoesUsadas >= maxAcoesPorTurno) {
      mostrarAviso('Você já usou suas $maxAcoesPorTurno ações neste turno.');
      return;
    }

    final dado = jogo.aleatorio.nextInt(6);
    final opcoes = paresDeAcoes[dado];
    atualizar(() => acoesUsadas++);
    jogo.registrar('${jogadorAtual.pais.nome} sorteou ${dado + 1}: ${opcoes.join(' ou ')}.');

    final semOpcao = opcoes.every((a) => !acaoDisponivel(a));

    final escolhida = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (contextoDialogo) => SimpleDialog(
        title: Text('Dado das ações: ${dado + 1}'),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text('Escolha uma das ações para fazer agora:'),
          ),
          for (final acao in opcoes)
            SimpleDialogOption(
              onPressed: acaoDisponivel(acao) ? () => Navigator.pop(contextoDialogo, acao) : null,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: acaoDisponivel(acao) ? infoAcoesSorteio[acao]!.cor : Colors.black26,
                    child: Icon(infoAcoesSorteio[acao]!.icone, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(acao, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(
                          acaoDisponivel(acao)
                              ? infoAcoesSorteio[acao]!.descricao
                              : 'Indisponível (faltam moedas ou tropas).',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (semOpcao)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(contextoDialogo, 'nenhuma'),
              child: const Text('Nenhuma disponível — perder esta ação'),
            ),
        ],
      ),
    );

    switch (escolhida) {
      case 'Guerra':
        await batalhar();
        break;
      case 'Aliança':
        await proporAlianca();
        break;
      case 'Negociação':
        await negociar();
        break;
      case 'Procurar recursos':
        procurarRecursos();
        break;
    }
    atualizar();
  }

  // ───── Turno ─────

  Future<void> iniciarTurno() async {
    if (resultadoDado != null || jogo.vencedor != null) return;

    atualizar(() => jogadorAtual.estoque[jogadorAtual.recursoPrincipal] = min(
          12,
          (jogadorAtual.estoque[jogadorAtual.recursoPrincipal] ?? 0) + 2,
        ));

    final valorDado = jogo.aleatorio.nextInt(6) + 1;

    atualizar(() {
      resultadoDado = valorDado;
      jogadorAtual.posicao = (jogadorAtual.posicao + valorDado) % casasDoTabuleiro.length;
      mensagem =
          'Você tirou $valorDado e caiu em ${casasDoTabuleiro[jogadorAtual.posicao]}. (+2 ${jogadorAtual.recursoPrincipal} de produção)';
    });

    jogo.registrar(
      '${jogadorAtual.pais.nome} tirou $valorDado e caiu em ${casasDoTabuleiro[jogadorAtual.posicao]}.',
    );

    await resolverCasa();
  }

  Future<void> resolverCasa() async {
    switch (casasDoTabuleiro[jogadorAtual.posicao]) {
      case 'Moedas':
        jogadorAtual.moedas += 3;
        mensagem += ' Ganhou 3 moedas.';
        break;

      case 'Trigo':
        jogadorAtual.estoque['Alimentos'] = min(12, (jogadorAtual.estoque['Alimentos'] ?? 0) + 2);
        mensagem += ' Ganhou 2 alimentos.';
        break;

      case 'Negociação':
        await negociar();
        break;

      case 'Aliança':
        await proporAlianca();
        break;

      case 'Defesa':
        jogadorAtual.bonusDefesaProximaBatalha = 2;
        mensagem += ' Bônus de +2 na próxima defesa.';
        break;

      case 'Guerra':
        await batalhar();
        break;

      case 'Exército':
        if (jogadorAtual.moedas >= 2 && jogadorAtual.tropas <= 3) {
          jogadorAtual.moedas -= 2;
          jogadorAtual.tropas = min(10, jogadorAtual.tropas + 2);
          mensagem += ' Recrutou 2 tropas por 2 moedas.';
        } else {
          mostrarAviso('Precisa de 2 moedas e espaço para tropas.');
        }
        break;

      case 'Castelo':
        if (jogadorAtual.moedas >= 3 && jogadorAtual.defesaTotal < 10) {
          jogadorAtual.moedas -= 3;
          jogadorAtual.melhoriasDefesa++;
          mensagem += ' Defesa +1 por 3 moedas.';
        } else {
          mostrarAviso('Precisa de 3 moedas; defesa máxima é 10.');
        }
        break;

      case 'Produção':
        final recursoEscolhido = await escolherRecurso('Produção: escolha 2 unidades');
        adicionarRecurso(jogadorAtual, recursoEscolhido, 2);
        mensagem += ' Produziu 2 $recursoEscolhido.';
        break;

      case 'Espionagem':
        final indiceAlvo = await escolherAlvo();
        if (indiceAlvo != null) {
          final alvo = jogo.jogadores[indiceAlvo];
          final recursosAlvo = alvo.estoque.entries
              .where((e) => e.value > 0)
              .map((e) => '${e.key} ${e.value}')
              .join(', ');
          mensagem = '${alvo.pais.nome}: ${alvo.tropas} tropas. Recursos: $recursosAlvo.';
        }
        break;

      case 'Navio':
        jogadorAtual.moedas += 2;
        mensagem += ' Ganhou 2 moedas.';
        break;

      case 'Evento':
        final sorteioEvento = jogo.aleatorio.nextInt(4);
        if (sorteioEvento == 0) jogadorAtual.moedas += 2;
        if (sorteioEvento == 1) {
          jogadorAtual.estoque['Alimentos'] = min(12, (jogadorAtual.estoque['Alimentos'] ?? 0) + 1);
        }
        if (sorteioEvento == 2) {
          jogadorAtual.tropas = min(10, jogadorAtual.tropas + 1);
        }
        mensagem = 'Evento: ${[
          'ganhou 2 moedas.',
          'ganhou 1 alimento.',
          'ganhou 1 tropa.',
          'nada aconteceu.',
        ][sorteioEvento]}';
        break;

      case 'Mobilização':
        mensagem =
            'Mobilização entre territórios vizinhos será ativada quando as fronteiras jogáveis forem definidas.';
        break;

      case 'Recuperação':
        jogadorAtual.tropas = min(10, jogadorAtual.tropas + 1);
        mensagem += ' Recuperou 1 tropa.';
        break;

      case 'Tesouro':
        jogadorAtual.moedas += 4;
        mensagem += ' Ganhou 4 moedas!';
        break;

      case 'Capital':
        if (!jogadorAtual.jaPassouPelaCapital) {
          jogadorAtual.moedas += 2;
          jogadorAtual.jaPassouPelaCapital = true;
          mensagem += ' Ganhou 2 moedas.';
        } else {
          mensagem += ' O bônus da capital já foi recebido.';
        }
        break;
    }

    atualizar();
  }

  // ───── Negociação ─────

  String descreverLado(Map<String, int> recursos, int moedas) {
    final partes = <String>[
      for (final e in recursos.entries)
        if (e.value > 0) '${e.value} ${e.key}',
      if (moedas > 0) '$moedas moeda(s)',
    ];
    return partes.isEmpty ? 'nada' : partes.join(' + ');
  }

  void fecharTroca(Jogador proponente, Jogador receptor, Proposta proposta) {
    atualizar(() {
      proposta.da.forEach((recurso, qtd) {
        proponente.estoque[recurso] = (proponente.estoque[recurso] ?? 0) - qtd;
        receptor.estoque[recurso] = min(12, (receptor.estoque[recurso] ?? 0) + qtd);
      });
      proposta.recebe.forEach((recurso, qtd) {
        receptor.estoque[recurso] = (receptor.estoque[recurso] ?? 0) - qtd;
        proponente.estoque[recurso] = min(12, (proponente.estoque[recurso] ?? 0) + qtd);
      });
      proponente.moedas += proposta.moedasRecebe - proposta.moedasDa;
      receptor.moedas += proposta.moedasDa - proposta.moedasRecebe;

      mensagem =
          'Troca fechada: ${proponente.pais.nome} deu ${descreverLado(proposta.da, proposta.moedasDa)} '
          'e recebeu ${descreverLado(proposta.recebe, proposta.moedasRecebe)} de ${receptor.pais.nome}.';
    });
    jogo.registrar(mensagem);
  }

  Future<void> negociar() async {
    final indiceAlvo = await escolherAlvo();
    if (indiceAlvo == null) return;

    var proponente = jogadorAtual;
    var receptor = jogo.jogadores[indiceAlvo];

    final primeira = await showDialog<Proposta>(
      context: context,
      barrierDismissible: false,
      builder: (_) => MesaNegociacao(
        proponente: proponente,
        receptor: receptor,
        inicial: Proposta(),
        titulo: 'Nova proposta',
      ),
    );
    if (primeira == null) return;
    Proposta proposta = primeira;

    // A proposta vai e volta até alguém aceitar ou recusar.
    while (true) {
      final resposta = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (contextoDialogo) => AlertDialog(
          title: Text('Proposta para ${receptor.pais.nome}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${proponente.pais.nome} oferece:', style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(descreverLado(proposta.da, proposta.moedasDa)),
              const SizedBox(height: 12),
              const Text('Em troca de:', style: TextStyle(fontWeight: FontWeight.w700)),
              Text(descreverLado(proposta.recebe, proposta.moedasRecebe)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(contextoDialogo, 'recusar'),
              child: const Text('Recusar'),
            ),
            OutlinedButton(
              onPressed: () => Navigator.pop(contextoDialogo, 'contra'),
              child: const Text('Contraproposta'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(contextoDialogo, 'aceitar'),
              child: const Text('Aceitar'),
            ),
          ],
        ),
      );

      if (resposta == 'aceitar') {
        fecharTroca(proponente, receptor, proposta);
        return;
      }

      if (resposta == 'contra') {
        // Os papéis se invertem: quem recebeu a proposta passa a propor.
        final antigoProponente = proponente;
        proponente = receptor;
        receptor = antigoProponente;

        final contra = await showDialog<Proposta>(
          context: context,
          barrierDismissible: false,
          builder: (_) => MesaNegociacao(
            proponente: proponente,
            receptor: receptor,
            inicial: proposta.invertida(),
            titulo: 'Contraproposta de ${proponente.pais.nome}',
          ),
        );

        if (contra == null) {
          mensagem = '${proponente.pais.nome} desistiu da negociação com ${receptor.pais.nome}.';
          jogo.registrar(mensagem);
          atualizar();
          return;
        }
        proposta = contra;
        continue;
      }

      mensagem = '${receptor.pais.nome} recusou a proposta de ${proponente.pais.nome}.';
      jogo.registrar(mensagem);
      atualizar();
      mostrarAviso('Proposta recusada.');
      return;
    }
  }

  // ───── Aliança ─────

  Future<void> proporAlianca() async {
    final indiceAlvo = await escolherAlvo();
    if (indiceAlvo == null) return;
    final alvo = jogo.jogadores[indiceAlvo];

    final aceitou = await showDialog<bool>(
      context: context,
      builder: (contextoDialogo) => AlertDialog(
        title: Text('Aliança com ${alvo.pais.nome}'),
        content: const Text(
          'Pacto de 3 rodadas: cada país entrega 1 unidade de seu recurso principal ao outro por rodada. Aceitar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contextoDialogo, false),
            child: const Text('Recusar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(contextoDialogo, true),
            child: const Text('Aceitar'),
          ),
        ],
      ),
    );

    if (aceitou == true) {
      jogo.registrar('Aliança de 3 rodadas entre ${jogadorAtual.pais.nome} e ${alvo.pais.nome}.');
      mostrarAviso('Aliança registrada. Entregas ainda são manuais.');
    }
  }

  // ───── Batalha ─────

  Future<void> batalhar() async {
    final indiceAlvo = await escolherAlvo();
    if (indiceAlvo == null) return;
    final defensor = jogo.jogadores[indiceAlvo];

    if (jogadorAtual.moedas < 2 || jogadorAtual.tropas < 1) {
      mostrarAviso('Precisa de 2 moedas e pelo menos 1 tropa.');
      return;
    }

    jogadorAtual.moedas -= 2;

    final forcaAtaque =
        jogo.aleatorio.nextInt(6) + 1 + jogadorAtual.tropas + jogadorAtual.ataqueTotal;

    final forcaDefesa = jogo.aleatorio.nextInt(6) +
        1 +
        defensor.defesaTotal +
        defensor.bonusDefesaProximaBatalha;

    final atacanteVenceu = forcaAtaque > forcaDefesa;

    int dano = 0;
    if (atacanteVenceu) {
      // Dano = 20 menos a defesa do alvo (incluindo o bônus da casa Defesa).
      dano = max(0, 20 - defensor.defesaTotal - defensor.bonusDefesaProximaBatalha);
      defensor.vida = max(0, defensor.vida - dano);
      jogadorAtual.tropas = max(0, jogadorAtual.tropas - 1);
      defensor.tropas = max(0, defensor.tropas - 1);
    } else {
      jogadorAtual.tropas = max(0, jogadorAtual.tropas - 1);
    }

    defensor.bonusDefesaProximaBatalha = 0;

    mensagem =
        'Ataque $forcaAtaque × defesa $forcaDefesa. ${atacanteVenceu ? jogadorAtual.pais.nome : defensor.pais.nome} venceu. Empate favorece a defesa.'
        '${atacanteVenceu ? ' ${defensor.pais.nome} perdeu $dano de vida (${defensor.vida}/100).' : ''}'
        '${!defensor.vivo ? ' ${defensor.pais.nome} foi eliminado!' : ''}';
    jogo.registrar(mensagem);
    atualizar();

    await showDialog<void>(
      context: context,
      builder: (contextoDialogo) => AlertDialog(
        icon: Icon(
          atacanteVenceu ? Icons.emoji_events : Icons.shield,
          color: atacanteVenceu ? corEconomia : corSocial,
          size: 36,
        ),
        title: const Text('Resultado da batalha'),
        content: Text(mensagem),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(contextoDialogo),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );

    if (jogo.vencedor != null) await mostrarVitoria();
  }

  Future<void> mostrarVitoria() async {
    final campeao = jogo.vencedor!;
    jogo.registrar('${campeao.pais.nome} venceu a partida!');
    atualizar();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (contextoDialogo) => AlertDialog(
        icon: Icon(Icons.emoji_events, color: campeao.cor, size: 48),
        title: Text('${campeao.pais.nome} venceu!'),
        content: const Text('Todos os outros países foram eliminados.'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(contextoDialogo);
              Navigator.popUntil(context, (rota) => rota.isFirst);
            },
            child: const Text('Nova partida'),
          ),
        ],
      ),
    );
  }

  // ───── Melhorias e fim de turno ─────

  void melhorarAtributo(bool melhorarAtaque) {
    final atributoAtual = melhorarAtaque ? jogadorAtual.ataqueTotal : jogadorAtual.defesaTotal;

    if (jogadorAtual.moedas < 3 || atributoAtual >= 10) {
      mostrarAviso('Precisa de 3 moedas e atributo abaixo de 10.');
      return;
    }

    atualizar(() {
      jogadorAtual.moedas -= 3;
      if (melhorarAtaque) {
        jogadorAtual.melhoriasAtaque++;
        mensagem = 'Ataque melhorado para ${jogadorAtual.ataqueTotal}.';
      } else {
        jogadorAtual.melhoriasDefesa++;
        mensagem = 'Defesa melhorada para ${jogadorAtual.defesaTotal}.';
      }
    });
  }

  void encerrarTurno() {
    if (resultadoDado == null) return;

    atualizar(() {
      acoesUsadas = 0;
      resultadoDado = null;
      jogo.proximoTurno();
      mensagem = 'Vez de ${jogadorAtual.pais.nome}! Role o dado para começar.';
    });
  }

  // ───── Diálogos de ajuda ─────

  void mostrarRegras() {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Como jogar'),
        content: SingleChildScrollView(
          child: Text(
            '1. No início do turno, receba 2 unidades do recurso principal.\n'
            '2. Role o dado e ande pelo tabuleiro.\n'
            '3. Resolva a casa onde parou (toque nela para ver o efeito).\n'
            '4. Se quiser, sorteie ações (até 2 por turno).\n'
            '5. Encerre o turno.\n\n'
            'Sorteio de ações: você pode sortear até 2 vezes por turno. '
            'O dado mostra 2 das 4 ações (Guerra, Aliança, Negociação, Procurar recursos) '
            'e você escolhe uma para fazer.\n\n'
            'Guerra custa 2 moedas.\n'
            'Ataque = dado + tropas + ataque.\n'
            'Defesa = dado + defesa + tropas + bônus.\n'
            'Maior resultado vence; empate favorece a defesa.\n\n'
            'Vida: todo país começa com 100. Se o atacante vence, o defensor perde 20 menos a sua defesa. '
            'Com 0 de vida o país é eliminado. Vence o último país em pé.\n\n'
            'Recursos (gaste 2 de cada, na aba País):\n'
            '• Alimentos: +1 tropa\n'
            '• Ferro: +1 ataque\n'
            '• Aço: +1 defesa\n'
            '• Cristais e Especiarias: +1 moeda\n'
            '• Medicamentos: cura 20 de vida\n'
            '• Madeira: +2 de defesa na próxima batalha\n\n'
            'Casa Produção: você escolhe qual recurso ganhar.\n'
            'Procurar recursos: custa 1 moeda. Pode render 1 ou 2 unidades de um recurso sorteado, ou nada.',
          ),
        ),
      ),
    );
  }

  void mostrarLegenda() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        builder: (_, controle) => ListView(
          controller: controle,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Text(
              'O que cada casa faz',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            for (final nome in casasDoTabuleiro)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: infoCasas[nome]!.cor,
                  child: Icon(infoCasas[nome]!.icone, color: Colors.white, size: 20),
                ),
                title: Text(nome, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(infoCasas[nome]!.descricao),
              ),
          ],
        ),
      ),
    );
  }

  void mostrarInfoCasa(int indice) {
    final nome = casasDoTabuleiro[indice];
    final info = infoCasas[nome]!;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: info.cor,
              child: Icon(info.icone, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Casa ${indice + 1} • $nome',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(info.descricao),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───── Widgets auxiliares ─────

  Widget pilulaHud(IconData icone, String valor, String rotulo) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Icon(icone, color: Colors.white, size: 18),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  rotulo,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      );

  Widget barraVidaHud(Jogador jogador) {
    final fracao = jogador.vida / 100;
    final corBarra = fracao > 0.5
        ? Colors.white
        : (fracao > 0.25 ? Colors.amberAccent : Colors.redAccent);
    return Padding(
      padding: const EdgeInsets.fromLTRB(3, 10, 3, 0),
      child: Row(
        children: [
          const Icon(Icons.favorite, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: fracao,
                minHeight: 12,
                color: corBarra,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${jogador.vida}/100',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget hud() {
    final jogador = jogadorAtual;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [escurecer(jogador.cor, 0.45), escurecer(jogador.cor, 0.26)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Text(
                  jogador.pais.nome.substring(0, 1),
                  style: TextStyle(
                    color: escurecer(jogador.cor, 0.4),
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vez de ${jogador.pais.nome}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Rodada ${jogo.rodada} • ${jogador.pais.especialidade}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'O que cada casa faz',
                onPressed: mostrarLegenda,
                icon: const Icon(Icons.grid_view_rounded, color: Colors.white),
              ),
              IconButton(
                tooltip: 'Regras',
                onPressed: mostrarRegras,
                icon: const Icon(Icons.help_outline, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              pilulaHud(Icons.monetization_on, '${jogador.moedas}', 'Moedas'),
              pilulaHud(Icons.groups, '${jogador.tropas}/10', 'Tropas'),
              pilulaHud(Icons.flash_on, '${jogador.ataqueTotal}/10', 'Ataque'),
              pilulaHud(Icons.shield, '${jogador.defesaTotal}/10', 'Defesa'),
            ],
          ),
          barraVidaHud(jogador),
        ],
      ),
    );
  }

  // ───── Build principal ─────

  @override
  Widget build(BuildContext context) => Scaffold(
        bottomNavigationBar: NavigationBar(
          selectedIndex: abaSelecionada,
          onDestinationSelected: (novaAba) => atualizar(() => abaSelecionada = novaAba),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map),
              label: 'Tabuleiro',
            ),
            NavigationDestination(
              icon: Icon(Icons.shield_outlined),
              selectedIcon: Icon(Icons.shield),
              label: 'País',
            ),
            NavigationDestination(
              icon: Icon(Icons.groups_outlined),
              selectedIcon: Icon(Icons.groups),
              label: 'Jogadores',
            ),
            NavigationDestination(
              icon: Icon(Icons.history),
              label: 'Histórico',
            ),
          ],
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              hud(),
              Expanded(
                child: abaSelecionada == 0
                    ? abaMapa()
                    : abaSelecionada == 1
                        ? abaPais()
                        : abaSelecionada == 2
                            ? abaJogadores()
                            : abaHistorico(),
              ),
            ],
          ),
        ),
      );

  // ───── Aba: Tabuleiro ─────

  // Posição (linha, coluna) da casa [i] no contorno de um quadrado 5x5.
  (int, int) posicaoNaGrade(int i) {
    if (i <= 4) return (0, i);
    if (i <= 8) return (i - 4, 4);
    if (i <= 12) return (4, 12 - i);
    return (16 - i, 0);
  }

  Widget celulaTabuleiro(int i, double lado) {
    final nome = casasDoTabuleiro[i];
    final info = infoCasas[nome]!;
    final jogadoresAqui = jogo.jogadores.where((j) => j.posicao == i && j.vivo).toList();
    final ativa = jogadorAtual.posicao == i;
    final (linha, coluna) = posicaoNaGrade(i);

    return Positioned(
      left: coluna * lado,
      top: linha * lado,
      width: lado,
      height: lado,
      child: GestureDetector(
        onTap: () => mostrarInfoCasa(i),
        child: Container(
          margin: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            color: info.cor,
            borderRadius: BorderRadius.circular(12),
            border: ativa ? Border.all(color: Colors.white, width: 3) : null,
            boxShadow: ativa
                ? [BoxShadow(color: Colors.white.withValues(alpha: 0.6), blurRadius: 10)]
                : null,
          ),
          child: Stack(
            children: [
              Positioned(
                left: 6,
                top: 3,
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(info.icone, color: Colors.white, size: lado * 0.3),
                    Text(
                      nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (jogadoresAqui.isNotEmpty)
                Positioned(
                  left: 3,
                  right: 3,
                  bottom: 3,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 2,
                    children: [
                      for (final j in jogadoresAqui)
                        Container(
                          width: 13,
                          height: 13,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: j.cor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: j == jogadorAtual ? 2 : 1),
                          ),
                          child: Text(
                            j.pais.nome.substring(0, 1),
                            style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget tabuleiro() => LayoutBuilder(
        builder: (contexto, restricoes) {
          final lado = min(restricoes.maxWidth, 440.0) / 5;
          final casaAtual = casasDoTabuleiro[jogadorAtual.posicao];
          final infoAtual = infoCasas[casaAtual]!;

          return Center(
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: corMesa,
                borderRadius: BorderRadius.circular(24),
              ),
              child: SizedBox(
                width: lado * 5,
                height: lado * 5,
                child: Stack(
                  children: [
                    // Centro do tabuleiro: situação atual.
                    Positioned(
                      left: lado,
                      top: lado,
                      width: lado * 3,
                      height: lado * 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (filho, animacao) =>
                                ScaleTransition(scale: animacao, child: filho),
                            child: Container(
                              key: ValueKey(resultadoDado),
                              width: lado * 1.1,
                              height: lado * 1.1,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                resultadoDado?.toString() ?? '?',
                                style: TextStyle(
                                  fontSize: lado * 0.6,
                                  fontWeight: FontWeight.w900,
                                  color: corMesa,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Icon(infoAtual.icone, color: Colors.white, size: 18),
                          Text(
                            'Casa ${jogadorAtual.posicao + 1} • $casaAtual',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (int i = 0; i < casasDoTabuleiro.length; i++) celulaTabuleiro(i, lado),
                  ],
                ),
              ),
            ),
          );
        },
      );

  Widget passoDoTurno(int numero, String texto, {required bool feito, required bool ativo}) {
    final cor = jogadorAtual.cor;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: ativo ? cor.withValues(alpha: 0.14) : const Color(0xfff0f2ef),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ativo ? cor : Colors.transparent, width: 1.5),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 10,
              backgroundColor: feito ? Colors.green : (ativo ? cor : Colors.black26),
              child: feito
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : Text('$numero', style: const TextStyle(fontSize: 11, color: Colors.white)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                texto,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: ativo ? FontWeight.w700 : FontWeight.w500,
                  color: ativo || feito ? Colors.black87 : Colors.black45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget abaMapa() {
    final dadoRolado = resultadoDado != null;
    final fim = jogo.vencedor != null;
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        tabuleiro(),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    passoDoTurno(1, 'Rolar dado', feito: dadoRolado, ativo: !dadoRolado),
                    passoDoTurno(2, 'Encerrar turno', feito: false, ativo: dadoRolado),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 18, color: jogadorAtual.cor),
                    const SizedBox(width: 8),
                    Expanded(child: Text(mensagem, style: const TextStyle(height: 1.3))),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: escurecer(jogadorAtual.cor, 0.42),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: dadoRolado || fim ? null : iniciarTurno,
                        icon: const Icon(Icons.casino),
                        label: const Text('Rolar dado'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: dadoRolado && !fim ? encerrarTurno : null,
                        icon: const Icon(Icons.skip_next),
                        label: const Text('Encerrar turno'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: fim || acoesUsadas >= maxAcoesPorTurno ? null : sortearAcoes,
                    icon: const Icon(Icons.casino_outlined),
                    label: Text('Sortear ação ($acoesUsadas/$maxAcoesPorTurno)'),
                  ),
                ),
              ],
            ),
          ),
        ),
        Text(
          'Toque em uma casa do tabuleiro para ver o que ela faz.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black.withValues(alpha: 0.5), fontSize: 12),
        ),
      ],
    );
  }

  // ───── Aba: País ─────

  Widget barraAtributo(String rotulo, IconData icone, int valor, Color cor) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Icon(icone, size: 18, color: cor),
            const SizedBox(width: 8),
            SizedBox(
              width: 76,
              child: Text(rotulo, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: valor / 5,
                  minHeight: 10,
                  color: cor,
                  backgroundColor: cor.withValues(alpha: 0.15),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text('$valor/5', style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      );

  Widget cartaoRecurso(String recurso) {
    final quantidade = jogadorAtual.estoque[recurso] ?? 0;
    final tem = quantidade > 0;
    return Container(
      width: 98,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: tem ? jogadorAtual.cor.withValues(alpha: 0.12) : const Color(0xfff0f2ef),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(iconesRecursos[recurso], color: tem ? escurecer(jogadorAtual.cor, 0.4) : Colors.black26),
          const SizedBox(height: 4),
          Text(
            '$quantidade',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: tem ? Colors.black87 : Colors.black38,
            ),
          ),
          Text(
            recurso,
            style: TextStyle(fontSize: 11, color: tem ? Colors.black54 : Colors.black38),
          ),
        ],
      ),
    );
  }

  Widget usoRecurso(String recurso) {
    final funcao = funcoesRecursos[recurso]!;
    final pode = (jogadorAtual.estoque[recurso] ?? 0) >= custoUsoRecurso;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: pode ? jogadorAtual.cor.withValues(alpha: 0.15) : const Color(0xfff0f2ef),
        child: Icon(
          iconesRecursos[recurso],
          color: pode ? escurecer(jogadorAtual.cor, 0.4) : Colors.black26,
        ),
      ),
      title: Text(
        '$recurso → ${funcao.efeito}',
        style: TextStyle(fontWeight: FontWeight.w600, color: pode ? null : Colors.black38),
      ),
      subtitle: Text('${funcao.historia} (gasta $custoUsoRecurso)'),
      trailing: FilledButton(
        onPressed: pode && jogo.vencedor == null ? () => usarRecurso(recurso) : null,
        child: const Text('Usar'),
      ),
    );
  }

  Widget acaoPais({
    required IconData icone,
    required String titulo,
    required String subtitulo,
    required VoidCallback aoTocar,
    int? custo,
    bool habilitada = true,
  }) {
    final disponivel = habilitada && (custo == null || jogadorAtual.moedas >= custo);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: disponivel ? jogadorAtual.cor.withValues(alpha: 0.15) : const Color(0xfff0f2ef),
        child: Icon(icone, color: disponivel ? escurecer(jogadorAtual.cor, 0.4) : Colors.black26),
      ),
      title: Text(titulo, style: TextStyle(fontWeight: FontWeight.w600, color: disponivel ? null : Colors.black38)),
      subtitle: Text(subtitulo),
      trailing: custo == null
          ? const Icon(Icons.chevron_right)
          : Chip(
              avatar: const Icon(Icons.monetization_on, size: 16, color: corEconomia),
              label: Text('$custo'),
              visualDensity: VisualDensity.compact,
            ),
      onTap: jogo.vencedor != null ? null : aoTocar,
    );
  }

  Widget abaPais() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Atributos', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  barraAtributo('Ataque', Icons.flash_on, jogadorAtual.ataqueTotal, corMilitar),
                  barraAtributo('Defesa', Icons.shield, jogadorAtual.defesaTotal, corSocial),
                  barraAtributo('Comércio', Icons.handshake, jogadorAtual.pais.comercio, corEconomia),
                  barraAtributo('Produção', Icons.agriculture, jogadorAtual.pais.producao, corProducao),
                ],
              ),
            ),
          ),
          Text('Recursos', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final recurso in todosRecursos) cartaoRecurso(recurso)],
          ),
          const SizedBox(height: 18),
          Text('Usar recursos', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [for (final recurso in todosRecursos) usoRecurso(recurso)],
            ),
          ),
          const SizedBox(height: 10),
          Text('Ações', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                acaoPais(
                  icone: Icons.casino,
                  titulo: 'Sortear ações',
                  subtitulo:
                      'Role o dado e escolha 1 de 2 ações: guerra, aliança, negociação ou procurar recursos ($acoesUsadas/$maxAcoesPorTurno usadas)',
                  habilitada: acoesUsadas < maxAcoesPorTurno,
                  aoTocar: sortearAcoes,
                ),
                const Divider(height: 1),
                acaoPais(
                  icone: Icons.trending_up,
                  titulo: 'Melhorar ataque',
                  subtitulo: 'Ataque +1 (máximo 10)',
                  custo: 3,
                  aoTocar: () => melhorarAtributo(true),
                ),
                const Divider(height: 1),
                acaoPais(
                  icone: Icons.security,
                  titulo: 'Melhorar defesa',
                  subtitulo: 'Defesa +1 (máximo 10)',
                  custo: 3,
                  aoTocar: () => melhorarAtributo(false),
                ),
              ],
            ),
          ),
        ],
      );

  // ───── Aba: Jogadores ─────

  Widget abaJogadores() => ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Text(
            'Todos os países',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          for (final jogador in jogo.jogadores)
            Card(
              clipBehavior: Clip.antiAlias,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: jogador.vivo ? jogador.cor : Colors.black26, width: 7)),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: jogador.cor,
                          child: Text(
                            jogador.pais.nome.substring(0, 1),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            jogador.pais.nome,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (!jogador.vivo)
                          const Chip(
                            label: Text('Eliminado'),
                            visualDensity: VisualDensity.compact,
                          )
                        else if (jogador == jogadorAtual)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: jogador.cor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Vez atual',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.favorite, size: 18, color: corMilitar),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: jogador.vida / 100,
                              minHeight: 8,
                              color: corMilitar,
                              backgroundColor: corMilitar.withValues(alpha: 0.15),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${jogador.vida}/100', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.monetization_on, size: 18, color: corEconomia),
                        const SizedBox(width: 4),
                        Text('${jogador.moedas}', style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(width: 16),
                        for (int t = 0; t < 5; t++)
                          Icon(
                            Icons.shield,
                            size: 16,
                            color: t < jogador.tropas ? jogador.cor : Colors.black12,
                          ),
                        const Spacer(),
                        Icon(infoCasas[casasDoTabuleiro[jogador.posicao]]!.icone, size: 16, color: Colors.black54),
                        const SizedBox(width: 4),
                        Text(
                          'Casa ${jogador.posicao + 1}',
                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${jogador.recursoPrincipal}: ${jogador.estoque[jogador.recursoPrincipal]}',
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );

  // ───── Aba: Histórico ─────

  Widget abaHistorico() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Histórico da partida',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (jogo.historico.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Role o dado para começar. As jogadas aparecerão aqui.'),
              ),
            ),
          for (final registro in jogo.historico)
            Card(
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.history, color: Colors.black45),
                title: Text(registro),
              ),
            ),
        ],
      );
}

// ───────────────────────── NEGOCIAÇÃO ─────────────────────────

class Proposta {
  final Map<String, int> da; // o que o proponente entrega
  final Map<String, int> recebe; // o que o proponente pede
  int moedasDa;
  int moedasRecebe;

  Proposta({
    Map<String, int>? da,
    Map<String, int>? recebe,
    this.moedasDa = 0,
    this.moedasRecebe = 0,
  })  : da = {...?da},
        recebe = {...?recebe};

  // Usada na contraproposta: quem recebia passa a propor.
  Proposta invertida() => Proposta(
        da: recebe,
        recebe: da,
        moedasDa: moedasRecebe,
        moedasRecebe: moedasDa,
      );
}

// Valor aproximado de cada recurso, em moedas (serve só como guia na mesa).
const valorRecursos = <String, int>{
  'Alimentos': 1,
  'Madeira': 1,
  'Ferro': 2,
  'Medicamentos': 2,
  'Especiarias': 2,
  'Aço': 3,
  'Cristais': 3,
};

int valorTotal(Map<String, int> recursos, int moedas) =>
    moedas +
    recursos.entries.fold<int>(0, (soma, e) => soma + e.value * (valorRecursos[e.key] ?? 1));

class MesaNegociacao extends StatefulWidget {
  final Jogador proponente, receptor;
  final Proposta inicial;
  final String titulo;

  const MesaNegociacao({
    super.key,
    required this.proponente,
    required this.receptor,
    required this.inicial,
    required this.titulo,
  });

  @override
  State<MesaNegociacao> createState() => _MesaNegociacaoState();
}

class _MesaNegociacaoState extends State<MesaNegociacao> {
  late final Proposta p = Proposta(
    da: widget.inicial.da,
    recebe: widget.inicial.recebe,
    moedasDa: widget.inicial.moedasDa,
    moedasRecebe: widget.inicial.moedasRecebe,
  );

  int totalRecursos(Map<String, int> m) => m.values.fold<int>(0, (a, b) => a + b);

  // Cada lado precisa dar algo e a troca deve incluir ao menos 1 recurso.
  bool get valida {
    final dando = totalRecursos(p.da) + p.moedasDa;
    final recebendo = totalRecursos(p.recebe) + p.moedasRecebe;
    return dando > 0 && recebendo > 0 && totalRecursos(p.da) + totalRecursos(p.recebe) > 0;
  }

  Widget linha(IconData icone, String rotulo, int valor, int maximo, ValueChanged<int> aoMudar) {
    final atual = min(valor, maximo);
    return Row(
      children: [
        Icon(icone, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(rotulo, style: const TextStyle(fontSize: 13))),
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: atual > 0 ? () => aoMudar(atual - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        SizedBox(
          width: 24,
          child: Text('$atual', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: atual < maximo ? () => aoMudar(atual + 1) : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }

  Widget secao(Jogador quemDa, Jogador quemRecebe, Map<String, int> mapa, int moedas,
      ValueChanged<int> aoMudarMoedas) {
    final disponiveis = todosRecursos.where((r) => (quemDa.estoque[r] ?? 0) > 0).toList();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: quemDa.cor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: quemDa.cor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${quemDa.pais.nome} dá', style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          if (disponiveis.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text('Sem recursos para oferecer.', style: TextStyle(color: Colors.black54, fontSize: 12)),
            ),
          for (final recurso in disponiveis)
            linha(
              iconesRecursos[recurso]!,
              '$recurso (vale ${valorRecursos[recurso] ?? 1}) • tem ${quemDa.estoque[recurso]}',
              mapa[recurso] ?? 0,
              max(0, min(quemDa.estoque[recurso] ?? 0, 12 - (quemRecebe.estoque[recurso] ?? 0))),
              (v) => setState(() => mapa[recurso] = v),
            ),
          linha(Icons.monetization_on, 'Moedas • tem ${quemDa.moedas}', moedas, quemDa.moedas, aoMudarMoedas),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(widget.titulo, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(
                  '${widget.proponente.pais.nome} negocia com ${widget.receptor.pais.nome}',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        secao(widget.proponente, widget.receptor, p.da, p.moedasDa,
                            (v) => setState(() => p.moedasDa = v)),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Icon(Icons.swap_vert, color: Colors.black45),
                        ),
                        secao(widget.receptor, widget.proponente, p.recebe, p.moedasRecebe,
                            (v) => setState(() => p.moedasRecebe = v)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  valida
                      ? 'Valor aproximado: ${widget.proponente.pais.nome} dá ${valorTotal(p.da, p.moedasDa)} • '
                          '${widget.receptor.pais.nome} dá ${valorTotal(p.recebe, p.moedasRecebe)}'
                      : 'Cada lado precisa dar algo, e a troca deve ter pelo menos 1 recurso.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: valida ? () => Navigator.pop(context, p) : null,
                      child: const Text('Enviar proposta'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
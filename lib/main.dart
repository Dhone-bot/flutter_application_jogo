import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const ConquistaApp());

// ───────────────────────── MODELOS ─────────────────────────

class Pais {
  final String nome, especialidade;
  final int ataque, defesa, comercio, producao;
  final List<String> recursos;

  const Pais(
    this.nome,
    this.ataque,
    this.defesa,
    this.comercio,
    this.producao,
    this.especialidade,
    this.recursos,
  );
}

const todosPaises = [
  Pais('Veridânia', 2, 3, 3, 5, 'Florestas e agricultura', ['Alimentos', 'Madeira']),
  Pais('Nortélia', 3, 5, 2, 4, 'Montanhas e minerais', ['Ferro']),
  Pais('Solária', 5, 2, 3, 4, 'Deserto e energia', ['Energia']),
  Pais('Thalassa', 2, 3, 5, 4, 'Mar e pesca', ['Alimentos']),
  Pais('Zafira', 2, 3, 4, 4, 'Cristais e gemas', ['Cristais']),
  Pais('Karnor', 5, 4, 2, 3, 'Metalurgia', ['Aço']),
  Pais('Ismara', 2, 3, 3, 5, 'Ervas e cura', ['Medicamentos']),
  Pais('Druvânia', 3, 2, 2, 3, 'Espionagem e artefatos', ['Cristais']),
  Pais('Selvion', 1, 2, 5, 4, 'Especiarias e alimentos', ['Alimentos']),
];

const todosRecursos = [
  'Alimentos',
  'Ferro',
  'Aço',
  'Energia',
  'Cristais',
  'Medicamentos',
  'Especiarias',
  'Madeira',
];

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

class Jogador {
  final Pais pais;
  int moedas = 3;
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

  int get ataqueTotal => min(5, pais.ataque + melhoriasAtaque);
  int get defesaTotal => min(5, pais.defesa + melhoriasDefesa);
  String get recursoPrincipal => pais.recursos.first;
}

class Jogo {
  final List<Jogador> jogadores;
  final Random aleatorio = Random();
  int indiceTurno = 0;
  int rodada = 1;
  final List<String> historico = [];

  Jogo(this.jogadores);

  Jogador get jogadorAtivo => jogadores[indiceTurno];

  void proximoTurno() {
    indiceTurno++;
    if (indiceTurno >= jogadores.length) {
      indiceTurno = 0;
      rodada++;
    }
  }

  void registrar(String texto) => historico.insert(0, 'Rodada $rodada • $texto');
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
                  const Icon(
                    Icons.public,
                    color: Color.fromARGB(255, 43, 10, 187),
                    size: 62,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'CONQUISTA & COMÉRCIO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Um mundo. Nove nações. Uma disputa por poder.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Jogadores',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  DropdownButtonFormField<int>(
                    value: quantidadeJogadores,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (int numero = 2; numero <= 9; numero++)
                        DropdownMenuItem(
                          value: numero,
                          child: Text('$numero jogadores'),
                        ),
                    ],
                    onChanged: (novoValor) =>
                        setState(() => quantidadeJogadores = novoValor!),
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
  int abaSelecionada = 0;
  String mensagem = 'Sua vez. Produza recursos e role o dado.';

  Jogador get jogadorAtual => jogo.jogadorAtivo;

  void atualizar([VoidCallback? alteracao]) => setState(alteracao ?? () {});

  void mostrarAviso(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  // ───── Escolha de alvo ─────

  Future<int?> escolherAlvo() async {
    final outrosJogadores =
        jogo.jogadores.where((jogador) => jogador != jogadorAtual).toList();

    return showDialog<int>(
      context: context,
      builder: (contextoDialogo) => SimpleDialog(
        title: const Text('Escolha um país'),
        children: [
          for (final jogador in outrosJogadores)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(
                contextoDialogo,
                jogo.jogadores.indexOf(jogador),
              ),
              child: Text(jogador.pais.nome),
            ),
        ],
      ),
    );
  }

  // ───── Turno ─────

  Future<void> iniciarTurno() async {
    if (resultadoDado != null) return;

    atualizar(() => jogadorAtual.estoque[jogadorAtual.recursoPrincipal] = min(
          12,
          (jogadorAtual.estoque[jogadorAtual.recursoPrincipal] ?? 0) + 2,
        ));

    final valorDado = jogo.aleatorio.nextInt(6) + 1;

    atualizar(() {
      resultadoDado = valorDado;
      jogadorAtual.posicao =
          (jogadorAtual.posicao + valorDado) % casasDoTabuleiro.length;
      mensagem =
          'Você tirou $valorDado e caiu em ${casasDoTabuleiro[jogadorAtual.posicao]}.';
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
        break;

      case 'Trigo':
        jogadorAtual.estoque['Alimentos'] =
            min(12, (jogadorAtual.estoque['Alimentos'] ?? 0) + 2);
        break;

      case 'Negociação':
        await negociar();
        break;

      case 'Aliança':
        await proporAlianca();
        break;

      case 'Defesa':
        jogadorAtual.bonusDefesaProximaBatalha = 2;
        mensagem = 'Bônus de +2 na próxima defesa.';
        break;

      case 'Guerra':
        await batalhar();
        break;

      case 'Exército':
        if (jogadorAtual.moedas >= 2 && jogadorAtual.tropas <= 3) {
          jogadorAtual.moedas -= 2;
          jogadorAtual.tropas = min(5, jogadorAtual.tropas + 2);
        } else {
          mostrarAviso('Precisa de 2 moedas e espaço para tropas.');
        }
        break;

      case 'Castelo':
        if (jogadorAtual.moedas >= 3 && jogadorAtual.defesaTotal < 5) {
          jogadorAtual.moedas -= 3;
          jogadorAtual.melhoriasDefesa++;
        } else {
          mostrarAviso('Precisa de 3 moedas; defesa máxima é 5.');
        }
        break;

      case 'Produção':
        jogadorAtual.estoque[jogadorAtual.recursoPrincipal] = min(
          12,
          (jogadorAtual.estoque[jogadorAtual.recursoPrincipal] ?? 0) + 2,
        );
        break;

      case 'Espionagem':
        final indiceAlvo = await escolherAlvo();
        if (indiceAlvo != null) {
          final alvo = jogo.jogadores[indiceAlvo];
          mensagem =
              '${alvo.pais.nome}: ${alvo.tropas} tropas. Recursos: ${alvo.estoque}';
        }
        break;

      case 'Navio':
        jogadorAtual.moedas += 2;
        break;

      case 'Evento':
        final sorteioEvento = jogo.aleatorio.nextInt(4);
        if (sorteioEvento == 0) jogadorAtual.moedas += 2;
        if (sorteioEvento == 1) {
          jogadorAtual.estoque['Alimentos'] =
              min(12, (jogadorAtual.estoque['Alimentos'] ?? 0) + 1);
        }
        if (sorteioEvento == 2) {
          jogadorAtual.tropas = min(5, jogadorAtual.tropas + 1);
        }
        mensagem = [
          'Ganhou 2 moedas.',
          'Ganhou 1 alimento.',
          'Ganhou 1 tropa.',
          'Nada aconteceu.',
        ][sorteioEvento];
        break;

      case 'Mobilização':
        mensagem =
            'Mobilização entre territórios vizinhos será ativada quando as fronteiras jogáveis forem definidas.';
        break;

      case 'Recuperação':
        jogadorAtual.tropas = min(5, jogadorAtual.tropas + 1);
        break;

      case 'Tesouro':
        jogadorAtual.moedas += 4;
        break;

      case 'Capital':
        if (!jogadorAtual.jaPassouPelaCapital) {
          jogadorAtual.moedas += 2;
          jogadorAtual.jaPassouPelaCapital = true;
        }
        break;
    }

    atualizar();
  }

  // ───── Negociação ─────

  Future<void> negociar() async {
    final indiceAlvo = await escolherAlvo();
    if (indiceAlvo == null) return;
    final alvo = jogo.jogadores[indiceAlvo];

    final recursoOferecido = await showDialog<String>(
      context: context,
      builder: (contextoDialogo) => SimpleDialog(
        title: const Text('Recurso para oferecer'),
        children: [
          for (final recurso in todosRecursos)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(contextoDialogo, recurso),
              child: Text(
                '$recurso • ${jogadorAtual.estoque[recurso]} disponíveis',
              ),
            ),
        ],
      ),
    );

    if (recursoOferecido == null ||
        (jogadorAtual.estoque[recursoOferecido] ?? 0) < 1) {
      mostrarAviso('Você não tem esse recurso.');
      return;
    }

    final controladorPreco = TextEditingController(text: '1');

    final preco = await showDialog<int>(
      context: context,
      builder: (contextoDialogo) => AlertDialog(
        title: const Text('Preço em moedas (1 a 3)'),
        content: TextField(
          controller: controladorPreco,
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contextoDialogo),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              contextoDialogo,
              int.tryParse(controladorPreco.text),
            ),
            child: const Text('Oferecer'),
          ),
        ],
      ),
    );

    if (preco == null || preco < 1 || preco > 3 || alvo.moedas < preco) return;

    final aceitou = await showDialog<bool>(
      context: context,
      builder: (contextoDialogo) => AlertDialog(
        title: Text('Oferta para ${alvo.pais.nome}'),
        content: Text('1 $recursoOferecido por $preco moeda(s).'),
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
      jogadorAtual.estoque[recursoOferecido] =
          (jogadorAtual.estoque[recursoOferecido] ?? 0) - 1;
      alvo.estoque[recursoOferecido] =
          (alvo.estoque[recursoOferecido] ?? 0) + 1;
      alvo.moedas -= preco;
      jogadorAtual.moedas += preco;
      jogo.registrar(
        '${alvo.pais.nome} comprou 1 $recursoOferecido por $preco moedas.',
      );
      atualizar();
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
      jogo.registrar(
        'Aliança de 3 rodadas entre ${jogadorAtual.pais.nome} e ${alvo.pais.nome}.',
      );
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

    final forcaAtaque = jogo.aleatorio.nextInt(6) +
        1 +
        jogadorAtual.tropas +
        jogadorAtual.ataqueTotal;

    final forcaDefesa = jogo.aleatorio.nextInt(6) +
        1 +
        defensor.defesaTotal +
        defensor.bonusDefesaProximaBatalha;

    final atacanteVenceu = forcaAtaque > forcaDefesa;

    if (atacanteVenceu) {
      jogadorAtual.tropas = max(0, jogadorAtual.tropas - 1);
      defensor.tropas = max(0, defensor.tropas - 1);
    } else {
      jogadorAtual.tropas = max(0, jogadorAtual.tropas - 1);
    }

    defensor.bonusDefesaProximaBatalha = 0;

    mensagem =
        'Ataque $forcaAtaque × defesa $forcaDefesa. ${atacanteVenceu ? jogadorAtual.pais.nome : defensor.pais.nome} venceu. Empate favorece a defesa.';
    jogo.registrar(mensagem);
    atualizar();

    await showDialog<void>(
      context: context,
      builder: (contextoDialogo) => AlertDialog(
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
  }

  // ───── Melhorias e fim de turno ─────

  void melhorarAtributo(bool melhorarAtaque) {
    final atributoAtual =
        melhorarAtaque ? jogadorAtual.ataqueTotal : jogadorAtual.defesaTotal;

    if (jogadorAtual.moedas < 3 || atributoAtual >= 5) {
      mostrarAviso('Precisa de 3 moedas e atributo abaixo de 5.');
      return;
    }

    atualizar(() {
      jogadorAtual.moedas -= 3;
      if (melhorarAtaque) jogadorAtual.melhoriasAtaque++;
      // atenção: está fora do "if", então a defesa sobe sempre
      jogadorAtual.melhoriasDefesa++;
    });
  }

  void encerrarTurno() {
    if (resultadoDado == null) return;

    atualizar(() {
      resultadoDado = null;
      jogo.proximoTurno();
      mensagem = 'Vez de ${jogadorAtual.pais.nome}.';
    });
  }

  // ───── Widgets auxiliares ─────

  Widget cardEstatistica(String titulo, String valor, IconData icone) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xfff0f4f0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 16, color: const Color(0xff28634d)),
            const SizedBox(width: 6),
            Text(
              '$titulo $valor',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );

  // ───── Build principal ─────

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Conquista & Comércio',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              tooltip: 'Regras',
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const AlertDialog(
                  title: Text('Regras rápidas'),
                  content: Text(
                    'No início do turno, receba 2 unidades do recurso principal. '
                    'Role o dado e resolva a casa. Guerra custa 2 moedas. '
                    'Ataque = dado + tropas + ataque. Defesa = dado + defesa + bônus. '
                    'Maior resultado vence; empate favorece a defesa.',
                  ),
                ),
              ),
              icon: const Icon(Icons.help_outline),
            ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: abaSelecionada,
          onDestinationSelected: (novaAba) =>
              atualizar(() => abaSelecionada = novaAba),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map),
              label: 'Mapa',
            ),
            NavigationDestination(
              icon: Icon(Icons.shield_outlined),
              label: 'País',
            ),
            NavigationDestination(
              icon: Icon(Icons.groups_outlined),
              label: 'Jogadores',
            ),
            NavigationDestination(
              icon: Icon(Icons.history),
              label: 'Histórico',
            ),
          ],
        ),
        body: SafeArea(
          child: abaSelecionada == 0
              ? abaMapa()
              : abaSelecionada == 1
                  ? abaPais()
                  : abaSelecionada == 2
                      ? abaJogadores()
                      : abaHistorico(),
        ),
      );

  // ───── Aba: Mapa ─────

  Widget abaMapa() => ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Mapa do mundo',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                'Rodada ${jogo.rodada}',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              'assets/mapa_mundo.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox(
                height: 240,
                child: Center(
                  child: Text('Não foi possível carregar o mapa.'),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sua vez: ${jogadorAtual.pais.nome}',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    mensagem,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      cardEstatistica(
                        'Moedas',
                        '${jogadorAtual.moedas}',
                        Icons.monetization_on_outlined,
                      ),
                      cardEstatistica(
                        'Tropas',
                        '${jogadorAtual.tropas}',
                        Icons.shield_outlined,
                      ),
                      cardEstatistica(
                        'Casa',
                        '${jogadorAtual.posicao + 1}',
                        Icons.flag_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: resultadoDado == null ? iniciarTurno : null,
                          icon: const Icon(Icons.casino),
                          label: const Text('Rolar dado'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: resultadoDado != null ? encerrarTurno : null,
                          child: const Text('Encerrar turno'),
                        ),
                      ),
                    ],
                  ),
                  if (resultadoDado != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Dado: $resultadoDado • ${casasDoTabuleiro[jogadorAtual.posicao]}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Text(
            'Países do mapa',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Wrap(
            spacing: 6,
            children: [
              for (final pais in todosPaises) Chip(label: Text(pais.nome)),
            ],
          ),
        ],
      );

  // ───── Aba: País ─────

  Widget abaPais() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            jogadorAtual.pais.nome,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            jogadorAtual.pais.especialidade,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              cardEstatistica('Ataque', '${jogadorAtual.ataqueTotal}/5', Icons.flash_on),
              cardEstatistica('Defesa', '${jogadorAtual.defesaTotal}/5', Icons.shield),
              cardEstatistica(
                'Comércio',
                '${jogadorAtual.pais.comercio}/5',
                Icons.handshake_outlined,
              ),
              cardEstatistica(
                'Produção',
                '${jogadorAtual.pais.producao}/5',
                Icons.agriculture,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text('Recursos', style: Theme.of(context).textTheme.titleLarge),
          Wrap(
            spacing: 6,
            children: [
              for (final recurso in todosRecursos)
                Chip(label: Text('$recurso: ${jogadorAtual.estoque[recurso]}')),
            ],
          ),
          const SizedBox(height: 16),
          Text('Ações', style: Theme.of(context).textTheme.titleLarge),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.swap_horiz),
                  title: const Text('Negociar recursos'),
                  subtitle: const Text('Ofereça 1 recurso por 1 a 3 moedas'),
                  onTap: negociar,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.handshake_outlined),
                  title: const Text('Propor aliança'),
                  subtitle: const Text('Pacto de 3 rodadas'),
                  onTap: proporAlianca,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.sports),
                  title: const Text('Iniciar guerra'),
                  subtitle: const Text('Custa 2 moedas'),
                  onTap: batalhar,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.trending_up),
                  title: const Text('Melhorar ataque'),
                  subtitle: const Text('Custa 3 moedas'),
                  onTap: () => melhorarAtributo(true),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Melhorar defesa'),
                  subtitle: const Text('Custa 3 moedas'),
                  onTap: () => melhorarAtributo(false),
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
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          for (final jogador in jogo.jogadores)
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(jogador.pais.nome.substring(0, 1)),
                ),
                title: Text(jogador.pais.nome),
                subtitle: Text(
                  '${jogador.moedas} moedas • ${jogador.tropas} tropas • ${jogador.recursoPrincipal}: ${jogador.estoque[jogador.recursoPrincipal]}',
                ),
                trailing: Text('Casa ${jogador.posicao + 1}'),
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
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (jogo.historico.isEmpty) const Text('As jogadas aparecerão aqui.'),
          for (final registro in jogo.historico)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(registro),
              ),
            ),
        ],
      );
}
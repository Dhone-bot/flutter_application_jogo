
import 'dart:math';
import 'package:flutter/material.dart';

void main()=>runApp(const ConquistaApp());
class Country {
 final String name,specialty; final int attack,defense,trade,production; final List<String> resources;
 const Country(this.name,this.attack,this.defense,this.trade,this.production,this.specialty,this.resources);
}
const countries=[
 Country('Veridânia',2,3,3,5,'Florestas e agricultura',['Alimentos','Madeira']),
 Country('Nortélia',3,5,2,4,'Montanhas e minerais',['Ferro']),
 Country('Solária',5,2,3,4,'Deserto e energia',['Energia']),
 Country('Thalassa',2,3,5,4,'Mar e pesca',['Alimentos']),
 Country('Zafira',2,3,4,4,'Cristais e gemas',['Cristais']),
 Country('Karnor',5,4,2,3,'Metalurgia',['Aço']),
 Country('Ismara',2,3,3,5,'Ervas e cura',['Medicamentos']),
 Country('Druvânia',3,2,2,3,'Espionagem e artefatos',['Cristais']),
 Country('Selvion',1,2,5,4,'Especiarias e alimentos',['Alimentos']),
];
const resources=['Alimentos','Ferro','Aço','Energia','Cristais','Medicamentos','Especiarias','Madeira'];
const spaces=['Moedas','Trigo','Negociação','Aliança','Defesa','Guerra','Exército','Castelo','Produção','Espionagem','Navio','Evento','Mobilização','Recuperação','Tesouro','Capital'];
class Player {
 final Country country; int coins=3,troops=3,pos=0,atkUp=0,defUp=0,defBonus=0; bool capital=false;
 final Map<String,int> stock={for(final r in resources)r:0};
 Player(this.country); int get attack=>min(5,country.attack+atkUp); int get defense=>min(5,country.defense+defUp); String get primary=>country.resources.first;
}
class Game {
 final List<Player> players; final Random rng=Random(); int turn=0,round=1; final List<String> log=[];
 Game(this.players); Player get active=>players[turn];
 void next(){turn++;if(turn>=players.length){turn=0;round++;}}
 void note(String s)=>log.insert(0,'Rodada $round • $s');
}
class ConquistaApp extends StatelessWidget {
 const ConquistaApp({super.key});
 @override Widget build(BuildContext context)=>MaterialApp(title:'Conquista & Comércio',debugShowCheckedModeBanner:false,
 theme:ThemeData(colorScheme:ColorScheme.fromSeed(seedColor:const Color(0xff28634d),brightness:Brightness.light),scaffoldBackgroundColor:const Color(0xfff5f6f3),useMaterial3:true,
 cardTheme:CardThemeData(color:Colors.white,elevation:0,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18),side:const BorderSide(color:Color(0xffe5e9e4))))),
 home:const SetupScreen());
}
class SetupScreen extends StatefulWidget {const SetupScreen({super.key});@override State<SetupScreen> createState()=>_SetupScreenState();}
class _SetupScreenState extends State<SetupScreen>{
 int count=2;
 @override Widget build(BuildContext context)=>Scaffold(body:Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:460),child:Padding(padding:const EdgeInsets.all(28),child:Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.stretch,children:[
 const Icon(Icons.public,color:Color(0xff28634d),size:62),const SizedBox(height:18),
 const Text('CONQUISTA & COMÉRCIO',textAlign:TextAlign.center,style:TextStyle(fontSize:23,fontWeight:FontWeight.w800,letterSpacing:1)),
 const SizedBox(height:8),const Text('Um mundo. Nove nações. Uma disputa por poder.',textAlign:TextAlign.center,style:TextStyle(color:Colors.black54)),
 const SizedBox(height:30),const Text('Jogadores',style:TextStyle(fontWeight:FontWeight.w600)),
 DropdownButtonFormField<int>(value:count,decoration:const InputDecoration(border:OutlineInputBorder()),items:[for(int i=2;i<=9;i++)DropdownMenuItem(value:i,child:Text('$i jogadores'))],onChanged:(v)=>setState(()=>count=v!)),
 const SizedBox(height:18),FilledButton(onPressed:(){final cs=[...countries]..shuffle();final ps=List.generate(count,(i){final p=Player(cs[i]);p.stock[p.primary]=3;if(p.country.resources.length>1)p.stock[p.country.resources[1]]=1;return p;});Navigator.push(context,MaterialPageRoute(builder:(_)=>GameScreen(game:Game(ps))));},child:const Padding(padding:EdgeInsets.all(14),child:Text('Começar partida'))),
 ])))));
 }

class GameScreen extends StatefulWidget {final Game game;const GameScreen({super.key,required this.game});@override State<GameScreen> createState()=>_GameScreenState();}
class _GameScreenState extends State<GameScreen>{
 late Game g=widget.game; int? die; int tab=0; String message='Sua vez. Produza recursos e role o dado.';
 Player get p=>g.active;
 void update([VoidCallback? fn])=>setState(fn??(){});
 void toast(String s){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(s)));}
 Future<int?> chooseTarget()async{final others=g.players.where((x)=>x!=p).toList();return showDialog<int>(context:context,builder:(c)=>SimpleDialog(title:const Text('Escolha um país'),children:[for(final x in others)SimpleDialogOption(onPressed:()=>Navigator.pop(c,g.players.indexOf(x)),child:Text(x.country.name))]));}
 Future<void> startTurn()async{
 if(die!=null)return;
 update(()=>p.stock[p.primary]=min(12,(p.stock[p.primary]??0)+2));
 final d=g.rng.nextInt(6)+1;
 update((){die=d;p.pos=(p.pos+d)%spaces.length;message='Você tirou $d e caiu em ${spaces[p.pos]}.';});
 g.note('${p.country.name} tirou $d e caiu em ${spaces[p.pos]}.');
 await resolveSpace();
 }
 Future<void> resolveSpace()async{
 switch(spaces[p.pos]){
 case 'Moedas':p.coins+=3;break;
 case 'Trigo':p.stock['Alimentos']=min(12,(p.stock['Alimentos']??0)+2);break;
 case 'Negociação':await trade();break;
 case 'Aliança':await alliance();break;
 case 'Defesa':p.defBonus=2;message='Bônus de +2 na próxima defesa.';break;
 case 'Guerra':await battle();break;
 case 'Exército':if(p.coins>=2&&p.troops<=3){p.coins-=2;p.troops=min(5,p.troops+2);}else toast('Precisa de 2 moedas e espaço para tropas.');break;
 case 'Castelo':if(p.coins>=3&&p.defense<5){p.coins-=3;p.defUp++;}else toast('Precisa de 3 moedas; defesa máxima é 5.');break;
 case 'Produção':p.stock[p.primary]=min(12,(p.stock[p.primary]??0)+2);break;
 case 'Espionagem':final i=await chooseTarget();if(i!=null){final q=g.players[i];message='${q.country.name}: ${q.troops} tropas. Recursos: ${q.stock}';}break;
 case 'Navio':p.coins+=2;break;
 case 'Evento':final e=g.rng.nextInt(4);if(e==0)p.coins+=2;if(e==1)p.stock['Alimentos']=min(12,(p.stock['Alimentos']??0)+1);if(e==2)p.troops=min(5,p.troops+1);message=['Ganhou 2 moedas.','Ganhou 1 alimento.','Ganhou 1 tropa.','Nada aconteceu.'][e];break;
 case 'Mobilização':message='Mobilização entre territórios vizinhos será ativada quando as fronteiras jogáveis forem definidas.';break;
 case 'Recuperação':p.troops=min(5,p.troops+1);break;
 case 'Tesouro':p.coins+=4;break;
 case 'Capital':if(!p.capital){p.coins+=2;p.capital=true;}break;
 }
 update();
 }
 Future<void> trade()async{
 final i=await chooseTarget();if(i==null)return;final q=g.players[i];
 final r=await showDialog<String>(context:context,builder:(c)=>SimpleDialog(title:const Text('Recurso para oferecer'),children:[for(final x in resources)SimpleDialogOption(onPressed:()=>Navigator.pop(c,x),child:Text('$x • ${p.stock[x]} disponíveis'))]));
 if(r==null||(p.stock[r]??0)<1){toast('Você não tem esse recurso.');return;}
 final ctl=TextEditingController(text:'1');
 final price=await showDialog<int>(context:context,builder:(c)=>AlertDialog(title:const Text('Preço em moedas (1 a 3)'),content:TextField(controller:ctl,keyboardType:TextInputType.number),actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('Cancelar')),FilledButton(onPressed:()=>Navigator.pop(c,int.tryParse(ctl.text)),child:const Text('Oferecer'))]));
 if(price==null||price<1||price>3||q.coins<price)return;
 final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:Text('Oferta para ${q.country.name}'),content:Text('1 $r por $price moeda(s).'),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Recusar')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Aceitar'))]));
 if(ok==true){p.stock[r]=(p.stock[r]??0)-1;q.stock[r]=(q.stock[r]??0)+1;q.coins-=price;p.coins+=price;g.note('${q.country.name} comprou 1 $r por $price moedas.');update();}
 }
 Future<void> alliance()async{final i=await chooseTarget();if(i==null)return;final q=g.players[i];final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:Text('Aliança com ${q.country.name}'),content:const Text('Pacto de 3 rodadas: cada país entrega 1 unidade de seu recurso principal ao outro por rodada. Aceitar?'),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Recusar')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Aceitar'))]));if(ok==true){g.note('Aliança de 3 rodadas entre ${p.country.name} e ${q.country.name}.');toast('Aliança registrada. Entregas ainda são manuais.');}}
 Future<void> battle()async{final i=await chooseTarget();if(i==null)return;final q=g.players[i];if(p.coins<2||p.troops<1){toast('Precisa de 2 moedas e pelo menos 1 tropa.');return;}p.coins-=2;final a=g.rng.nextInt(6)+1+p.troops+p.attack;final b=g.rng.nextInt(6)+1+q.defense+q.defBonus;final win=a>b;if(win){p.troops=max(0,p.troops-1);q.troops=max(0,q.troops-1);}else{p.troops=max(0,p.troops-1);}q.defBonus=0;message='Ataque $a × defesa $b. ${win?p.country.name:q.country.name} venceu. Empate favorece a defesa.';g.note(message);update();await showDialog<void>(context:context,builder:(c)=>AlertDialog(title:const Text('Resultado da batalha'),content:Text(message),actions:[FilledButton(onPressed:()=>Navigator.pop(c),child:const Text('Continuar'))]));}
 void upgrade(bool attack){if(p.coins<3||(attack?p.attack:p.defense)>=5){toast('Precisa de 3 moedas e atributo abaixo de 5.');return;}update((){p.coins-=3;if(attack)p.atkUp++;p.defUp++;
});}
 void finishTurn(){if(die==null)return;update((){die=null;g.next();message='Vez de ${p.country.name}.';});}
 Widget stat(String label,String value,IconData icon)=>Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:10),decoration:BoxDecoration(color:const Color(0xfff0f4f0),borderRadius:BorderRadius.circular(12)),child:Row(mainAxisSize:MainAxisSize.min,children:[Icon(icon,size:16,color:const Color(0xff28634d)),const SizedBox(width:6),Text('$label $value',style:const TextStyle(fontWeight:FontWeight.w600,fontSize:12))]));
 @override Widget build(BuildContext context)=>Scaffold(
 appBar:AppBar(title:const Text('Conquista & Comércio',style:TextStyle(fontWeight:FontWeight.bold)),centerTitle:false,actions:[IconButton(tooltip:'Regras',onPressed:()=>showDialog(context:context,builder:(_)=>const AlertDialog(title:Text('Regras rápidas'),content:Text('No início do turno, receba 2 unidades do recurso principal. Role o dado e resolva a casa. Guerra custa 2 moedas. Ataque = dado + tropas + ataque. Defesa = dado + defesa + bônus. Maior resultado vence; empate favorece a defesa.'))),icon:const Icon(Icons.help_outline))]),
 bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(v)=>update(()=>tab=v),destinations:const [NavigationDestination(icon:Icon(Icons.map_outlined),selectedIcon:Icon(Icons.map),label:'Mapa'),NavigationDestination(icon:Icon(Icons.shield_outlined),label:'País'),NavigationDestination(icon:Icon(Icons.groups_outlined),label:'Jogadores'),NavigationDestination(icon:Icon(Icons.history),label:'Histórico')]),
 body:SafeArea(child:tab==0?mapTab():tab==1?countryTab():tab==2?playersTab():historyTab()),
 );
 Widget mapTab()=>ListView(padding:const EdgeInsets.all(14),children:[
 Row(children:[Expanded(child:Text('Mapa do mundo',style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.bold))),Text('Rodada ${g.round}',style:const TextStyle(color:Colors.black54))]),
 const SizedBox(height:10),
 ClipRRect(borderRadius:BorderRadius.circular(18),child:Image.asset('assets/mapa_mundo.png',fit:BoxFit.contain,errorBuilder:(_,__,___)=>const SizedBox(height:240,child:Center(child:Text('Não foi possível carregar o mapa.'))))),
 const SizedBox(height:12),
 Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
 Text('Sua vez: ${p.country.name}',style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.bold)),
 Text(message,style:const TextStyle(color:Colors.black54)),const SizedBox(height:10),
 Wrap(spacing:8,runSpacing:8,children:[stat('Moedas','${p.coins}',Icons.monetization_on_outlined),stat('Tropas','${p.troops}',Icons.shield_outlined),stat('Casa','${p.pos+1}',Icons.flag_outlined)]),
 const SizedBox(height:12),Row(children:[Expanded(child:FilledButton.icon(onPressed:die==null?startTurn:null,icon:const Icon(Icons.casino),label:const Text('Rolar dado'))),const SizedBox(width:8),Expanded(child:OutlinedButton(onPressed:die!=null?finishTurn:null,child:const Text('Encerrar turno')))]),
 if(die!=null)Padding(padding:const EdgeInsets.only(top:8),child:Text('Dado: $die • ${spaces[p.pos]}',style:const TextStyle(fontWeight:FontWeight.bold))),
 ]))),
 Text('Países do mapa',style:Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.bold)),
 Wrap(spacing:6,children:[for(final c in countries)Chip(label:Text(c.name))]),
 ]);
 Widget countryTab()=>ListView(padding:const EdgeInsets.all(16),children:[
 Text(p.country.name,style:Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight:FontWeight.bold)),Text(p.country.specialty,style:const TextStyle(color:Colors.black54)),
 const SizedBox(height:14),Wrap(spacing:8,runSpacing:8,children:[stat('Ataque','${p.attack}/5',Icons.flash_on),stat('Defesa','${p.defense}/5',Icons.shield),stat('Comércio','${p.country.trade}/5',Icons.handshake_outlined),stat('Produção','${p.country.production}/5',Icons.agriculture)]),
 const SizedBox(height:18),Text('Recursos',style:Theme.of(context).textTheme.titleLarge),Wrap(spacing:6,children:[for(final r in resources)Chip(label:Text('$r: ${p.stock[r]}'))]),
 const SizedBox(height:16),Text('Ações',style:Theme.of(context).textTheme.titleLarge),
 Card(child:Column(children:[ListTile(leading:const Icon(Icons.swap_horiz),title:const Text('Negociar recursos'),subtitle:const Text('Ofereça 1 recurso por 1 a 3 moedas'),onTap:trade),const Divider(height:1),ListTile(leading:const Icon(Icons.handshake_outlined),title:const Text('Propor aliança'),subtitle:const Text('Pacto de 3 rodadas'),onTap:alliance),const Divider(height:1),ListTile(leading:const Icon(Icons.sports),title:const Text('Iniciar guerra'),subtitle:const Text('Custa 2 moedas'),onTap:battle),const Divider(height:1),ListTile(leading:const Icon(Icons.trending_up),title:const Text('Melhorar ataque'),subtitle:const Text('Custa 3 moedas'),onTap:()=>upgrade(true)),const Divider(height:1),ListTile(leading:const Icon(Icons.security),title:const Text('Melhorar defesa'),subtitle:const Text('Custa 3 moedas'),onTap:()=>upgrade(false))])),
 ]);
 Widget playersTab()=>ListView(padding:const EdgeInsets.all(14),children:[Text('Todos os países',style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.bold)),for(final x in g.players)Card(child:ListTile(leading:CircleAvatar(child:Text(x.country.name.substring(0,1))),title:Text(x.country.name),subtitle:Text('${x.coins} moedas • ${x.troops} tropas • ${x.primary}: ${x.stock[x.primary]}'),trailing:Text('Casa ${x.pos+1}')))]);
 Widget historyTab()=>ListView(padding:const EdgeInsets.all(16),children:[Text('Histórico da partida',style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.bold)),const SizedBox(height:10),if(g.log.isEmpty)const Text('As jogadas aparecerão aqui.'),for(final x in g.log)Card(child:Padding(padding:const EdgeInsets.all(12),child:Text(x)))]);
}

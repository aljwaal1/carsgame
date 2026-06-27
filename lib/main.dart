import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RetroV4App());
}

class RetroV4App extends StatelessWidget {
  const RetroV4App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ألعاب زمان V4.2',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xff07111f),
        appBarTheme: const AppBarTheme(centerTitle: true, backgroundColor: Color(0xff0b1220)),
      ),
      home: const Directionality(textDirection: TextDirection.rtl, child: HomeV4()),
    );
  }
}

class Sfx {
  static final AudioPlayer _p = AudioPlayer();
  static int _lastShot = 0;
  static Future<void> play(String path, {double volume = .72}) async {
    try {
      await _p.stop();
      await _p.play(AssetSource(path), volume: volume);
    } catch (_) {}
  }
  static void start() => play('sounds/shared/game_start.wav');
  static void over() => play('sounds/shared/game_over.wav');
  static void fuel() => play('sounds/fuel_plane/fuel_pickup.wav');
  static void boom() => play('sounds/fuel_plane/plane_explosion.wav');
  static void pass() => play('sounds/retro_road/car_pass.wav', volume: .45);
  static void stage() => play('sounds/retro_road/stage_clear.wav');
  static void shot(int tick) {
    if (tick - _lastShot > 10) {
      _lastShot = tick;
      play('sounds/fuel_plane/plane_shoot.wav', volume: .38);
    }
  }
}

class HomeV4 extends StatelessWidget {
  const HomeV4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xff020617), Color(0xff0f172a), Color(0xff082f49)]),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const SizedBox(height: 8),
              const Text('ألعاب زمان V4.2', textAlign: TextAlign.center, style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              const Text('تحسين رسومات السيارات والطريق والمنظور', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 28),
              GameTile(title: 'طائرة الوقود', icon: '✈️', text: 'إطلاق تلقائي وتحكم بالسحب أو الشريط.', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Directionality(textDirection: TextDirection.rtl, child: PlaneGame())))),
              const SizedBox(height: 16),
              GameTile(title: 'طريق التحمل', icon: '🏎️', text: 'أنت تلحق السيارات أمامك وتتجاوزها. رسومات أوضح وطريق أوسع.', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Directionality(textDirection: TextDirection.rtl, child: RoadGame())))),
              const Spacer(),
              const Text('نسخة أصلية بروح ألعاب التحمل القديمة.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 12)),
            ]),
          ),
        ),
      ),
    );
  }
}

class GameTile extends StatelessWidget {
  const GameTile({super.key, required this.title, required this.icon, required this.text, required this.onTap});
  final String title, icon, text;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(28),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(.08), borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.white12)),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 42)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(text, style: const TextStyle(color: Colors.white70)),
        ])),
        const Icon(Icons.play_circle_fill, size: 34, color: Colors.lightBlueAccent),
      ]),
    ),
  );
}

class RetroButton extends StatelessWidget {
  const RetroButton({super.key, required this.text, required this.onTap, this.icon});
  final String text;
  final IconData? icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
    onPressed: onTap,
    icon: Icon(icon ?? Icons.play_arrow),
    label: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
  );
}

class StartCard extends StatelessWidget {
  const StartCard({super.key, required this.title, required this.subtitle, required this.onTap});
  final String title, subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.all(22),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: Colors.black.withOpacity(.70), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white24)),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
      const SizedBox(height: 18),
      RetroButton(text: 'ابدأ', icon: Icons.play_arrow, onTap: onTap),
    ]),
  );
}

class PixelArt {
  static void draw(Canvas canvas, Offset center, double px, List<String> rows, Map<String, Color> pal, {double shadow = 0}) {
    final maxCols = rows.map((e) => e.length).fold<int>(0, math.max);
    final origin = Offset(center.dx - maxCols * px / 2, center.dy - rows.length * px / 2);
    if (shadow > 0) canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(origin.dx + shadow, origin.dy + shadow, maxCols * px, rows.length * px), Radius.circular(px)), Paint()..color = Colors.black.withOpacity(.36));
    for (var y = 0; y < rows.length; y++) {
      for (var x = 0; x < rows[y].length; x++) {
        final color = pal[rows[y][x]];
        if (color == null) continue;
        canvas.drawRect(Rect.fromLTWH(origin.dx + x * px, origin.dy + y * px, px + .12, px + .12), Paint()..color = color);
      }
    }
  }
}

class PlaneObj {
  PlaneObj({required this.x, required this.y, required this.kind, required this.size});
  double x, y, size;
  int kind;
}

class Bullet {
  Bullet(this.x, this.y);
  double x, y;
}

class PlaneGame extends StatefulWidget {
  const PlaneGame({super.key});
  @override
  State<PlaneGame> createState() => _PlaneGameState();
}

class _PlaneGameState extends State<PlaneGame> {
  final rnd = math.Random();
  Timer? timer;
  double planeX = .5;
  double fuel = 100;
  int score = 0, distance = 0, tick = 0, level = 1;
  bool running = false, gameOver = false;
  final objects = <PlaneObj>[];
  final bullets = <Bullet>[];

  void start() {
    timer?.cancel();
    planeX = .5; fuel = 100; score = 0; distance = 0; tick = 0; level = 1;
    running = true; gameOver = false; objects.clear(); bullets.clear(); Sfx.start();
    timer = Timer.periodic(const Duration(milliseconds: 33), (_) => step());
    setState(() {});
  }

  void step() {
    if (!running) return;
    tick++; distance++; level = 1 + distance ~/ 1800;
    final speed = math.min(.014, .0048 + level * .00065);
    fuel -= .032;
    if (tick % 12 == 0) score++;
    if (tick % 9 == 0) { bullets.add(Bullet(planeX - .018, .735)); bullets.add(Bullet(planeX + .018, .735)); Sfx.shot(tick); }
    if (rnd.nextDouble() < (.014 + level * .0015).clamp(.014, .030)) {
      final r = rnd.nextDouble(); final kind = r < .27 ? 0 : r < .76 ? 1 : 2;
      objects.add(PlaneObj(x: .12 + rnd.nextDouble() * .76, y: -.08, kind: kind, size: kind == 0 ? .048 : .062));
    }
    for (final b in bullets) b.y -= .034;
    for (final o in objects) o.y += speed;
    bullets.removeWhere((b) => b.y < -.05); objects.removeWhere((o) => o.y > 1.12);
    final hitO = <PlaneObj>[]; final hitB = <Bullet>[];
    for (final b in bullets) {
      for (final o in objects) {
        if (o.kind != 0 && (b.x - o.x).abs() < o.size * .8 && (b.y - o.y).abs() < o.size) { hitO.add(o); hitB.add(b); score += 60; Sfx.boom(); break; }
      }
    }
    objects.removeWhere(hitO.contains); bullets.removeWhere(hitB.contains);
    for (final o in List<PlaneObj>.from(objects)) {
      if ((planeX - o.x).abs() < o.size * .86 && (.80 - o.y).abs() < o.size * .95) {
        if (o.kind == 0) { fuel = math.min(100, fuel + 20); score += 120; objects.remove(o); Sfx.fuel(); }
        else { running = false; gameOver = true; Sfx.over(); }
      }
    }
    if (fuel <= 0) { running = false; gameOver = true; Sfx.over(); }
    if (mounted) setState(() {});
  }

  void setPlane(double value) { if (!running) return; planeX = value.clamp(.08, .92).toDouble(); setState(() {}); }
  @override void dispose() { timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final fuelColor = fuel > 45 ? Colors.greenAccent : fuel > 20 ? Colors.orangeAccent : Colors.redAccent;
    return Scaffold(appBar: AppBar(title: const Text('طائرة الوقود')), body: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.all(12), child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Text('النقاط: $score', style: const TextStyle(fontWeight: FontWeight.w900)), Text('المسافة: ${distance ~/ 30}'), Text('مرحلة: $level')]),
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: fuel.clamp(0, 100) / 100, minHeight: 12, valueColor: AlwaysStoppedAnimation(fuelColor), backgroundColor: Colors.white12)),
      ])),
      Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 12), clipBehavior: Clip.antiAlias, decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white12)), child: LayoutBuilder(builder: (context, c) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (d) => setPlane(d.localPosition.dx / c.maxWidth),
        onPanUpdate: (d) => setPlane(d.localPosition.dx / c.maxWidth),
        child: Stack(children: [
          CustomPaint(painter: PlanePainter(planeX: planeX, objects: objects, bullets: bullets, tick: tick), child: const SizedBox.expand()),
          if (!running) Center(child: StartCard(title: gameOver ? 'انتهت الجولة' : 'طائرة الوقود', subtitle: gameOver ? 'النقاط: $score' : 'إطلاق تلقائي وتحكم بالسحب أو الشريط', onTap: start)),
        ]),
      )))),
      Container(margin: const EdgeInsets.fromLTRB(14, 10, 14, 12), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.white.withOpacity(.07), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)), child: Column(children: [
        const Text('شريط تحكم مثل الماوس', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
        Slider(value: planeX.clamp(.08, .92), min: .08, max: .92, onChanged: running ? setPlane : null),
      ])),
    ])));
  }
}

class PlanePainter extends CustomPainter {
  PlanePainter({required this.planeX, required this.objects, required this.bullets, required this.tick});
  final double planeX; final List<PlaneObj> objects; final List<Bullet> bullets; final int tick;
  @override void paint(Canvas c, Size s) {
    final w=s.width,h=s.height; final bg=Offset.zero&s;
    c.drawRect(bg, Paint()..shader=const LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Color(0xff00111d),Color(0xff06334f),Color(0xff00111d)]).createShader(bg));
    final river=Path()..moveTo(w*.27,0)..cubicTo(w*.12,h*.23,w*.38,h*.42,w*.24,h*.66)..cubicTo(w*.14,h*.82,w*.17,h,w*.10,h)..lineTo(w*.90,h)..cubicTo(w*.83,h*.82,w*.86,h*.66,w*.76,h*.50)..cubicTo(w*.62,h*.30,w*.88,h*.18,w*.73,0)..close();
    c.drawPath(river, Paint()..shader=const LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Color(0xff155e75),Color(0xff0891b2),Color(0xff0e7490)]).createShader(bg));
    final bank=Paint()..color=const Color(0xff14532d); for(var i=0;i<16;i++){ final y=((i*64+tick*2)%(h+80)).toDouble()-40; c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0,y,w*.13,20),const Radius.circular(6)),bank); c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*.87,y+22,w*.13,20),const Radius.circular(6)),bank); }
    for(final b in bullets){ final o=Offset(b.x*w,b.y*h); c.drawCircle(o,5,Paint()..color=const Color(0xfffff176)); c.drawCircle(o,11,Paint()..color=const Color(0xfffff176).withOpacity(.15)); }
    for(final o in objects) _obj(c,s,o);
    PixelArt.draw(c, Offset(planeX*w,h*.80), math.max(4,w*.014), const ['.....C.....','....CCC....','....YYY....','B..YYYYY..B','BBYYYYYYYBB','..RYYYR..','...Y.Y...','..B...B..'], {'C':const Color(0xffe0f2fe),'Y':const Color(0xff38bdf8),'B':const Color(0xff2563eb),'R':const Color(0xffef4444)}, shadow:5);
    final scan=Paint()..color=Colors.black.withOpacity(.08); for(double y=0;y<h;y+=5){c.drawRect(Rect.fromLTWH(0,y,w,1),scan);} }
  void _obj(Canvas c, Size s, PlaneObj o){ final center=Offset(o.x*s.width,o.y*s.height); final px=math.max(3,s.width*o.size/8); if(o.kind==0){ PixelArt.draw(c,center,px,const ['..GG..','..YY..','.YYYY.','.YRR.','.YRR.','.YYYY.','..GG..'],{'G':const Color(0xff22c55e),'Y':const Color(0xffffd166),'R':const Color(0xffef4444)},shadow:4); } else if(o.kind==2){ PixelArt.draw(c,center,px,const ['...R...','..RRR..','.RBRBR.','RRBBBBR','..BBB..','.B...B.'],{'R':const Color(0xffef4444),'B':const Color(0xff334155)},shadow:4); } else { PixelArt.draw(c,center,px,const ['..SS..','.SSSS.','SSSSSS','SDSDSS','.SSSS.','..SS..'],{'S':const Color(0xff94a3b8),'D':const Color(0xff334155)},shadow:4); }}
  @override bool shouldRepaint(covariant PlanePainter oldDelegate)=>true;
}

class RoadOpponent {
  RoadOpponent({required this.lane, required this.depth, required this.color, required this.speedBias});
  int lane; double depth; Color color; double speedBias;
}

class RoadGame extends StatefulWidget { const RoadGame({super.key}); @override State<RoadGame> createState()=>_RoadGameState(); }

class _RoadGameState extends State<RoadGame> {
  final rnd=math.Random(); Timer? timer; int playerLane=2, score=0, distance=0, passed=0, target=40, day=1, tick=0; bool running=false, gameOver=false;
  final opponents=<RoadOpponent>[]; final colors=const [Color(0xffef4444),Color(0xffffd166),Color(0xff22c55e),Color(0xffa78bfa),Color(0xfff97316)];
  String get weather { final p=(passed%target)/target; if(p<.18)return 'نهار'; if(p<.34)return 'غروب'; if(p<.52)return 'ليل'; if(p<.68)return 'ضباب'; if(p<.84)return 'ثلج'; return 'مطر'; }
  void start(){ timer?.cancel(); playerLane=2; score=0; distance=0; passed=0; target=40; day=1; tick=0; running=true; gameOver=false; opponents.clear(); Sfx.start(); timer=Timer.periodic(const Duration(milliseconds:33),(_)=>step()); setState((){}); }
  void step(){ if(!running)return; tick++; distance++; if(tick%12==0)score++; final roadSpeed=math.min(.0135,.0048+day*.00055+distance/260000); final spawn=(.010+day*.0012).clamp(.010,.024); if(rnd.nextDouble()<spawn&&opponents.length<5){ final lane=rnd.nextInt(5); final close=opponents.any((o)=>o.lane==lane&&o.depth<.24); if(!close){opponents.add(RoadOpponent(lane:lane,depth:.045,color:colors[rnd.nextInt(colors.length)],speedBias:.82+rnd.nextDouble()*.28));}}
    for(final o in opponents){o.depth+=roadSpeed*o.speedBias;} final done=opponents.where((o)=>o.depth>1.08).length; if(done>0){passed+=done; score+=done*100; Sfx.pass(); opponents.removeWhere((o)=>o.depth>1.08);} if(passed>=target){day++; passed=0; target=math.min(90,target+12); score+=800; opponents.clear(); Sfx.stage();}
    for(final o in opponents){ if(o.depth>.78&&o.depth<.96&&o.lane==playerLane){running=false; gameOver=true; Sfx.over();}}
    if(mounted)setState((){});
  }
  void left(){ if(!running)return; playerLane=math.max(0,playerLane-1); setState((){}); } void right(){ if(!running)return; playerLane=math.min(4,playerLane+1); setState((){}); }
  @override void dispose(){timer?.cancel();super.dispose();}
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('طريق التحمل V4.2')),body:SafeArea(child:Column(children:[
    Padding(padding:const EdgeInsets.fromLTRB(12,8,12,8),child:Column(children:[Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children:[Text('النقاط: $score',style:const TextStyle(fontWeight:FontWeight.w900)),Text('اليوم: $day'),Text('تجاوز: $passed / $target')]),const SizedBox(height:7),ClipRRect(borderRadius:BorderRadius.circular(20),child:LinearProgressIndicator(value:(passed/target).clamp(0,1),minHeight:10,backgroundColor:Colors.white12))])),
    Expanded(child:Container(margin:const EdgeInsets.symmetric(horizontal:12),clipBehavior:Clip.antiAlias,decoration:BoxDecoration(borderRadius:BorderRadius.circular(22),border:Border.all(color:Colors.white12)),child:Stack(children:[CustomPaint(painter:RoadPainter(playerLane:playerLane,opponents:opponents,weather:weather,tick:tick,day:day),child:const SizedBox.expand()),Positioned(top:10,left:12,child:Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:6),decoration:BoxDecoration(color:Colors.black.withOpacity(.35),borderRadius:BorderRadius.circular(14)),child:Text(weather,style:const TextStyle(fontWeight:FontWeight.bold)))),if(!running)Center(child:StartCard(title:gameOver?'حادث!':'طريق التحمل',subtitle:gameOver?'النقاط: $score':'أنت تلحق السيارات أمامك وتتجاوزها. الهدف: $target سيارة',onTap:start))]))),
    Padding(padding:const EdgeInsets.fromLTRB(14,10,14,12),child:Row(children:[Expanded(child:RetroButton(text:'يسار',icon:Icons.keyboard_arrow_right,onTap:left)),const SizedBox(width:12),Expanded(child:RetroButton(text:'يمين',icon:Icons.keyboard_arrow_left,onTap:right))]))
  ])));
}

class RoadPainter extends CustomPainter {
  RoadPainter({required this.playerLane,required this.opponents,required this.weather,required this.tick,required this.day});
  final int playerLane, tick, day; final List<RoadOpponent> opponents; final String weather;
  double _ease(double d)=>math.pow(d.clamp(0.0,1.0),1.12).toDouble(); double _y(Size s,double d)=>s.height*(.40+.61*_ease(d)); double _rw(Size s,double d)=>s.width*(.16+.84*_ease(d)); double _laneX(Size s,int lane,double d){final w=_rw(s,d),left=s.width*.5-w/2;return left+w*((lane+.5)/5.0);} 
  @override void paint(Canvas c,Size s){_sky(c,s);_horizon(c,s);_road(c,s);_sideShoulders(c,s);_motion(c,s);_posts(c,s);final sorted=List<RoadOpponent>.from(opponents)..sort((a,b)=>a.depth.compareTo(b.depth));for(final o in sorted)_opp(c,s,o);_player(c,s);_weather(c,s);_vignette(c,s);}
  void _sky(Canvas c,Size s){List<Color> colors; switch(weather){case 'غروب':colors=const[Color(0xff35104f),Color(0xffe11d48),Color(0xfff59e0b)];break;case 'ليل':colors=const[Color(0xff020617),Color(0xff0f172a),Color(0xff1e293b)];break;case 'ضباب':colors=const[Color(0xff64748b),Color(0xffa8b3c4),Color(0xffdbe2eb)];break;case 'ثلج':colors=const[Color(0xff93c5fd),Color(0xffdbeafe),Color(0xffffffff)];break;case 'مطر':colors=const[Color(0xff0f172a),Color(0xff334155),Color(0xff475569)];break;default:colors=const[Color(0xff0ea5e9),Color(0xff67e8f9),Color(0xff86efac)];}
    c.drawRect(Offset.zero&s,Paint()..shader=LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:colors).createShader(Offset.zero&s)); if(weather=='ليل'){c.drawCircle(Offset(s.width*.78,s.height*.13),22,Paint()..color=Colors.white70);for(var i=0;i<22;i++){c.drawCircle(Offset((i*53%s.width).toDouble(),(18+i*19%(s.height*.24)).toDouble()),1.2,Paint()..color=Colors.white54);}}else{c.drawCircle(Offset(s.width*.76,s.height*.17),30,Paint()..color=const Color(0xfffff3b0));}}
  void _horizon(Canvas c,Size s){final mountain=Path()..moveTo(0,s.height*.36)..lineTo(s.width*.18,s.height*.25)..lineTo(s.width*.35,s.height*.36)..lineTo(s.width*.55,s.height*.23)..lineTo(s.width*.78,s.height*.36)..lineTo(s.width,s.height*.27)..lineTo(s.width,s.height*.44)..lineTo(0,s.height*.44)..close();c.drawPath(mountain,Paint()..color=weather=='ليل'?const Color(0xff0b1220):const Color(0xff2563eb).withOpacity(.22));final ground=weather=='ثلج'?const Color(0xfff8fafc):weather=='مطر'?const Color(0xff14532d):const Color(0xff16a34a);c.drawRect(Rect.fromLTWH(0,s.height*.40,s.width,s.height*.60),Paint()..color=ground);} 
  void _road(Canvas c,Size s){final road=Path()..moveTo(s.width*.455,s.height*.40)..lineTo(s.width*.545,s.height*.40)..lineTo(s.width*.985,s.height)..lineTo(s.width*.015,s.height)..close();c.drawPath(road,Paint()..shader=const LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Color(0xff4b5563),Color(0xff1f2937),Color(0xff020617)]).createShader(Rect.fromLTWH(0,s.height*.40,s.width,s.height*.60)));c.drawPath(road,Paint()..style=PaintingStyle.stroke..strokeWidth=5..color=Colors.white.withOpacity(.42));}
  void _sideShoulders(Canvas c,Size s){for(var i=0;i<16;i++){final d=(((i*64+tick*5)%760)/760).clamp(.03,.98);final y=_y(s,d),rw=_rw(s,d);final center=s.width*.5;final left=center-rw/2,right=center+rw/2;final size=6+d*18;final p=Paint()..color=(i%2==0?Colors.white:Colors.redAccent).withOpacity(.85);c.drawRect(Rect.fromCenter(center:Offset(left-4*d,y),width:size,height:4+d*8),p);c.drawRect(Rect.fromCenter(center:Offset(right+4*d,y),width:size,height:4+d*8),p);}}
  void _motion(Canvas c,Size s){final lane=Paint()..color=Colors.white.withOpacity(weather=='ضباب'?.25:.72);for(var i=0;i<17;i++){final d=(((i*60+tick*6)%780)/780).clamp(.025,.98);final y=_y(s,d);c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center:Offset(s.width*.5,y),width:2+d*7,height:12+d*46),const Radius.circular(4)),lane);}}
  void _posts(Canvas c,Size s){for(var i=0;i<10;i++){final d=(((i*83+tick*4)%820)/820).clamp(.06,.99);final y=_y(s,d),rw=_rw(s,d),left=s.width*.5-rw/2-14*d,right=s.width*.5+rw/2+14*d,size=3+d*8;_post(c,Offset(left,y),size);_post(c,Offset(right,y+20*d),size);}}
  void _post(Canvas c,Offset o,double size){c.drawRect(Rect.fromCenter(center:o,width:size,height:size*3.2),Paint()..color=Colors.white70);c.drawRect(Rect.fromCenter(center:o.translate(0,-size),width:size*1.4,height:size*.7),Paint()..color=Colors.redAccent);} 
  void _opp(Canvas c,Size s,RoadOpponent o){final x=_laneX(s,o.lane,o.depth),y=_y(s,o.depth);final scale=.32+o.depth*1.28;_drawCar(c,Offset(x,y),s.width*.062*scale,o.color,true,o.depth);} 
  void _player(Canvas c,Size s){final x=_laneX(s,playerLane,.88),y=s.height*.84;if(weather=='ليل'||weather=='ضباب'||weather=='مطر'){final light=Path()..moveTo(x-18,y-18)..lineTo(x-s.width*.20,y-s.height*.30)..lineTo(x+s.width*.20,y-s.height*.30)..lineTo(x+18,y-18)..close();c.drawPath(light,Paint()..color=const Color(0xfffff3b0).withOpacity(weather=='ضباب'?.20:.14));}_drawCar(c,Offset(x,y),s.width*.092,const Color(0xff38bdf8),false,.95);} 
  void _drawCar(Canvas c,Offset center,double width,Color body,bool opponent,double depth){final height=width*1.55;final shadow=RRect.fromRectAndRadius(Rect.fromCenter(center:center.translate(0,height*.16),width:width*1.18,height:height*.86),Radius.circular(width*.22));c.drawRRect(shadow,Paint()..color=Colors.black.withOpacity(.32));
    final bodyPath=Path()..moveTo(center.dx,center.dy-height*.54)..lineTo(center.dx-width*.42,center.dy-height*.30)..lineTo(center.dx-width*.50,center.dy+height*.36)..quadraticBezierTo(center.dx,center.dy+height*.58,center.dx+width*.50,center.dy+height*.36)..lineTo(center.dx+width*.42,center.dy-height*.30)..close();c.drawPath(bodyPath,Paint()..color=body);c.drawPath(bodyPath,Paint()..style=PaintingStyle.stroke..strokeWidth=math.max(1.2,width*.045)..color=Colors.white.withOpacity(.55));
    final hood=Path()..moveTo(center.dx,center.dy-height*.48)..lineTo(center.dx-width*.24,center.dy-height*.23)..lineTo(center.dx+width*.24,center.dy-height*.23)..close();c.drawPath(hood,Paint()..color=Colors.white.withOpacity(.18));
    final cabin=RRect.fromRectAndRadius(Rect.fromCenter(center:center.translate(0,-height*.12),width:width*.52,height:height*.30),Radius.circular(width*.09));c.drawRRect(cabin,Paint()..color=const Color(0xffdbeafe));c.drawRRect(cabin,Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=const Color(0xff0f172a).withOpacity(.6));
    final wheel=Paint()..color=const Color(0xff020617);c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(center.dx-width*.60,center.dy-height*.20,width*.17,height*.38),Radius.circular(width*.05)),wheel);c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(center.dx+width*.43,center.dy-height*.20,width*.17,height*.38),Radius.circular(width*.05)),wheel);c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(center.dx-width*.58,center.dy+height*.20,width*.17,height*.30),Radius.circular(width*.05)),wheel);c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(center.dx+width*.41,center.dy+height*.20,width*.17,height*.30),Radius.circular(width*.05)),wheel);
    final lamp=Paint()..color=opponent?const Color(0xfffff176):const Color(0xffef4444);c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(center.dx-width*.32,center.dy+height*.40,width*.18,height*.07),Radius.circular(2)),lamp);c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(center.dx+width*.14,center.dy+height*.40,width*.18,height*.07),Radius.circular(2)),lamp);}
  void _weather(Canvas c,Size s){if(weather=='ضباب')c.drawRect(Offset.zero&s,Paint()..color=Colors.white.withOpacity(.25));if(weather=='ليل')c.drawRect(Offset.zero&s,Paint()..color=Colors.black.withOpacity(.10));if(weather=='مطر'||weather=='ثلج'){for(var i=0;i<90;i++){final x=((i*61+tick*2)%s.width).toDouble(),y=((i*47+tick*5)%s.height).toDouble();if(weather=='مطر')c.drawLine(Offset(x,y),Offset(x-6,y+18),Paint()..color=const Color(0xff93c5fd).withOpacity(.70)..strokeWidth=1.5);else c.drawCircle(Offset(x,y),i%3==0?2.4:1.4,Paint()..color=Colors.white.withOpacity(.90));}}}
  void _vignette(Canvas c,Size s){c.drawRect(Offset.zero&s,Paint()..style=PaintingStyle.stroke..strokeWidth=12..color=Colors.black.withOpacity(.20));final scan=Paint()..color=Colors.black.withOpacity(.055);for(double y=0;y<s.height;y+=5){c.drawRect(Rect.fromLTWH(0,y,s.width,1),scan);}}
  @override bool shouldRepaint(covariant RoadPainter oldDelegate)=>true;
}

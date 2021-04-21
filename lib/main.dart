import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:soundpool/soundpool.dart';

var _soundPool = Soundpool();
var keySound = [];

Future<int> _loadSound(int soundNumber) async {
  var asset = await rootBundle.load("assets/note$soundNumber.wav");
  return await _soundPool.load(asset);
}

void playSound(int soundNumber) {
  _soundPool.play(keySound[soundNumber - 1]);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  keySound = [for (int i = 1; i < 8; ++i) await _loadSound(i)];
  runApp(ChangeNotifierProvider(
    create: (context) => Settings(),
    child: ParrotTrainerApp(),
  ));
}

class ParrotTrainerApp extends StatefulWidget {
  @override
  _ParrotTrainerAppState createState() => _ParrotTrainerAppState();
}

class _ParrotTrainerAppState extends State<ParrotTrainerApp> {
  bool settingsWidgetActive = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Consumer<Settings>(builder: (context, settings, child) {
            return TouchBackground(
              settings,
              color: Colors.grey,
              onAlternateTouch: () {
                setState(() {
                  settingsWidgetActive = !settingsWidgetActive;
                });
              },
              child: settingsWidgetActive ? SettingsWidget(settings) : TouchForeground(settings),
            );
          }),
        ),
      ),
    );
  }
}

class TouchBackground extends StatelessWidget {
  final Settings settings;
  final Color color;
  final Function()? onAlternateTouch;
  final Widget child;

  const TouchBackground(
    this.settings, {
    this.color = Colors.white,
    required this.child,
    this.onAlternateTouch,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: color, child: child),
        GestureDetector(
            onLongPress: () => onAlternateTouch?.call(),
            child: Icon(Icons.settings, size: 40, color: Colors.grey.shade600)),
      ],
    );
  }
}

class TouchForeground extends StatelessWidget {
  final Settings settings;

  const TouchForeground(this.settings, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          for (final t in settings.targets)
            TouchTarget(
                xpct: t.x,
                ypct: t.y,
                color: t.color,
                size: t.size,
                onTouch: () {
                  playSound(t.soundNo);
                  settings.reposition();
                }),
          //TouchTarget(xpct: 75, ypct: 25, color: Colors.yellow, size: settings.targetSize, onTouch: () => playSound(3)),
          //TouchTarget(xpct: 25, ypct: 75, color: Colors.green, size: settings.targetSize, onTouch: () => playSound(4)),
          //TouchTarget(xpct: 75, ypct: 75, color: Colors.blue.shade900, size: settings.targetSize, onTouch: () => playSound(6)),
        ],
      ),
    );
  }
}

class TouchTarget extends StatelessWidget {
  final double xpct;
  final double ypct;
  final Color color;
  final double size;
  final Function() onTouch;

  const TouchTarget({
    this.xpct = 50,
    this.ypct = 50,
    this.color = Colors.black,
    this.size = 50,
    required this.onTouch,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: MediaQuery.of(context).size.width * xpct / 100 - size / 2,
      top: MediaQuery.of(context).size.height * ypct / 100 - size / 2,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => onTouch(),
        onPanStart: (_) => onTouch(),
        child: SizedBox(
          width: size,
          height: size,
          child: Container(
            color: color,
          ),
        ),
      ),
    );
  }
}

class SettingsWidget extends StatelessWidget {
  final Settings settings;

  const SettingsWidget(this.settings, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints.loose(Size(double.infinity, 60)),
        child: Slider(
          value: settings.targetSize,
          min: 20,
          max: 320,
          divisions: 10,
          label: settings.targetSize.round().toString(),
          onChanged: (double value) => settings.targetSize = value,
        ),
      ),
    );
  }
}

class Target {
  final double x;
  final double y;
  final double size;
  final Color color;
  final int soundNo;

  Target({required this.x, required this.y, required this.size, required this.color, required this.soundNo});
}

// settings data model
class Settings extends ChangeNotifier {
  final Random _rng = Random();
  final List<Color> colors = [Colors.red, Colors.yellow, Colors.green, Colors.blue.shade900];

  List<Target> targets = [];

  Settings() {
    reposition();
  }

  double _targetSize = 230.0;
  double get targetSize => _targetSize;
  set targetSize(double targetSize) {
    _targetSize = targetSize;
    reposition();
    notifyListeners();
  }

  void reposition() {
    targets = [
      Target(
          x: 50 - 30 + _rng.nextDouble() * 60,
          y: 50 - 30 + _rng.nextDouble() * 60,
          size: _targetSize,
          color: colors[0],
          soundNo: 1),
    ];
    notifyListeners();
  }
}

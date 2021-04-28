import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:soundpool/soundpool.dart';

var _soundPool = Soundpool();
var keySound = [];

Future<int> _loadSound(int soundNumber) async {
  var asset = await rootBundle.load("assets/note$soundNumber.wav");
  return await _soundPool.load(asset);
}

void playSound(int soundNumber) {
  _soundPool.play(keySound[soundNumber]);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  keySound = [for (int i = 0; i < 8; ++i) await _loadSound(i)];
  runApp(ChangeNotifierProvider(
    create: (context) => AppState(),
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
          child: Consumer<AppState>(builder: (context, settings, child) {
            return TouchBackgroundWidget(
              settings,
              color: Colors.grey,
              onAlternateTouch: () {
                setState(() {
                  settingsWidgetActive = !settingsWidgetActive;
                });
              },
              child: settingsWidgetActive ? SettingsWidget(settings) : TouchForegroundWidget(settings),
            );
          }),
        ),
      ),
    );
  }
}

class SettingsWidget extends StatelessWidget {
  final AppState settings;

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

class TouchBackgroundWidget extends StatelessWidget {
  final AppState settings;
  final Color color;
  final Function()? onAlternateTouch;
  final Widget child;

  const TouchBackgroundWidget(
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
            child: Icon(Icons.settings, size: 80, color: Colors.black.withAlpha(10))),
      ],
    );
  }
}

class TouchForegroundWidget extends StatelessWidget {
  final AppState settings;

  const TouchForegroundWidget(this.settings, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          for (final targetConfig in settings.targets)
            TouchTargetWidget(
                config: targetConfig,
                onTouch: () {
                  playSound(targetConfig.soundNo);
                  settings.reposition();
                }),
        ],
      ),
    );
  }
}

class TouchTargetWidget extends StatelessWidget {
  final TargetConfig config;
  final Function() onTouch;

  const TouchTargetWidget({
    required this.config,
    required this.onTouch,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: MediaQuery.of(context).size.width * config.x / 100 - config.size / 2,
      top: MediaQuery.of(context).size.height * config.y / 100 - config.size / 2,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => onTouch(),
        onPanStart: (_) => onTouch(),
        child: SizedBox(
          width: config.size,
          height: config.size,
          child: Container(
            color: config.color,
            child: Transform.scale(
              scale: config.cueScale,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withAlpha(config.cueAlpha),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TargetConfig {
  double x;
  double y;
  double size;
  Color color;
  int soundNo;
  double cueScale = 0;
  int cueAlpha = 255;

  TargetConfig({
    required this.x,
    required this.y,
    required this.soundNo,
    this.size = 80,
    this.color = Colors.grey,
    this.cueScale = 0,
    this.cueAlpha = 255,
  });
}

// settings data model
class AppState extends ChangeNotifier {
  final Random _rng = Random();
  final List<Color> colors = [Colors.red, Colors.yellow, Colors.green, Colors.blue.shade900];

  List<TargetConfig> targets = [
    TargetConfig(x: 250, y: 250, color: Colors.red, cueScale: 0, soundNo: 0),
    TargetConfig(x: 50, y: 50, color: Colors.red, cueScale: 0.1, soundNo: 1),
  ];

  AppState() {
    reposition();
  }

  double _targetSize = 80.0;
  double get targetSize => _targetSize;
  set targetSize(double targetSize) {
    _targetSize = targetSize;
    reposition();
    notifyListeners();
  }

  void reposition() {
    for (var t in targets) {
      t
        ..x = 50 - 30 + _rng.nextDouble() * 60
        ..y = 50 - 30 + _rng.nextDouble() * 60
        ..size = _targetSize
        ..color = colors[0];
    }
    notifyListeners();
  }
}

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
          for (int i = 0; i < settings.targets.length; ++i)
            TouchTargetWidget(
                position: kSlotPositions[i],
                config: settings.targets[i],
                onTouch: () {
                  playSound(settings.targets[i].soundIndex);
                  settings.shuffle();
                }),
        ],
      ),
    );
  }
}

class TouchTargetWidget extends StatelessWidget {
  final Offset position;
  final TargetConfig config;
  final Function() onTouch;

  const TouchTargetWidget({
    required this.position,
    required this.config,
    required this.onTouch,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: MediaQuery.of(context).size.width * position.dx / 100 - config.size / 2,
      top: MediaQuery.of(context).size.height * position.dy / 100 - config.size / 2,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => onTouch(),
        // onPanStart: (_) => onTouch(),
        child: SizedBox(
          width: config.size,
          height: config.size,
          child: Container(
            color: config.color,
            child: Transform.scale(
              scale: config.cueScale / 100.0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (config.color == Colors.black ? Colors.white : Colors.black).withAlpha(config.cueAlpha),
                ),
              ),
            ),
          ),
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
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [SizedBox(height: 80, width: 100)],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SlotSetting(settings, settings.targets[0]),
              SlotSetting(settings, settings.targets[1]),
              SlotSetting(settings, settings.targets[2]),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SlotSetting(settings, settings.targets[3]),
              SlotSetting(settings, settings.targets[4]),
              SlotSetting(settings, settings.targets[5]),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SlotSetting(settings, settings.targets[6]),
              SlotSetting(settings, settings.targets[7]),
              SlotSetting(settings, settings.targets[8]),
            ],
          ),
        ],
      ),
    );
  }
}

class SlotSetting extends StatelessWidget {
  final AppState settings;
  final TargetConfig targetConfig;
  const SlotSetting(this.settings, this.targetConfig, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: Colors.grey.shade400,
        child: Column(
          children: [
            Slider(
              value: targetConfig.colorIndex.toDouble(),
              min: 0,
              max: 6,
              divisions: 6,
              activeColor: targetConfig.color,
              label: "color: ${targetConfig.colorName}",
              onChanged: (double value) {
                targetConfig.colorIndex = value.round();
                settings.notify();
              },
            ),
            Slider(
              value: targetConfig.size,
              min: 0,
              max: 200,
              divisions: 4,
              label: "size: ${targetConfig.size.round()}",
              onChanged: (double value) {
                targetConfig.size = value;
                settings.notify();
              },
            ),
            Slider(
              value: targetConfig.cueScale.toDouble(),
              min: 0,
              max: 50,
              divisions: 5,
              label: "cue scale: ${targetConfig.cueScale}%",
              onChanged: (double value) {
                targetConfig.cueScale = value.toInt();
                settings.notify();
              },
            ),
            Slider(
              value: targetConfig.cueAlpha.toDouble(),
              min: 5,
              max: 100,
              divisions: 9,
              label: "cue alpha: ${targetConfig.cueAlpha.toInt()}%",
              onChanged: (double value) {
                targetConfig.cueAlpha = value.toInt();
                settings.notify();
              },
            ),
            Slider(
              value: targetConfig.soundIndex.toDouble(),
              min: 0,
              max: 1,
              divisions: 1,
              label: "sound: ${targetConfig.soundIndex}",
              onChanged: (double value) {
                targetConfig.soundIndex = value.toInt();
                settings.notify();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TargetConfig {
  final Random _rng = Random();

  static const List<Color> _colors = [
    Colors.transparent,
    Colors.cyan,
    Colors.red,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.black,
    Colors.white,
  ];

  static const List<String> _colorNames = ["transparent", "random", "red", "yellow", "green", "blue", "black", "white"];

  int soundIndex;
  double size;
  int colorIndex;
  int cueScale; // 0 - 50%
  int cueAlpha; // 0 - 100 %

  Color get color => colorIndex == 1 // on index 1, give back a random color from red,yellow,green,blue
      ? _colors[_rng.nextInt(4) + 2]
      : _colors[colorIndex];
  String get colorName => _colorNames[colorIndex];

  TargetConfig({
    this.soundIndex = 0,
    this.size = 0,
    this.colorIndex = 0,
    this.cueScale = 0,
    this.cueAlpha = 100,
  });
}

const List<Offset> kSlotPositions = [
  Offset(20, 20),
  Offset(50, 20),
  Offset(80, 20),
  Offset(20, 50),
  Offset(50, 50),
  Offset(80, 50),
  Offset(20, 80),
  Offset(50, 80),
  Offset(80, 80),
];

// settings data model
class AppState extends ChangeNotifier {
  final Random _rng = Random();

  List<TargetConfig> targets = [
    TargetConfig(size: 100, cueScale: 30, soundIndex: 1),
    TargetConfig(size: 100, cueScale: 30, soundIndex: 1),
    TargetConfig(),
    TargetConfig(),
    TargetConfig(),
    TargetConfig(),
    TargetConfig(),
    TargetConfig(),
    TargetConfig(),
  ];

  AppState() {}

  void notify() {
    notifyListeners();
  }

  double _targetSize = 80.0;
  double get targetSize => _targetSize;
  set targetSize(double targetSize) {
    _targetSize = targetSize;
    notifyListeners();
  }

  void shuffle() {
    targets.shuffle(_rng);
    notifyListeners();
  }
}

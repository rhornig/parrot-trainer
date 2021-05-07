import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:soundpool/soundpool.dart';

// TODO baybe https://riverpod.dev/ would be a better state management solution?
// https://pub.dev/packages/get is also interesting

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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Consumer<AppState>(builder: (context, state, child) {
            return state.settingsPanelActive
                ? SettingsPanel(state)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PlayArea(state),
                      StatPanel(state),
                    ],
                  );
          }),
        ),
      ),
    );
  }
}

class StatPanel extends StatelessWidget {
  final AppState state;
  const StatPanel(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int sum = state.success + state.failure;
    int pct = (sum == 0) ? 0 : ((state.success / sum) * 100).round();

    return Expanded(
        child: Container(
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onLongPress: () {
              state
                ..failure = 0
                ..success = 0
                ..notify();
            },
            child: Text(
              "☺${state.success} ☹${state.failure}\n$pct% ∑$sum",
              style: TextStyle(color: Colors.white10, fontSize: 40),
              textAlign: TextAlign.end,
            ),
          ),
          GestureDetector(
            onLongPress: () {
              state
                ..settingsPanelActive = true
                ..notify();
            },
            child: Icon(Icons.settings, size: 80, color: Colors.white10),
          ),
        ],
      ),
    ));
  }
}

class PlayArea extends StatelessWidget {
  final AppState state;

  const PlayArea(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Stack(
        children: [
          Container(color: state.backgroundColor),
          GridView.count(
            crossAxisCount: 3,
            children: [
              for (int i = 0; i < state.targets.length; ++i)
                TouchTarget(
                    position: kSlotPositions[i],
                    config: state.targets[i],
                    onTouch: () {
                      state.executeConsequence(state.targets[i].consequence);
                    }),
            ],
          ),
        ],
      ),
    );
  }
}

class TouchTarget extends StatelessWidget {
  final Offset position;
  final TargetConfig config;
  final Function() onTouch;

  const TouchTarget({
    required this.position,
    required this.config,
    required this.onTouch,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque, // FIXME do we need this?
        onTapDown: (_) => onTouch(),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: config.size, maxHeight: config.size),
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

class SettingsPanel extends StatelessWidget {
  final AppState state;

  const SettingsPanel(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                  onPressed: () {
                    state
                      ..settingsPanelActive = false
                      ..notify();
                  },
                  child: Text("Ok")),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SlotSettingCard(state, state.targets[0]),
              SlotSettingCard(state, state.targets[1]),
              SlotSettingCard(state, state.targets[2]),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SlotSettingCard(state, state.targets[3]),
              SlotSettingCard(state, state.targets[4]),
              SlotSettingCard(state, state.targets[5]),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SlotSettingCard(state, state.targets[6]),
              SlotSettingCard(state, state.targets[7]),
              SlotSettingCard(state, state.targets[8]),
            ],
          ),
        ],
      ),
    );
  }
}

class SlotSettingCard extends StatelessWidget {
  final AppState state;
  final TargetConfig targetConfig;
  const SlotSettingCard(this.state, this.targetConfig, {Key? key}) : super(key: key);

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
                state.notify();
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
                state.notify();
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
                state.notify();
              },
            ),
            Slider(
              value: targetConfig.cueAlpha.toDouble(),
              min: 5,
              max: 100,
              divisions: 9,
              activeColor: Colors.blue.withAlpha(targetConfig.cueAlpha.toInt() * 2),
              label: "cue alpha: ${targetConfig.cueAlpha.toInt()}%",
              onChanged: (double value) {
                targetConfig.cueAlpha = value.toInt();
                state.notify();
              },
            ),
            Slider(
              value: targetConfig.consequence.toDouble(),
              activeColor: [Colors.red, Colors.orange, Colors.green][targetConfig.consequence],
              min: 0,
              max: 2,
              divisions: 2,
              label: "result: " + ["failure", "neutral", "success"][targetConfig.consequence],
              onChanged: (double value) {
                targetConfig.consequence = value.toInt();
                state.notify();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// data classes
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

  int consequence; // the result of action? 0-failure, 1-neutral, 2-success
  double size;
  int colorIndex;
  int cueScale; // 0 - 50%
  int cueAlpha; // 0 - 100 %

  Color get color => colorIndex == 1 // on index 1, give back a random color from red,yellow,green,blue
      ? _colors[_rng.nextInt(4) + 2]
      : _colors[colorIndex];
  String get colorName => _colorNames[colorIndex];

  TargetConfig({
    this.consequence = 1,
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
  bool settingsPanelActive = false;

  int success = 0;
  int failure = 0;
  Color backgroundColor = Colors.grey;

  List<TargetConfig> targets = [
    TargetConfig(size: 100, cueScale: 30, consequence: 2),
    TargetConfig(size: 100, cueScale: 30, consequence: 2),
    TargetConfig(),
    TargetConfig(),
    TargetConfig(),
    TargetConfig(),
    TargetConfig(),
    TargetConfig(),
    TargetConfig(),
  ];

  void notify() {
    notifyListeners();
  }

  void executeConsequence(int consequence) {
    if (consequence == 0) {
      // failure
      playSound(0);
      failure++;
      targets.shuffle(_rng);
      notifyListeners();
    }
    if (consequence == 2) {
      // success
      playSound(1);
      success++;
      targets.shuffle(_rng);
      notifyListeners();
    }
  }
}

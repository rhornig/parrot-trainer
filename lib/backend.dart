import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

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
    this.cueAlpha = 95,
  });
}

/// app state data model
class AppState extends ChangeNotifier {
  static const int kFailure = 0;
  static const int kNeutral = 1;
  static const int kSuccess = 2;

  bool settingsPanelVisible = false;
  bool playAreaVisible = true;

  // statistics counters
  int success = 0;
  int failure = 0;

  // timeouts after success or failure events
  int successDelay = 2;
  int failureDelay = 4;

  Color backgroundColor = Colors.grey;

  List<TargetConfig> targets = [
    TargetConfig(size: 100, cueScale: 30, consequence: kSuccess),
    TargetConfig(size: 100, cueScale: 30, consequence: kSuccess),
    TargetConfig(),
    TargetConfig(),
    TargetConfig(),
    TargetConfig(),
    TargetConfig(),
    TargetConfig(),
    TargetConfig(),
  ];

  /// notify all widgets listening on state changes
  void notify() {
    notifyListeners();
  }

  void executeConsequence(int consequence) {
    if (consequence == kFailure) {
      failure++;
      _playSound(Sound.failure);
      targets.shuffle();

      if (failureDelay != 0) {
        // turn off play area for a while
        playAreaVisible = false;
        // wait a bit and then turn back the play area
        Future.delayed(Duration(seconds: failureDelay), () {
          playAreaVisible = true;
          notifyListeners();
        });
      }
    }

    if (consequence == kNeutral) {}

    // success
    if (consequence == kSuccess) {
      success++;
      _playSound(Sound.success);
      targets.shuffle();

      if (successDelay != 0) {
        // turn off play area for a while
        playAreaVisible = false;
        // wait a bit and then turn back the play area
        Future.delayed(Duration(seconds: successDelay), () {
          playAreaVisible = true;
          notifyListeners();
        });
      }
    }

    notifyListeners();
  }
}

/// low latency sound engine
enum Sound { failure, success }
const _soundToFileName = {Sound.failure: "failure.wav", Sound.success: "success.wav"};

var _soundPool = Soundpool();
var _soundToId = Map<Sound, int>();

void _playSound(Sound sound) async {
  int soundId = _soundToId[sound] ?? await _soundPool.load(await rootBundle.load("assets/${_soundToFileName[sound]}"));
  if (soundId >= 0) {
    _soundToId[sound] = soundId;
  }
  _soundPool.play(soundId);
}

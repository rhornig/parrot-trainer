import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

/// data classes

// symbolic shape colors. Random colors must be at the end and they start with random1
enum ShapeColor { transparent, black, white, red, yellow, green, blue, random1, random2, random3, random4 }

extension ShapeColorExt on ShapeColor {
  static const _colorSounds = [Sound.none, Sound.none, Sound.none, Sound.piros, Sound.sarga, Sound.zold, Sound.kek];
  static const _colorValues = [
    Colors.transparent,
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.yellow,
    Colors.green,
    Colors.blue
  ];

  // trick: select randomly the r,y,g or b index if we address above the list size  (3 is the position of red in _colorValues)
  int _shapeColorToIndex() => index < _colorValues.length ? index : 3 + (index + AppState.colorRandom) % 4;

  Sound get sound => _colorSounds[_shapeColorToIndex()];
  Color get color => _colorValues[_shapeColorToIndex()];
  String get name => toString().replaceFirst('ShapeColor.', '');
}

class TargetConfig {
  int consequence; // the result of action? 0-failure, 1-neutral, 2-success
  double size;
  int cueScale; // 0 - 50%
  int cueAlpha; // 0 - 100 %

  ShapeColor shapeColor;

  TargetConfig({
    this.consequence = 1,
    this.size = 0,
    this.shapeColor = ShapeColor.transparent,
    this.cueScale = 0,
    this.cueAlpha = 95,
  });
}

/// app state data model
class AppState extends ChangeNotifier {
  static const int kFailure = 0;
  static const int kNeutral = 1;
  static const int kSuccess = 2;

  bool inputAllowed = true;
  bool settingsPanelVisible = false;
  bool playAreaVisible = true;

  // statistics counters
  int success = 0;
  int neutral = 0;
  int failure = 0;

  // timeouts after success or failure events
  int successDelay = 2;
  int failureDelay = 4;
  // delay offset of announcement relative to the play area display (in secs, can be negative)
  int announcementDelayOffset = 0; // TODO make this configurable

  ShapeColor announcedColor = ShapeColor.transparent;

  Color backgroundColor = Colors.grey;
  int backgroundConsequence = kNeutral;

  final Random _rng = Random();
  static int colorRandom = 0; // a random integer for color randomization

  List<TargetConfig> targets = [
    TargetConfig(size: 100, cueScale: 30, shapeColor: ShapeColor.random1, consequence: kSuccess),
    TargetConfig(size: 100, cueScale: 30, shapeColor: ShapeColor.random1, consequence: kSuccess),
    TargetConfig(size: 100, cueScale: 30, shapeColor: ShapeColor.random1, consequence: kSuccess),
    TargetConfig(),
    TargetConfig(),
    TargetConfig(),
    TargetConfig(),
    TargetConfig(),
    TargetConfig(),
  ];

  AppState() {
    _initSound();
  }

  /// notify all widgets listening on state changes
  void notify() => notifyListeners();

  void randomize() {
    // TODO make this configurable
    targets.shuffle();
    colorRandom = _rng.nextInt(1000);
  }

  void executeConsequence(int consequence) {
    // disable input after a touch to prevent multiple touches and registering a
    // touch event behind a target. Input will be allowed after a timeout.
    // touch events are first delivered to the topmost widgets
    inputAllowed = false;

    if (consequence == kFailure) {
      failure++;
      _playSound(Sound.failure);
      randomize();

      if (failureDelay != 0) {
        // turn off play area for a while
        playAreaVisible = false;
        // wait a bit and then turn back the play area
        Future.delayed(Duration(seconds: failureDelay), _revealPlayArea);
        // and optionally announce a cue
        if (announcedColor != ShapeColor.transparent)
          Future.delayed(Duration(seconds: failureDelay + announcementDelayOffset), _announceCue);
      }
    }

    if (consequence == kNeutral) {
      neutral++;
      Future.delayed(Duration(milliseconds: 500), _revealPlayArea);
    }

    // success
    if (consequence == kSuccess) {
      success++;
      _playSound(Sound.success);
      randomize();

      if (successDelay != 0) {
        // turn off play area for a while
        playAreaVisible = false;
        // wait a bit and then turn back the play area
        Future.delayed(Duration(seconds: successDelay), _revealPlayArea);
        // and optionally announce a cue
        if (announcedColor != ShapeColor.transparent)
          Future.delayed(Duration(seconds: successDelay + announcementDelayOffset), _announceCue);
      }
    }

    notifyListeners();
  }

  void _announceCue() {
    // announce color cue
    _playSound(announcedColor.sound);
    // TODO announce other cues like shape, size, number
  }

  // show play area and re-enable inputs
  void _revealPlayArea() {
    playAreaVisible = true;
    inputAllowed = true;
    notifyListeners();
  }
}

/// low latency sound engine
enum Sound { none, failure, success, piros, kek, zold, sarga, egy, ketto, harom, kor, haromszog, negyszog }
const _soundToFileName = {
  Sound.failure: "failure.mp3",
  Sound.success: "success.mp3",
  Sound.piros: "piros.mp3",
  Sound.kek: "kek.mp3",
  Sound.zold: "zold.mp3",
  Sound.sarga: "sarga.mp3",
  Sound.egy: "egy.mp3",
  Sound.ketto: "ketto.mp3",
  Sound.harom: "harom.mp3",
  Sound.kor: "kor.mp3",
  Sound.haromszog: "haromszog.mp3",
  Sound.negyszog: "negyszog.mp3",
};

var _soundPool = Soundpool(streamType: StreamType.notification);
var _soundToId = Map<Sound, int>();

Future<void> _initSound() async {
  for (var s in Sound.values)
    if (s != Sound.none) _soundToId[s] = await _soundPool.load(await rootBundle.load("assets/${_soundToFileName[s]}"));
}

Future<int> _playSound(Sound sound) async {
  if (sound == Sound.none) return 0;

  int soundId = _soundToId[sound] ?? await _soundPool.load(await rootBundle.load("assets/${_soundToFileName[sound]}"));
  if (soundId >= 0) _soundToId[sound] = soundId;

  return await _soundPool.play(soundId);
}

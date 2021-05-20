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

enum Consequence { nrm, failure, neutral, success, reward }

extension ConsequenceExt on Consequence {
  static const _colorSounds = [Sound.nrm, Sound.none, Sound.none, Sound.none, Sound.reward];
  static const _colorValues = [Colors.red, Colors.red, Colors.orange, Colors.lightGreen, Colors.green];

  Sound get sound => _colorSounds[index];
  Color get color => _colorValues[index];
  String get name => toString().replaceFirst('Consequence.', '');
}

const alphaValues = [0, 6, 16, 32, 64, 128];

class TargetConfig {
  Consequence consequence; // the result of action? 0-failure, 1-neutral, 2-success
  int shapeSize; // 0 - 5
  int alpha;

  ShapeColor shapeColor;

  TargetConfig({
    this.consequence = Consequence.neutral,
    this.shapeSize = 0,
    this.shapeColor = ShapeColor.transparent,
    this.alpha = 0,
  });
}

/// app state data model
class AppState extends ChangeNotifier {
  final Random _rng = Random();
  static int colorRandom = 0; // a random integer for color randomization

  bool inputAllowed = true;
  bool settingsPanelVisible = false;
  bool playAreaVisible = true;

  // statistics counters
  double referenceMean = 0.5;
  double get referenceStdDev =>
      (success + failure) == 0 ? 0 : sqrt(referenceMean * (1 - referenceMean) / (success + failure));
  int reward = 0;
  int success = 0;
  int neutral = 0;
  int failure = 0;
  int noRewardMarker = 0;

  // play area timeouts after success or failure events
  int successDelay = 2;
  int failureDelay = 4;
  // delay offset of announcement relative to the displaying of play area (in secs, can be negative)
  int announcementDelayOffset = 0;

  ShapeColor announcedColor = ShapeColor.transparent;

  Color backgroundColor = Colors.grey;
  Consequence backgroundConsequence = Consequence.neutral;

  int targetSize = 3; // 0-5

  List<TargetConfig> targets = [
    TargetConfig(alpha: 2, shapeSize: 2, shapeColor: ShapeColor.random1, consequence: Consequence.reward),
    TargetConfig(alpha: 2, shapeSize: 2, shapeColor: ShapeColor.random1, consequence: Consequence.reward),
    TargetConfig(alpha: 2, shapeSize: 2, shapeColor: ShapeColor.random1, consequence: Consequence.reward),
    TargetConfig(alpha: 2, shapeSize: 2, shapeColor: ShapeColor.random1, consequence: Consequence.reward),
    TargetConfig(alpha: 0, shapeSize: 2, shapeColor: ShapeColor.random2, consequence: Consequence.nrm),
    TargetConfig(alpha: 0, shapeSize: 2, shapeColor: ShapeColor.random2, consequence: Consequence.nrm),
    TargetConfig(alpha: 0, shapeSize: 2, shapeColor: ShapeColor.random2, consequence: Consequence.nrm),
    TargetConfig(alpha: 0, shapeSize: 2, shapeColor: ShapeColor.random2, consequence: Consequence.nrm),
    TargetConfig(),
  ];

  AppState() {
    _initSound();
    calculateReferenceMean();
  }

  // must be called whenever a target consequence have changed (i.e. after the Settings screen)
  // recalculate expected probability of success in case of randomly choosing from the targets
  void calculateReferenceMean() {
    int s = 0, n = 0;
    for (var t in targets) {
      if (t.consequence != Consequence.neutral) n++;
      if (t.consequence == Consequence.success || t.consequence == Consequence.reward) s++;
    }
    referenceMean = n == 0 ? 0 : s / n;
  }

  /// notify all widgets listening on state changes
  void notify() => notifyListeners();

  void randomize() {
    // TODO make this configurable
    targets.shuffle();
    colorRandom = _rng.nextInt(1000);
  }

  void executeConsequence(Consequence consequence) {
    // disable input after a touch to prevent multiple touches and registering a
    // touch event behind a target. Input will be allowed after a timeout.
    // touch events are first delivered to the topmost widgets
    inputAllowed = false;

    if (consequence == Consequence.nrm) {
      _playSound(Sound.nrm);
      noRewardMarker++;
    }

    if (consequence == Consequence.nrm || consequence == Consequence.failure) {
      failure++;
      randomize();

      if (failureDelay != 0) {
        // turn off play area for a while
        playAreaVisible = false;
        // wait a bit and then turn back the play area
        Future.delayed(Duration(seconds: failureDelay), _revealPlayArea);
        // and optionally announce a cue
        if (announcedColor != ShapeColor.transparent)
          Future.delayed(Duration(seconds: failureDelay + announcementDelayOffset), _announceColor);
      }
    }

    if (consequence == Consequence.neutral) {
      neutral++;
      Future.delayed(Duration(milliseconds: 500), _revealPlayArea);
    }

    if (consequence == Consequence.reward) {
      _playSound(Sound.reward);
      reward++;
    }

    // success
    if (consequence == Consequence.success || consequence == Consequence.reward) {
      success++;
      randomize();

      if (successDelay != 0) {
        // turn off play area for a while
        playAreaVisible = false;
        // wait a bit and then turn back the play area
        Future.delayed(Duration(seconds: successDelay), _revealPlayArea);
        // and optionally announce a cue
        if (announcedColor != ShapeColor.transparent)
          Future.delayed(Duration(seconds: successDelay + announcementDelayOffset), _announceColor);
      }
    }

    notifyListeners();
  }

  void _announceColor() {
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
enum Sound { none, nrm, reward, piros, kek, zold, sarga, egy, ketto, harom, kor, haromszog, negyszog }
const _soundToFileName = {
  Sound.nrm: "failure.mp3",
  Sound.reward: "success.mp3",
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

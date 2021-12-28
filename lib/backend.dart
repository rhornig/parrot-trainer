import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

import 'config.dart';

/// low latency sound engine
enum Sound { none, nrm, reward, red, blue, green, yellow, one, two, three, circle, triangle, square }
const _soundToFileName = {
  Sound.nrm: "failure.mp3",
  Sound.reward: "success.mp3",
  Sound.red: "piros.mp3",
  Sound.blue: "kek.mp3",
  Sound.green: "zold.mp3",
  Sound.yellow: "sarga.mp3",
  Sound.one: "egy.mp3",
  Sound.two: "ketto.mp3",
  Sound.three: "harom.mp3",
  Sound.circle: "kor.mp3",
  Sound.triangle: "haromszog.mp3",
  Sound.square: "negyszog.mp3",
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

/// data classes

extension ShapeColorExt on ShapeColor {
  static const _colorSounds = [Sound.none, Sound.none, Sound.none, Sound.red, Sound.yellow, Sound.green, Sound.blue];
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
  int _shapeColorToIndex() => index < _colorValues.length ? index : 3 + (index + AppState.randomSeed) % 4;

  Sound get sound => _colorSounds[_shapeColorToIndex()];
  Color get color => _colorValues[_shapeColorToIndex()];
  String get name => toString().replaceFirst('ShapeColor.', '');
}

extension ConsequenceExt on Consequence {
  static const _colorSounds = [Sound.nrm, Sound.none, Sound.none, Sound.none, Sound.reward];
  static const _colorValues = [Colors.red, Colors.red, Colors.orange, Colors.lightGreen, Colors.green];

  Sound get sound => _colorSounds[index];
  Color get color => _colorValues[index];
  String get name => toString().replaceFirst('Consequence.', '');
}

/// app state data model
class AppState with ChangeNotifier {
  // user configured settings
  MainConfig config = MainConfig();

  final Random _rng = Random();
  static int randomSeed = 0; // a random integer for color randomization

  bool inputAllowed = true;
  bool settingsPanelVisible = false;
  bool sceneDetailsVisible = false;
  bool playAreaVisible = true;

  // statistics counters
  double referenceMean = 0.5;
  double get referenceStdDev => (success + failure) == 0 ? 0 : sqrt(referenceMean * (1 - referenceMean) / (success + failure));
  int reward = 0;
  int success = 0;
  int neutral = 0;
  int failure = 0;
  int noRewardMarker = 0;
  List<double> successRateHistory = [];

  void resetSessionStatistics() {
    reward = 0;
    success = 0;
    neutral = 0;
    failure = 0;
    noRewardMarker = 0;
    successRateHistory = [];
    notifyListeners();
  }

  static const successWindowSize = 20;
  // history of the latest 20 events ( 1 = success, 0 = failure)
  List<int> successWindow = List<int>.filled(successWindowSize, 0, growable: true);
  int successWindowSum = 0; // the number of successful consequences in the last 'successWindowSize'

  void resetWindowStatistics() {
    successWindow = List<int>.filled(successWindowSize, 0, growable: true);
    successWindowSum = 0;
    notifyListeners();
  }

  AppState() {
    _initSound();
    calculateReferenceMean();
    Timer.periodic(Duration(seconds: 5), _updateSuccessRateHistory);
  }

  // must be called whenever a target consequence have changed (i.e. after the Settings screen)
  // recalculate expected probability of success in case of randomly choosing from the targets
  void calculateReferenceMean() {
    int s = 0, n = 0;
    for (var t in config.scene.targets) {
      if (t.consequence != Consequence.neutral) n++;
      if (t.consequence == Consequence.success || t.consequence == Consequence.reward) s++;
    }
    referenceMean = n == 0 ? 0 : s / n;
  }

  void _updateSuccessRateHistory(Timer timer) {
    if (successRateHistory.length == 120) successRateHistory.removeLast();
    if (success + failure > 0) successRateHistory.insert(0, success.toDouble() / (success + failure));
    notifyListeners();
  }

  // pass 0 for failure and 1 for success. Stores the passed value in a FIFO of size 'successWindowSize'
  void _updateSuccessWindow(int e) {
    if (successWindow.length == successWindowSize) successWindowSum -= successWindow.removeLast();
    successWindow.insert(0, e);
    successWindowSum += e;
  }

  // advance to the next scene if the required conditions are met (and clear the window statistics)
  void _testAndAdvanceToNextScene() {
    if (config.loopSize > 1 && successWindowSum * 100 >= successWindowSize * config.successRateForNextStep) {
      config.index = (config.index + 1) % config.loopSize;
      resetWindowStatistics();
    }
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
      _updateSuccessWindow(0);
      failure++;
      if (config.scene.shuffleOnFailure) config.scene.targets.shuffle();
      if (config.scene.newTargetOnFailure) randomSeed = _rng.nextInt(1000);

      if (config.scene.failureDelay != 0) {
        // turn off play area for a while
        playAreaVisible = false;
        // wait a bit and then turn back the play area
        Future.delayed(Duration(seconds: config.scene.failureDelay), _revealPlayArea);
        // and optionally announce a cue
        if (config.scene.announcedColor != ShapeColor.transparent)
          Future.delayed(Duration(seconds: config.scene.failureDelay + config.scene.announcementDelayOffset), _announceColor);
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
      _updateSuccessWindow(1);
      _testAndAdvanceToNextScene();
      if (config.scene.shuffleOnSuccess) config.scene.targets.shuffle();
      randomSeed = _rng.nextInt(1000);

      if (config.scene.successDelay != 0) {
        // turn off play area for a while
        playAreaVisible = false;
        // wait a bit and then turn back the play area
        Future.delayed(Duration(seconds: config.scene.successDelay), _revealPlayArea);
        // and optionally announce a cue
        if (config.scene.announcedColor != ShapeColor.transparent)
          Future.delayed(Duration(seconds: config.scene.successDelay + config.scene.announcementDelayOffset), _announceColor);
      }
    }

    notifyListeners();
  }

  void _announceColor() {
    // announce color cue
    _playSound(config.scene.announcedColor.sound);
    // TODO announce other cues like shape, size, number
  }

  // show play area and re-enable inputs
  void _revealPlayArea() {
    playAreaVisible = true;
    inputAllowed = true;
    notifyListeners();
  }

  /// notify all widgets listening on state changes
  void notify() => notifyListeners();
}

import 'package:dart_json_mapper/dart_json_mapper.dart' show JsonMapper, jsonSerializable, JsonProperty, enumConverterNumeric;
import 'package:flutter/foundation.dart';

// symbolic shape colors. Random colors must be at the end and they start with random1
@jsonSerializable
enum ShapeColor { transparent, black, white, red, yellow, green, blue, random1, random2, random3, random4 }

@jsonSerializable
enum Consequence { nrm, failure, neutral, success, reward }

const alphaValues = [0, 6, 12, 18, 32, 96];

@jsonSerializable
class TargetConfig with ChangeNotifier {
  late Consequence _consequence;
  Consequence get consequence => _consequence;
  set consequence(Consequence value) {
    _consequence = value;
    notifyListeners();
  }

  late int _shapeSize; // 0 - 5
  int get shapeSize => _shapeSize;
  set shapeSize(int value) {
    _shapeSize = value;
    notifyListeners();
  }

  late int _alpha; // 0 - 5
  int get alpha => _alpha;
  set alpha(int value) {
    _alpha = value;
    notifyListeners();
  }

  late ShapeColor _shapeColor;
  ShapeColor get shapeColor => _shapeColor;
  set shapeColor(ShapeColor value) {
    _shapeColor = value;
    notifyListeners();
  }

  TargetConfig({consequence = Consequence.neutral, shapeSize = 0, shapeColor = ShapeColor.transparent, alpha = 0}) {
    _consequence = consequence;
    _shapeSize = shapeSize;
    _shapeColor = shapeColor;
    _alpha = alpha;
  }
}

const _c2shape = {
  'r': ShapeColor.red,
  'g': ShapeColor.green,
  'b': ShapeColor.blue,
  'y': ShapeColor.yellow,
  'w': ShapeColor.white,
  'l': ShapeColor.black,
  't': ShapeColor.transparent,
  '1': ShapeColor.random1,
  '2': ShapeColor.random2,
  '3': ShapeColor.random3,
  '4': ShapeColor.random4
};

@jsonSerializable
class SceneConfig with ChangeNotifier {
  SceneConfig(String name, {String? reward, String? nrm}) : _name = name {
    reward?.split('').forEach((ch) {
      if (targets.length >= 9) return;
      targets.add(TargetConfig(shapeSize: 2, shapeColor: _c2shape[ch], consequence: Consequence.reward));
    });
    nrm?.split('').forEach((ch) {
      if (targets.length >= 9) return;
      targets.add(TargetConfig(shapeSize: 2, shapeColor: _c2shape[ch], consequence: Consequence.nrm));
    });

    while (targets.length < 9) targets.add(TargetConfig());
  }

  List<TargetConfig> targets = [];

  // config name
  String _name;
  String get name => _name;
  set name(String value) {
    _name = value;
    notifyListeners();
  }

  // play area timeouts after success or failure events
  int _successDelay = 2; // 0-5
  int get successDelay => _successDelay;
  set successDelay(int value) {
    _successDelay = value;
    notifyListeners();
  }

  int _failureDelay = 2;
  int get failureDelay => _failureDelay;
  set failureDelay(int value) {
    _failureDelay = value;
    notifyListeners();
  }

  // delay offset of announcement relative to the displaying of play area (in secs, can be negative)
  int _announcementDelayOffset = 0;
  int get announcementDelayOffset => _announcementDelayOffset;
  set announcementDelayOffset(int value) {
    _announcementDelayOffset = value;
    notifyListeners();
  }

  ShapeColor _announcedColor = ShapeColor.transparent;
  ShapeColor get announcedColor => _announcedColor;
  set announcedColor(ShapeColor value) {
    _announcedColor = value;
    notifyListeners();
  }

  Consequence _backgroundConsequence = Consequence.neutral;
  Consequence get backgroundConsequence => _backgroundConsequence;
  set backgroundConsequence(Consequence value) {
    _backgroundConsequence = value;
    notifyListeners();
  }

  int _targetSize = 2;
  int get targetSize => _targetSize;
  set targetSize(int value) {
    _targetSize = value;
    notifyListeners();
  }

  int _positionNoise = 5; // 0-5
  int get positionNoise => _positionNoise;
  set positionNoise(int value) {
    _positionNoise = value;
    notifyListeners();
  }

  bool _shuffleOnSuccess = true; // whether shuffle the targets on success
  bool get shuffleOnSuccess => _shuffleOnSuccess;
  set shuffleOnSuccess(bool value) {
    _shuffleOnSuccess = value;
    notifyListeners();
  }

  bool _shuffleOnFailure = false; // whether shuffle the targets on failure
  bool get shuffleOnFailure => _shuffleOnFailure;
  set shuffleOnFailure(bool value) {
    _shuffleOnFailure = value;
    notifyListeners();
  }

  bool _newTargetOnFailure = false; // whether choose a new random target color on failure
  bool get newTargetOnFailure => _newTargetOnFailure;
  set newTargetOnFailure(bool value) {
    _newTargetOnFailure = value;
    notifyListeners();
  }
}

@jsonSerializable
class MainConfig with ChangeNotifier {
  List<SceneConfig> scenes = [
    SceneConfig("green - yellow", reward: 'gggg', nrm: 'yyyy')..announcedColor = ShapeColor.green,
    SceneConfig("green - red", reward: 'gggg', nrm: 'rrrr')..announcedColor = ShapeColor.green,
    SceneConfig("green - blue", reward: 'gggg', nrm: 'bbbb')..announcedColor = ShapeColor.green,
    SceneConfig("green - other", reward: 'gggg', nrm: 'yrbyr')..announcedColor = ShapeColor.green,
    SceneConfig("yellow - green", reward: 'yyyy', nrm: 'gggg')..announcedColor = ShapeColor.yellow,
    SceneConfig("yellow - red", reward: 'yyyy', nrm: 'rrrr')..announcedColor = ShapeColor.yellow,
    SceneConfig("yellow - blue", reward: 'yyyy', nrm: 'bbbb')..announcedColor = ShapeColor.yellow,
    SceneConfig("yellow - other", reward: 'yyyy', nrm: 'grbgr')..announcedColor = ShapeColor.yellow,
    SceneConfig("red - yellow", reward: 'rrrr', nrm: 'yyyy')..announcedColor = ShapeColor.red,
    SceneConfig("red - blue", reward: 'rrrr', nrm: 'bbbb')..announcedColor = ShapeColor.red,
    SceneConfig("red - green", reward: 'rrrr', nrm: 'gggg')..announcedColor = ShapeColor.red,
    SceneConfig("red - other", reward: 'rrrr', nrm: 'ybgyb')..announcedColor = ShapeColor.red,
    SceneConfig("blue - yellow", reward: 'bbbb', nrm: 'yyyy')..announcedColor = ShapeColor.blue,
    SceneConfig("blue - red", reward: 'bbbb', nrm: 'rrrr')..announcedColor = ShapeColor.blue,
    SceneConfig("blue - green", reward: 'bbbb', nrm: 'gggg')..announcedColor = ShapeColor.blue,
    SceneConfig("blue - other", reward: 'bbbb', nrm: 'yrgyr')..announcedColor = ShapeColor.blue,
    SceneConfig("random 1:3", reward: '11', nrm: '223344')..announcedColor = ShapeColor.random1,
  ];

  int _index = 0;
  int get index => _index;
  set index(int index) {
    _index = index;
    notifyListeners();
  }

  int _loopSize = 0; // the number of scene profiles in the loop. 0 means no looping
  int get loopSize => _loopSize;
  set loopSize(int loopSize) {
    _loopSize = loopSize;
    notifyListeners();
  }

  // The required success rate in the last 20 event to advance to the next scene profile automatically, (> 100 means never)
  int _successRateForNextStep = 105;
  int get successRateForNextStep => _successRateForNextStep;
  set successRateForNextStep(int successRateForNextStep) {
    _successRateForNextStep = successRateForNextStep;
    notifyListeners();
  }

  SceneConfig get scene => scenes[index];
}

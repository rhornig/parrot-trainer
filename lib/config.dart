// symbolic shape colors. Random colors must be at the end and they start with random1

import 'package:dart_json_mapper/dart_json_mapper.dart' show JsonMapper, jsonSerializable, JsonProperty, enumConverterNumeric;
import 'package:flutter/foundation.dart';
//import 'package:flutter/material.dart';

@jsonSerializable
enum ShapeColor { transparent, black, white, red, yellow, green, blue, random1, random2, random3, random4 }

@jsonSerializable
enum Consequence { nrm, failure, neutral, success, reward }

const alphaValues = [0, 6, 12, 18, 32, 96];

@jsonSerializable
class TargetConfig extends ChangeNotifier {
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
class SceneConfig extends ChangeNotifier {
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
class MainConfig extends ChangeNotifier {
  int index = 0;
  List<SceneConfig> configs = [
    SceneConfig("green - yellow", reward: 'gggg', nrm: 'yyyy'),
    SceneConfig("green - red", reward: 'gggg', nrm: 'rrrr'),
    SceneConfig("green - blue", reward: 'gggg', nrm: 'bbbb'),
    SceneConfig("green - other", reward: 'gggg', nrm: 'yrbyr'),
    SceneConfig("yellow - green", reward: 'yyyy', nrm: 'gggg'),
    SceneConfig("yellow - red", reward: 'yyyy', nrm: 'rrrr'),
    SceneConfig("yellow - blue", reward: 'yyyy', nrm: 'bbbb'),
    SceneConfig("yellow - other", reward: 'yyyy', nrm: 'grbgr'),
    SceneConfig("red - yellow", reward: 'rrrr', nrm: 'yyyy'),
    SceneConfig("red - blue", reward: 'rrrr', nrm: 'bbbb'),
    SceneConfig("red - green", reward: 'rrrr', nrm: 'gggg'),
    SceneConfig("red - other", reward: 'rrrr', nrm: 'ybgyb'),
    SceneConfig("blue - yellow", reward: 'bbbb', nrm: 'yyyy'),
    SceneConfig("blue - red", reward: 'bbbb', nrm: 'rrrr'),
    SceneConfig("blue - green", reward: 'bbbb', nrm: 'gggg'),
    SceneConfig("blue - other", reward: 'bbbb', nrm: 'yrgyr'),
    SceneConfig("random 1:3", reward: '11', nrm: '223344'),
  ];
  get active => configs[index];
}

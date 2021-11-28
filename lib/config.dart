// symbolic shape colors. Random colors must be at the end and they start with random1
import 'package:flutter/material.dart';

enum ShapeColor { transparent, black, white, red, yellow, green, blue, random1, random2, random3, random4 }

enum Consequence { nrm, failure, neutral, success, reward }

const alphaValues = [0, 6, 12, 18, 32, 96];

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

class SceneConfig extends ChangeNotifier {
  List<TargetConfig> targets = [
    TargetConfig(shapeSize: 2, shapeColor: ShapeColor.random1, consequence: Consequence.reward),
    TargetConfig(shapeSize: 2, shapeColor: ShapeColor.random1, consequence: Consequence.reward),
    TargetConfig(shapeSize: 2, shapeColor: ShapeColor.random2, consequence: Consequence.nrm),
    TargetConfig(shapeSize: 2, shapeColor: ShapeColor.random2, consequence: Consequence.nrm),
    TargetConfig(),
    TargetConfig(shapeSize: 2, shapeColor: ShapeColor.random3, consequence: Consequence.nrm),
    TargetConfig(shapeSize: 2, shapeColor: ShapeColor.random3, consequence: Consequence.nrm),
    TargetConfig(shapeSize: 2, shapeColor: ShapeColor.random4, consequence: Consequence.nrm),
    TargetConfig(shapeSize: 2, shapeColor: ShapeColor.random4, consequence: Consequence.nrm),
  ];

  // config name
  String _name = "Unnamed";
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

  Color _backgroundColor = Colors.grey;
  Color get backgroundColor => _backgroundColor;
  set backgroundColor(Color value) {
    _backgroundColor = value;
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

  int _positionNoise = 0; // 0-5
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

  bool _shuffleOnFailure = true; // whether shuffle the targets on failure
  bool get shuffleOnFailure => _shuffleOnFailure;
  set shuffleOnFailure(bool value) {
    _shuffleOnFailure = value;
    notifyListeners();
  }

  bool _newTargetOnFailure = true; // whether choose a new random target color on failure
  bool get newTargetOnFailure => _newTargetOnFailure;
  set newTargetOnFailure(bool value) {
    _newTargetOnFailure = value;
    notifyListeners();
  }
}

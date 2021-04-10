import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

var _soundPool = Soundpool();
var keySound = [];

Future<int> _loadSound(int soundNumber) async {
  var asset = await rootBundle.load("assets/note$soundNumber.wav");
  return await _soundPool.load(asset);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  keySound = [for (int i = 1; i < 8; ++i) await _loadSound(i)];
  runApp(ParrotTrainerApp());
}

class ParrotTrainerApp extends StatelessWidget {
  void playSound(int soundNumber) {
    _soundPool.play(keySound[soundNumber - 1]);
  }

  Widget buildTarget({Color color = Colors.black, double size = 0, required int soundNumber}) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(size),
        child: GestureDetector(
          onTapDown: (TapDownDetails d) {
            playSound(soundNumber);
          },
          child: Container(color: color),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double targetSize = 40;
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white60,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    buildTarget(color: Colors.red, size: targetSize, soundNumber: 1),
                    buildTarget(color: Colors.yellow, size: targetSize, soundNumber: 3),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    buildTarget(color: Colors.green, size: targetSize, soundNumber: 4),
                    buildTarget(color: Colors.blue.shade900, size: targetSize, soundNumber: 6)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

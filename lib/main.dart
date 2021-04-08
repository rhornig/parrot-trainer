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

  Widget buildKey({required Color color, required int soundNumber}) {
    return Expanded(
      child: GestureDetector(
        onTapDown: (TapDownDetails d) {
          playSound(soundNumber);
        },
        child: Container(
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              buildKey(color: Colors.red, soundNumber: 1),
              buildKey(color: Colors.yellow, soundNumber: 3),
              buildKey(color: Colors.green, soundNumber: 4),
              buildKey(color: Colors.blue.shade900, soundNumber: 6),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:soundpool/soundpool.dart';

var _soundPool = Soundpool();
var keySound = [];

Future<int> _loadSound(int soundNumber) async {
  var asset = await rootBundle.load("assets/note$soundNumber.wav");
  return await _soundPool.load(asset);
}

void playSound(int soundNumber) {
  _soundPool.play(keySound[soundNumber - 1]);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  keySound = [for (int i = 1; i < 8; ++i) await _loadSound(i)];
  runApp(ChangeNotifierProvider(
    create: (context) => Settings(),
    child: ParrotTrainerApp(),
  ));
}

class ParrotTrainerApp extends StatefulWidget {
  @override
  _ParrotTrainerAppState createState() => _ParrotTrainerAppState();
}

class _ParrotTrainerAppState extends State<ParrotTrainerApp> {
  bool settingsWidgetActive = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Consumer<Settings>(builder: (context, settings, child) {
            return TouchBackground(
              settings,
              color: Colors.grey,
              onAlternateTouch: () {
                setState(() {
                  settingsWidgetActive = !settingsWidgetActive;
                });
              },
              child: settingsWidgetActive ? SettingsWidget(settings) : TouchForeground(settings),
            );
          }),
        ),
      ),
    );
  }
}

class TouchBackground extends StatelessWidget {
  final Settings settings;
  final Color color;
  final Function()? onAlternateTouch;
  final Widget child;

  const TouchBackground(
    this.settings, {
    this.color = Colors.white,
    required this.child,
    this.onAlternateTouch,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => onAlternateTouch?.call(),
      child: Container(color: color, child: child),
    );
  }
}

class TouchForeground extends StatelessWidget {
  final Settings settings;

  const TouchForeground(this.settings, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            TouchTarget(color: Colors.red, size: settings.targetSize, onTouch: () => playSound(1)),
            TouchTarget(color: Colors.yellow, size: settings.targetSize, onTouch: () => playSound(3)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            TouchTarget(color: Colors.green, size: settings.targetSize, onTouch: () => playSound(4)),
            TouchTarget(color: Colors.blue.shade900, size: settings.targetSize, onTouch: () => playSound(6))
          ],
        ),
      ],
    );
  }
}

class TouchTarget extends StatelessWidget {
  final Color color;
  final double size;
  final Function() onTouch;

  const TouchTarget({
    this.color = Colors.black,
    this.size = 50,
    required this.onTouch,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Container(
        color: color,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => onTouch(),
          onPanStart: (_) => onTouch(),
        ),
      ),
    );
  }
}

class SettingsWidget extends StatelessWidget {
  final Settings settings;

  const SettingsWidget(this.settings, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: settings.targetSize,
      min: 20,
      max: 320,
      divisions: 10,
      label: settings.targetSize.round().toString(),
      onChanged: (double value) => settings.targetSize = value,
    );
  }
}

// settings data model
class Settings extends ChangeNotifier {
  double _targetSize = 230.0;
  double get targetSize => _targetSize;
  set targetSize(double targetSize) {
    _targetSize = targetSize;
    notifyListeners();
  }
}

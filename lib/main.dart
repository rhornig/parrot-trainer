import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'backend.dart';
import 'settings.dart';
import 'statistics.dart';

// TODO baybe https://riverpod.dev/ would be a better state management solution?
// https://pub.dev/packages/get is also interesting

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => AppState(),
    child: ParrotTrainerApp(),
  ));
}

class ParrotTrainerApp extends StatefulWidget {
  @override
  _ParrotTrainerAppState createState() => _ParrotTrainerAppState();
}

class _ParrotTrainerAppState extends State<ParrotTrainerApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(canvasColor: Colors.black, cardColor: Colors.grey.shade900),
      home: Scaffold(
        body: SafeArea(
          child: Consumer<AppState>(builder: (context, state, child) {
            return state.settingsPanelVisible
                ? SettingsPanel(state)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [PlayArea(state), StatisticsPanel(state)],
                  );
          }),
        ),
      ),
    );
  }
}

class PlayArea extends StatelessWidget {
  final AppState state;
  const PlayArea(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Stack(
        children: [
          Container(color: state.backgroundColor),
          if (state.playAreaVisible)
            GestureDetector(
              onTapDown: (_) => state.executeConsequence(state.backgroundConsequence),
              child: GridView.count(
                physics: NeverScrollableScrollPhysics(), // to prevent scrolling
                crossAxisCount: 3,
                children: [for (var t in state.targets) TouchTarget(state, t)],
              ),
            ),
        ],
      ),
    );
  }
}

class TouchTarget extends StatelessWidget {
  final AppState state;
  final TargetConfig target;
  const TouchTarget(this.state, this.target, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTapDown: (_) => state.executeConsequence(target.consequence),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: target.size, maxHeight: target.size),
          child: Container(
            color: target.color,
            child: Transform.scale(
              scale: target.cueScale / 100.0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (target.color == Colors.black ? Colors.white : Colors.black).withAlpha(target.cueAlpha),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

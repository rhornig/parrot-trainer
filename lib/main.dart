import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'backend.dart';
import 'settings.dart';
import 'statistics.dart';

// TODO baybe https://riverpod.dev/ would be a better state management solution?
// https://pub.dev/packages/get is also interesting

void main() {
  // debugPaintPointersEnabled = true;
  // debugPaintSizeEnabled = true;
  // debugPaintLayerBordersEnabled = true;

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
    return Listener(
      onPointerDown: (_) {
        // execute only if there was no other pointer event executed recently (generated by a target)
        // this prevents multiple events in a short succession or registering an event behind a target shape.
        if (state.inputAllowed) state.executeConsequence(state.backgroundConsequence);
      },
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          color: state.backgroundColor,
          child: state.playAreaVisible
              ? GridView.count(
                  physics: NeverScrollableScrollPhysics(), // to prevent scrolling
                  crossAxisCount: 3,
                  children: [for (var t in state.targets) TouchTarget(state, t)],
                )
              : null,
        ),
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
      child: Listener(
        onPointerDown: (_) {
          if (state.inputAllowed) state.executeConsequence(target.consequence);
        },
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: target.size, maxHeight: target.size),
          child: Container(
            color: target.shapeColor.color,
            child: Transform.scale(
              scale: target.cueScale / 100.0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      (target.shapeColor == ShapeColor.black ? Colors.white : Colors.black).withAlpha(target.cueAlpha),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

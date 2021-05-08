import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'backend.dart';
import 'settings.dart';

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
      home: Scaffold(
        body: SafeArea(
          child: Consumer<AppState>(builder: (context, state, child) {
            return state.settingsPanelVisible
                ? SettingsPanel(state)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PlayArea(state),
                      StatPanel(state),
                    ],
                  );
          }),
        ),
      ),
    );
  }
}

class StatPanel extends StatelessWidget {
  final AppState state;
  const StatPanel(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int sum = state.success + state.failure;
    int pct = (sum == 0) ? 0 : ((state.success / sum) * 100).round();

    return Expanded(
        child: Container(
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onLongPress: () {
              state
                ..failure = 0
                ..success = 0
                ..notify();
            },
            child: Text(
              "S${state.success} F${state.failure}\n$pct% ∑$sum",
              style: TextStyle(color: Colors.white24, fontSize: 40),
              textAlign: TextAlign.end,
            ),
          ),
          GestureDetector(
            onLongPress: () {
              state
                ..settingsPanelVisible = true
                ..notify();
            },
            child: Icon(Icons.settings, size: 80, color: Colors.white10),
          ),
        ],
      ),
    ));
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
            GridView.count(
              crossAxisCount: 3,
              children: [
                for (int i = 0; i < state.targets.length; ++i)
                  TouchTarget(
                      config: state.targets[i],
                      onTouch: () {
                        state.executeConsequence(state.targets[i].consequence);
                      }),
              ],
            ),
        ],
      ),
    );
  }
}

class TouchTarget extends StatelessWidget {
  final TargetConfig config;
  final Function() onTouch;

  const TouchTarget({
    required this.config,
    required this.onTouch,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque, // FIXME do we need this?
        onTapDown: (_) => onTouch(),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: config.size, maxHeight: config.size),
          child: Container(
            color: config.color,
            child: Transform.scale(
              scale: config.cueScale / 100.0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (config.color == Colors.black ? Colors.white : Colors.black).withAlpha(config.cueAlpha),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

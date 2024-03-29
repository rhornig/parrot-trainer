import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'backend.dart';
import 'config.dart';
import 'config_ui.dart';
import 'main.mapper.g.dart' show initializeJsonMapper;
import 'statistics.dart';

// TODO maybe https://riverpod.dev/ would be a better state management solution?
// https://pub.dev/packages/get is also interesting

void main() {
  // debugPaintPointersEnabled = true;
  // debugPaintSizeEnabled = true;
  // debugPaintLayerBordersEnabled = true;
  initializeJsonMapper();
  WidgetsFlutterBinding.ensureInitialized();

  // We setup preferred orientations and only after it finished we run our app
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (value) => runApp(ChangeNotifierProvider(
      create: (context) => AppState(),
      child: ParrotTrainerApp(),
    )),
  );
}

class ParrotTrainerApp extends StatefulWidget {
  @override
  _ParrotTrainerAppState createState() => _ParrotTrainerAppState();
}

class _ParrotTrainerAppState extends State<ParrotTrainerApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          brightness: Brightness.dark,
          cardColor: Colors.grey.shade900,
          checkboxTheme: CheckboxThemeData(
            checkColor: MaterialStateColor.resolveWith((states) => Colors.grey.shade900),
            fillColor: MaterialStateColor.resolveWith((states) => Colors.grey.shade200),
          )),
      home: Scaffold(
        body: SafeArea(
          child: Consumer<AppState>(builder: (context, state, child) {
            return state.settingsPanelVisible
                ? MainConfigPanel(
                    state,
                    onClose: () {
                      state
                        ..settingsPanelVisible = false
                        ..notifyListeners();
                    },
                  )
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
    var rng = Random(AppState.randomSeed);
    return Listener(
      onPointerDown: (_) {
        // execute only if there was no other pointer event executed recently (generated by a target)
        // this prevents multiple events in a short succession or registering an event behind a target shape.
        if (state.inputAllowed) state.executeConsequence(state.config.scene.backgroundConsequence);
      },
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          color: Colors.grey, // background color (TODO make configurable)
          child: state.playAreaVisible
              ? GridView.count(
                  physics: NeverScrollableScrollPhysics(), // to prevent scrolling
                  crossAxisCount: 3,
                  children: [
                    for (var t in state.config.scene.targets)
                      Transform.translate(
                        offset: Offset(
                          (rng.nextDouble() - 0.5) * state.config.scene.positionNoise * 25.0,
                          (rng.nextDouble() - 0.5) * state.config.scene.positionNoise * 25.0,
                        ),
                        child: TouchTarget(state, t),
                      )
                  ],
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
          constraints: BoxConstraints(minWidth: target.shapeSize * 40, minHeight: target.shapeSize * 40),
          child: Container(
              color: target.shapeColor.color,
              child: UnconstrainedBox(
                child: target.alpha > 0
                    ? SizedBox(
                        width: state.config.scene.targetSize * 10,
                        height: state.config.scene.targetSize * 10,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (target.shapeColor == ShapeColor.black ? Colors.white : Colors.black)
                                .withAlpha(alphaValues[target.alpha]),
                          ),
                        ),
                      )
                    : null,
              )),
        ),
      ),
    );
  }
}

//print(JsonMapper.serialize(state.config));

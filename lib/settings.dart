import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'backend.dart';

class SettingsPanel extends StatelessWidget {
  final AppState state;
  const SettingsPanel(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          height: 100,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Slider(
                    value: state.backgroundConsequence.toDouble(),
                    activeColor: [Colors.red, Colors.orange, Colors.green][state.backgroundConsequence],
                    min: 0,
                    max: 2,
                    divisions: 2,
                    label: "background result: " + ["failure", "neutral", "success"][state.backgroundConsequence],
                    onChanged: (double value) {
                      state.backgroundConsequence = value.toInt();
                      state.notify();
                    },
                  ),
                  Slider(
                    value: state.successDelay.toDouble(),
                    min: 0,
                    max: 5,
                    divisions: 5,
                    label: "success timeout: ${state.successDelay}s",
                    onChanged: (double value) {
                      state.successDelay = value.toInt();
                      state.notify();
                    },
                  ),
                  Slider(
                    value: state.failureDelay.toDouble(),
                    min: 0,
                    max: 5,
                    divisions: 5,
                    label: "failure timeout: ${state.failureDelay}s",
                    onChanged: (double value) {
                      state.failureDelay = value.toInt();
                      state.notify();
                    },
                  ),
                  ElevatedButton(
                      onPressed: () {
                        state
                          ..settingsPanelVisible = false
                          ..notify();
                      },
                      child: Text("Ok")),
                ],
              ),
              Row(
                children: [
                  Slider(
                    value: state.targetSize.toDouble(),
                    min: 0,
                    max: 4,
                    divisions: 4,
                    label: "target size: ${state.targetSize}",
                    onChanged: (double value) {
                      state.targetSize = value.toInt();
                      state.notify();
                    },
                  ),
                  Expanded(
                    child: Slider(
                      value: state.announcedColor.index.toDouble(),
                      min: 0,
                      max: ShapeColor.values.length - 1,
                      divisions: ShapeColor.values.length - 1,
                      activeColor: state.announcedColor.color,
                      label: "announced color: ${state.announcedColor.name}",
                      onChanged: (double value) {
                        state.announcedColor = ShapeColor.values[value.toInt()];
                        state.notify();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TargetSettingCard(state, state.targets[0]),
            TargetSettingCard(state, state.targets[1]),
            TargetSettingCard(state, state.targets[2]),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TargetSettingCard(state, state.targets[3]),
            TargetSettingCard(state, state.targets[4]),
            TargetSettingCard(state, state.targets[5]),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TargetSettingCard(state, state.targets[6]),
            TargetSettingCard(state, state.targets[7]),
            TargetSettingCard(state, state.targets[8]),
          ],
        ),
      ],
    );
  }
}

class TargetSettingCard extends StatelessWidget {
  final AppState state;
  final TargetConfig targetConfig;
  const TargetSettingCard(this.state, this.targetConfig, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Column(
          children: [
            Slider(
              value: targetConfig.shapeColor.index.toDouble(),
              min: 0,
              max: ShapeColor.values.length - 1,
              divisions: ShapeColor.values.length - 1,
              activeColor: targetConfig.shapeColor.color,
              label: "color: ${targetConfig.shapeColor.name}",
              onChanged: (double value) {
                targetConfig.shapeColor = ShapeColor.values[value.toInt()];
                state.notify();
              },
            ),
            Slider(
              value: targetConfig.shapeSize.toDouble(),
              min: 0,
              max: 5,
              divisions: 5,
              label: "size: ${targetConfig.shapeSize.round()}",
              onChanged: (double value) {
                targetConfig.shapeSize = value.toInt();
                state.notify();
              },
            ),
            Slider(
              value: targetConfig.alpha.toDouble(),
              min: 0,
              max: 5,
              divisions: 5,
              activeColor: Colors.blue.withAlpha(alphaValues[targetConfig.alpha.toInt()]),
              label: "target alpha: ${targetConfig.alpha.toInt()}",
              onChanged: (double value) {
                targetConfig.alpha = value.toInt();
                state.notify();
              },
            ),
            Slider(
              value: targetConfig.consequence.toDouble(),
              activeColor: [Colors.red, Colors.orange, Colors.green][targetConfig.consequence],
              min: 0,
              max: 2,
              divisions: 2,
              label: "result: " + ["failure", "neutral", "success"][targetConfig.consequence],
              onChanged: (double value) {
                targetConfig.consequence = value.toInt();
                state.notify();
              },
            ),
          ],
        ),
      ),
    );
  }
}

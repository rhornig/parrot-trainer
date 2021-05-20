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
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                      onPressed: () {
                        state
                          ..settingsPanelVisible = false
                          ..calculateReferenceMean() // recalculate as the Consequence settings might have changed
                          ..notify();
                      },
                      child: Text("Ok")),
                ),
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
        GlobalSettingCard(state: state),
      ],
    );
  }
}

class GlobalSettingCard extends StatelessWidget {
  final AppState state;
  const GlobalSettingCard({required this.state, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: state.backgroundConsequence.index.toDouble(),
                  activeColor: state.backgroundConsequence.color,
                  min: 0,
                  max: 4,
                  divisions: 4,
                  label: "background result: ${state.backgroundConsequence.name}",
                  onChanged: (double value) {
                    state.backgroundConsequence = Consequence.values[value.toInt()];
                    state.notify();
                  },
                ),
              ),
              Expanded(
                child: Slider(
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
              ),
            ],
          ),
          Row(
            children: [
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Slider(
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
              ),
              Expanded(
                child: Slider(
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
              ),
              Expanded(
                child: Slider(
                  value: state.announcementDelayOffset.toDouble(),
                  min: -2,
                  max: 2,
                  divisions: 4,
                  label: "announcement delay: ${state.announcementDelayOffset}s",
                  onChanged: (double value) {
                    state.announcementDelayOffset = value.toInt();
                    state.notify();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
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
              value: targetConfig.consequence.index.toDouble(),
              activeColor: targetConfig.consequence.color,
              min: 0,
              max: 4,
              divisions: 4,
              label: "result: ${targetConfig.consequence.name}",
              onChanged: (double value) {
                targetConfig.consequence = Consequence.values[value.toInt()];
                state.notify();
              },
            ),
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
          ],
        ),
      ),
    );
  }
}

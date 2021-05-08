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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Slider(
                value: state.successDelay.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                label: "success timeout: ${state.successDelay}s",
                onChanged: (double value) {
                  state.successDelay = value.round();
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
                  state.failureDelay = value.round();
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
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SlotSettingCard(state, state.targets[0]),
            SlotSettingCard(state, state.targets[1]),
            SlotSettingCard(state, state.targets[2]),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SlotSettingCard(state, state.targets[3]),
            SlotSettingCard(state, state.targets[4]),
            SlotSettingCard(state, state.targets[5]),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SlotSettingCard(state, state.targets[6]),
            SlotSettingCard(state, state.targets[7]),
            SlotSettingCard(state, state.targets[8]),
          ],
        ),
      ],
    );
  }
}

class SlotSettingCard extends StatelessWidget {
  final AppState state;
  final TargetConfig targetConfig;
  const SlotSettingCard(this.state, this.targetConfig, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Column(
          children: [
            Slider(
              value: targetConfig.colorIndex.toDouble(),
              min: 0,
              max: 6,
              divisions: 6,
              activeColor: targetConfig.color,
              label: "color: ${targetConfig.colorName}",
              onChanged: (double value) {
                targetConfig.colorIndex = value.round();
                state.notify();
              },
            ),
            Slider(
              value: targetConfig.size,
              min: 0,
              max: 200,
              divisions: 4,
              label: "size: ${targetConfig.size.round()}",
              onChanged: (double value) {
                targetConfig.size = value;
                state.notify();
              },
            ),
            Slider(
              value: targetConfig.cueScale.toDouble(),
              min: 0,
              max: 50,
              divisions: 5,
              label: "cue scale: ${targetConfig.cueScale}%",
              onChanged: (double value) {
                targetConfig.cueScale = value.toInt();
                state.notify();
              },
            ),
            Slider(
              value: targetConfig.cueAlpha.toDouble(),
              min: 5,
              max: 95,
              divisions: 9,
              activeColor: Colors.blue.withAlpha(targetConfig.cueAlpha.toInt() * 2),
              label: "cue alpha: ${targetConfig.cueAlpha.toInt()}%",
              onChanged: (double value) {
                targetConfig.cueAlpha = value.toInt();
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

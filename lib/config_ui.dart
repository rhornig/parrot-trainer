import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'backend.dart';
import 'config.dart';

class MainConfigPanel extends StatelessWidget {
  final AppState state;
  final VoidCallback onClose;
  const MainConfigPanel(this.state, {required this.onClose, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, child) {
      return state.sceneDetailsVisible
          ? SceneConfigPanel(state.config.scene, onAccept: () {
              state.sceneDetailsVisible = false;
              state.notifyListeners();
            })
          : ReorderableListView.builder(
              itemCount: state.config.scenes.length,
              itemBuilder: (context, index) {
                final item = state.config.scenes[index];
                return Dismissible(
                    key: ObjectKey(item),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Container(
                        height: 50,
                        color: index == state.config.index ? Colors.lightBlue : Colors.white10,
                        child: Center(child: Text(item.name)),
                      ),
                      onTap: () {
                        if (state.config.index != index) {
                          state
                            ..config.index = index
                            ..resetWindowStatistics()
                            ..calculateReferenceMean();
                        }
                        onClose();
                      },
                    ),
                    direction: DismissDirection.horizontal,
                    onDismissed: (direction) {
                      if (direction == DismissDirection.startToEnd) {
                        state.config.scenes.removeAt(index);
                        state.config.notifyListeners();
                      }
                      if (direction == DismissDirection.endToStart) {
                        state.sceneDetailsVisible = true;
                        state.notifyListeners();
                      }
                    },
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd && index != state.config.index) return true;
                      if (direction == DismissDirection.endToStart) {
                        state.config.index = index;
                        return true;
                      }
                      return false;
                    },
                    background: Container(
                        color: Colors.red,
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        alignment: Alignment.centerLeft,
                        child: Icon(Icons.delete)),
                    secondaryBackground: Container(
                        color: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 50.0),
                        alignment: Alignment.centerRight,
                        child: Icon(Icons.edit)));
              },
              onReorder: (int oldIndex, int newIndex) {
                if (oldIndex < newIndex) newIndex -= 1;
                final item = state.config.scenes.removeAt(oldIndex);
                state.config.scenes.insert(newIndex, item);
                // keep the active selection at the same place after reordering
                if (oldIndex == state.config.index)
                  state.config.index = newIndex;
                else if (oldIndex < state.config.index && state.config.index <= newIndex)
                  state.config.index -= 1;
                else if (oldIndex > state.config.index && state.config.index >= newIndex) state.config.index += 1;
                state.notifyListeners();
              },
            );
    });
  }
}

class SceneConfigPanel extends StatelessWidget {
  final SceneConfig scene;
  final VoidCallback onAccept;
  const SceneConfigPanel(this.scene, {required this.onAccept, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GlobalConfigCard(scene),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [TargetConfigCard(scene.targets[0]), TargetConfigCard(scene.targets[1]), TargetConfigCard(scene.targets[2])],
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [TargetConfigCard(scene.targets[3]), TargetConfigCard(scene.targets[4]), TargetConfigCard(scene.targets[5])],
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [TargetConfigCard(scene.targets[6]), TargetConfigCard(scene.targets[7]), TargetConfigCard(scene.targets[8])],
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(onPressed: onAccept, child: Text("Ok")),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// to configure global setting of the scene (i.e. those not related to individual targets)
class GlobalConfigCard extends StatelessWidget {
  final SceneConfig scene;
  const GlobalConfigCard(this.scene, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: scene,
      child: Card(
        child: Consumer<SceneConfig>(builder: (context, data, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                        child: TextFormField(
                          initialValue: data.name,
                          onChanged: (v) => data.name = v,
                        )),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Checkbox(
                          value: data.shuffleOnSuccess,
                          onChanged: (bool? value) {
                            data.shuffleOnSuccess = value ?? true;
                          },
                        ),
                        Text("Shuffle on success")
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Checkbox(
                          value: data.shuffleOnFailure,
                          onChanged: (bool? value) {
                            data.shuffleOnFailure = value ?? true;
                          },
                        ),
                        Text("Shuffle on failure")
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Checkbox(
                          value: data.newTargetOnFailure,
                          onChanged: (bool? value) {
                            data.newTargetOnFailure = value ?? true;
                          },
                        ),
                        Text("New target on failure")
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: data.backgroundConsequence.index.toDouble(),
                      activeColor: data.backgroundConsequence.color,
                      min: 0,
                      max: 4,
                      divisions: 4,
                      label: "background result: ${data.backgroundConsequence.name}",
                      onChanged: (double value) {
                        data.backgroundConsequence = Consequence.values[value.toInt()];
                      },
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: data.targetSize.toDouble(),
                      min: 0,
                      max: 4,
                      divisions: 4,
                      label: "target size: ${data.targetSize}",
                      onChanged: (double value) {
                        data.targetSize = value.toInt();
                      },
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: data.positionNoise.toDouble(),
                      min: 0,
                      max: 5,
                      divisions: 5,
                      label: "position noise: ${data.positionNoise}",
                      onChanged: (double value) {
                        data.positionNoise = value.toInt();
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: data.announcedColor.index.toDouble(),
                      min: 0,
                      max: ShapeColor.values.length - 1,
                      divisions: ShapeColor.values.length - 1,
                      activeColor: data.announcedColor.color,
                      label: "announced color: ${data.announcedColor.name}",
                      onChanged: (double value) {
                        data.announcedColor = ShapeColor.values[value.toInt()];
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
                      value: data.successDelay.toDouble(),
                      min: 0,
                      max: 5,
                      divisions: 5,
                      label: "success timeout: ${data.successDelay}s",
                      onChanged: (double value) {
                        data.successDelay = value.toInt();
                      },
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: data.failureDelay.toDouble(),
                      min: 0,
                      max: 5,
                      divisions: 5,
                      label: "failure timeout: ${data.failureDelay}s",
                      onChanged: (double value) {
                        data.failureDelay = value.toInt();
                      },
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: data.announcementDelayOffset.toDouble(),
                      min: -2,
                      max: 2,
                      divisions: 4,
                      label: "announcement delay: ${data.announcementDelayOffset}s",
                      onChanged: (double value) {
                        data.announcementDelayOffset = value.toInt();
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

/// card to configure a single target
class TargetConfigCard extends StatelessWidget {
  final TargetConfig targetConfig;
  const TargetConfigCard(this.targetConfig, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: targetConfig,
      child: Expanded(
        child: Card(
          child: Consumer<TargetConfig>(
            builder: (context, data, child) {
              return Column(
                children: [
                  Slider(
                    value: data.consequence.index.toDouble(),
                    activeColor: data.consequence.color,
                    min: 0,
                    max: 4,
                    divisions: 4,
                    label: "result: ${data.consequence.name}",
                    onChanged: (double value) {
                      data.consequence = Consequence.values[value.toInt()];
                    },
                  ),
                  Slider(
                    value: data.shapeColor.index.toDouble(),
                    min: 0,
                    max: ShapeColor.values.length - 1,
                    divisions: ShapeColor.values.length - 1,
                    activeColor: data.shapeColor.color,
                    label: "color: ${data.shapeColor.name}",
                    onChanged: (double value) {
                      data.shapeColor = ShapeColor.values[value.toInt()];
                    },
                  ),
                  Slider(
                    value: data.shapeSize.toDouble(),
                    min: 0,
                    max: 5,
                    divisions: 5,
                    label: "size: ${data.shapeSize.round()}",
                    onChanged: (double value) {
                      data.shapeSize = value.toInt();
                    },
                  ),
                  Slider(
                    value: data.alpha.toDouble(),
                    min: 0,
                    max: 5,
                    divisions: 5,
                    activeColor: Colors.blue.withAlpha(alphaValues[data.alpha.toInt()]),
                    label: "target alpha: ${data.alpha.toInt()}",
                    onChanged: (double value) {
                      data.alpha = value.toInt();
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

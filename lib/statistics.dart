import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'backend.dart';

class StatisticsPanel extends StatelessWidget {
  final AppState state;
  const StatisticsPanel(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double probability = 0, variance = 0;
    int sum = state.success + state.failure;
    if (sum != 0) {
      probability = state.success / sum;
      variance = sqrt(probability * (1 - probability) / sum);
    }
    int referenceMeanPct = (state.referenceMean * 100).round();
    int referenceConfidencePct = (state.referenceStdDev * 100).round();
    int referenceConfidencePct2 = (state.referenceStdDev * 2 * 100).round();
    int referenceConfidencePct3 = (state.referenceStdDev * 3 * 100).round();
    int successPct = (probability * 100).round();

    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onLongPress: () {
              state
                ..failure = 0
                ..neutral = 0
                ..success = 0
                ..notify();
            },
            child: Text(
              "S${state.success}+F${state.failure}=∑$sum N${state.neutral}\nS$successPct% B$referenceMeanPct±(σ$referenceConfidencePct 2σ$referenceConfidencePct2 3σ$referenceConfidencePct3)%",
              style: TextStyle(color: Colors.grey.shade900, fontSize: 40),
              textAlign: TextAlign.end,
            ),
          ),
          GestureDetector(
            onLongPress: () {
              state
                ..settingsPanelVisible = true
                ..notify();
            },
            child: Icon(Icons.settings, size: 80, color: Colors.grey.shade900),
          ),
        ],
      ),
    );
  }
}

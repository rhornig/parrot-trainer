import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'backend.dart';

class StatisticsPanel extends StatelessWidget {
  final AppState state;
  const StatisticsPanel(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int sum = state.success + state.neutral + state.failure;
    int successPct = (sum == 0) ? 0 : ((state.success / sum) * 100).round();
    int neutralPct = (sum == 0) ? 0 : ((state.neutral / sum) * 100).round();
    int failurePct = (sum == 0) ? 0 : ((state.failure / sum) * 100).round();

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
              "S${state.success} N${state.neutral} F${state.failure} ∑$sum\nS$successPct% N$neutralPct% F$failurePct%",
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

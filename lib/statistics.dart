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
      child: Column(
        children: [
          Expanded(
              child: Container(
                  color: Colors.grey.shade900, child: CustomPaint(size: Size.infinite, painter: ChartPainter(state)))),
          Row(
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
                  style: TextStyle(color: Colors.grey.shade800, fontSize: 40),
                  textAlign: TextAlign.end,
                ),
              ),
              GestureDetector(
                onLongPress: () {
                  state
                    ..settingsPanelVisible = true
                    ..notify();
                },
                child: Icon(Icons.settings, size: 80, color: Colors.grey.shade800),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  final AppState state;

  ChartPainter(this.state);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha(16);
    var refStart = Offset(0, state.referenceMean);
    var refEnd = Offset(-600, state.referenceMean);
    canvas
      ..save()
      ..translate(size.width, size.height)
      ..scale(size.width / 600.0, -size.height)
      ..clipRect(Rect.fromLTRB(-600, 1, 0, 0));

    // 1 minute time divs
    for (double t = 0; t > -600; t -= 60) canvas.drawLine(Offset(t, 0), Offset(t, 1), paint);

    canvas
      ..drawLine(Offset(-600, 0.25), Offset(0, 0.25), paint)
      ..drawLine(Offset(-600, 0.5), Offset(0, 0.5), paint)
      ..drawLine(Offset(-600, 0.75), Offset(0, 0.75), paint);

    paint.color = Colors.white.withAlpha(16);
    canvas
      ..drawLine(refStart, refEnd, paint..strokeWidth = state.referenceStdDev * 3)
      ..drawLine(refStart, refEnd, paint..strokeWidth = state.referenceStdDev * 2)
      ..drawLine(refStart, refEnd, paint..strokeWidth = state.referenceStdDev)
      ..drawLine(refStart, refEnd, paint..strokeWidth = 0);

    final incPaint = Paint()..color = Colors.green.withAlpha(128);
    final decPaint = Paint()..color = Colors.red.withAlpha(128);
    final ncPaint = Paint()..color = Colors.yellow.withAlpha(128);
    for (int i = 1; i < state.history.length; i++) {
      final laterValue = state.history[i - 1];
      final earlierValue = state.history[i];
      canvas.drawLine(
          Offset(-5.0 * (i - 1), laterValue),
          Offset(-5.0 * i, earlierValue),
          laterValue > earlierValue
              ? incPaint
              : laterValue == earlierValue
                  ? ncPaint
                  : decPaint);
    }

    canvas..restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

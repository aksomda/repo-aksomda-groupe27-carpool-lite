import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SatisfactionChart extends StatelessWidget {
  final double punctuality;
  final double driving;
  final double atmosphere;

  const SatisfactionChart({
    super.key,
    required this.punctuality,
    required this.driving,
    required this.atmosphere,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: 10,
          alignment: BarChartAlignment.spaceAround,

          barGroups: [
            _createBarGroup(index: 0, value: punctuality),
            _createBarGroup(index: 1, value: driving),
            _createBarGroup(index: 2, value: atmosphere),
          ],

          gridData: const FlGridData(show: true),

          borderData: FlBorderData(show: false),

          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, interval: 1),
            ),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: _bottomTitle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  BarChartGroupData _createBarGroup({
    required int index,
    required double value,
  }) {
    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: value,
          width: 35,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _bottomTitle(double value, TitleMeta meta) {
    String text;

    switch (value.toInt()) {
      case 0:
        text = 'Ponctualité';
        break;
      case 1:
        text = 'Conduite';
        break;
      case 2:
        text = 'Ambiance';
        break;
      default:
        text = '';
    }

    return SideTitleWidget(
      meta: meta,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11),
      ),
    );
  }
}

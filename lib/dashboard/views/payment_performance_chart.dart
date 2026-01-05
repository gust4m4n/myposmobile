import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../payments/models/payment_performance_model.dart';
import '../../shared/utils/currency_formatter.dart';

class PaymentPerformanceChart extends StatelessWidget {
  final List<PaymentPerformanceModel> data;

  const PaymentPerformanceChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(child: Text('No data available')),
      );
    }

    return SizedBox(
      height: 300,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, top: 16),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: _getMaxAmount() / 5,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withValues(alpha: 0.2),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    if (value.toInt() >= 0 && value.toInt() < data.length) {
                      final date = DateTime.parse(data[value.toInt()].date);
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          DateFormat('MMM dd').format(date),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: _getMaxAmount() / 5,
                  reservedSize: 60,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    if (value == 0) {
                      return const Text(
                        'Rp 0',
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      );
                    }
                    return Text(
                      _formatCompactCurrency(value),
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            minX: 0,
            maxX: (data.length - 1).toDouble(),
            minY: 0,
            maxY: _getMaxAmount() * 1.1,
            lineBarsData: [
              LineChartBarData(
                spots: data
                    .asMap()
                    .entries
                    .map((e) => FlSpot(e.key.toDouble(), e.value.totalAmount))
                    .toList(),
                isCurved: true,
                color: const Color(0xFF007AFF), // Solid iOS blue
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: const Color(0xFF007AFF),
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (touchedSpot) => Colors.blueGrey,
                tooltipRoundedRadius: 8,
                getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                  return touchedBarSpots.map((barSpot) {
                    final flSpot = barSpot;
                    if (flSpot.x.toInt() >= 0 &&
                        flSpot.x.toInt() < data.length) {
                      final item = data[flSpot.x.toInt()];
                      return LineTooltipItem(
                        '${DateFormat('MMM dd').format(DateTime.parse(item.date))}\n',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: CurrencyFormatter.format(item.totalAmount),
                            style: const TextStyle(color: Colors.white70),
                          ),
                          TextSpan(
                            text: '\n${item.qty} transactions',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    }
                    return null;
                  }).toList();
                },
              ),
              handleBuiltInTouches: true,
            ),
          ),
        ),
      ),
    );
  }

  double _getMaxAmount() {
    if (data.isEmpty) return 1000000;
    return data.map((e) => e.totalAmount).reduce((a, b) => a > b ? a : b);
  }

  String _formatCompactCurrency(double value) {
    if (value >= 1000000) {
      return 'Rp ${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return 'Rp ${(value / 1000).toStringAsFixed(0)}K';
    }
    return CurrencyFormatter.format(value);
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:study/src/features/stats/providers/stats_provider.dart';
import 'package:study/src/utils/formatters.dart';

/// Placeholder screen for Stats.
class StatsScreen extends StatelessWidget {
  /// Creates a [StatsScreen] widget.
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StatsProvider>(
      builder: (context, provider, _) {
        final total = provider.timePerDay.values.fold(0, (a, b) => a + b);
        final avg =
            provider.timePerDay.isNotEmpty
                ? (total ~/ provider.timePerDay.length)
                : 0;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Statistics'),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {},
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'INSIGHTS',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Week'),
                    selected: provider.selectedPeriod == StatsPeriod.Week,
                    onSelected:
                        (_) => provider.setSelectedPeriod(StatsPeriod.Week),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Month'),
                    selected: provider.selectedPeriod == StatsPeriod.Month,
                    onSelected:
                        (_) => provider.setSelectedPeriod(StatsPeriod.Month),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Year'),
                    selected: provider.selectedPeriod == StatsPeriod.Year,
                    onSelected:
                        (_) => provider.setSelectedPeriod(StatsPeriod.Year),
                  ),
                  const Spacer(),
                  Text(
                    'Total: ${formatDuration(total)}',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Avg: ${formatDuration(avg)}',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFF232323),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child:
                    provider.timePerDay.isEmpty
                        ? const Center(
                          child: Text(
                            'No data for this period',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                        : BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            barGroups:
                                provider.timePerDay.entries
                                    .toList()
                                    .asMap()
                                    .entries
                                    .map(
                                      (entry) => BarChartGroupData(
                                        x: entry.key,
                                        barRods: [
                                          BarChartRodData(
                                            toY: entry.value.value.toDouble(),
                                            color: Colors.blueAccent,
                                            width: 18,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                        ],
                                        showingTooltipIndicators: [0],
                                      ),
                                    )
                                    .toList(),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (double value, meta) {
                                    final idx = value.toInt();
                                    if (idx < 0 ||
                                        idx >= provider.timePerDay.length)
                                      return const SizedBox();
                                    final date = provider.timePerDay.keys
                                        .elementAt(idx);
                                    return Text(
                                      date.substring(5),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(show: false),
                          ),
                        ),
              ),
              const SizedBox(height: 24),
              Text(
                'PROJECTS BREAKDOWN',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFF232323),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child:
                    provider.timePerProject.isEmpty
                        ? const Center(
                          child: Text(
                            'No data for this period',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                        : PieChart(
                          PieChartData(
                            sections:
                                provider.timePerProject.entries
                                    .toList()
                                    .asMap()
                                    .entries
                                    .map(
                                      (entry) => PieChartSectionData(
                                        value: entry.value.value.toDouble(),
                                        color:
                                            Colors.primaries[entry.key %
                                                Colors.primaries.length],
                                        title: entry.value.key,
                                        radius: 60,
                                        titleStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    )
                                    .toList(),
                            centerSpaceRadius: 40,
                          ),
                        ),
              ),
            ],
          ),
        );
      },
    );
  }
}

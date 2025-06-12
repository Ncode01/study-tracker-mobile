import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:study/src/models/project_model.dart';

/// Detailed view screen for a specific project.
///
/// This screen displays project progress, insights with charts, and timer controls
/// matching the design specifications with modern UI components.
class ProjectDetailScreen extends StatefulWidget {
  /// The project to display details for
  final Project project;

  /// Creates a [ProjectDetailScreen].
  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  int _selectedSegment = 0; // 0 for "Today", 1 for "Total"

  // Static hardcoded data for the chart matching the design
  final List<BarChartGroupData> _chartData = [
    BarChartGroupData(
      x: 0, // Sunday
      barRods: [
        BarChartRodData(
          toY: 0,
          color: const Color(0xFF4A90E2),
          width: 16,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    ),
    BarChartGroupData(
      x: 1, // Monday
      barRods: [
        BarChartRodData(
          toY: 2.5,
          color: const Color(0xFF4A90E2),
          width: 16,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    ),
    BarChartGroupData(
      x: 2, // Tuesday
      barRods: [
        BarChartRodData(
          toY: 1.5,
          color: const Color(0xFF4A90E2),
          width: 16,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    ),
    BarChartGroupData(
      x: 3, // Wednesday
      barRods: [
        BarChartRodData(
          toY: 0,
          color: const Color(0xFF4A90E2),
          width: 16,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    ),
    BarChartGroupData(
      x: 4, // Thursday
      barRods: [
        BarChartRodData(
          toY: 1.0,
          color: const Color(0xFF4A90E2),
          width: 16,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    ),
    BarChartGroupData(
      x: 5, // Friday
      barRods: [
        BarChartRodData(
          toY: 0,
          color: const Color(0xFF4A90E2),
          width: 16,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    ),
    BarChartGroupData(
      x: 6, // Saturday
      barRods: [
        BarChartRodData(
          toY: 0,
          color: const Color(0xFF4A90E2),
          width: 16,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Dark background
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'O/L', // Hardcoded project name from design
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {
            // TODO: Show project options menu
          },
          tooltip: 'More Options',
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildProgressSummarySection(),
          const SizedBox(height: 24),
          _buildInsightsSection(),
          const SizedBox(height: 100), // Extra space for FAB
        ],
      ),
    );
  }

  Widget _buildProgressSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Custom Segmented Control
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSegment = 0;
                    });
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                          _selectedSegment == 0
                              ? const Color(0xFF4A90E2)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        'Today',
                        style: TextStyle(
                          color:
                              _selectedSegment == 0
                                  ? Colors.white
                                  : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSegment = 1;
                    });
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                          _selectedSegment == 1
                              ? const Color(0xFF4A90E2)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        'Total',
                        style: TextStyle(
                          color:
                              _selectedSegment == 1
                                  ? Colors.white
                                  : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Progress Text
        const Text(
          '1h 00m / 6h 00m', // Hardcoded from design
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        const Text(
          '17 %', // Hardcoded from design
          style: TextStyle(
            color: Color(0xFF4A90E2),
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        // Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: const LinearProgressIndicator(
            value: 0.17, // 17% from design
            backgroundColor: Color(0xFF2A2A2A),
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with INSIGHTS and Share button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'INSIGHTS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Share functionality
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Share',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date range and navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Jun 8 - Jun 14, 2025',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // TODO: Previous week
                    },
                    icon: const Icon(Icons.chevron_left, color: Colors.grey),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: Next week
                    },
                    icon: const Icon(Icons.chevron_right, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Time period chips
          Row(
            children: [
              _buildTimePeriodChip('Week', true),
              const SizedBox(width: 8),
              _buildTimePeriodChip('8 Weeks', false),
              const SizedBox(width: 8),
              _buildTimePeriodChip('Month', false),
              const SizedBox(width: 8),
              _buildTimePeriodChip('Year', false),
            ],
          ),
          const SizedBox(height: 24),

          // Bar Chart
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 3,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                        return Text(
                          days[value.toInt()],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value == 0) return const Text('');
                        return Text(
                          '${value.toInt()}h',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: _chartData,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePeriodChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF4A90E2) : const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      width: 72,
      height: 72,
      decoration: const BoxDecoration(
        color: Color(0xFF4A90E2),
        shape: BoxShape.circle,
      ),
      child: FloatingActionButton(
        onPressed: () {
          // TODO: Start timer or navigate to timer screen
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
      ),
    );
  }
}

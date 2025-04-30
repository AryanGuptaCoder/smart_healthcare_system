import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:smart_healthcare_system/models/health_data_model.dart';
import 'package:smart_healthcare_system/providers/auth_provider.dart';
import 'package:smart_healthcare_system/providers/health_data_provider.dart';
import 'package:smart_healthcare_system/utils/app_theme.dart';
import 'package:smart_healthcare_system/widgets/loading_indicator.dart';

class HealthDetailsScreen extends StatefulWidget {
  const HealthDetailsScreen({super.key});

  @override
  State<HealthDetailsScreen> createState() => _HealthDetailsScreenState();
}

class _HealthDetailsScreenState extends State<HealthDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<HealthData> _historicalData = [];
  String _selectedMetric = 'heartRate';
  String _selectedPeriod = '24h';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final healthDataProvider =
        Provider.of<HealthDataProvider>(context, listen: false);

    if (authProvider.user != null) {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(hours: 24));

      _historicalData = await healthDataProvider.getHistoricalData(
        authProvider.user!.id,
        startDate,
        endDate,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<FlSpot> _getChartData() {
    return _historicalData.asMap().entries.map((entry) {
      final data = entry.value;
      final x = entry.key.toDouble();
      double y;

      switch (_selectedMetric) {
        case 'heartRate':
          y = data.heartRate;
          break;
        case 'spO2':
          y = data.spO2;
          break;
        case 'temperature':
          y = data.temperature;
          break;
        case 'stress':
          y = data.stressLevel;
          break;
        default:
          y = 0;
      }

      return FlSpot(x, y);
    }).toList();
  }

  String _getYAxisLabel(double value) {
    switch (_selectedMetric) {
      case 'heartRate':
        return '${value.toInt()} BPM';
      case 'spO2':
        return '${value.toInt()}%';
      case 'temperature':
        return '${value.toStringAsFixed(1)}°C';
      case 'stress':
        return '${value.toInt()}%';
      default:
        return value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Details'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Heart Rate'),
            Tab(text: 'SpO₂'),
            Tab(text: 'Temperature'),
            Tab(text: 'Stress'),
          ],
          onTap: (index) {
            setState(() {
              switch (index) {
                case 0:
                  _selectedMetric = 'heartRate';
                  break;
                case 1:
                  _selectedMetric = 'spO2';
                  break;
                case 2:
                  _selectedMetric = 'temperature';
                  break;
                case 3:
                  _selectedMetric = 'stress';
                  break;
              }
            });
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: '24h', label: Text('24h')),
                      ButtonSegment(value: '7d', label: Text('7d')),
                      ButtonSegment(value: '30d', label: Text('30d')),
                      ButtonSegment(value: '90d', label: Text('90d')),
                    ],
                    selected: {_selectedPeriod},
                    onSelectionChanged: (Set<String> selection) {
                      setState(() {
                        _selectedPeriod = selection.first;
                      });
                      _loadData();
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  _getYAxisLabel(value),
                                  style: AppTextStyles.caption,
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value % 6 == 0) {
                                  final index = value.toInt();
                                  if (index < _historicalData.length) {
                                    return Text(
                                      '${_historicalData[index].timestamp.hour}:00',
                                      style: AppTextStyles.caption,
                                    );
                                  }
                                }
                                return const Text('');
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _getChartData(),
                            isCurved: true,
                            color: Theme.of(context).colorScheme.primary,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_historicalData.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Statistics',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildStatCard(
                              'Average',
                              _calculateAverage(),
                              Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 16),
                            _buildStatCard(
                              'Minimum',
                              _calculateMin(),
                              Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 16),
                            _buildStatCard(
                              'Maximum',
                              _calculateMax(),
                              Theme.of(context).colorScheme.tertiary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.body2.copyWith(
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.heading3.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateAverage() {
    if (_historicalData.isEmpty) return '0';

    double sum = 0;
    for (var data in _historicalData) {
      switch (_selectedMetric) {
        case 'heartRate':
          sum += data.heartRate;
          break;
        case 'spO2':
          sum += data.spO2;
          break;
        case 'temperature':
          sum += data.temperature;
          break;
        case 'stress':
          sum += data.stressLevel;
          break;
      }
    }

    final average = sum / _historicalData.length;
    return _formatValue(average);
  }

  String _calculateMin() {
    if (_historicalData.isEmpty) return '0';

    double min = double.infinity;
    for (var data in _historicalData) {
      double value;
      switch (_selectedMetric) {
        case 'heartRate':
          value = data.heartRate;
          break;
        case 'spO2':
          value = data.spO2;
          break;
        case 'temperature':
          value = data.temperature;
          break;
        case 'stress':
          value = data.stressLevel;
          break;
        default:
          value = 0;
      }
      if (value < min) min = value;
    }

    return _formatValue(min);
  }

  String _calculateMax() {
    if (_historicalData.isEmpty) return '0';

    double max = double.negativeInfinity;
    for (var data in _historicalData) {
      double value;
      switch (_selectedMetric) {
        case 'heartRate':
          value = data.heartRate;
          break;
        case 'spO2':
          value = data.spO2;
          break;
        case 'temperature':
          value = data.temperature;
          break;
        case 'stress':
          value = data.stressLevel;
          break;
        default:
          value = 0;
      }
      if (value > max) max = value;
    }

    return _formatValue(max);
  }

  String _formatValue(double value) {
    switch (_selectedMetric) {
      case 'heartRate':
        return '${value.toInt()} BPM';
      case 'spO2':
        return '${value.toInt()}%';
      case 'temperature':
        return '${value.toStringAsFixed(1)}°C';
      case 'stress':
        return '${value.toInt()}%';
      default:
        return value.toString();
    }
  }
}

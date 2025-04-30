import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_healthcare_system/models/health_data_model.dart';
import 'package:smart_healthcare_system/providers/auth_provider.dart';
import 'package:smart_healthcare_system/providers/health_data_provider.dart';
import 'package:smart_healthcare_system/utils/app_theme.dart';//yo chai kasko lagi ho hw mama <dev1: Ayush >
import 'package:smart_healthcare_system/widgets/loading_indicator.dart';

Widget _buildSummaryCard(BuildContext context, HealthDataProvider healthDataProvider) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Summary', style: Theme.of(context).textTheme.titleLarge),
          // Add more summary information here
        ],
      ),
    ),
  );
}

Widget _buildTrendsCard(BuildContext context) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Trends', style: Theme.of(context).textTheme.titleLarge),
          // Add trend information here
        ],
      ),
    ),
  );
}

Widget _buildRecommendationsCard(BuildContext context, HealthDataProvider healthDataProvider) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recommendations', style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    ),
  );
}

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  bool _isLoading = true;
  List<HealthData> _recentData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final healthDataProvider = Provider.of<HealthDataProvider>(context, listen: false);

    if (authProvider.user != null) {
      _recentData = await healthDataProvider.getRecentHealthData(
        authProvider.user!.id,
        limit: 24,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final healthDataProvider = Provider.of<HealthDataProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Insights'),
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_recentData.isNotEmpty) ...[
              _buildSummaryCard(context, healthDataProvider),
              const SizedBox(height: 16),
              _buildTrendsCard(context),
              const SizedBox(height: 16),
              _buildRecommendationsCard(context, healthDataProvider),
            ] else ...[
              const Center(
                child: Text('No health data available'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

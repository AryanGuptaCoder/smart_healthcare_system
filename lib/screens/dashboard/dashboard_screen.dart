import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_healthcare_system/models/health_data_model.dart';
import 'package:smart_healthcare_system/providers/auth_provider.dart';
import 'package:smart_healthcare_system/providers/device_provider.dart';
import 'package:smart_healthcare_system/providers/health_data_provider.dart';
import 'package:smart_healthcare_system/providers/notification_provider.dart';
import 'package:smart_healthcare_system/screens/dashboard/widgets/device_status_card.dart';
import 'package:smart_healthcare_system/screens/dashboard/widgets/health_metric_card.dart';
import 'package:smart_healthcare_system/screens/dashboard/widgets/insights_card.dart';
import 'package:smart_healthcare_system/screens/dashboard/widgets/notification_bell.dart';
import 'package:smart_healthcare_system/utils/app_theme.dart';
import 'package:smart_healthcare_system/widgets/loading_indicator.dart';
//<Dev Ayush: I changed the label text for ECG as requested but idk if it will effect this
//long ass code it seems like it does but it works fine just dont ask me>

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final healthDataProvider =
        Provider.of<HealthDataProvider>(context, listen: false);
    final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    if (authProvider.user != null) {
      await Future.wait([
        healthDataProvider.fetchLatestData(authProvider.user!.id),
        healthDataProvider.getRecentHealthData(authProvider.user!.id),
        deviceProvider.fetchSavedDevice(authProvider.user!.id),
        notificationProvider.fetchNotifications(authProvider.user!.id),
      ]);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final healthDataProvider = Provider.of<HealthDataProvider>(context);
    final deviceProvider = Provider.of<DeviceProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: LoadingIndicator(),
        ),
      );
    }

    final user = authProvider.user;
    final latestData = healthDataProvider.latestData;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hello, ${user?.name ?? 'User'}',
          style: AppTextStyles.heading3,
        ),
        actions: [
          NotificationBell(
            unreadCount: notificationProvider.unreadCount,
            onTap: () {
              // Navigate to notifications screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DeviceStatusCard(
                device: deviceProvider.connectedDevice,
                isConnected: deviceProvider.isConnected,
                onConnect: () {
                  Navigator.pushNamed(context, '/device-pairing');
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Health Metrics',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 8),
              if (latestData != null) ...[
                _buildHealthMetricsGrid(latestData),
              ] else ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No health data available. Connect your device to start monitoring.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              InsightsCard(
                latestData: latestData,
                onViewMore: () {
                  Navigator.pushNamed(context, '/insights');
                },
              ),
              const SizedBox(height: 16),
              _buildQuickActions(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.spa),
            label: 'Meditation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on dashboard
              break;
            case 1:
              Navigator.pushNamed(context, '/health-details');
              break;
            case 2:
              Navigator.pushNamed(context, '/meditation');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _buildHealthMetricsGrid(HealthData data) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        HealthMetricCard(
          title: 'Heart Rate',
          value: '${data.heartRate.toInt()}',
          unit: 'BPM',
          icon: Icons.favorite,
          color: data.isHeartRateNormal ? Colors.green : Colors.red,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/health-details',
              arguments: {'metric': 'heartRate'},
            );
          },
        ),
        HealthMetricCard(
          title: 'SpO₂',
          value: '${data.spO2.toInt()}',
          unit: '%',
          icon: Icons.air,
          color: data.isSpO2Normal ? Colors.green : Colors.red,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/health-details',
              arguments: {'metric': 'spO2'},
            );
          },
        ),
        HealthMetricCard(
          title: 'Temperature',
          value: data.temperature.toStringAsFixed(1),
          unit: '°C',
          icon: Icons.thermostat,
          color: data.isTemperatureNormal ? Colors.green : Colors.red,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/health-details',
              arguments: {'metric': 'temperature'},
            );
          },
        ),
        HealthMetricCard(
          title: 'Stress',
          value: '${data.stressLevel.toInt()}',
          unit: '%',
          icon: Icons.psychology,
          color: data.isStressLevelNormal ? Colors.green : Colors.red,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/health-details',
              arguments: {'metric': 'stress'},
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.monitor_heart,
                label: 'Metric',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/health-details',
                    arguments: {'metric': 'ecg'},
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                icon: Icons.spa,
                label: 'Meditation',
                onTap: () {
                  Navigator.pushNamed(context, '/meditation');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.history,
                label: 'History',
                onTap: () {
                  Navigator.pushNamed(context, '/health-details');
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                icon: Icons.bluetooth,
                label: 'Connect Device',
                onTap: () {
                  Navigator.pushNamed(context, '/device-pairing');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

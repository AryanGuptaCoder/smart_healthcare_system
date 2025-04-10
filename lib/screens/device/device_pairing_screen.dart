import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:smart_healthcare_system/providers/auth_provider.dart';
import 'package:smart_healthcare_system/providers/device_provider.dart';
import 'package:smart_healthcare_system/utils/app_theme.dart';
import 'package:smart_healthcare_system/widgets/custom_button.dart';
import 'package:smart_healthcare_system/widgets/loading_indicator.dart';

class DevicePairingScreen extends StatefulWidget {
  const DevicePairingScreen({super.key});

  @override
  State<DevicePairingScreen> createState() => _DevicePairingScreenState();
}

class _DevicePairingScreenState extends State<DevicePairingScreen> {
  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    await Provider.of<DeviceProvider>(context, listen: false).startScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Device'),
      ),
      body: Consumer2<DeviceProvider, AuthProvider>(
        builder: (context, deviceProvider, authProvider, _) {
          if (deviceProvider.isScanning) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingIndicator(),
                  SizedBox(height: 16),
                  Text('Scanning for devices...'),
                ],
              ),
            );
          }

          if (deviceProvider.discoveredDevices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wifi_off,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No devices found',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Make sure your device is powered on and in pairing mode',
                    style: AppTextStyles.body2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Scan Again',
                    onPressed: _startScan,
                    icon: Icons.refresh,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Available Devices',
                  style: AppTextStyles.heading3,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: deviceProvider.discoveredDevices.length,
                  itemBuilder: (context, index) {
                    final device = deviceProvider.discoveredDevices[index];
                    return _buildDeviceCard(
                      device,
                      deviceProvider,
                      authProvider,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CustomButton(
                      text: 'Scan Again',
                      onPressed: _startScan,
                      icon: Icons.refresh,
                      isOutlined: true,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Make sure your device is powered on and in pairing mode',
                      style: AppTextStyles.caption.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDeviceCard(
      WiFiAccessPoint device,
      DeviceProvider deviceProvider,
      AuthProvider authProvider,
      ) {
    final isConnecting = deviceProvider.isConnecting;
    final isConnected = deviceProvider.connectedDevice?.ssid == device.ssid;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.wifi,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.ssid,
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Signal Strength: ${_getSignalStrength(device.level)}',
                    style: AppTextStyles.body2.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            if (isConnecting)
              const SizedBox(
                width: 24,
                height: 24,
                child: LoadingIndicator(),
              )
            else
              CustomButton(
                text: isConnected ? 'Connected' : 'Connect',
                onPressed: isConnected
                    ? () {}
                    : () => _handleConnect(deviceProvider, authProvider, device),
                backgroundColor: isConnected
                    ? Theme.of(context).colorScheme.secondary
                    : null,
              ),
          ],
        ),
      ),
    );
  }

  void _handleConnect(DeviceProvider deviceProvider, AuthProvider authProvider, WiFiAccessPoint device) {
    if (authProvider.user != null) {
      deviceProvider.connectToDevice(device, authProvider.user!.id).then((_) {
        if (mounted && deviceProvider.isConnected) {
          Navigator.pop(context);
        }
      });
    }
  }

  String _getSignalStrength(int level) {
    if (level >= -50) {
      return 'Excellent';
    } else if (level >= -60) {
      return 'Good';
    } else if (level >= -70) {
      return 'Fair';
    } else {
      return 'Poor';
    }
  }
}

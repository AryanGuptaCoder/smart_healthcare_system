import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:smart_healthcare_system/models/device_model.dart';
import 'package:smart_healthcare_system/models/health_data_model.dart';
import 'package:smart_healthcare_system/services/device_service.dart';
import 'package:uuid/uuid.dart';

class DeviceProvider with ChangeNotifier {
  final DeviceService _deviceService = DeviceService();
  final NetworkInfo _networkInfo = NetworkInfo();

  DeviceModel? _connectedDevice;
  List<WiFiAccessPoint> _discoveredDevices = [];
  bool _isScanning = false;
  bool _isConnecting = false;
  Timer? _healthDataTimer;

  DeviceModel? get connectedDevice => _connectedDevice;
  List<WiFiAccessPoint> get discoveredDevices => _discoveredDevices;
  bool get isScanning => _isScanning;
  bool get isConnecting => _isConnecting;
  bool get isConnected => _connectedDevice != null;

  Future<void> startScan() async {
    if (_isScanning) return;
    
    try {
      _isScanning = true;
      _discoveredDevices = [];
      notifyListeners();

      // Request permission for WiFi scan
      final can = await WiFiScan.instance.canStartScan();
      if (can != CanStartScan.yes) {
        throw Exception('Cannot scan for WiFi networks');
      }

      // Start WiFi scan
      final result = await WiFiScan.instance.startScan();
      if (result != true) {
        throw Exception('Failed to start WiFi scan');
      }

      // Get scan results
      final results = await WiFiScan.instance.getScannedResults();
      
      // Filter for our device SSIDs (assuming they start with "SmartHealth_")
      _discoveredDevices = results.where((ap) => 
        ap.ssid.startsWith('SmartHealth_')
      ).toList();

      notifyListeners();
      
      // Stop scanning after 30 seconds
      await Future.delayed(const Duration(seconds: 30));
      if (_isScanning) {
        _isScanning = false;
        notifyListeners();
      }
    } catch (e) {
      print('Error scanning for devices: $e');
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<void> stopScan() async {
    _isScanning = false;
    notifyListeners();
  }

  Future<void> connectToDevice(WiFiAccessPoint accessPoint, String userId) async {
    if (_isConnecting) return;
    
    try {
      _isConnecting = true;
      notifyListeners();

      // Disconnect from current device if connected
      await disconnect();

      // Get current WiFi network info
      final wifiName = await _networkInfo.getWifiName();
      final wifiIP = await _networkInfo.getWifiIP();

      if (wifiName == null || wifiIP == null) {
        throw Exception('Failed to get WiFi information');
      }

      // Try to connect to device API
      final response = await http.get(Uri.parse('http://$wifiIP:80/connect'));
      
      if (response.statusCode == 200) {
        final deviceInfo = json.decode(response.body);
        
        // Create or update device in Firestore
        final deviceModel = DeviceModel(
          id: const Uuid().v4(),
          name: deviceInfo['name'] ?? 'Smart Health Device',
          ipAddress: wifiIP,
          isConnected: true,
          lastConnected: DateTime.now(),
          batteryLevel: deviceInfo['battery'] ?? 100,
          ssid: wifiName.replaceAll('"', ''),
          signalStrength: accessPoint.level,
        );

        await _deviceService.saveDevice(deviceModel, userId);
        _connectedDevice = deviceModel;

        // Start polling for health data
        _startHealthDataPolling(userId);

        notifyListeners();
      } else {
        throw Exception('Failed to connect to device');
      }
    } catch (e) {
      print('Error connecting to device: $e');
      await disconnect();
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    try {
      _healthDataTimer?.cancel();
      _healthDataTimer = null;

      if (_connectedDevice != null) {
        try {
          await http.get(Uri.parse('http://${_connectedDevice!.ipAddress}:80/disconnect'));
        } catch (e) {
          print('Error disconnecting from device API: $e');
        }

        final updatedDevice = _connectedDevice!.copyWith(
          isConnected: false,
        );

        await _deviceService.updateDevice(updatedDevice);
        _connectedDevice = updatedDevice;
      }

      notifyListeners();
    } catch (e) {
      print('Error disconnecting from device: $e');
    }
  }

  void _startHealthDataPolling(String userId) {
    _healthDataTimer?.cancel();
    _healthDataTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        if (_connectedDevice == null) {
          timer.cancel();
          return;
        }

        final response = await http.get(
          Uri.parse('http://${_connectedDevice!.ipAddress}:80/health-data')
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final healthData = HealthData(
            id: const Uuid().v4(),
            userId: userId,
            timestamp: DateTime.now(),
            heartRate: data['heartRate']?.toDouble() ?? 0,
            spO2: data['spO2']?.toDouble() ?? 0,
            temperature: data['temperature']?.toDouble() ?? 0,
            stressLevel: data['stressLevel']?.toDouble() ?? 0,
            isAbnormal: false,
            deviceId: _connectedDevice?.id,
          );

          // Notify listeners about new health data
          print('Received health data: ${healthData.toJson()}');
        }
      } catch (e) {
        print('Error polling health data: $e');
      }
    });
  }

  Future<void> fetchSavedDevice(String userId) async {
    try {
      _connectedDevice = await _deviceService.getDeviceByUserId(userId);
      if (_connectedDevice != null && _connectedDevice!.isConnected) {
        _startHealthDataPolling(userId);
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching saved device: $e');
    }
  }
}


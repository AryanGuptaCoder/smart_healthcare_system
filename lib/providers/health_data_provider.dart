import 'package:flutter/foundation.dart';
import 'package:smart_healthcare_system/models/health_data_model.dart';
import 'package:smart_healthcare_system/services/health_data_service.dart';

class HealthDataProvider with ChangeNotifier {
  final HealthDataService _healthDataService = HealthDataService();

  HealthData? _latestData;
  List<HealthData> _recentData = [];
  bool _isLoading = false;

  HealthData? get latestData => _latestData;
  List<HealthData> get recentData => _recentData;
  bool get isLoading => _isLoading;

  Future<void> fetchLatestData(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _latestData = await _healthDataService.getLatestHealthData(userId);
    } catch (e) {
      print('Error fetching latest health data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<HealthData>> getRecentHealthData(String userId, {int limit = 24}) async {
    try {
      _isLoading = true;
      notifyListeners();

      _recentData = await _healthDataService.getRecentHealthData(userId, limit: limit);
      return _recentData;
    } catch (e) {
      print('Error fetching recent health data: $e');
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addHealthData(HealthData data) async {
    try {
      await _healthDataService.addHealthData(data);

      // Update local data
      if (_latestData == null || data.timestamp.isAfter(_latestData!.timestamp)) {
        _latestData = data;
      }

      _recentData = [data, ..._recentData];
      if (_recentData.length > 24) {
        _recentData = _recentData.sublist(0, 24);
      }

      notifyListeners();
    } catch (e) {
      print('Error adding health data: $e');
      rethrow;
    }
  }

  Future<List<HealthData>> getHistoricalData(
      String userId,
      DateTime startDate,
      DateTime endDate
      ) async {
    try {
      return await _healthDataService.getHistoricalHealthData(
          userId,
          startDate,
          endDate
      );
    } catch (e) {
      print('Error fetching historical health data: $e');
      rethrow;
    }
  }

  Map<String, dynamic> getAverageValues(List<HealthData> data) {
    if (data.isEmpty) {
      return {
        'heartRate': 0.0,
        'spO2': 0.0,
        'temperature': 0.0,
        'stressLevel': 0.0,
      };
    }

    double totalHeartRate = 0;
    double totalSpO2 = 0;
    double totalTemperature = 0;
    double totalStressLevel = 0;

    for (var item in data) {
      totalHeartRate += item.heartRate;
      totalSpO2 += item.spO2;
      totalTemperature += item.temperature;
      totalStressLevel += item.stressLevel;
    }

    return {
      'heartRate': totalHeartRate / data.length,
      'spO2': totalSpO2 / data.length,
      'temperature': totalTemperature / data.length,
      'stressLevel': totalStressLevel / data.length,
    };
  }

  bool checkForAbnormalities(HealthData data) {
    return data.isAbnormal ||
        !data.isHeartRateNormal ||
        !data.isSpO2Normal ||
        !data.isTemperatureNormal ||
        !data.isStressLevelNormal;
  }

  String getRecommendation(HealthData data) {
    if (!data.isHeartRateNormal) {
      if (data.heartRate < 60) {
        return 'Your heart rate is lower than normal. Consider gentle movement or consult a doctor if you feel dizzy.';
      } else {
        return 'Your heart rate is elevated. Try deep breathing exercises to help it return to normal.';
      }
    } else if (!data.isSpO2Normal) {
      return 'Your blood oxygen level is lower than optimal. Try to get fresh air and practice deep breathing.';
    } else if (!data.isTemperatureNormal) {
      if (data.temperature > 37.2) {
        return 'Your body temperature is elevated. Rest and stay hydrated.';
      } else {
        return 'Your body temperature is lower than normal. Keep warm and monitor for changes.';
      }
    } else if (!data.isStressLevelNormal) {
      return 'Your stress levels are elevated. Consider taking a break for meditation or deep breathing.';
    }

    return 'All your vital signs are within normal ranges. Keep up the good work!';
  }
}

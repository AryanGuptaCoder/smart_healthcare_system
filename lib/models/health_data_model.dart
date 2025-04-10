import 'package:cloud_firestore/cloud_firestore.dart';

class HealthData {
  final String id;
  final String userId;
  final DateTime timestamp;
  final double heartRate;
  final double spO2;
  final double temperature;
  final List<double>? ecgData;
  final double stressLevel;
  final bool isAbnormal;
  final String? deviceId;

  HealthData({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.heartRate,
    required this.spO2,
    required this.temperature,
    this.ecgData,
    required this.stressLevel,
    required this.isAbnormal,
    this.deviceId,
  });

  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(
      id: json['id'] as String,
      userId: json['userId'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      heartRate: (json['heartRate'] as num).toDouble(),
      spO2: (json['spO2'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
      ecgData: json['ecgData'] != null
          ? List<double>.from(json['ecgData'].map((x) => (x as num).toDouble()))
          : null,
      stressLevel: (json['stressLevel'] as num).toDouble(),
      isAbnormal: json['isAbnormal'] as bool,
      deviceId: json['deviceId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': timestamp,
      'heartRate': heartRate,
      'spO2': spO2,
      'temperature': temperature,
      'ecgData': ecgData,
      'stressLevel': stressLevel,
      'isAbnormal': isAbnormal,
      'deviceId': deviceId,
    };
  }

  bool get isHeartRateNormal => heartRate >= 60 && heartRate <= 100;
  bool get isSpO2Normal => spO2 >= 95;
  bool get isTemperatureNormal => temperature >= 36.1 && temperature <= 37.2;
  bool get isStressLevelNormal => stressLevel <= 50;
}


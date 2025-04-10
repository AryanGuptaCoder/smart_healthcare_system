import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceModel {
  final String id;
  final String name;
  final String ipAddress;
  final bool isConnected;
  final DateTime lastConnected;
  final String? firmwareVersion;
  final int batteryLevel;
  final String? ssid;
  final int? signalStrength;

  DeviceModel({
    required this.id,
    required this.name,
    required this.ipAddress,
    required this.isConnected,
    required this.lastConnected,
    this.firmwareVersion,
    required this.batteryLevel,
    this.ssid,
    this.signalStrength,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      ipAddress: json['ipAddress'] as String,
      isConnected: json['isConnected'] as bool,
      lastConnected: (json['lastConnected'] as Timestamp).toDate(),
      firmwareVersion: json['firmwareVersion'] as String?,
      batteryLevel: json['batteryLevel'] as int,
      ssid: json['ssid'] as String?,
      signalStrength: json['signalStrength'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ipAddress': ipAddress,
      'isConnected': isConnected,
      'lastConnected': Timestamp.fromDate(lastConnected),
      'firmwareVersion': firmwareVersion,
      'batteryLevel': batteryLevel,
      'ssid': ssid,
      'signalStrength': signalStrength,
    };
  }

  DeviceModel copyWith({
    String? id,
    String? name,
    String? ipAddress,
    bool? isConnected,
    DateTime? lastConnected,
    String? firmwareVersion,
    int? batteryLevel,
    String? ssid,
    int? signalStrength,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      isConnected: isConnected ?? this.isConnected,
      lastConnected: lastConnected ?? this.lastConnected,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      ssid: ssid ?? this.ssid,
      signalStrength: signalStrength ?? this.signalStrength,
    );
  }
}


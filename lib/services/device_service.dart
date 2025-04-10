import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_healthcare_system/models/device_model.dart';

class DeviceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<void> saveDevice(DeviceModel device, String userId) async {
    try {
      // Save device to devices collection
      await _firestore.collection('devices').doc(device.id).set(device.toJson());
      
      // Update user's device reference
      await _firestore.collection('users').doc(userId).update({
        'deviceId': device.id,
      });
    } catch (e) {
      print('Error saving device: $e');
      rethrow;
    }
  }
  
  Future<void> updateDevice(DeviceModel device) async {
    try {
      await _firestore.collection('devices').doc(device.id).update(device.toJson());
    } catch (e) {
      print('Error updating device: $e');
      rethrow;
    }
  }
  
  Future<DeviceModel?> getDeviceById(String deviceId) async {
    try {
      final doc = await _firestore.collection('devices').doc(deviceId).get();
      
      if (!doc.exists) {
        return null;
      }
      
      return DeviceModel.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      print('Error getting device: $e');
      rethrow;
    }
  }
  
  Future<DeviceModel?> getDeviceByUserId(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists || userDoc.data()!['deviceId'] == null) {
        return null;
      }
      
      final deviceId = userDoc.data()!['deviceId'];
      return await getDeviceById(deviceId);
    } catch (e) {
      print('Error getting device by user ID: $e');
      rethrow;
    }
  }
  
  Future<void> removeDevice(String deviceId, String userId) async {
    try {
      // Remove device from devices collection
      await _firestore.collection('devices').doc(deviceId).delete();
      
      // Remove device reference from user
      await _firestore.collection('users').doc(userId).update({
        'deviceId': null,
      });
    } catch (e) {
      print('Error removing device: $e');
      rethrow;
    }
  }
}


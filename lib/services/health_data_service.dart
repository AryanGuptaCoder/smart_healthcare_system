import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_healthcare_system/models/health_data_model.dart';

class HealthDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<HealthData?> getLatestHealthData(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('health_data')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) {
        return null;
      }
      
      return HealthData.fromJson({
        'id': snapshot.docs.first.id,
        ...snapshot.docs.first.data(),
      });
    } catch (e) {
      print('Error getting latest health data: $e');
      rethrow;
    }
  }
  
  Future<List<HealthData>> getRecentHealthData(String userId, {int limit = 24}) async {
    try {
      final snapshot = await _firestore
          .collection('health_data')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) => HealthData.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e) {
      print('Error getting recent health data: $e');
      rethrow;
    }
  }
  
  Future<void> addHealthData(HealthData data) async {
    try {
      await _firestore.collection('health_data').doc(data.id).set(data.toJson());
    } catch (e) {
      print('Error adding health data: $e');
      rethrow;
    }
  }
  
  Future<List<HealthData>> getHistoricalHealthData(
    String userId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    try {
      final snapshot = await _firestore
          .collection('health_data')
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .where('timestamp', isLessThanOrEqualTo: endDate)
          .orderBy('timestamp', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => HealthData.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e) {
      print('Error getting historical health data: $e');
      rethrow;
    }
  }
}


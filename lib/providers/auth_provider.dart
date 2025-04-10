import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_healthcare_system/models/user_model.dart';
import 'package:smart_healthcare_system/services/auth_service.dart';
import 'package:smart_healthcare_system/services/user_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  
  UserModel? _user;
  bool _isLoading = true;
  
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  
  AuthProvider() {
    _init();
  }
  
  Future<void> _init() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        _user = await _userService.getUserById(currentUser.uid);
      }
    } catch (e) {
      print('Error initializing auth provider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final user = await _authService.signInWithEmailAndPassword(email, password);
      _user = await _userService.getUserById(user.uid);
      
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> signUp(String name, String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final user = await _authService.signUpWithEmailAndPassword(email, password);
      
      final newUser = UserModel(
        id: user.uid,
        email: email,
        name: name,
        createdAt: DateTime.now(),
      );
      
      await _userService.createUser(newUser);
      _user = newUser;
      
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }
  
  Future<void> updateProfile({String? name, String? photoUrl}) async {
    try {
      if (_user == null) return;
      
      final updatedUser = _user!.copyWith(
        name: name,
        photoUrl: photoUrl,
      );
      
      await _userService.updateUser(updatedUser);
      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }
  
  Future<void> updateHealthProfile(Map<String, dynamic> healthProfile) async {
    try {
      if (_user == null) return;
      
      final updatedUser = _user!.copyWith(
        healthProfile: healthProfile,
      );
      
      await _userService.updateUser(updatedUser);
      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      print('Error updating health profile: $e');
      rethrow;
    }
  }
  
  Future<void> linkDevice(String deviceId) async {
    try {
      if (_user == null) return;
      
      final updatedUser = _user!.copyWith(
        deviceId: deviceId,
      );
      
      await _userService.updateUser(updatedUser);
      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      print('Error linking device: $e');
      rethrow;
    }
  }
}


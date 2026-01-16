import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _authRepository.currentUser;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authRepository.signIn(email, password);
      return true;
    } on FirebaseAuthException catch (e) {
      String msg = e.message ?? 'Đăng nhập thất bại';
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        msg = 'Email hoặc mật khẩu không chính xác.';
      } else if (e.code == 'invalid-email') {
        msg = 'Định dạng email không hợp lệ.';
      }
      _setError(msg);
      return false;
    } catch (e) {
      _setError('Đã xảy ra lỗi: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
    required String role,
    String? phoneNumber,
    String? birthDate,
    String? gender,
    String? address,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authRepository.signUp(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
        phoneNumber: phoneNumber,
        birthDate: birthDate,
        gender: gender,
        address: address,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Đăng ký thất bại');
      return false;
    } catch (e) {
      _setError('Đã xảy ra lỗi: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authRepository.signOut();
    notifyListeners();
  }

  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authRepository.sendPasswordResetEmail(email);
      return true;
    } on FirebaseAuthException catch (e) {
      String msg = e.message ?? 'Lỗi không xác định';
      if (e.code == 'user-not-found') msg = 'Email này chưa đăng ký tài khoản.';
      if (e.code == 'invalid-email') msg = 'Email không hợp lệ.';
      _setError(msg);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> checkPhoneNumberExists(String phoneNumber) async {
    try {
      return await _authRepository.isPhoneNumberTaken(phoneNumber);
    } catch (e) {
      // In case of error (e.g. permission), assume not taken or handle gracefully
      return false;
    }
  }
}

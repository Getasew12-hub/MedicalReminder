import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../shared/services/auth_service.dart';
import '../../../shared/services/database_service.dart';
import '../models/user_profile.dart';

class UserProfileProvider extends ChangeNotifier {
  UserProfileProvider({
    required DatabaseService databaseService,
    required AuthService authService,
    ImagePicker? imagePicker,
  })  : _databaseService = databaseService,
        _authService = authService,
        _imagePicker = imagePicker ?? ImagePicker();

  final DatabaseService _databaseService;
  final AuthService _authService;
  final ImagePicker _imagePicker;

  StreamSubscription<UserProfile?>? _subscription;
  UserProfile? profile;
  bool isLoading = false;
  String? errorMessage;
  String? _userId;

  void bindUser({
    required String? userId,
    required String fallbackEmail,
    required String fallbackName,
  }) {
    if (_userId == userId) return;
    _userId = userId;
    _subscription?.cancel();
    profile = null;

    if (userId == null) {
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    _subscription = _databaseService
        .watchUserProfile(
      userId,
      fallbackEmail: fallbackEmail,
      fallbackName: fallbackName,
    )
        .listen(
      (nextProfile) {
        profile = nextProfile;
        isLoading = false;
        errorMessage = null;
        notifyListeners();
      },
      onError: (_) {
        isLoading = false;
        errorMessage = 'Could not load profile.';
        notifyListeners();
      },
    );
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
    required String emergencyContact,
    String? avatarBase64,
    bool clearAvatar = false,
  }) async {
    final current = profile;
    if (current == null) return false;

    return _runAction(() async {
      final next = current.copyWith(
        name: name.trim(),
        phone: phone.trim(),
        emergencyContact: emergencyContact.trim(),
        avatarBase64: avatarBase64,
        clearAvatar: clearAvatar,
      );

      await _databaseService.updateUserProfile(next);
      await _authService.updateDisplayName(next.name);
    });
  }

  Future<String?> pickAvatarBase64() async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 55,
        maxWidth: 600,
      );
      if (file == null) return null;

      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (_) {
      errorMessage = 'Could not pick image.';
      notifyListeners();
      return null;
    }
  }

  Uint8List? get avatarBytes {
    final encoded = profile?.avatarBase64;
    if (encoded == null || encoded.isEmpty) return null;
    return avatarBytesFromBase64(encoded);
  }

  Uint8List? avatarBytesFromBase64(String encoded) {
    try {
      return base64Decode(encoded);
    } catch (_) {
      return null;
    }
  }

  String get displayName {
    final name = profile?.name.trim() ?? '';
    return name.isEmpty ? 'Mona' : name;
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  Future<bool> _runAction(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await action();
      return true;
    } catch (_) {
      errorMessage = 'Unable to save profile changes.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

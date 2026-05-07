import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../shared/services/database_service.dart';
import '../../../shared/services/notification_service.dart';
import '../models/medicine.dart';

class MedicineProvider extends ChangeNotifier {
  MedicineProvider({
    required DatabaseService databaseService,
    required NotificationService notificationService,
  })  : _databaseService = databaseService,
        _notificationService = notificationService;

  final DatabaseService _databaseService;
  final NotificationService _notificationService;

  StreamSubscription<List<Medicine>>? _subscription;
  String? _userId;

  List<Medicine> medicines = [];
  bool isLoading = false;
  String? errorMessage;

  void bindUser(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _subscription?.cancel();
    medicines = [];

    if (userId == null) {
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    _subscription = _databaseService.watchMedicines(userId).listen(
      (items) {
        medicines = items;
        isLoading = false;
        errorMessage = null;
        notifyListeners();
        unawaited(_rescheduleReminders(items));
      },
      onError: (_) {
        isLoading = false;
        errorMessage = 'Could not load medicines.';
        notifyListeners();
      },
    );
  }

  Medicine? findById(String id) {
    try {
      return medicines.firstWhere((medicine) => medicine.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> addMedicine(Medicine medicine) async {
    final userId = _requireUserId();
    return _runAction(() async {
      final id = await _databaseService.addMedicine(userId, medicine);
      await _notificationService.scheduleMedicine(medicine.copyWith(id: id));
    });
  }

  Future<bool> updateMedicine(Medicine medicine) async {
    final userId = _requireUserId();
    return _runAction(() async {
      await _databaseService.updateMedicine(userId, medicine);
      await _notificationService.scheduleMedicine(medicine);
    });
  }

  Future<bool> deleteMedicine(String medicineId) async {
    final userId = _requireUserId();
    return _runAction(() async {
      await _databaseService.deleteMedicine(userId, medicineId);
      await _notificationService.cancelMedicine(medicineId);
    });
  }

  Future<void> markDone(String medicineId) async {
    final userId = _requireUserId();
    await _databaseService.updateMedicineStatus(
      userId: userId,
      medicineId: medicineId,
      isDone: true,
      isSkipped: false,
    );
  }

  Future<void> markSkipped(String medicineId) async {
    final userId = _requireUserId();
    await _databaseService.updateMedicineStatus(
      userId: userId,
      medicineId: medicineId,
      isDone: false,
      isSkipped: true,
    );
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  String _requireUserId() {
    final userId = _userId;
    if (userId == null) {
      throw StateError('User must be authenticated.');
    }
    return userId;
  }

  Future<bool> _runAction(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await action();
      return true;
    } catch (_) {
      errorMessage = 'Unable to save changes. Please try again.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _rescheduleReminders(List<Medicine> items) async {
    try {
      for (final medicine in items) {
        await _notificationService.scheduleMedicine(medicine);
      }
    } catch (_) {
      // Firestore is still the source of truth if local notification setup fails.
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

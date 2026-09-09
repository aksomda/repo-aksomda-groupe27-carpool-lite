import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../auth/data/models/user_model.dart';
import '../../data/user_management_remote_datasource.dart';

class UserManagementProvider extends ChangeNotifier {
  final UserManagementRemoteDataSource _dataSource;
  StreamSubscription<List<UserModel>>? _subscription;

  List<UserModel> users = [];
  bool isLoading = true;
  String? errorMessage;

  UserManagementProvider(this._dataSource) {
    _subscription = _dataSource.getUsers().listen(
      (value) {
        users = value;
        isLoading = false;
        errorMessage = null;
        notifyListeners();
      },
      onError: (Object error) {
        isLoading = false;
        errorMessage = 'Impossible de charger les utilisateurs : $error';
        notifyListeners();
      },
    );
  }

  Future<void> updateUser(UserModel user, {bool? isActive, String? role}) async {
    try {
      await _dataSource.updateUser(
        uid: user.uid,
        isActive: isActive ?? user.isActive,
        role: role ?? user.role,
      );
    } catch (error) {
      errorMessage = 'Modification impossible : $error';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

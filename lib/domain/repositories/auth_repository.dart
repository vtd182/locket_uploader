import 'package:locket_uploader/models/user_profile.dart';
import 'package:rxdart/rxdart.dart';

import '../../utils/enums/authentication_status.dart';
import '../service/locket_service.dart';

abstract class AuthRepository {
  Stream<AuthenticationStatus> get status;
  Stream<UserProfile?> get user;

  Future<void> loginByEmailAndPassword({
    required String email,
    required String password,
  });

  void logoutV1();
}

class AuthRepositoryImpl implements AuthRepository {
  final LocketService _locketService;
  final BehaviorSubject<AuthenticationStatus> _statusController = BehaviorSubject.seeded(AuthenticationStatus.unknown);
  final BehaviorSubject<UserProfile?> _userController = BehaviorSubject<UserProfile?>.seeded(null);

  AuthRepositoryImpl(this._locketService);

  @override
  Stream<AuthenticationStatus> get status => _statusController.stream;

  @override
  Stream<UserProfile?> get user => _userController.stream;

  @override
  Future<void> loginByEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userProfile = await _locketService.login(email, password);
      _userController.add(userProfile);
      _statusController.add(AuthenticationStatus.authenticated);
    } catch (error) {
      print(error);
      _statusController.add(AuthenticationStatus.unauthenticated);
      _userController.add(null);
      throw Exception('Login failed: $error');
    }
  }

  @override
  void logoutV1() {
    _statusController.add(AuthenticationStatus.unauthenticated);
    _userController.add(null);
  }

  // Clean up streams when no longer needed
  void dispose() {
    _statusController.close();
    _userController.close();
  }
}

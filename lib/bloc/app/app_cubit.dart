import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:locket_uploader/models/user_profile.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../utils/enums/authentication_status.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  final AuthRepository _authRepository;

  AppCubit(this._authRepository) : super(const AppState()) {
    _authRepository.status.listen((status) {
      _authRepository.user.listen((user) {
        if (user != null) {
          emit(state.copyWith(status: status, userProfile: user));
        }
      });
    });
  }

  Future<void> login(String email, String password) async {
    try {
      emit(const AuthenticationLoading());
      await _authRepository.loginByEmailAndPassword(email: email, password: password);
    } catch (e) {
      emit(AuthenticationFailure(e.toString()));
    }
  }

  void logout() {
    _authRepository.logoutV1();
    emit(state.copyWith(userProfile: null, status: AuthenticationStatus.unauthenticated));
    emit(const LogoutSuccess());
  }
}

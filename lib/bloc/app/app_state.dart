part of 'app_cubit.dart';

class AppState extends Equatable {
  final UserProfile? userProfile;
  final AuthenticationStatus status;

  const AppState({
    this.userProfile,
    this.status = AuthenticationStatus.unauthenticated,
  });

  AppState copyWith({
    UserProfile? userProfile,
    AuthenticationStatus? status,
  }) {
    return AppState(
      userProfile: userProfile,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        userProfile,
        status,
      ];
}

class AuthenticationFailure extends AppState {
  final String message;

  const AuthenticationFailure(this.message);
}

class AuthenticationSuccess extends AppState {
  const AuthenticationSuccess();
}

class AuthenticationLoading extends AppState {
  const AuthenticationLoading();
}

class LogoutSuccess extends AppState {
  const LogoutSuccess();
}

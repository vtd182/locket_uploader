import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locket_uploader/constants/constants.dart';
import 'package:locket_uploader/domain/repositories/upload_repository.dart';
import 'package:locket_uploader/routes.dart';
import 'package:locket_uploader/ui/login_screen.dart';
import 'package:locket_uploader/ui/main_screen.dart';
import 'package:locket_uploader/utils/enums/authentication_status.dart';

import 'bloc/app/app_cubit.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/service/locket_service.dart';

void main() async {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final LocketService _locketService;
  late final AuthRepository _authRepository;
  late final UploadRepository _uploadRepository;

  @override
  void initState() {
    super.initState();
    _locketService = LocketService();
    _authRepository = AuthRepositoryImpl(_locketService);
    _uploadRepository = UploadRepositoryImpl(_locketService);
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<LocketService>(create: (_) => _locketService),
        RepositoryProvider<AuthRepository>(create: (_) => _authRepository),
        RepositoryProvider<UploadRepository>(create: (_) => _uploadRepository),
      ],
      child: BlocProvider(
        create: (BuildContext context) {
          return AppCubit(
            _authRepository,
          );
        },
        child: const MyApp(),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Locket Uploader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(Constants.yellowColor)),
        useMaterial3: true,
        fontFamily: 'Netto',
      ),
      routes: routes,
      navigatorKey: _navigatorKey,
      builder: (context, child) {
        return BlocListener<AppCubit, AppState>(
          listener: (context, state) async {
            switch (state.status) {
              case AuthenticationStatus.authenticated:
                _navigatorKey.currentState?.pushNamedAndRemoveUntil(MainScreen.route, (route) => false);
                break;
              case AuthenticationStatus.unauthenticated:
                if (state is LogoutSuccess) {
                  _navigatorKey.currentState?.pushNamedAndRemoveUntil(LoginScreen.route, (route) => false);
                }
                break;
              case AuthenticationStatus.unknown:
                break;
            }
          },
          child: child,
        );
      },
      onGenerateRoute: (_) => MaterialPageRoute(builder: (context) => const LoginScreen()),
      debugShowCheckedModeBanner: false,
    );
  }
}

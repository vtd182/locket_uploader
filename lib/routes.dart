import 'package:flutter/cupertino.dart';
import 'package:locket_uploader/ui/login_screen.dart';
import 'package:locket_uploader/ui/main_screen.dart';

final Map<String, Widget Function(BuildContext)> routes = {
  LoginScreen.route: (context) => const LoginScreen(),
  MainScreen.route: (context) => const MainScreen(),
};

import 'package:flutter/material.dart';
import 'package:locket_uploader/service/my_locket_service.dart';
import 'package:locket_uploader/ui/main_screen.dart';

import '../constants/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final usernameFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();
  late var _autoValidateMode = AutovalidateMode.disabled;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTextTitle(),
          _buildFormLogin(),
          const SizedBox(height: 20),
          _buildFormPassword(),
          _buildLoginButton(),
          _buildInformationApp(),
        ],
      ),
    );
  }

  Widget _buildTextTitle() {
    return const Text(
      'Login',
      style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900),
    );
  }

  Widget _buildFormPassword() {
    return Form(
      key: passwordFormKey,
      autovalidateMode: _autoValidateMode,
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: const Text(
              "Password",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: TextFormField(
              controller: _passwordTextController,
              obscureText: true,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return "Please enter your password";
                }
                if (value.length < 6) {
                  return "Password must be at least 6 characters";
                }
                return null;
              },
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(Constants.yellowColor), width: 2.0),
                ),
                hintText: "Enter your password",
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                fillColor: Colors.grey.withOpacity(0.2),
                filled: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      margin: const EdgeInsets.only(top: 50),
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _login();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(Constants.yellowColor),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
        ),
        child: const Text(
          "Login",
          style: TextStyle(color: Color(0xff1f1d1a), fontSize: 22, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget _buildFormLogin() {
    return Form(
      key: usernameFormKey,
      autovalidateMode: _autoValidateMode,
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: const Text(
              "Email",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: TextFormField(
              controller: _emailTextController,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return "Please enter your email";
                }
                final emailValid = RegExp(
                  Constants.emailRegex,
                ).hasMatch(value);
                if (!emailValid) {
                  return "Please enter a valid email";
                }
                return null;
              },
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(Constants.yellowColor), width: 2.0),
                ),
                hintText: "Enter your email",
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                fillColor: Colors.grey.withOpacity(0.2),
                filled: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationApp() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: const Text(
        "© 2024 Vu Tien Dat",
        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
      ),
    );
  }

  void _login() async {
    if (_autoValidateMode == AutovalidateMode.disabled) {
      setState(() {
        _autoValidateMode = AutovalidateMode.always;
      });
    }
    final isEmailValid = usernameFormKey.currentState?.validate() ?? false;
    final isPasswordValid = passwordFormKey.currentState?.validate() ?? false;
    final isValid = isEmailValid && isPasswordValid;
    if (!isValid) {
      return;
    } else {
      final email = _emailTextController.text;
      final password = _passwordTextController.text;
      try {
        final token = await MyLocketServices.loginV2(email, password);
        if (token != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const MainScreen(),
            ),
          );
        } else {
          print(token);
        }
      } catch (error) {
        print(error.toString());
        return null;
      }
    }
  }
}

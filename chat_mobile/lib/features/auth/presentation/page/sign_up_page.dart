import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../presentation/bloc/auth_bloc.dart';
import '../../../../core/navigation/blur_page_route.dart';
import 'login_page.dart';
import '../widget/signup/email_input.dart';
import '../widget/login/login_button.dart';
import '../widget/login/password_input.dart';
import '../widget/signup/signup_title.dart';
import '../widget/login/username_input.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  String? _usernameError;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _onRegister() {
    final u = _username.text.trim();
    final e = _email.text.trim();
    final p = _password.text;

    final emailRegex = RegExp(
      r"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}",
      caseSensitive: false,
    );
    setState(() {
      _usernameError = u.isEmpty ? 'Username is required' : null;
      _emailError = e.isEmpty
          ? 'Email is required'
          : (emailRegex.hasMatch(e) ? null : 'Enter a valid email');
      _passwordError = p.length < 6
          ? 'Password must be at least 6 chars'
          : null;
    });
    if (_usernameError != null || _emailError != null || _passwordError != null)
      return;

    context.read<AuthBloc>().add(RegisterUser(u, e, p));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            Navigator.of(context).pop();
          }
          if (state is RegisterFailure) {
            final msg = state.failure.message.isNotEmpty
                ? state.failure.message
                : 'Registration failed';
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(msg),
                  behavior: SnackBarBehavior.floating,
                ),
              );
          }
        },
        builder: (context, state) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/images/bg3.jpeg', fit: BoxFit.cover),

              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      width: size.width * 0.88,
                      constraints: const BoxConstraints(maxWidth: 420),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 22,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SignUpTitle(),
                          const SizedBox(height: 22),
                          UsernameInput(
                            controller: _username,
                            errorText: _usernameError,
                            onChanged: (_) {
                              if (_usernameError != null) {
                                setState(() => _usernameError = null);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          EmailInput(
                            controller: _email,
                            errorText: _emailError,
                            onChanged: (_) {
                              if (_emailError != null) {
                                setState(() => _emailError = null);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          PasswordInput(
                            controller: _password,
                            errorText: _passwordError,
                            onChanged: (_) {
                              if (_passwordError != null) {
                                setState(() => _passwordError = null);
                              }
                            },
                          ),
                          const SizedBox(height: 22),
                          LoginButton(onPressed: _onRegister, text: 'Register'),
                          const SizedBox(height: 8),
                          Center(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text(
                                  'Have an account? ',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                      BlurPageRoute(
                                        builder: (_) => const LoginPage(),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Login'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              if (state is RegisterLoading)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x66000000),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

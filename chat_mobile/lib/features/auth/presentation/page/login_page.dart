import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/blur_page_route.dart';
import '../../../../main.dart';
import '../bloc/auth_bloc.dart';
import '../widget/login/login_button.dart';
import '../widget/login/login_title.dart';
import '../widget/login/password_input.dart';
import '../widget/login/register_link.dart';
import '../widget/login/remember_forgot_row.dart';
import '../widget/login/username_input.dart';
import 'sign_up_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _remember = false;
  String? _usernameError;
  String? _passwordError;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _onLogin() {
    // simple client-side validation
    final u = _username.text.trim();
    final p = _password.text;
    setState(() {
      _usernameError = u.isEmpty ? 'Username is required' : null;
      _passwordError = p.isEmpty ? 'Password is required' : null;
    });
    if (_usernameError != null || _passwordError != null) return;

    context.read<AuthBloc>().add(LoginUser(u, p));
    debugPrint('Login with username=$u, remember=$_remember');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            debugPrint('✨✨Login successful');
            Navigator.of(
              context,
            ).push(BlurPageRoute(builder: (_) => const MyApp()));
          }
          if (state is loginFailure) {
            final msg = state.failure.message.isNotEmpty
                ? state.failure.message
                : 'Login failed';
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
              // Background image (ensure asset exists)
              Image.asset('assets/images/bg3.jpeg', fit: BoxFit.cover),

              // Frosted glass center box
              SafeArea(
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        width: size.width * 0.88,
                        constraints: BoxConstraints(
                          maxWidth: 420,
                          maxHeight: size.height * 0.8,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 22,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: SingleChildScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 4),
                              const Align(
                                alignment: Alignment.topCenter,
                                child: LoginTitle(),
                              ),
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

                              PasswordInput(
                                controller: _password,
                                errorText: _passwordError,
                                onChanged: (_) {
                                  if (_passwordError != null) {
                                    setState(() => _passwordError = null);
                                  }
                                },
                              ),
                              const SizedBox(height: 18),

                              RememberForgotRow(
                                remember: _remember,
                                onRememberChanged: (v) =>
                                    setState(() => _remember = v ?? false),
                                onForgot: () {
                                  // TODO: navigate to forgot password
                                },
                              ),
                              const SizedBox(height: 18),

                              LoginButton(onPressed: _onLogin, text: 'Login'),
                              const SizedBox(height: 8),

                              RegisterLink(
                                onTap: () {
                                  Navigator.of(context).push(
                                    BlurPageRoute(
                                      builder: (_) => const SignUpPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              if (state is loginLoading)
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

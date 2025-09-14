import 'package:flutter/material.dart';

class RegisterLink extends StatelessWidget {
  const RegisterLink({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Text(
            'Register',
            style: TextStyle(
              color: Colors.white70,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    );
  }
}

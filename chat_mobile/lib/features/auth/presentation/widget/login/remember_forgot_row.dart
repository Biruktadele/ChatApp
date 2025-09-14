import 'package:flutter/material.dart';

class RememberForgotRow extends StatelessWidget {
  const RememberForgotRow({
    super.key,
    required this.remember,
    required this.onRememberChanged,
    required this.onForgot,
  });

  final bool remember;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onForgot;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: remember,
          onChanged: onRememberChanged,
          activeColor: Colors.white,
          checkColor: Colors.black,
          side: const BorderSide(color: Colors.white70),
        ),
        const Text('Remember me', style: TextStyle(color: Colors.white70)),
        const Spacer(),
        InkWell(
          onTap: onForgot,
          child: const Text(
            'Forgot Password?',
            style: TextStyle(
              color: Colors.white,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

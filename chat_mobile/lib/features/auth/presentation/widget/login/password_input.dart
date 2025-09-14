import 'package:flutter/material.dart';

import 'dashed_underline.dart';

class PasswordInput extends StatefulWidget {
  const PasswordInput({
    super.key,
    required this.controller,
    this.onChanged,
    this.errorText,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? errorText;

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Password', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 6),
        TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          obscureText: _obscure,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white70,
          decoration: InputDecoration(
            isDense: true,
            border: InputBorder.none,
            hintText: 'Enter password',
            hintStyle: const TextStyle(color: Colors.white54),
            suffixIcon: IconButton(
              icon: Icon(
                _obscure ? Icons.visibility : Icons.visibility_off,
                color: Colors.white70,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
        const SizedBox(height: 2),
        const DashedUnderline(),
        if (widget.errorText != null && widget.errorText!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

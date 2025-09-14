import 'package:flutter/material.dart';

import 'dashed_underline.dart';

class UsernameInput extends StatelessWidget {
  const UsernameInput({
    super.key,
    required this.controller,
    this.onChanged,
    this.errorText,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Username', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white70,
          decoration: const InputDecoration(
            isDense: true,
            border: InputBorder.none,
            hintText: 'Enter username',
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
        const SizedBox(height: 2),
        const DashedUnderline(),
        if (errorText != null && errorText!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

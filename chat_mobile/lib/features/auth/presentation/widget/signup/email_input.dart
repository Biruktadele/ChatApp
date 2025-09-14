import 'package:flutter/material.dart';

import '../login/dashed_underline.dart';

class EmailInput extends StatelessWidget {
  const EmailInput({
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
        const Text('Email', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white70,
          decoration: const InputDecoration(
            isDense: true,
            border: InputBorder.none,
            hintText: 'Enter email',
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

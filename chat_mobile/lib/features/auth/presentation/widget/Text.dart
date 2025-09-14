

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextWidget extends StatelessWidget {
  const TextWidget({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(text,
      style: GoogleFonts.poppins(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: const Color.fromRGBO(0, 0, 0, 1),
        // letterSpacing: 0.02 * 27,
        
        
        
      ),),  
    );
  }
}
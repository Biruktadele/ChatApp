import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InputFiled extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  const InputFiled({super.key , required this.label, required this.hint, required this.controller});

  @override
  Widget build(BuildContext context) {
    return 
           Container(
            width: 310,
            margin: const EdgeInsets.only(top: 20),
            child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '   $label',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: const Color.fromRGBO(111, 111, 111, 1),
            letterSpacing: 0.02 * 16,
            
          ),
        ),
        TextField(
          controller: controller,
          
          
          style: const TextStyle(
            color: Colors.grey,
          ),
          decoration: InputDecoration(
            filled: true,
          hintText: '   $hint ',
          hintStyle: const TextStyle(
            
            color: Color.fromRGBO(136, 136, 136, 1),
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
          ),
              enabledBorder: InputBorder.none,
             
            fillColor: const Color.fromRGBO(255, 255, 255, 1),
            border: OutlineInputBorder(
             
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        
      ],
    ),
       );
  }
}
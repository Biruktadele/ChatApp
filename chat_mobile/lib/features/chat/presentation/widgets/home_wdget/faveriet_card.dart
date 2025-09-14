import 'package:flutter/material.dart';

class FaverietCard extends StatefulWidget {
  const FaverietCard({super.key});

  @override
  State<FaverietCard> createState() => _FaverietCardState();
}

class _FaverietCardState extends State<FaverietCard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 144,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              image: const DecorationImage(
                image: AssetImage(
                  'assets/images/man1.jpeg',
                ), // Placeholder image
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Icon(Icons.favorite, color: Colors.red, size: 14),
          ),
          const Positioned(
            bottom: 30,
            left: 10,
            child: Text(
              'Biruk\ntadele',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

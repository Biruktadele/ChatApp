import 'package:flutter/material.dart';
import '../../../../../core/constant/color_const.dart';

class ProfileShow extends StatefulWidget {
  final String username;
  const ProfileShow({super.key, required this.username});

  @override
  State<ProfileShow> createState() => _ProfileShowState();
}

class _ProfileShowState extends State<ProfileShow> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 32, top: 50),
      color: bg,
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: plusButton,
            child: const ClipOval(
              child: Image(
                image: AssetImage('assets/images/man2.jpeg'),
                fit: BoxFit.cover,
                width: 50,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            widget.username,
            style: TextStyle(color: white,
             fontSize: 27 , 
           
             fontFamily: 'Roboto',
             letterSpacing: 1
             ),
          ),
        ],
      ),
    );
  }
}
import '../../../../../core/constant/color_const.dart';
import 'package:flutter/material.dart';

class SearchBarr extends StatefulWidget {
  const SearchBarr({super.key});

  @override
  State<SearchBarr> createState() => _SearchBarrState();
}

class _SearchBarrState extends State<SearchBarr> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 270,
      decoration: BoxDecoration(
        color: searchfill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 1),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '        Search...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.search, color: Colors.white, size: 30),
                onPressed: () {
                  // TODO: Implement search functionality
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

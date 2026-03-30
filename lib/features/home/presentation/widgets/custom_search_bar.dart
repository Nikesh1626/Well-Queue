import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFD8ECEB).withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const TextField(
        style: TextStyle(fontSize: 18),
        decoration: InputDecoration(
          hintText: 'Search clinics or services',
          hintStyle: TextStyle(color: Color(0xFF62757E)),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Color(0xFF4E666E)),
          suffixIcon: Icon(Icons.tune_rounded, color: Color(0xFF4E666E)),
        ),
      ),
    );
  }
}

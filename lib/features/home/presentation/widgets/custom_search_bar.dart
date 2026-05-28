import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 390;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 4 : 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDDF0EE), Color(0xFFF3F8F8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            spreadRadius: -8,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: isCompact ? 14 : 16),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Search clinics or services',
          hintStyle: TextStyle(color: const Color(0xFF62757E), fontWeight: FontWeight.w500, fontSize: isCompact ? 13 : 14),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.78),
          contentPadding: EdgeInsets.symmetric(horizontal: isCompact ? 14 : 18, vertical: isCompact ? 13 : 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            borderSide: const BorderSide(color: AppTheme.softMint, width: 2),
          ),
          prefixIcon: Icon(Icons.search_rounded, color: const Color(0xFF4E666E), size: isCompact ? 20 : 22),
          suffixIcon: Container(
            margin: EdgeInsets.only(right: isCompact ? 6 : 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceSoft,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(Icons.tune_rounded, color: const Color(0xFF4E666E), size: isCompact ? 18 : 20),
          ),
        ),
      ),
    );
  }
}

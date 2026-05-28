import 'package:flutter/material.dart';
import '../../../../core/models/clinic.dart';
import '../../../../core/theme/app_theme.dart';
import 'clinic_card.dart';

class NearbyClinicsList extends StatelessWidget {
  final List<Clinic> clinics;
  final bool isLoading;

  const NearbyClinicsList({
    super.key,
    required this.clinics,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 390;

    if (isLoading) {
      return const AnimatedSwitcher(
        duration: Duration(milliseconds: 260),
        child: Padding(
          key: ValueKey('loading'),
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (clinics.isEmpty) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        child: Padding(
          key: const ValueKey('empty'),
          padding: EdgeInsets.symmetric(vertical: isCompact ? 18 : 24),
          child: Container(
            padding: EdgeInsets.all(isCompact ? 16 : 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: const Color(0xFFDCEBEB)),
            ),
            child: Row(
              children: [
                Icon(Icons.map_outlined, color: AppTheme.textMuted, size: isCompact ? 20 : 24),
                SizedBox(width: isCompact ? 8 : 10),
                Expanded(
                  child: Text(
                    'No clinics match this filter. Try switching filters or zooming out on map.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: isCompact ? 13 : 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      child: ListView.builder(
        key: const ValueKey('content'),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: clinics.length,
        itemBuilder: (context, index) {
          final clinic = clinics[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 260 + (index * 40)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, (1 - value) * 14),
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.only(bottom: isCompact ? 12 : 16),
              child: ClinicCard(clinic: clinic),
            ),
          );
        },
      ),
    );
  }
}

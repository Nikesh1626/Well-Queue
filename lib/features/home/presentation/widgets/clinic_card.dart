import 'package:flutter/material.dart';
import '../../../../core/models/clinic.dart';
import '../../../../core/theme/app_theme.dart';
import '../clinic_detail_screen.dart';

class ClinicCard extends StatelessWidget {
  final Clinic clinic;

  const ClinicCard({super.key, required this.clinic});

  Color _waitColor(int minutes) {
    if (minutes <= 15) return AppTheme.success;
    if (minutes <= 30) return AppTheme.warning;
    return AppTheme.danger;
  }

  @override
  Widget build(BuildContext context) {
    final waitColor = _waitColor(clinic.waitTimeMinutes);
    final isCompact = MediaQuery.sizeOf(context).width < 390;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ClinicDetailScreen(clinic: clinic),
          ),
        );
      },
      child: Card(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
        child: Padding(
          padding: EdgeInsets.all(isCompact ? 14 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: isCompact ? 46 : 52,
                    height: isCompact ? 46 : 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD2E8EE), Color(0xFFE7F3F5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_hospital, color: Color(0xFF00695C)),
                  ),
                  SizedBox(width: isCompact ? 10 : 12),
                  Expanded(
                    child: Text(
                      clinic.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'OPEN',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF00695C),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isCompact ? 8 : 10),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Color(0xFF5A7078)),
                  const SizedBox(width: 3),
                  Text(
                    '${(clinic.distance ?? 0).toStringAsFixed(1)} km',
                    style: const TextStyle(color: Color(0xFF5A7078)),
                  ),
                  const SizedBox(width: 12),
                  const Text('•', style: TextStyle(color: Color(0xFF5A7078))),
                  const SizedBox(width: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: waitColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${clinic.waitTimeMinutes} min wait',
                      style: TextStyle(color: waitColor, fontWeight: FontWeight.w700, fontSize: isCompact ? 12 : 13),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        clinic.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                clinic.address,
                style: TextStyle(
                  color: const Color(0xFF60757D),
                  fontSize: isCompact ? 12 : 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: clinic.services.take(3).map((service) {
                  return Chip(
                    label: Text(service),
                    labelStyle: const TextStyle(fontSize: 12),
                    backgroundColor: const Color(0xFFEFF3F4),
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ClinicDetailScreen(clinic: clinic),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('View details and join queue'),
                  style: FilledButton.styleFrom(
                    foregroundColor: AppTheme.primaryDark,
                    backgroundColor: AppTheme.surfaceSoft,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

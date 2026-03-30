import 'package:flutter/material.dart';
import '../../../../core/models/clinic.dart';
import '../clinic_detail_screen.dart';

class ClinicCard extends StatelessWidget {
  final Clinic clinic;

  const ClinicCard({super.key, required this.clinic});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD2E8EE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_hospital, color: Color(0xFF00695C)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      clinic.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F6EF),
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
              const SizedBox(height: 10),
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
                  Text(
                    '${clinic.waitTimeMinutes} min wait',
                    style: TextStyle(
                      color: clinic.waitTimeMinutes > 30
                          ? const Color(0xFFBC7B00)
                          : const Color(0xFF00695C),
                      fontWeight: FontWeight.w700,
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
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: clinic.services.map((service) {
                  return Chip(
                    label: Text(service),
                    labelStyle: const TextStyle(fontSize: 12),
                    backgroundColor: const Color(0xFFEFF3F4),
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

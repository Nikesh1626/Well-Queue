import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/clinic.dart';
import '../../../core/services/queue_service.dart';
import '../../../core/services/geofencing_service.dart';
import '../../../core/services/webhook_service.dart';
import '../../../core/services/auth_service.dart';
import '../../myqueue/presentation/check_in_screen.dart';

class ClinicDetailScreen extends StatefulWidget {
  final Clinic clinic;

  const ClinicDetailScreen({
    super.key,
    required this.clinic,
  });

  @override
  State<ClinicDetailScreen> createState() => _ClinicDetailScreenState();
}

class _ClinicDetailScreenState extends State<ClinicDetailScreen> {
  bool _enableGeofence = false;

  Future<void> _joinQueue() async {
    final authService = context.read<AuthService>();
    final queueService = context.read<QueueService>();

    if (authService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first')),
      );
      return;
    }

    final success = await queueService.joinQueue(
      clinicId: widget.clinic.id,
      clinicName: widget.clinic.name,
      userId: authService.currentUser!.id,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Joined queue successfully')),
        );

        // If geofence is enabled, start monitoring
        if (_enableGeofence) {
          context.read<GeofencingService>().startMonitoring(
            targetLatitude: widget.clinic.latitude,
            targetLongitude: widget.clinic.longitude,
            geofenceName: widget.clinic.name,
          );
        }

        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CheckInScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to join queue')),
        );
      }
    }
  }

  Future<void> _triggerAICall() async {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first')),
      );
      return;
    }

    try {
      await WebhookService.triggerAICall(
        userName: user.fullName,
        userPhone: user.phone ?? 'N/A',
        userEmail: user.email,
        clinicName: widget.clinic.name,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI call initiated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clinic Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 230,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF9FD1D3), Color(0xFF567C84)],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(29),
                      ),
                      child: const Icon(Icons.call, color: Color(0xFF00695C)),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(29),
                      ),
                      child: const Icon(Icons.near_me, color: Color(0xFF00695C)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.clinic.name,
                    style: const TextStyle(fontSize: 46, fontWeight: FontWeight.w700, height: 1.05),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7EAF6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Open until 8:00 PM', style: TextStyle(fontWeight: FontWeight.w600)),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text(widget.clinic.address, style: const TextStyle(fontSize: 22, color: Color(0xFF536872))),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.clinic.services
                  .map((s) => Chip(label: Text(s), backgroundColor: const Color(0xFFEFF3F4), side: BorderSide.none))
                  .toList(),
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF00695C), Color(0xFF0A8072)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CURRENT WAIT TIME', style: TextStyle(color: Colors.white70, letterSpacing: 1.4)),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.clinic.waitTimeMinutes} min',
                    style: const TextStyle(fontSize: 62, color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Card(
              color: Colors.white,
              child: CheckboxListTile(
                title: const Text('Join queue when I arrive (50m radius)'),
                subtitle: const Text('Enable geofencing'),
                value: _enableGeofence,
                onChanged: (value) {
                  setState(() {
                    _enableGeofence = value ?? false;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _joinQueue,
                child: const Text('Join Queue'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                onPressed: _triggerAICall,
                icon: const Icon(Icons.phone),
                label: const Text('Call AI Booking Agent'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B7A3C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

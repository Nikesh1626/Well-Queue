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
      appBar: AppBar(
        title: const Text('Clinic Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Clinic Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.clinic.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.clinic.rating.toStringAsFixed(1)} / 5.0',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Address Section
            Text(
              'Address',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(widget.clinic.address),
            const SizedBox(height: 16),

            // Wait Time Section
            Text(
              'Current Wait Time',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${widget.clinic.waitTimeMinutes} minutes',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 16),

            // Services Section
            if (widget.clinic.services.isNotEmpty) ...[
              Text(
                'Services',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: widget.clinic.services
                    .map(
                      (service) => Chip(label: Text(service)),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Contact Section
            if (widget.clinic.phone != null) ...[
              Text(
                'Contact',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.phone),
                title: Text(widget.clinic.phone!),
              ),
              const SizedBox(height: 16),
            ],

            // Geofence Option
            Card(
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

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _joinQueue,
                child: const Text('Join Queue'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _triggerAICall,
                icon: const Icon(Icons.phone),
                label: const Text('Call AI Booking Agent'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

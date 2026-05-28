import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/clinic.dart';
import '../../../core/services/queue_service.dart';
import '../../../core/services/geofencing_service.dart';
import '../../../core/services/webhook_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_theme.dart';
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
  bool _isJoining = false;
  bool _isCalling = false;

  Future<void> _joinQueue() async {
    if (_isJoining) return;

    final authService = context.read<AuthService>();
    final queueService = context.read<QueueService>();

    if (authService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first')),
      );
      return;
    }

    setState(() => _isJoining = true);

    final success = await queueService.joinQueue(
      clinicId: widget.clinic.id,
      clinicName: widget.clinic.name,
      userId: authService.currentUser!.id,
    );

    if (mounted) {
      setState(() => _isJoining = false);
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
    if (_isCalling) return;

    final authService = context.read<AuthService>();
    final user = authService.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first')),
      );
      return;
    }

    try {
      setState(() => _isCalling = true);
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
    } finally {
      if (mounted) {
        setState(() => _isCalling = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 390;

    return Scaffold(
      appBar: AppBar(title: const Text('Clinic Details')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isCompact ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: isCompact ? 200 : 230,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF9FD1D3), Color(0xFF567C84)],
                ),
              ),
              padding: EdgeInsets.all(isCompact ? 14 : 20),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: [
                    _heroAction(
                      icon: Icons.call,
                      label: 'Call clinic',
                      onTap: _triggerAICall,
                      compact: isCompact,
                    ),
                    const SizedBox(width: 12),
                    _heroAction(
                      icon: Icons.near_me,
                      label: 'Directions',
                      compact: isCompact,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Directions action coming soon')),
                        );
                      },
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: isCompact ? 34 : 42, fontWeight: FontWeight.w700, height: 1.05),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 14, vertical: isCompact ? 8 : 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7EAF6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Open until 8:00 PM', style: TextStyle(fontWeight: FontWeight.w600, fontSize: isCompact ? 12 : 14)),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.clinic.address,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: isCompact ? 16 : 20, color: const Color(0xFF536872)),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _metaChip(Icons.place_outlined, '${(widget.clinic.distance ?? 0).toStringAsFixed(1)} km away'),
                const SizedBox(width: 8),
                _metaChip(Icons.star_rounded, widget.clinic.rating.toStringAsFixed(1)),
              ],
            ),
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
              padding: EdgeInsets.all(isCompact ? 16 : 20),
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
                    style: TextStyle(fontSize: isCompact ? 50 : 62, color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Card(
              color: Colors.white,
              child: Semantics(
                label: 'Enable geofence queue join',
                hint: 'When enabled, queue monitoring starts automatically near clinic',
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
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: isCompact ? 54 : 58,
              child: Semantics(
                button: true,
                label: 'Join queue at this clinic',
                child: ElevatedButton(
                  onPressed: _isJoining ? null : _joinQueue,
                  child: _isJoining
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text('Join Queue'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: isCompact ? 54 : 58,
              child: ElevatedButton.icon(
                onPressed: _isCalling ? null : _triggerAICall,
                icon: _isCalling
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                      )
                    : const Icon(Icons.phone),
                label: Text(_isCalling ? 'Calling...' : 'Call AI Booking Agent'),
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

  Widget _metaChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryDark),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryDark),
          ),
        ],
      ),
    );
  }

  Widget _heroAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool compact = false,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(29),
        onTap: onTap,
        child: Container(
          width: compact ? 50 : 58,
          height: compact ? 50 : 58,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(compact ? 25 : 29),
          ),
          child: Icon(icon, color: const Color(0xFF00695C), size: compact ? 20 : 24),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/queue_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_theme.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  StreamSubscription? _ticker;

  Color _statusColor(String status) {
    switch (status) {
      case 'called':
        return AppTheme.success;
      case 'confirmed':
        return AppTheme.primary;
      case 'waiting':
        return AppTheme.warning;
      case 'cancelled':
        return AppTheme.danger;
      default:
        return AppTheme.textMuted;
    }
  }

  String _statusHint(String status) {
    switch (status) {
      case 'waiting':
        return 'Please stay nearby. We will update your turn live.';
      case 'confirmed':
        return 'Your check-in is confirmed at the clinic.';
      case 'called':
        return 'You are up next. Please proceed to the desk now.';
      case 'completed':
        return 'Visit completed. Thank you for using WellQueue.';
      case 'cancelled':
        return 'This queue entry is cancelled.';
      default:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = context.read<AuthService>().currentUser;
      if (user != null) {
        await context.read<QueueService>().loadUserQueue(user.id);
      }
    });

    _ticker = Stream.periodic(const Duration(seconds: 8)).listen((_) async {
      if (!mounted) return;
      final user = context.read<AuthService>().currentUser;
      if (user != null) {
        await context.read<QueueService>().loadUserQueue(user.id);
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final queue = context.watch<QueueService>().currentQueue;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 390;

    if (queue == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Queue')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFD8EFEA),
                  ),
                  child: Icon(
                    Icons.queue_outlined,
                    size: 64,
                    color: const Color(0xFF00695C),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No Active Queue',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Join a queue at a clinic to track your live turn and ETA.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () {
                    // The home tab already supports queue join. Keep action local.
                  },
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Explore clinics'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final statusColor = _statusColor(queue.status);
    final statusText = _statusText(queue.status);
    final statusHint = _statusHint(queue.status);

    return Scaffold(
      appBar: AppBar(title: const Text('My Queue')),
      body: Padding(
        padding: EdgeInsets.all(isCompact ? 14 : 20),
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.all(isCompact ? 14 : 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0C6D63), Color(0xFF168981)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadii.lg),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.25),
                    blurRadius: 26,
                    spreadRadius: -12,
                    offset: const Offset(0, 14),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Queue',
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    queue.clinicName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: isCompact ? 22 : 26, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: isCompact ? 150 : 170,
                      height: isCompact ? 150 : 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primary,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.20),
                            blurRadius: 24,
                            spreadRadius: 8,
                          )
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '#Q${queue.position}',
                        style: TextStyle(fontSize: isCompact ? 40 : 48, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Current Position', style: TextStyle(color: AppTheme.textMuted)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _infoPill(
                            icon: Icons.timer_outlined,
                            label: 'Estimated Wait',
                            value: '${queue.estimatedWaitMinutes} min',
                            color: AppTheme.warning,
                            compact: isCompact,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _infoPill(
                            icon: Icons.verified_user_outlined,
                            label: 'Status',
                            value: statusText,
                            color: statusColor,
                            compact: isCompact,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                      child: Text(
                        statusHint,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              button: true,
              label: 'Leave queue',
              hint: 'Cancel this queue entry and return to browse clinics',
              child: ElevatedButton.icon(
                onPressed: () async {
                  await context.read<QueueService>().cancelQueue(queue.id);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
                icon: const Icon(Icons.exit_to_app_rounded),
                label: const Text('Leave Queue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoPill({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool compact = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12, vertical: compact ? 8 : 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: compact ? 11 : 12, color: AppTheme.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: compact ? 13 : 14),
          ),
        ],
      ),
    );
  }

  String _statusText(String status) {
    switch (status) {
      case 'waiting':
        return 'Waiting';
      case 'confirmed':
        return 'Confirmed';
      case 'called':
        return 'Called';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/queue_service.dart';
import '../../../core/services/auth_service.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  StreamSubscription? _ticker;

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
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join a queue at a clinic to see your position here',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Queue')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(queue.clinicName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00695C),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00695C).withValues(alpha: 0.18),
                            blurRadius: 24,
                            spreadRadius: 8,
                          )
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '#Q${queue.position}',
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                    const Text('Current Position', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 10),
                    Text('Status: ${_statusText(queue.status)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('Estimated wait: ${queue.estimatedWaitMinutes} min'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await context.read<QueueService>().cancelQueue(queue.id);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB92D2D)),
              child: const Text('Leave Queue'),
            ),
          ],
        ),
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

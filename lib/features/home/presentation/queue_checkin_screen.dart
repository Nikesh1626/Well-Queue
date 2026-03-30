import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/queue_service.dart';
import '../../../core/services/auth_service.dart';

class QueueCheckInScreen extends StatefulWidget {
  const QueueCheckInScreen({super.key});

  @override
  State<QueueCheckInScreen> createState() => _QueueCheckInScreenState();
}

class _QueueCheckInScreenState extends State<QueueCheckInScreen> {
  @override
  void initState() {
    super.initState();
    // Load user's current queue entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = context.read<AuthService>();
      if (authService.currentUser != null) {
        context.read<QueueService>().loadUserQueue(authService.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Queue Position'),
          automaticallyImplyLeading: false,
        ),
        body: Consumer<QueueService>(
          builder: (context, queueService, _) {
            final queue = queueService.currentQueue;

            if (queue == null) {
              return const Scaffold(
                body: Center(
                  child: Text('No active queue entry'),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Clinic Name
                  Text(
                    queue.clinicName,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Position Circle
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getPositionColor(queue.status),
                      boxShadow: [
                        BoxShadow(
                          color: _getPositionColor(queue.status)
                              .withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          queue.status == 'called'
                              ? 'NEXT'
                              : '# ${queue.position}',
                          style:
                              Theme.of(context).textTheme.displayLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        if (queue.status != 'called')
                          Text(
                            'of ${queue.userTargetPosition}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Status Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Status',
                                style:
                                    Theme.of(context).textTheme.titleMedium,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(queue.status),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  queue.status.toUpperCase(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Est. Wait Time',
                                style:
                                    Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '${queue.estimatedWaitMinutes} min',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Joined At',
                                style:
                                    Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                _formatTime(queue.joinedAt),
                                style:
                                    Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Updates Section
                  if (queue.updates.isNotEmpty) ...[
                    Text(
                      'Queue Updates',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: queue.updates.length,
                      itemBuilder: (context, index) {
                        final update = queue.updates[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            child: ListTile(
                              leading: const Icon(Icons.info),
                              title: Text(update.message),
                              subtitle: Text(
                                _formatTime(update.timestamp),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Cancel Queue?'),
                            content: const Text(
                              'Are you sure you want to leave the queue?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text('Yes'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true && mounted) {
                          await context.read<QueueService>().cancelQueue(
                                queue.id,
                              );
                          if (mounted) {
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Leave Queue'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getPositionColor(String status) {
    switch (status) {
      case 'called':
        return Colors.red;
      case 'confirmed':
        return Colors.blue;
      case 'waiting':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'called':
        return Colors.red;
      case 'confirmed':
        return Colors.green;
      case 'waiting':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

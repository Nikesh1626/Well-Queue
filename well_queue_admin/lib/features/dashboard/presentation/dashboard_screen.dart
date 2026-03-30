import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/auth_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _client = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> _activeQueueStream() {
    return _client
        .from('queue_entries')
        .stream(primaryKey: ['id'])
        .order('joined_at', ascending: true)
        .map((rows) {
          final filtered = rows.where((row) {
            final status = row['status'] as String?;
            return status == 'waiting' || status == 'confirmed' || status == 'called';
          }).toList();
          filtered.sort((a, b) {
            final aJoined = DateTime.tryParse((a['joined_at'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bJoined = DateTime.tryParse((b['joined_at'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0);
            return aJoined.compareTo(bJoined);
          });
          return filtered.take(50).toList();
        });
  }

  Stream<List<Map<String, dynamic>>> _scheduledAppointmentsStream() {
    return _client
        .from('appointments')
        .stream(primaryKey: ['id'])
        .eq('status', 'scheduled');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AdminAuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinic Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: () => context.read<AdminAuthService>().signOut(),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _activeQueueStream(),
        builder: (context, queueSnapshot) {
          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: _scheduledAppointmentsStream(),
            builder: (context, appointmentSnapshot) {
              if (!queueSnapshot.hasData || !appointmentSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final rows = queueSnapshot.data!;
              final appointmentRows = appointmentSnapshot.data!;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Welcome, ${auth.profile?['first_name'] ?? 'Admin'}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _statCard('Active Queues', '${rows.length}')),
                      const SizedBox(width: 12),
                      Expanded(child: _statCard('Appointments', '${appointmentRows.length}')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Live Queue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  if (rows.isEmpty)
                    const Text('No active queue entries')
                  else
                    ...rows.map((row) {
                      return Card(
                        child: ListTile(
                          title: Text('${row['clinic_name']}  •  #${row['position']}'),
                          subtitle: Text('Status: ${row['status']}  •  User: ${row['user_id']}'),
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) async {
                              await _client.from('queue_entries').update({'status': v}).eq('id', row['id']);
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(value: 'called', child: Text('Mark Called')),
                              PopupMenuItem(value: 'completed', child: Text('Mark Completed')),
                              PopupMenuItem(value: 'cancelled', child: Text('Cancel')),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _statCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

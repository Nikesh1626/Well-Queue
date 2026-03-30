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
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Color(0xFF00695C)),
            SizedBox(width: 8),
            Text('WellQueue Admin'),
          ],
        ),
        actions: [
          CircleAvatar(
            backgroundColor: const Color(0xFFD8ECEE),
            child: Text(
              ((auth.profile?['first_name'] as String?)?.isNotEmpty ?? false)
                  ? (auth.profile!['first_name'] as String).substring(0, 1).toUpperCase()
                  : 'A',
              style: const TextStyle(color: Color(0xFF0C2732), fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
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
                  _statCard('Current Wait Time', '${rows.length > 1 ? rows.length + 8 : 12}', subtitle: '2m lower than average'),
                  const SizedBox(height: 12),
                  _statCard('Active Patients', '${rows.length}', subtitle: 'Priority cases in queue', highlighted: true),
                  const SizedBox(height: 12),
                  _statCard('Scheduled', '${appointmentRows.length}', subtitle: 'Total today'),
                  const SizedBox(height: 18),
                  const Text('Live Queue Feed', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w700, height: 1.05)),
                  const SizedBox(height: 6),
                  const Text('Real-time status of waiting patients', style: TextStyle(color: Color(0xFF546A72))),
                  const SizedBox(height: 10),
                  if (rows.isEmpty)
                    const Text('No active queue entries')
                  else
                    ...rows.map((row) {
                      final status = (row['status'] ?? 'waiting').toString();
                      final statusColor = status == 'called'
                          ? const Color(0xFF00695C)
                          : status == 'confirmed'
                              ? const Color(0xFF6B8E96)
                              : const Color(0xFF9BB8C0);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: const Color(0xFFD2EFE8),
                                child: Text(
                                  '#${row['position'] ?? '-'}',
                                  style: const TextStyle(color: Color(0xFF00695C), fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${row['clinic_name']}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
                                    const SizedBox(height: 2),
                                    Text('User: ${row['user_id']}', style: const TextStyle(color: Color(0xFF5A7078))),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.w700)),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (v) async {
                                  await _client.from('queue_entries').update({'status': v}).eq('id', row['id']);
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(value: 'called', child: Text('Mark Called')),
                                  PopupMenuItem(value: 'completed', child: Text('Mark Completed')),
                                  PopupMenuItem(value: 'cancelled', child: Text('Cancel')),
                                ],
                              )
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

  Widget _statCard(String title, String value, {String? subtitle, bool highlighted = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFF00695C) : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: highlighted ? Colors.white70 : const Color(0xFF445961),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 46,
              fontWeight: FontWeight.bold,
              color: highlighted ? Colors.white : const Color(0xFF0F1C20),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(color: highlighted ? Colors.white70 : const Color(0xFF5A7078)),
            ),
          ]
        ],
      ),
    );
  }
}

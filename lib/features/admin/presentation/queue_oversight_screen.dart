import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_schema.dart';
import '../../../../core/models/queue_entry.dart';

class AdminQueueOversightScreen extends StatefulWidget {
  const AdminQueueOversightScreen({super.key});

  @override
  State<AdminQueueOversightScreen> createState() =>
      _AdminQueueOversightScreenState();
}

class _AdminQueueOversightScreenState extends State<AdminQueueOversightScreen> {
  late Future<List<QueueEntry>> _queuesFuture;
  String _selectedStatus = SupabaseSchema.statusWaiting;

  @override
  void initState() {
    super.initState();
    _queuesFuture = _fetchQueues();
  }

  Future<List<QueueEntry>> _fetchQueues() async {
    final response = await Supabase.instance.client
        .from(SupabaseSchema.queueEntriesTable)
        .select()
        .eq(SupabaseSchema.queueStatus, _selectedStatus)
        .order(SupabaseSchema.queuePosition);

    return response.map((e) => QueueEntry.fromJson(e)).toList();
  }

  Future<void> _updateQueueStatus(
    String queueId,
    String newStatus,
  ) async {
    try {
      await Supabase.instance.client
          .from(SupabaseSchema.queueEntriesTable)
          .update({
            SupabaseSchema.queueStatus: newStatus,
            SupabaseSchema.queueUpdatedAt:
                DateTime.now().toIso8601String(),
          })
          .eq(SupabaseSchema.queueId, queueId);

      if (mounted) {
        setState(() {
          _queuesFuture = _fetchQueues();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Queue status updated')),
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
        title: const Text('Queue Oversight'),
      ),
      body: Column(
        children: [
          // Status filter chips
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SupabaseSchema.statusWaiting,
                  SupabaseSchema.statusConfirmed,
                  SupabaseSchema.statusCalled,
                  SupabaseSchema.statusCompleted,
                ]
                    .map(
                      (status) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(status.toUpperCase()),
                          selected: _selectedStatus == status,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedStatus = status;
                                _queuesFuture = _fetchQueues();
                              });
                            }
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          // Queue list
          Expanded(
            child: FutureBuilder<List<QueueEntry>>(
              future: _queuesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final queues = snapshot.data ?? [];

                if (queues.isEmpty) {
                  return const Center(
                    child: Text('No queues in this status'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: queues.length,
                  itemBuilder: (context, index) {
                    final queue = queues[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${queue.position}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        title: Text(queue.clinicName),
                        subtitle: Text(
                          'Position: ${queue.position} | Status: ${queue.status}',
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: const Text('Mark as Called'),
                              onTap: () => _updateQueueStatus(
                                queue.id,
                                SupabaseSchema.statusCalled,
                              ),
                            ),
                            PopupMenuItem(
                              child: const Text('Mark as Completed'),
                              onTap: () => _updateQueueStatus(
                                queue.id,
                                SupabaseSchema.statusCompleted,
                              ),
                            ),
                            PopupMenuItem(
                              child: const Text('Cancel'),
                              onTap: () => _updateQueueStatus(
                                queue.id,
                                SupabaseSchema.statusCancelled,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

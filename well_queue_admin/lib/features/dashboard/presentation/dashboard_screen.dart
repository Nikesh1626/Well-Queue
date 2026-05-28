import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/auth_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _client = Supabase.instance.client;
  final Map<String, Map<String, dynamic>> _userCache = {};
  final Map<String, Stream<List<Map<String, dynamic>>>> _activeQueueStreams = {};
  final Map<String, Stream<List<Map<String, dynamic>>>> _scheduledStreams = {};
  final Map<String, Stream<List<Map<String, dynamic>>>> _handledQueueStreams = {};
  String? _clinicName;
  int _defaultWaitPerPerson = 5;
  final Set<String> _busyRowIds = {};
  final Set<String> _expandedRowIds = {};

  Future<void> _fetchClinicName(String? clinicId) async {
    if (clinicId == null) return;
    try {
      final row = await _client.from('clinics').select('name, wait_time_minutes').eq('id', clinicId).maybeSingle();
      final name = row?['name'] as String?;
      final waitPerPerson = (row?['wait_time_minutes'] as num?)?.toInt();
      if (name != null && name.isNotEmpty) {
        setState(() => _clinicName = name);
      }
      if (waitPerPerson != null) {
        _defaultWaitPerPerson = waitPerPerson;
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> _fetchMissingUsers(List<Map<String, dynamic>> rows) async {
    final ids = rows
        .map((r) => (r['user_id'] ?? '') as String)
        .where((id) => id.isNotEmpty && !_userCache.containsKey(id))
        .toSet()
        .toList();
    if (ids.isEmpty) return;
    try {
      final res = await _client.from('users').select('id, first_name, last_name, phone').in_('id', ids);
      if (res is List) {
        for (final r in res) {
          final id = r['id'] as String?;
          if (id != null) _userCache[id] = r as Map<String, dynamic>;
        }
        setState(() {});
      }
    } catch (_) {}
  }

  int _computeCurrentWaitMinutes(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return 0;
    final estimatedValues = rows
        .map((r) {
          final v = r['estimated_wait'];
          if (v is num) return v.toInt();
          if (v is String) return int.tryParse(v);
          return null;
        })
        .whereType<int>()
        .toList();
    if (estimatedValues.isNotEmpty) {
      final avg = (estimatedValues.reduce((a, b) => a + b) / estimatedValues.length).round();
      return avg;
    }
    final perPerson = _defaultWaitPerPerson;
    final positions = rows
        .map((r) => (r['position'] is num) ? (r['position'] as num).toInt() : int.tryParse((r['position'] ?? '').toString()) ?? 0)
        .where((p) => p > 0)
        .toList();
    if (positions.isEmpty) return rows.length * perPerson;
    return positions.length * perPerson;
  }

  Future<List<Map<String, dynamic>>> _fetchActiveQueue(String clinicId) async {
    try {
      final res = await _client
          .from('queue_entries')
          .select('*')
          .eq('clinic_id', clinicId)
          .or('status.eq.waiting,status.eq.confirmed,status.eq.called')
          .order('joined_at', ascending: true)
          .limit(50);
      return List<Map<String, dynamic>>.from(res as List);
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchScheduledAppointments(String clinicId) async {
    try {
      final res = await _client
          .from('appointments')
          .select('*')
          .eq('clinic_id', clinicId)
          .eq('status', 'scheduled');
      return List<Map<String, dynamic>>.from(res as List);
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchHandledQueue(String clinicId) async {
    try {
      final res = await _client
          .from('queue_entries')
          .select('*')
          .eq('clinic_id', clinicId)
          .or('status.eq.completed,status.eq.cancelled')
          .order('joined_at', ascending: false)
          .limit(50);
      return List<Map<String, dynamic>>.from(res as List);
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  Stream<List<Map<String, dynamic>>> _activeQueueStream(String clinicId) async* {
    yield await _fetchActiveQueue(clinicId);
    yield* Stream.periodic(const Duration(seconds: 3)).asyncMap((_) => _fetchActiveQueue(clinicId));
  }

  Stream<List<Map<String, dynamic>>> _scheduledAppointmentsStream(String clinicId) async* {
    yield await _fetchScheduledAppointments(clinicId);
    yield* Stream.periodic(const Duration(seconds: 3)).asyncMap((_) => _fetchScheduledAppointments(clinicId));
  }

  Stream<List<Map<String, dynamic>>> _handledQueueStream(String clinicId) async* {
    yield await _fetchHandledQueue(clinicId);
    yield* Stream.periodic(const Duration(seconds: 3)).asyncMap((_) => _fetchHandledQueue(clinicId));
  }

  String _userDisplayName(Map<String, dynamic> row) {
    final userId = (row['user_id'] ?? '').toString();
    if (userId.isEmpty) return 'Unknown user';
    final profile = _userCache[userId];
    if (profile == null) {
      return userId.length > 6 ? 'User ${userId.substring(0, 6)}' : 'User $userId';
    }
    final first = (profile['first_name'] ?? '').toString().trim();
    final last = (profile['last_name'] ?? '').toString().trim();
    final full = '$first $last'.trim();
    if (full.isNotEmpty) return full;
    return userId.length > 6 ? 'User ${userId.substring(0, 6)}' : 'User $userId';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AdminAuthServiceBase>();
    final clinicId = auth.clinicId;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 390;
    final contentPadding = isCompact ? 12.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('WellQueue Admin'),
            if (_clinicName != null)
              Text(
                _clinicName!,
                style: const TextStyle(fontSize: 12, color: Color(0xFF5A7078), fontWeight: FontWeight.w500),
              ),
          ],
        ),
      ),
      body: clinicId == null
          ? Center(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFD3DEE2)),
                ),
                child: const Text('No clinic linked', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            )
          : StreamBuilder<List<Map<String, dynamic>>>(
              key: ValueKey('queue_$clinicId'),
              stream: _activeQueueStreams.putIfAbsent(clinicId, () => _activeQueueStream(clinicId)),
              builder: (context, queueSnapshot) {
                return StreamBuilder<List<Map<String, dynamic>>>(
                  key: ValueKey('appointments_$clinicId'),
                  stream: _scheduledStreams.putIfAbsent(clinicId, () => _scheduledAppointmentsStream(clinicId)),
                  builder: (context, appointmentSnapshot) {
                    return StreamBuilder<List<Map<String, dynamic>>>(
                      key: ValueKey('handled_$clinicId'),
                      stream: _handledQueueStreams.putIfAbsent(clinicId, () => _handledQueueStream(clinicId)),
                      builder: (context, handledSnapshot) {
                        if (!queueSnapshot.hasData || !appointmentSnapshot.hasData || !handledSnapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final rows = queueSnapshot.data!;
                        final appointmentRows = appointmentSnapshot.data!;
                        final handledRows = handledSnapshot.data!;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _fetchMissingUsers([...rows, ...handledRows]);
                          if (_clinicName == null) _fetchClinicName(clinicId);
                        });

                        return ListView(
                          padding: EdgeInsets.all(contentPadding),
                          children: [
                        Container(
                          padding: EdgeInsets.all(isCompact ? 14 : 18),
                          decoration: BoxDecoration(
                            color: Colors.green[800],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0C6D63).withValues(alpha: 0.18),
                                blurRadius: 18,
                                spreadRadius: -8,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Operations Snapshot', style: TextStyle(color: Colors.white70, fontSize: isCompact ? 15 : 16)),
                              const SizedBox(height: 6),
                              Text(
                                'Now serving ${rows.isNotEmpty ? '#${rows.first['position'] ?? '-'}' : 'no active queue'}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.white, fontSize: isCompact ? 19 : 22, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${rows.length} active • ${appointmentRows.length} scheduled',
                                style: TextStyle(color: Colors.white, fontSize: isCompact ? 14 : 16),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        isCompact
                            ? Column(
                                children: [
                                  _statCard('Current Wait Time', '${_computeCurrentWaitMinutes(rows)} min', compact: true),
                                  const SizedBox(height: 10),
                                  _statCard('Active Patients', '${rows.length}', highlighted: true, compact: true),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(child: _statCard('Current Wait Time', '${_computeCurrentWaitMinutes(rows)} min')),
                                  const SizedBox(width: 12),
                                  Expanded(child: _statCard('Active Patients', '${rows.length}', highlighted: true)),
                                ],
                              ),
                        const SizedBox(height: 18),
                        Text('Live Queue Feed', style: TextStyle(fontSize: isCompact ? 18 : 20, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                            if (rows.isEmpty)
                              const Text('No active queue entries')
                            else
                              for (var index = 0; index < rows.length; index++)
                                (() {
                                  final row = rows[index];
                                  final rowId = (row['id'] ?? '').toString();
                                  final status = (row['status'] ?? 'waiting').toString();
                                  final statusColor = status == 'called'
                                      ? const Color(0xFF00695C)
                                      : status == 'confirmed'
                                          ? const Color(0xFF6B8E96)
                                          : const Color(0xFF9BB8C0);
                                  final isExpanded = _expandedRowIds.contains(rowId);

                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: Duration(milliseconds: 240 + (index * 30)),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, (1 - value) * 12),
                                      child: child,
                                    ),
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 260),
                                  curve: Curves.easeOut,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: statusColor.withValues(alpha: 0.18)),
                                  ),
                                  child: Card(
                                    elevation: 0,
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: Padding(
                                      padding: EdgeInsets.all(isCompact ? 10 : 12),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: isCompact ? 22 : 26,
                                                backgroundColor: const Color(0xFFD2EFE8),
                                                child: Text(
                                                  '#${row['position'] ?? '-'}',
                                                  style: TextStyle(color: const Color(0xFF00695C), fontWeight: FontWeight.w700, fontSize: isCompact ? 14 : 16),
                                                ),
                                              ),
                                              SizedBox(width: isCompact ? 8 : 12),
                                              Expanded(
                                                child: Text(
                                                  _userDisplayName(row),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: isCompact ? 16 : 18),
                                                ),
                                              ),
                                              AnimatedSwitcher(
                                                duration: const Duration(milliseconds: 220),
                                                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                                                child: Container(
                                                  key: ValueKey('${row['id']}_$status'),
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(10)),
                                                  child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: isCompact ? 12 : 13)),
                                                ),
                                              ),
                                              IconButton(
                                                iconSize: isCompact ? 20 : 22,
                                                visualDensity: VisualDensity.compact,
                                                onPressed: () {
                                                  setState(() {
                                                    if (isExpanded) {
                                                      _expandedRowIds.remove(rowId);
                                                    } else {
                                                      _expandedRowIds.add(rowId);
                                                    }
                                                  });
                                                },
                                                icon: Icon(isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded),
                                              ),
                                            ],
                                          ),
                                          if (isExpanded) ...[
                                            const SizedBox(height: 8),
                                            _buildActionButtons(context, row, isCompact),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            })(),
                            const SizedBox(height: 18),
                            Text('Handled Patients', style: TextStyle(fontSize: isCompact ? 18 : 20, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(
                              'Completed and no-show records',
                              style: TextStyle(color: const Color(0xFF61757C), fontSize: isCompact ? 12 : 13),
                            ),
                            const SizedBox(height: 8),
                            if (handledRows.isEmpty)
                              const Text('No completed or no-show entries yet')
                            else
                              for (final row in handledRows)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: (row['status'] == 'cancelled') ? const Color(0xFFFFECEC) : const Color(0xFFEAF7EF),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: (row['status'] == 'cancelled') ? const Color(0xFFFFB3B3) : const Color(0xFFBCE6C8),
                                    ),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: (row['status'] == 'cancelled') ? const Color(0xFFFFD6D6) : const Color(0xFFD2EFE8),
                                      child: Text('#${row['position'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                    ),
                                    title: Text(
                                      _userDisplayName(row),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: (row['status'] == 'cancelled') ? const Color(0xFFFFDCDC) : const Color(0xFFD6F2DE),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        row['status'] == 'cancelled' ? 'NO-SHOW' : 'COMPLETED',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: (row['status'] == 'cancelled') ? const Color(0xFFC62828) : const Color(0xFF1B7F3B),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                      ],
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Map<String, dynamic> row, bool isCompact) {
    final rowId = (row['id'] ?? '').toString();
    final busy = _busyRowIds.contains(rowId);

    Future<void> callUser() async {
      final messenger = ScaffoldMessenger.maybeOf(context);
      final userId = (row['user_id'] ?? '') as String;
      String? phone = row['phone']?.toString();
      if ((phone == null || phone.isEmpty) && _userCache.containsKey(userId)) {
        phone = _userCache[userId]?['phone']?.toString();
      }
      if (phone == null || phone.isEmpty) {
        if (mounted && messenger != null) {
          messenger.showSnackBar(const SnackBar(content: Text('No phone number available')));
        }
        return;
      }

      try {
        _busyRowIds.add(rowId);
        if (mounted) setState(() {});
        await launchUrl(Uri.parse('tel:$phone'));
      } finally {
        _busyRowIds.remove(rowId);
        if (mounted) setState(() {});
      }
    }

    Future<void> updateStatus(String status, String errorText) async {
      final messenger = ScaffoldMessenger.maybeOf(context);
      try {
        _busyRowIds.add(rowId);
        if (mounted) setState(() {});
        await _client.from('queue_entries').update({'status': status}).eq('id', row['id']);
      } catch (_) {
        if (mounted && messenger != null) {
          messenger.showSnackBar(SnackBar(content: Text(errorText)));
        }
      } finally {
        _busyRowIds.remove(rowId);
        if (mounted) setState(() {});
      }
    }

    Widget actionButton({
      required String label,
      required Color color,
      required VoidCallback onTap,
    }) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: isCompact ? 10 : 12),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
        onPressed: busy ? null : onTap,
        child: busy
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label, maxLines: 1, style: TextStyle(fontSize: isCompact ? 13 : 14, fontWeight: FontWeight.w700)),
              ),
      );
    }

    if (isCompact) {
      return Column(
        children: [
          SizedBox(width: double.infinity, child: actionButton(label: 'Call', color: Colors.teal, onTap: callUser)),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: actionButton(label: 'Complete', color: Colors.green, onTap: () => updateStatus('completed', 'Failed to mark complete'))),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: actionButton(label: 'No-show', color: Colors.redAccent, onTap: () => updateStatus('cancelled', 'Failed to mark no-show'))),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: actionButton(label: 'Call', color: Colors.teal, onTap: callUser)),
        const SizedBox(width: 8),
        Expanded(child: actionButton(label: 'Complete', color: Colors.green, onTap: () => updateStatus('completed', 'Failed to mark complete'))),
        const SizedBox(width: 8),
        Expanded(child: actionButton(label: 'No-show', color: Colors.redAccent, onTap: () => updateStatus('cancelled', 'Failed to mark no-show'))),
      ],
    );
  }

  Widget _statCard(String title, String value, {bool highlighted = false, bool compact = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 10 : 12),
      decoration: BoxDecoration(
        color: highlighted ? Colors.teal : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: highlighted ? Colors.transparent : const Color(0xFFE2ECEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w600, color: highlighted ? Colors.white70 : const Color(0xFF55666D), fontSize: compact ? 14 : 16),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: compact ? 28 : 32, fontWeight: FontWeight.bold, color: highlighted ? Colors.white : const Color(0xFF24353D)),
          ),
        ],
      ),
    );
  }
}

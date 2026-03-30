import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/queue_entry.dart';
import '../constants/supabase_schema.dart';

class QueueService extends ChangeNotifier {
  static final QueueService _instance = QueueService._internal();

  factory QueueService() {
    return _instance;
  }

  QueueService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  QueueEntry? _currentQueueEntry;
  List<QueueEntry> _queueHistory = [];
  StreamSubscription<List<Map<String, dynamic>>>? _queueSubscription;

  QueueEntry? get currentQueue => _currentQueueEntry;
  List<QueueEntry> get queueHistory => _queueHistory;

  /// Join queue at a clinic
  Future<bool> joinQueue({
    required String clinicId,
    required String clinicName,
    required String userId,
  }) async {
    try {
      // First, get the current queue position at this clinic
      final response = await _supabase
          .from(SupabaseSchema.queueEntriesTable)
          .select('position')
          .eq(SupabaseSchema.queueClinicId, clinicId)
          .eq(SupabaseSchema.queueStatus, SupabaseSchema.statusWaiting)
          .order('position', ascending: false)
          .limit(1);

      int currentMaxPosition = 0;
      if (response.isNotEmpty) {
        currentMaxPosition = (response[0]['position'] as int?) ?? 0;
      }

      final newPosition = currentMaxPosition + 1;
      final estimatedWait = newPosition * 5; // 5 minutes per person

      // Create queue entry
      final result = await _supabase
          .from(SupabaseSchema.queueEntriesTable)
          .insert(
        {
          SupabaseSchema.queueClinicId: clinicId,
          SupabaseSchema.queueClinicName: clinicName,
          SupabaseSchema.queueUserId: userId,
          SupabaseSchema.queuePosition: newPosition,
          SupabaseSchema.queueUserTargetPosition: newPosition,
          SupabaseSchema.queueStatus: SupabaseSchema.statusConfirmed,
          SupabaseSchema.queueJoinedAt: DateTime.now().toIso8601String(),
          SupabaseSchema.queueEstimatedWait: estimatedWait,
          SupabaseSchema.queueCreatedAt: DateTime.now().toIso8601String(),
        },
      )
          .select()
          .single();

      _currentQueueEntry = QueueEntry.fromJson(result);
      await _addQueueUpdate(
        _currentQueueEntry!.id,
        'Joined queue at $clinicName',
        'info',
      );

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error joining queue: $e');
      return false;
    }
  }

  /// Cancel queue entry
  Future<bool> cancelQueue(String queueEntryId) async {
    try {
      await _supabase
          .from(SupabaseSchema.queueEntriesTable)
          .update(
            {
              SupabaseSchema.queueStatus: SupabaseSchema.statusCancelled,
              SupabaseSchema.queueUpdatedAt:
                  DateTime.now().toIso8601String(),
            },
          )
          .eq(SupabaseSchema.queueId, queueEntryId);

      await _addQueueUpdate(queueEntryId, 'Queue cancelled', 'info');

      _currentQueueEntry = null;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error cancelling queue: $e');
      return false;
    }
  }

  /// Load user's current queue entry
  Future<void> loadUserQueue(String userId) async {
    try {
      final response = await _supabase
          .from(SupabaseSchema.queueEntriesTable)
          .select()
          .eq(SupabaseSchema.queueUserId, userId)
          .or(
            '${SupabaseSchema.queueStatus}.eq.${SupabaseSchema.statusConfirmed},'
            '${SupabaseSchema.queueStatus}.eq.${SupabaseSchema.statusWaiting},'
            '${SupabaseSchema.queueStatus}.eq.${SupabaseSchema.statusCalled}',
          )
          .order(SupabaseSchema.queueCreatedAt, ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        _currentQueueEntry = QueueEntry.fromJson(response[0]);
        _startQueueListener(_currentQueueEntry!.id);
      } else {
        _currentQueueEntry = null;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user queue: $e');
    }
  }

  /// Load user's queue history
  Future<void> loadQueueHistory(String userId) async {
    try {
      final response = await _supabase
          .from(SupabaseSchema.queueEntriesTable)
          .select()
          .eq(SupabaseSchema.queueUserId, userId)
          .order(SupabaseSchema.queueCreatedAt, ascending: false);

      _queueHistory =
          response.map((e) => QueueEntry.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading queue history: $e');
    }
  }

  /// Add update to queue entry
  Future<void> _addQueueUpdate(
    String queueEntryId,
    String message,
    String? type,
  ) async {
    try {
      await _supabase.from(SupabaseSchema.queueUpdatesTable).insert(
        {
          'queue_entry_id': queueEntryId,
          'message': message,
          'type': type,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('Error adding queue update: $e');
    }
  }

  /// Start listening to real-time queue updates
  void _startQueueListener(String queueEntryId) {
    _queueSubscription?.cancel();
    _queueSubscription = _supabase
        .from(SupabaseSchema.queueEntriesTable)
        .stream(primaryKey: [SupabaseSchema.queueId])
        .eq(SupabaseSchema.queueId, queueEntryId)
        .listen((rows) {
      if (rows.isNotEmpty) {
        _currentQueueEntry = QueueEntry.fromJson(rows.first);
        notifyListeners();
      }
    });
  }

  /// Stop listening to real-time updates
  void stopListening() {
    _queueSubscription?.cancel();
    _queueSubscription = null;
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}

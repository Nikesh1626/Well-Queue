class QueueEntry {
  final String id;
  final String clinicId;
  final String clinicName;
  final String userId;
  final int position;
  final int userTargetPosition;
  final String status; // 'waiting', 'confirmed', 'called', 'completed', 'cancelled'
  final DateTime joinedAt;
  final int estimatedWaitMinutes;
  final List<QueueUpdate> updates;
  final DateTime? completedAt;

  QueueEntry({
    required this.id,
    required this.clinicId,
    required this.clinicName,
    required this.userId,
    required this.position,
    required this.userTargetPosition,
    required this.status,
    required this.joinedAt,
    required this.estimatedWaitMinutes,
    required this.updates,
    this.completedAt,
  });

  bool get isActive => status == 'waiting' || status == 'confirmed';
  bool get isCalled => status == 'called';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  factory QueueEntry.fromJson(Map<String, dynamic> json) {
    final updatesList = json['updates'] as List? ?? [];
    return QueueEntry(
      id: json['id'] as String,
      clinicId: json['clinic_id'] as String,
      clinicName: json['clinic_name'] as String? ?? '',
      userId: json['user_id'] as String,
      position: json['position'] as int? ?? 0,
      userTargetPosition: json['user_target_position'] as int? ?? 0,
      status: json['status'] as String? ?? 'waiting',
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'] as String)
          : DateTime.now(),
      estimatedWaitMinutes: json['estimated_wait_minutes'] as int? ?? 0,
      updates: updatesList
          .map((e) => QueueUpdate.fromJson(e as Map<String, dynamic>))
          .toList(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clinic_id': clinicId,
      'clinic_name': clinicName,
      'user_id': userId,
      'position': position,
      'user_target_position': userTargetPosition,
      'status': status,
      'joined_at': joinedAt.toIso8601String(),
      'estimated_wait_minutes': estimatedWaitMinutes,
      'updates': updates.map((u) => u.toJson()).toList(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  QueueEntry copyWith({
    String? id,
    String? clinicId,
    String? clinicName,
    String? userId,
    int? position,
    int? userTargetPosition,
    String? status,
    DateTime? joinedAt,
    int? estimatedWaitMinutes,
    List<QueueUpdate>? updates,
    DateTime? completedAt,
  }) {
    return QueueEntry(
      id: id ?? this.id,
      clinicId: clinicId ?? this.clinicId,
      clinicName: clinicName ?? this.clinicName,
      userId: userId ?? this.userId,
      position: position ?? this.position,
      userTargetPosition: userTargetPosition ?? this.userTargetPosition,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
      estimatedWaitMinutes: estimatedWaitMinutes ?? this.estimatedWaitMinutes,
      updates: updates ?? this.updates,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  String toString() =>
      'QueueEntry(id: $id, clinic: $clinicName, position: $position/$userTargetPosition, status: $status)';
}

class QueueUpdate {
  final String message;
  final DateTime timestamp;
  final String? type; // 'info', 'status', 'alert'

  QueueUpdate({
    required this.message,
    required this.timestamp,
    this.type,
  });

  factory QueueUpdate.fromJson(Map<String, dynamic> json) {
    return QueueUpdate(
      message: json['message'] as String,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
    };
  }
}

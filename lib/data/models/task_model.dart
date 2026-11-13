import 'dart:convert';

class SubTaskItem {
  final String title;
  final bool done;

  const SubTaskItem({required this.title, this.done = false});

  SubTaskItem copyWith({String? title, bool? done}) => SubTaskItem(
        title: title ?? this.title,
        done: done ?? this.done,
      );

  Map<String, dynamic> toJson() => {'title': title, 'done': done};

  factory SubTaskItem.fromJson(Map<String, dynamic> json) => SubTaskItem(
        title: (json['title'] ?? '').toString(),
        done: json['done'] == true,
      );
}

class Task {
  int? id;
  final String title;
  final String note;
  final int category;
  final int? dueAt;
  final int remindBefore;
  final bool done;
  final int createdAt;
  final int priority; // 0: عادية, 1: متوسطة, 2: قصوى
  final int repeatType; // 0: بدون, 1: يومي, 2: أسبوعي, 3: شهري
  final bool isPinned;
  final List<SubTaskItem> subtasks;

  Task({
    this.id,
    required this.title,
    this.note = '',
    this.category = 0,
    this.dueAt,
    this.remindBefore = 0,
    this.done = false,
    required this.createdAt,
    this.priority = 1,
    this.repeatType = 0,
    this.isPinned = false,
    this.subtasks = const [],
  });

  DateTime? get due =>
      dueAt == null ? null : DateTime.fromMillisecondsSinceEpoch(dueAt!);

  bool get isLate => !done && due != null && due!.isBefore(DateTime.now());

  bool get isToday {
    final d = due;
    if (d == null) return false;
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  int get completedSubtasks => subtasks.where((s) => s.done).length;

  DateTime? get nextOccurrence {
    if (due == null || repeatType == 0) return null;
    final current = due!;
    final now = DateTime.now();
    DateTime next = current;
    while (!next.isAfter(now)) {
      switch (repeatType) {
        case 1:
          next = next.add(const Duration(days: 1));
          break;
        case 2:
          next = next.add(const Duration(days: 7));
          break;
        case 3:
          next = DateTime(
            next.year,
            next.month + 1,
            next.day,
            next.hour,
            next.minute,
          );
          break;
        default:
          return null;
      }
    }
    return next;
  }

  Task copyWith({
    int? id,
    String? title,
    String? note,
    int? category,
    int? dueAt,
    bool clearDue = false,
    int? remindBefore,
    bool? done,
    int? createdAt,
    int? priority,
    int? repeatType,
    bool? isPinned,
    List<SubTaskItem>? subtasks,
  }) =>
      Task(
        id: id ?? this.id,
        title: title ?? this.title,
        note: note ?? this.note,
        category: category ?? this.category,
        dueAt: clearDue ? null : (dueAt ?? this.dueAt),
        remindBefore: remindBefore ?? this.remindBefore,
        done: done ?? this.done,
        createdAt: createdAt ?? this.createdAt,
        priority: priority ?? this.priority,
        repeatType: repeatType ?? this.repeatType,
        isPinned: isPinned ?? this.isPinned,
        subtasks: subtasks ?? this.subtasks,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'note': note,
        'category': category,
        'dueAt': dueAt,
        'remindBefore': remindBefore,
        'done': done ? 1 : 0,
        'createdAt': createdAt,
        'priority': priority,
        'repeatType': repeatType,
        'isPinned': isPinned ? 1 : 0,
        'subtasks': jsonEncode(subtasks.map((e) => e.toJson()).toList()),
      };

  factory Task.fromMap(Map<String, Object?> m) {
    List<SubTaskItem> parsedSubtasks = const [];
    final rawSub = m['subtasks'] as String?;
    if (rawSub != null && rawSub.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawSub) as List<dynamic>;
        parsedSubtasks = decoded
            .map((e) => SubTaskItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } catch (_) {
        parsedSubtasks = const [];
      }
    }

    return Task(
      id: m['id'] as int?,
      title: (m['title'] ?? '') as String,
      note: (m['note'] ?? '') as String,
      category: (m['category'] as int?) ?? 0,
      dueAt: m['dueAt'] as int?,
      remindBefore: (m['remindBefore'] as int?) ?? 0,
      done: ((m['done'] as int?) ?? 0) == 1,
      createdAt: (m['createdAt'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      priority: (m['priority'] as int?) ?? 1,
      repeatType: (m['repeatType'] as int?) ?? 0,
      isPinned: ((m['isPinned'] as int?) ?? 0) == 1,
      subtasks: parsedSubtasks,
    );
  }
}

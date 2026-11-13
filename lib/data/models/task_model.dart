class Task {
  int? id;
  String title;
  String note;
  int category; // فهرس النوع في taskCategories
  int? dueAt; // millisecondsSinceEpoch (اختياري)
  int remindBefore; // بالدقائق
  bool done;
  int createdAt;

  Task({
    this.id,
    required this.title,
    this.note = '',
    this.category = 0,
    this.dueAt,
    this.remindBefore = 0,
    this.done = false,
    required this.createdAt,
  });

  DateTime? get due =>
      dueAt == null ? null : DateTime.fromMillisecondsSinceEpoch(dueAt!);

  bool get isLate => !done && due != null && due!.isBefore(DateTime.now());

  Task copyWith({bool? done}) => Task(
        id: id,
        title: title,
        note: note,
        category: category,
        dueAt: dueAt,
        remindBefore: remindBefore,
        done: done ?? this.done,
        createdAt: createdAt,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'note': note,
        'category': category,
        'dueAt': dueAt,
        'remindBefore': remindBefore,
        'done': done ? 1 : 0,
        'createdAt': createdAt,
      };

  factory Task.fromMap(Map<String, Object?> m) => Task(
        id: m['id'] as int,
        title: m['title'] as String,
        note: (m['note'] as String?) ?? '',
        category: m['category'] as int,
        dueAt: m['dueAt'] as int?,
        remindBefore: m['remindBefore'] as int,
        done: (m['done'] as int) == 1,
        createdAt: m['createdAt'] as int,
      );
}

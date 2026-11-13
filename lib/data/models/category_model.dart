import 'package:flutter/material.dart';

class TaskCategory {
  final String name;
  final IconData icon;
  final Color color;

  const TaskCategory(this.name, this.icon, this.color);
}

const taskCategories = <TaskCategory>[
  TaskCategory('عمل', Icons.work_rounded, Color(0xFF4F46E5)),
  TaskCategory('دراسة', Icons.school_rounded, Color(0xFF0EA5E9)),
  TaskCategory('شخصي', Icons.person_rounded, Color(0xFFEC4899)),
  TaskCategory('صحة', Icons.favorite_rounded, Color(0xFFEF4444)),
  TaskCategory('تسوق', Icons.shopping_bag_rounded, Color(0xFFF59E0B)),
  TaskCategory('مالية', Icons.account_balance_wallet_rounded, Color(0xFF10B981)),
  TaskCategory('ملاحظات', Icons.sticky_note_2_rounded, Color(0xFF8B5CF6)),
  TaskCategory('عاجل', Icons.bolt_rounded, Color(0xFFF43F5E)),
];

import 'package:intl/intl.dart';

abstract class Fmt {
  static final _dt = DateFormat('EEE d MMM • h:mm a', 'ar');
  static final _timeOnly = DateFormat('h:mm a', 'ar');
  static final _dateOnly = DateFormat('EEEE، d MMMM', 'ar');

  static String dateTime(DateTime d) => _dt.format(d);
  static String time(DateTime d) => _timeOnly.format(d);
  static String fullDate(DateTime d) => _dateOnly.format(d);

  static String greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'صباح الإنجاز والنشاط';
    if (h < 17) return 'طاب يومك بكل خير';
    return 'مساء الهدوء والترتيب';
  }

  static String left(DateTime d) {
    final diff = d.difference(DateTime.now());
    if (diff.isNegative) {
      final a = diff.abs();
      if (a.inDays > 0) return 'متأخر منذ ${a.inDays} يوم';
      if (a.inHours > 0) return 'متأخر منذ ${a.inHours} س';
      final mins = a.inMinutes <= 0 ? 1 : a.inMinutes;
      return 'متأخر منذ $mins د';
    }
    if (diff.inDays > 0) {
      final remHours = diff.inHours % 24;
      if (remHours > 0) return 'بعد ${diff.inDays} يوم و $remHours س';
      return 'بعد ${diff.inDays} يوم';
    }
    if (diff.inHours > 0) {
      final remMins = diff.inMinutes % 60;
      if (remMins > 0) return 'بعد ${diff.inHours} س و $remMins د';
      return 'بعد ${diff.inHours} ساعة';
    }
    if (diff.inMinutes > 0) return 'بعد ${diff.inMinutes} دقيقة';
    return 'الآن';
  }

  static const remindOptions = <int, String>{
    0: 'في الوقت المحدد تماماً',
    5: 'قبل 5 دقائق',
    10: 'قبل 10 دقائق',
    15: 'قبل 15 دقيقة',
    30: 'قبل 30 دقيقة',
    60: 'قبل ساعة واحدة',
    120: 'قبل ساعتين',
    180: 'قبل 3 ساعات',
    1440: 'قبل يوم كامل',
  };

  static const repeatOptions = <int, String>{
    0: 'بدون تكرار (مرة واحدة)',
    1: 'يومياً في نفس الموعد',
    2: 'أسبوعياً في نفس اليوم',
    3: 'شهرياً في نفس التاريخ',
  };

  static const priorityLabels = <int, String>{
    0: 'عادية',
    1: 'متوسطة',
    2: 'قصوى',
  };
}

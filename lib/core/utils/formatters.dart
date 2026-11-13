import 'package:intl/intl.dart';

class Fmt {
  static final _dt = DateFormat('EEE d MMM • h:mm a', 'ar');

  static String dateTime(DateTime d) => _dt.format(d);

  /// "بعد 3 ساعة" / "متأخرة منذ يوم"
  static String left(DateTime d) {
    final diff = d.difference(DateTime.now());
    final a = diff.abs();
    String s;
    if (a.inDays >= 1) {
      s = '${a.inDays} يوم';
    } else if (a.inHours >= 1) {
      s = '${a.inHours} ساعة';
    } else {
      s = '${a.inMinutes < 1 ? 1 : a.inMinutes} دقيقة';
    }
    return diff.isNegative ? 'متأخرة منذ $s' : 'بعد $s';
  }

  static const remindOptions = {
    0: 'في الموعد تمامًا',
    10: 'قبل 10 دقائق',
    30: 'قبل 30 دقيقة',
    60: 'قبل ساعة',
    180: 'قبل 3 ساعات',
    1440: 'قبل يوم',
  };
}

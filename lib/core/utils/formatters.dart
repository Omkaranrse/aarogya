import 'package:intl/intl.dart';

class AarogyaFormatters {
  AarogyaFormatters._();

  static String currency(num amount, {String symbol = '₹'}) {
    final formatter = NumberFormat('#,##,###');
    return '$symbol${formatter.format(amount)}';
  }

  static String date(DateTime dateTime) {
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  static String dateWithDay(DateTime dateTime) {
    return DateFormat('EEE, dd MMM yyyy').format(dateTime);
  }

  static String time(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  static String dateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  static String monthYear(DateTime dateTime) {
    return DateFormat('MMMM yyyy').format(dateTime);
  }

  static String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return date(dateTime);
  }
}

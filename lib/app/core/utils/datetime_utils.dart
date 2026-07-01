import 'package:intl/intl.dart';

class DateTimeUtils {
  /// Formats a DateTime into a relative string (e.g. 'Just now', '5 mins ago', 'Today', 'Yesterday')
  /// or a simplified absolute format like 'Oct 12, 2026' if it's older.
  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 15) return 'Just now';
    if (difference.inMinutes < 1) return 'Seconds ago';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) {
      if (difference.inDays == 1) return 'Yesterday';
      return '${difference.inDays}d ago';
    }
    return DateFormat.yMMMd().format(dateTime);
  }

  /// Formats a DateTime into standard readable format with Date and time: 'Oct 12, 2026 • 2:30 PM'
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, yyyy • h:mm a').format(dateTime.toLocal());
  }

  /// Formats a DateTime into absolute short date format: 'Oct 12, 2026'
  static String formatDate(DateTime dateTime) {
    return DateFormat.yMMMd().format(dateTime.toLocal());
  }

  /// Formats a DateTime to a simplified relative date without hours/minutes (e.g. 'Today', 'Yesterday', '3d ago', '12/10')
  static String formatSimpleDate(DateTime dt) {
    final now = DateTime.now();
    
    // Clear time elements for exact day comparison
    final today = DateTime(now.year, now.month, now.day);
    final comparisonDate = DateTime(dt.year, dt.month, dt.day);
    final diffDays = today.difference(comparisonDate).inDays;

    if (diffDays == 0) return 'Today';
    if (diffDays == 1) return 'Yesterday';
    if (diffDays < 7) return '${diffDays}d ago';
    return '${dt.day}/${dt.month}';
  }
}

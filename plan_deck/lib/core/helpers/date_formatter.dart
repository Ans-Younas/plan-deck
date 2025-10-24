import 'package:intl/intl.dart'; // For date formatting

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy, hh:mm a').format(dateTime);
  }
}

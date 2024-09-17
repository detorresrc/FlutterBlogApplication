import 'package:intl/intl.dart';

String formatDate({required dateTime, String format = 'd MMMM yyyy'}) {
  return DateFormat(format).format(dateTime);
}

import 'package:intl/intl.dart';

final _fmt = new NumberFormat("#,##0.00", "en_US");

String amountToDollars(int amount) {
  return "\$" + _fmt.format(amount / 100.0);
}

String formatAmount(int amount) {
  return _fmt.format(amount / 100.0);
}

double amountFromFormat(String text) {
  return _fmt.parse(text).toDouble();
}
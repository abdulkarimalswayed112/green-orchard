import 'package:intl/intl.dart';

double toDouble(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

String money(double v) => 'SAR ${v.toStringAsFixed(2)}';

/// "771e8400-e29b-..." → "#771E"
String shortId(String id) => '#${id.replaceAll('-', '').substring(0, 4).toUpperCase()}';

String niceDate(DateTime? d) =>
    d == null ? '' : DateFormat('d MMM yyyy · h:mm a').format(d.toLocal());

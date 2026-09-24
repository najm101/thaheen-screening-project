import 'package:intl/intl.dart';

/// Digits follow [locale], so `ar_EG` gets Arabic-Indic numerals (١:٠٥).
String formatDuration(Duration duration, String locale) {
  final totalSeconds = duration.isNegative ? 0 : duration.inSeconds;
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  final plain = NumberFormat('0', locale);
  final padded = NumberFormat('00', locale);
  if (hours > 0) return '${plain.format(hours)}:${padded.format(minutes)}:${padded.format(seconds)}';
  return '${plain.format(minutes)}:${padded.format(seconds)}';
}

String formatSpeed(double speed, String locale) => '${NumberFormat('0.##', locale).format(speed)}x';

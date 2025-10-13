// lib/core/utils/formatters.dart
import 'package:intl/intl.dart';

class Formatters {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
  }

  static String formatPercent(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }

  static String formatPlayTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  static String formatAge(int age) {
    return '$age años';
  }

  static String formatDifficulty(int level) {
    switch (level) {
      case 1:
        return 'Fácil';
      case 2:
        return 'Medio';
      case 3:
        return 'Difícil';
      default:
        return 'Personalizado';
    }
  }
}

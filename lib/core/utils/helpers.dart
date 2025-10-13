// lib/core/utils/helpers.dart
import 'package:flutter/material.dart';

class Helpers {
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  static bool isEmailValid(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static String getLearningStyleDescription(String style) {
    switch (style) {
      case 'visual':
        return 'Aprende mejor con imágenes y colores';
      case 'auditivo':
        return 'Aprende mejor con sonidos y música';
      case 'kinestésico':
        return 'Aprende mejor moviéndose y tocando';
      default:
        return 'Estilo de aprendizaje mixto';
    }
  }

  static double calculateProgress(List<bool> completedTasks) {
    if (completedTasks.isEmpty) return 0.0;
    final completedCount = completedTasks.where((task) => task).length;
    return completedCount / completedTasks.length;
  }
}

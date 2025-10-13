// lib/core/utils/validators.dart

class Validators {
  // Validación de email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu correo electrónico';
    }

    // Expresión regular para validar email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
      caseSensitive: false,
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Por favor ingresa un correo electrónico válido';
    }

    return null;
  }

  // Validación de contraseña
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }

    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    // Validar fortaleza de contraseña (opcional)
    if (!_hasMinimumPasswordStrength(value)) {
      return 'La contraseña debe incluir letras y números';
    }

    return null;
  }

  // Validación de confirmación de contraseña
  static String? validateConfirmPassword(
    String? value,
    String originalPassword,
  ) {
    if (value == null || value.isEmpty) {
      return 'Por favor confirma tu contraseña';
    }

    if (value != originalPassword) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  // Validación de nombre
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu nombre';
    }

    if (value.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }

    if (value.length > 50) {
      return 'El nombre es demasiado largo';
    }

    // Validar que solo contenga letras y espacios
    final nameRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'El nombre solo puede contener letras y espacios';
    }

    return null;
  }

  // Validación de nombre del niño
  static String? validateChildName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa el nombre del niño';
    }

    if (value.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }

    if (value.length > 30) {
      return 'El nombre es demasiado largo';
    }

    return null;
  }

  // Validación de edad
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa la edad';
    }

    final age = int.tryParse(value);
    if (age == null) {
      return 'La edad debe ser un número válido';
    }

    if (age < 0) {
      return 'La edad no puede ser negativa';
    }

    if (age > 120) {
      return 'Por favor ingresa una edad válida';
    }

    // Para niños, edades típicas entre 2 y 18 años
    if (age < 2 || age > 18) {
      return 'La edad debe estar entre 2 y 18 años';
    }

    return null;
  }

  // Validación de síndrome/condición
  static String? validateSyndrome(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Opcional
    }

    if (value.length < 2) {
      return 'Por favor ingresa un nombre válido';
    }

    return null;
  }

  // Validación de estilo de aprendizaje
  static String? validateLearningStyle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor selecciona un estilo de aprendizaje';
    }

    final validStyles = ['visual', 'auditory', 'kinesthetic'];
    if (!validStyles.contains(value)) {
      return 'Estilo de aprendizaje no válido';
    }

    return null;
  }

  // Validación de tipo de usuario
  static String? validateUserType(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor selecciona un tipo de usuario';
    }

    final validTypes = ['parent', 'professional'];
    if (!validTypes.contains(value)) {
      return 'Tipo de usuario no válido';
    }

    return null;
  }

  // Validación de dificultad
  static String? validateDifficulty(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor selecciona un nivel de dificultad';
    }

    final validLevels = ['easy', 'medium', 'hard'];
    if (!validLevels.contains(value)) {
      return 'Nivel de dificultad no válido';
    }

    return null;
  }

  // Validación de sensibilidad
  static String? validateSensitivity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa un valor de sensibilidad';
    }

    final sensitivity = double.tryParse(value);
    if (sensitivity == null) {
      return 'La sensibilidad debe ser un número';
    }

    if (sensitivity < 0.0 || sensitivity > 1.0) {
      return 'La sensibilidad debe estar entre 0.0 y 1.0';
    }

    return null;
  }

  // Validación de campos requeridos genérica
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa $fieldName';
    }

    return null;
  }

  // Validación de teléfono
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Opcional
    }

    // Remover espacios, paréntesis, guiones, etc.
    final cleanPhone = value.replaceAll(RegExp(r'[^\d+]'), '');

    if (cleanPhone.length < 8) {
      return 'El número de teléfono es demasiado corto';
    }

    if (cleanPhone.length > 15) {
      return 'El número de teléfono es demasiado largo';
    }

    return null;
  }

  // Validación de URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Opcional
    }

    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Por favor ingresa una URL válida';
    }

    return null;
  }

  // Validación de fecha
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa una fecha';
    }

    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Por favor ingresa una fecha válida (YYYY-MM-DD)';
    }
  }

  // Validación de número positivo
  static String? validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa $fieldName';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return '$fieldName debe ser un número válido';
    }

    if (number < 0) {
      return '$fieldName no puede ser negativo';
    }

    return null;
  }

  // Validación de porcentaje
  static String? validatePercentage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa un porcentaje';
    }

    final percentage = double.tryParse(value);
    if (percentage == null) {
      return 'El porcentaje debe ser un número válido';
    }

    if (percentage < 0 || percentage > 100) {
      return 'El porcentaje debe estar entre 0 y 100';
    }

    return null;
  }

  // Validación de tiempo en minutos
  static String? validateTimeMinutes(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa el tiempo en minutos';
    }

    final minutes = int.tryParse(value);
    if (minutes == null) {
      return 'El tiempo debe ser un número válido';
    }

    if (minutes < 1) {
      return 'El tiempo debe ser al menos 1 minuto';
    }

    if (minutes > 1440) {
      return 'El tiempo no puede ser mayor a 24 horas';
    }

    return null;
  }

  // Validación de rutina - nombre
  static String? validateRoutineName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa un nombre para la rutina';
    }

    if (value.length < 2) {
      return 'El nombre de la rutina debe tener al menos 2 caracteres';
    }

    if (value.length > 50) {
      return 'El nombre de la rutina es demasiado largo';
    }

    return null;
  }

  // Validación de rutina - descripción
  static String? validateRoutineDescription(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Opcional
    }

    if (value.length > 200) {
      return 'La descripción no puede tener más de 200 caracteres';
    }

    return null;
  }

  // Validación de tarea de rutina
  static String? validateTaskName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa un nombre para la tarea';
    }

    if (value.length < 2) {
      return 'El nombre de la tarea debe tener al menos 2 caracteres';
    }

    if (value.length > 50) {
      return 'El nombre de la tarea es demasiado largo';
    }

    return null;
  }

  // Validación de hora
  static String? validateTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa una hora';
    }

    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timeRegex.hasMatch(value)) {
      return 'Por favor ingresa una hora válida (HH:MM)';
    }

    return null;
  }

  // Validación múltiple - ejecuta varias validaciones
  static String? validateMultiple(List<String? Function()> validators) {
    for (final validator in validators) {
      final result = validator();
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  // Helper para validar fortaleza de contraseña
  static bool _hasMinimumPasswordStrength(String password) {
    // Al menos una letra y un número
    final hasLetters = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumbers = RegExp(r'[0-9]').hasMatch(password);

    return hasLetters && hasNumbers;
  }

  // Sanitizar entrada de texto
  static String sanitizeText(String text) {
    // Remover espacios extra al inicio y final
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // Sanitizar email
  static String sanitizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  // Formatear número para mostrar
  static String formatNumber(double number, {int decimals = 2}) {
    return number.toStringAsFixed(decimals);
  }

  // Formatear porcentaje para mostrar
  static String formatPercentage(double percentage, {int decimals = 1}) {
    return '${formatNumber(percentage, decimals: decimals)}%';
  }

  // Formatear tiempo para mostrar
  static String formatTimeMinutes(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours h';
      } else {
        return '$hours h $remainingMinutes min';
      }
    }
  }

  // Validar si un string es numérico
  static bool isNumeric(String? value) {
    if (value == null) return false;
    return double.tryParse(value) != null;
  }

  // Validar si un string es un entero
  static bool isInteger(String? value) {
    if (value == null) return false;
    return int.tryParse(value) != null;
  }
}

// Clase helper para validaciones específicas de KOVA
class KovaValidators {
  // Validación de habilidades (skill levels)
  static String? validateSkillLevel(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa un nivel de habilidad';
    }

    final level = double.tryParse(value);
    if (level == null) {
      return 'El nivel de habilidad debe ser un número';
    }

    if (level < 0.0 || level > 1.0) {
      return 'El nivel de habilidad debe estar entre 0.0 y 1.0';
    }

    return null;
  }

  // Validación de áreas de enfoque
  static String? validateFocusAreas(List<String>? focusAreas) {
    if (focusAreas == null || focusAreas.isEmpty) {
      return 'Por favor selecciona al menos un área de enfoque';
    }

    if (focusAreas.length > 5) {
      return 'No puedes seleccionar más de 5 áreas de enfoque';
    }

    return null;
  }

  // Validación de tipo de feedback
  static String? validateFeedbackType(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor selecciona un tipo de feedback';
    }

    final validTypes = ['visual', 'auditory', 'tactile', 'mixed'];
    if (!validTypes.contains(value)) {
      return 'Tipo de feedback no válido';
    }

    return null;
  }

  // Validación de configuración de accesibilidad
  static String? validateAccessibilitySetting(
    String? value,
    String settingType,
  ) {
    if (value == null || value.isEmpty) {
      return 'Por favor configura $settingType';
    }

    switch (settingType) {
      case 'fontSize':
        final size = double.tryParse(value);
        if (size == null || size < 12.0 || size > 24.0) {
          return 'El tamaño de fuente debe estar entre 12.0 y 24.0';
        }
        break;
      case 'contrast':
        final contrast = double.tryParse(value);
        if (contrast == null || contrast < 1.0 || contrast > 3.0) {
          return 'El contraste debe estar entre 1.0 y 3.0';
        }
        break;
    }

    return null;
  }
}

// Mixin para facilitar validaciones en formularios
mixin ValidationMixin {
  String? validateEmail(String? value) => Validators.validateEmail(value);
  String? validatePassword(String? value) => Validators.validatePassword(value);
  String? validateName(String? value) => Validators.validateName(value);
  String? validateRequired(String? value, String fieldName) =>
      Validators.validateRequired(value, fieldName);
  String? validateAge(String? value) => Validators.validateAge(value);
}

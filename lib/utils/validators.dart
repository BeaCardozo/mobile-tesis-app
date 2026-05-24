/// Validadores reutilizables para formularios.
class Validators {
  /// Regex razonable para email. No es RFC-5322 completo, pero rechaza
  /// la mayoría de entradas inválidas (espacios, dobles @, sin TLD, etc.).
  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  /// Valida un email. Retorna mensaje de error o null si es válido.
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su correo';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Por favor ingrese un correo válido';
    }
    return null;
  }

  /// Política de contraseña para registro / cambio / reset.
  /// Mínimo 8 caracteres, al menos una letra y un número.
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese una contraseña';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
    final hasDigit = RegExp(r'\d').hasMatch(value);
    if (!hasLetter || !hasDigit) {
      return 'Debe incluir al menos una letra y un número';
    }
    return null;
  }

  /// Política relajada para login: solo verifica longitud mínima de 6
  /// para no bloquear cuentas creadas antes de endurecer las reglas.
  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  /// Valida que un campo no esté vacío.
  static String? required(String? value, {String fieldName = 'Este campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }

  /// Valida que [confirmation] coincida con [original].
  static String? matchesPassword(String? confirmation, String original) {
    if (confirmation == null || confirmation.isEmpty) {
      return 'Por favor confirme la contraseña';
    }
    if (confirmation != original) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }
}

class ChatLogic {
  static final Map<RegExp, String> responses = {
    // saludo
    RegExp(r'hola|buenas|hey', caseSensitive: false):
        'Hola 👋 Soy el asistente de PlayZone. ¿En qué puedo ayudarte?',

    // registro
    RegExp(r'registr|crear cuenta', caseSensitive: false):
        'Puedes registrarte desde la pantalla inicial completando tus datos básicos como nombre, correo y contraseña.',

    // login
    RegExp(r'login|iniciar sesi[oó]n', caseSensitive: false):
        'Para iniciar sesión ingresa tu correo y contraseña en la pantalla principal.',

    // buscar
    RegExp(r'buscar|cancha|encontrar', caseSensitive: false):
        'Puedes buscar canchas usando filtros como ubicación, fecha, horario y número de jugadores.',

    // reservar
    RegExp(r'reserv', caseSensitive: false):
        'Selecciona una cancha, elige fecha y hora y presiona "Reservar". Luego continúa con el pago.',

    // pago
    RegExp(r'pago|pagar|mercado pago', caseSensitive: false):
        'El pago se realiza mediante Mercado Pago de forma segura dentro de la app.',

    // precio
    RegExp(r'precio|costo|vale', caseSensitive: false):
        'El precio depende de la cancha, horario y duración. Siempre podrás verlo antes de confirmar.',

    // cancelar
    RegExp(r'cancelar|eliminar reserva', caseSensitive: false):
        'Puedes cancelar tu reserva desde la sección "Mis reservas" en tu perfil.',

    // reservas
    RegExp(r'mis reservas|ver reservas', caseSensitive: false):
        'Puedes ver todas tus reservas activas en la sección "Mis reservas" dentro de tu perfil.',

    // perfil
    RegExp(r'perfil|cuenta', caseSensitive: false):
        'En tu perfil puedes editar tus datos, ver reservas y gestionar tu cuenta.',

    // horarios
    RegExp(r'horario|hora', caseSensitive: false):
        'Cada cancha tiene horarios disponibles que puedes consultar antes de reservar.',

    // ubicación
    RegExp(r'ubicaci[oó]n|donde', caseSensitive: false):
        'Puedes ver la ubicación de cada cancha en el mapa dentro de la app.',

    // disponibilidad
    RegExp(r'disponible|disponibilidad', caseSensitive: false):
        'La disponibilidad depende del horario seleccionado. Puedes verificarlo antes de reservar.',

    // contacto
    RegExp(r'contacto|soporte|ayuda', caseSensitive: false):
        'Si necesitas ayuda adicional puedes contactar soporte desde la app o escribirnos directamente.',

    // app
    RegExp(r'que hace|para que sirve', caseSensitive: false):
        'PlayZone te permite buscar, reservar y pagar canchas deportivas de forma rápida y sencilla.',

    // fallback
  };

  static String getResponse(String text) {
    for (final entry in responses.entries) {
      if (entry.key.hasMatch(text)) {
        return entry.value;
      }
    }

    return 'No entendí tu pregunta 🤔. Puedes intentar con cosas como "reservar cancha", "cómo pagar" o "buscar cancha".';
  }
}
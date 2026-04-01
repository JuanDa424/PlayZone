class ChatLogic {
  static final Map<RegExp, String> responses = {
    // ───────────── SALUDOS ─────────────
    RegExp(r'hola|buenas|hey|holi|que mas|qué más', caseSensitive: false):
        'Hola 👋 Soy el asistente de PlayZone. ¿En qué puedo ayudarte?',

    RegExp(r'gracias|muchas gracias', caseSensitive: false):
        '¡Con gusto! 😊 Si necesitas algo más aquí estoy.',

    // ───────────── REGISTRO / LOGIN ─────────────
    RegExp(
      r'registr|crear cuenta',
      caseSensitive: false,
    ): 'Puedes registrarte desde la pantalla inicial completando tus datos y confirmando tu correo con un código.',

    RegExp(
      r'login|iniciar sesi[oó]n|entrar',
      caseSensitive: false,
    ): 'Ingresa tu correo y contraseña en la pantalla principal para iniciar sesión.',

    RegExp(
      r'no puedo entrar|error login|no inicia',
      caseSensitive: false,
    ): 'Verifica tu correo y contraseña. Si olvidaste tu clave, usa la opción de recuperación.',

    RegExp(
      r'olvid[eé] mi contrase',
      caseSensitive: false,
    ): 'Puedes recuperar tu contraseña desde la opción "¿Olvidaste tu contraseña?" en el login.',

    // ───────────── APP / FUNCIONALIDAD ─────────────
    RegExp(
      r'que hace|para que sirve|que es playzone',
      caseSensitive: false,
    ): 'PlayZone te permite buscar, reservar y pagar canchas deportivas de forma rápida y segura.',

    RegExp(
      r'como funciona',
      caseSensitive: false,
    ): 'Buscas una cancha, eliges horario, reservas y pagas. Todo desde la app.',

    // ───────────── CANCHAS ─────────────
    RegExp(r'buscar|cancha|encontrar', caseSensitive: false):
        'Puedes buscar canchas desde la pantalla principal o sección "Inicio".',

    RegExp(
      r'ubicaci[oó]n|donde queda',
      caseSensitive: false,
    ): 'Cada cancha tiene su ubicación disponible en el mapa dentro de la app.',

    RegExp(r'horario|hora disponible', caseSensitive: false):
        'Puedes ver los horarios disponibles antes de reservar cada cancha.',

    RegExp(
      r'disponible|disponibilidad',
      caseSensitive: false,
    ): 'La disponibilidad depende del horario seleccionado y reservas existentes.',

    // ───────────── RESERVAS ─────────────
    RegExp(r'reserv', caseSensitive: false):
        'Selecciona una cancha, elige fecha y hora y presiona "Reservar".',

    RegExp(r'mis reservas|ver reservas', caseSensitive: false):
        'Puedes ver tus reservas en la sección "Reservas" de tu perfil.',

    RegExp(r'no veo mi reserva', caseSensitive: false):
        'Actualiza la pantalla o verifica el estado del pago.',

    // ───────────── CANCELACIÓN (POLÍTICAS) ─────────────
    RegExp(
      r'cancelar|eliminar reserva',
      caseSensitive: false,
    ): 'Puedes cancelar tu reserva desde "Reservas". Solo se permite cancelar hasta el día anterior. No se puede cancelar el mismo día.',

    RegExp(
      r'cancelar mismo dia|cancelar hoy',
      caseSensitive: false,
    ): 'No es posible cancelar reservas el mismo día por políticas de la aplicación.',

    // ───────────── PAGOS ─────────────
    RegExp(r'pago|pagar|mercado pago', caseSensitive: false):
        'Puedes pagar con Mercado Pago o en efectivo según disponibilidad.',

    RegExp(r'fallo pago|error pago|rechazado', caseSensitive: false):
        'El pago fue rechazado. Intenta nuevamente o usa otro método.',

    RegExp(
      r'efectivo',
      caseSensitive: false,
    ): 'El pago en efectivo requiere compromiso. Si no asistes, tu cuenta puede ser suspendida.',

    RegExp(
      r'politica efectivo|no asistir|no voy',
      caseSensitive: false,
    ): 'Si reservas en efectivo y no asistes, tu cuenta será suspendida temporalmente. Reincidir puede causar bloqueo permanente.',

    // ───────────── PRECIOS ─────────────
    RegExp(
      r'precio|costo|vale|cuanto cuesta',
      caseSensitive: false,
    ): 'El precio depende de la cancha y horario. Siempre lo verás antes de confirmar.',

    RegExp(r'porque cambia precio', caseSensitive: false):
        'Los precios pueden variar según horario (ej: horas pico vs valle).',

    // ───────────── PERFIL ─────────────
    RegExp(r'perfil|cuenta', caseSensitive: false):
        'En tu perfil puedes ver reservas, editar datos y gestionar tu cuenta.',

    RegExp(r'editar datos|cambiar datos', caseSensitive: false):
        'Puedes modificar tu información desde la sección perfil.',

    // ───────────── ERRORES / SOPORTE ─────────────
    RegExp(r'error|problema|no funciona', caseSensitive: false):
        'Ocurrió un problema. Intenta nuevamente o revisa tu conexión.',

    RegExp(
      r'no carga|app lenta',
      caseSensitive: false,
    ): 'Puede ser un problema de conexión. Intenta recargar o revisar tu internet.',

    RegExp(r'soporte|ayuda|contacto', caseSensitive: false):
        'Puedes contactar soporte al correo playzone@gmail.com.',

    // ───────────── ADMIN / NEGOCIO ─────────────
    RegExp(
      r'crear cancha|registrar cancha',
      caseSensitive: false,
    ): 'Los administradores pueden registrar canchas desde el panel de administración.',

    RegExp(r'reporte|estadistica|ganancias', caseSensitive: false):
        'Puedes ver reportes desde el panel administrativo de cada cancha.',

    // ───────────── SEGURIDAD ─────────────
    RegExp(r'datos seguros|seguridad', caseSensitive: false):
        'Tus datos y pagos están protegidos mediante protocolos seguros.',

    // ───────────── DESPEDIDA ─────────────
    RegExp(r'adios|chao|nos vemos', caseSensitive: false):
        '¡Hasta luego! 👋 Que disfrutes PlayZone.',
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

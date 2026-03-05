import 'package:flutter/material.dart';

/// Un "bot" de ayuda que vive 100% en el frontend y responde con
/// mensajes predefinidos. No hace ninguna petición al backend.
class HelpBotWidget extends StatefulWidget {
  const HelpBotWidget({Key? key}) : super(key: key);

  @override
  State<HelpBotWidget> createState() => _HelpBotWidgetState();
}

class _HelpBotWidgetState extends State<HelpBotWidget> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();

  // preguntas sugeridas que el usuario puede tocar para enviarlas
  static const List<String> _suggested = [
    '¿Cómo me registro?',
    'Buscar cancha',
    '¿Cómo reservo?',
    '¿Cómo pago?',
    '¿Qué hace esta app?'
  ];

  // Map de patrones a respuestas. Puedes ampliar con más casos.
  static final Map<RegExp, String> _staticResponses = {
    RegExp(r'registr', caseSensitive: false):
        'Para registrarte ve a la sección "Crear cuenta" y completa el formulario con tus datos (nombre, correo, contraseña, teléfono). Luego pulsa "Registrarse".',
    RegExp(r'login|iniciar sesi[oó]n', caseSensitive: false):
        'En la pantalla de inicio de sesión escribe tu correo y contraseña y toca "Iniciar sesión". Si olvidaste tu contraseña, usa el enlace de recuperación.',
    RegExp(r'cancha|buscar', caseSensitive: false):
        'Puedes buscar canchas en la pestaña "Inicio" escribiendo el nombre o zona en la barra de búsqueda, o explorarlas en el mapa. También puedes filtrar por deporte o disponibilidad.',
    RegExp(r'reservar', caseSensitive: false):
        'Para reservar selecciona una cancha en la lista o en el mapa, toca "Seleccionar fecha y hora", elige los datos y confirma. Luego sigue al pago.',
    RegExp(r'pag', caseSensitive: false):
        'El pago se realiza con Mercado Pago. Una vez elijas fecha y hora de la reserva, aparecerá el botón de pago que te llevará al portal seguro.',
    RegExp(r'perfil', caseSensitive: false):
        'En la pestaña "Perfil" puedes ver y editar tu información, además de ver tus reservas activas.',
    RegExp(r'ayuda|hola', caseSensitive: false):
        '¡Hola! Soy el asistente de ayuda de PlayZone. Pregúntame cómo registrarte, iniciar sesión, buscar canchas, reservar o pagar.',
  };

  String _getResponse(String userText) {
    for (final entry in _staticResponses.entries) {
      if (entry.key.hasMatch(userText)) {
        return entry.value;
      }
    }
    return
        'Perdón, no entendí tu pregunta. Intenta con frases como "¿cómo me registro?", "buscar cancha" o "reservar".';
  }

  @override
  void initState() {
    super.initState();
    _messages.add({
      'from': 'bot',
      'text':
          'Hola, soy el asistente de ayuda de PlayZone. Puedes elegir una pregunta de abajo o escribir la tuya.'
    });
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'from': 'user', 'text': text});
      _controller.clear();
    });
    final reply = _getResponse(text);
    // Simulamos un pequeño retraso para que parezca más natural
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _messages.add({'from': 'bot', 'text': reply});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: const [
                Icon(Icons.help_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text('Asistente de ayuda',
                    style: TextStyle(fontWeight: FontWeight.bold))
              ],
            ),
          ),
          const Divider(height: 1),
          // pedimos al usuario seleccionar sugerencias sólo si no ha enviado preguntas
          if (_messages.length <= 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Wrap(
                spacing: 8,
                children: _suggested.map((q) {
                  return ActionChip(
                    label:
                        Text(q, style: const TextStyle(color: Colors.white)),
                    backgroundColor: Colors.blue,
                    onPressed: () {
                      _controller.text = q;
                      _send();
                    },
                  );
                }).toList(),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                final isUser = m['from'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(m['text'] ?? ''),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                        const InputDecoration(hintText: 'Escribe tu pregunta...'),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _send,
                  child: const Text('Enviar'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

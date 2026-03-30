import 'package:flutter/material.dart'; 

// IMPORTA TUS COLORES AQUÍ
import '../util/constants.dart';
import '../util/chat_logic.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;

  final List<String> _suggested = [
    '¿Cómo reservar?',
    'Buscar cancha',
    '¿Cómo pagar?',
    'Ver reservas',
    'Cancelar reserva'
  ];

  @override
  void initState() {
    super.initState();

    _messages.add({
      'from': 'bot',
      'text':
          'Hola 👋 Soy el asistente de PlayZone.\nPuedes tocar una opción o escribir tu pregunta.'
    });
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'from': 'user', 'text': text});
      _controller.clear();
      _loading = true;
    });

    final reply = ChatLogic.getResponse(text);

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _messages.add({'from': 'bot', 'text': reply});
        _loading = false;
      });
    });
  }

  Widget _buildMessage(Map<String, String> m) {
    final isUser = m['from'] == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: isUser ? kGreenGlow : null,
          color: isUser ? null : kCardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: isUser ? kGreenShadow : kCardShadow,
          border: Border.all(color: kBorderColor),
        ),
        child: Text(
          m['text'] ?? '',
          style: TextStyle(
            color: isUser ? kCarbonBlack : kWhite,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: kBgGradient),
      child: Column(
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kSurfaceColor,
              border: Border(bottom: BorderSide(color: kBorderColor)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: kGreenGlow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.smart_toy, color: Colors.black),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Asistente PlayZone',
                  style: TextStyle(
                    color: kWhite,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),

          // SUGERENCIAS
          if (_messages.length <= 1)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                children: _suggested.map((q) {
                  return ActionChip(
                    label: Text(q, style: const TextStyle(color: kWhite)),
                    backgroundColor: kDarkGray,
                    side: BorderSide(color: kBorderColor),
                    onPressed: () {
                      _controller.text = q;
                      _send();
                    },
                  );
                }).toList(),
              ),
            ),

          // MENSAJES
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _buildMessage(_messages[i]),
            ),
          ),

          // LOADING
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: LinearProgressIndicator(),
            ),

          // INPUT
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kSurfaceColor,
              border: Border(top: BorderSide(color: kBorderColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: kWhite),
                    decoration: InputDecoration(
                      hintText: 'Escribe tu mensaje...',
                      hintStyle: TextStyle(color: kLightGray),
                      filled: true,
                      fillColor: kDarkGray,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: kGreenGlow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.black),
                    onPressed: _send,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
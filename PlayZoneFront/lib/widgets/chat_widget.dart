import 'package:flutter/material.dart';
import '../services/chat_service.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final List<Map<String, String>> _messages = [];
  Map<String, dynamic>? _conversationState;
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  bool _initialized = false;

  // predefined questions shown as buttons for quick access
  static const List<String> _suggestedQuestions = [
    '¿Cómo puedo buscar canchas?',
    '¿Cómo reservo?',
    '¿Cómo pago?',
    '¿Qué hace esta app?'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        // welcome message explaining how to use the assistant
        _messages.add({
          'from': 'bot',
          'text':
              'Hola, soy el asistente de PlayZone. Puedo responder preguntas sobre cómo usar la aplicación. "Toca" una de las sugerencias o escribe tu pregunta.'
        });
        _initialized = true;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'from': 'user', 'text': text});
      _controller.clear();
      _loading = true;
    });
    try {
      final resp = await ChatService.sendMessage(text, _conversationState);
      final botMessage = resp['message'] ?? 'No hay respuesta';
      setState(() {
        _messages.add({'from': 'bot', 'text': botMessage.toString()});
        _conversationState = resp['conversation_state'] ?? _conversationState;
      });
    } catch (e) {
      setState(() {
        _messages.add({'from': 'bot', 'text': 'Error de chat: $e'});
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.green[50],
            border: Border(
              bottom: BorderSide(color: Colors.green[200]!, width: 1),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.chat_bubble, color: Colors.green[700]),
              const SizedBox(width: 8),
              Text(
                'Asistente PlayZone',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        // Suggestion chips
        if (_messages.length <= 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggestedQuestions.map((q) {
                return ActionChip(
                  label: Text(
                    q,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.green[700],
                  onPressed: () {
                    _controller.text = q;
                    _send();
                  },
                );
              }).toList(),
            ),
          ),
        // Messages list
        Expanded(
          child: _messages.isEmpty
              ? const Center(
                  child: Text('Iniciando chat...'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final m = _messages[index];
                   final isUser = m['from'] == 'user';
                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(
                          maxWidth:
                              MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Colors.green[100]
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          m['text'] ?? '',
                          style: TextStyle(
                            color: isUser ? Colors.green[900] : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        // Loading indicator
        if (_loading)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const LinearProgressIndicator(),
          ),
        // Input area
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Escribe tu mensaje...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  enabled: !_loading,
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _loading ? null : _send,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Enviar',
                        style: TextStyle(color: Colors.white),
                      ),
              )
            ],
          ),
        )
      ],
    );
  }
}

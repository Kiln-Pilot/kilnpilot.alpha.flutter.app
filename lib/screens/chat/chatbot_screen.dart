import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../blocs/chatbot/chatbot_session_bloc.dart';
import '../../blocs/chatbot/chatbot_bloc.dart';
import '../../repositories/cement_operations/serializers/cement_query_request.dart';
import '../../repositories/cement_operations/serializers/user_sessions_response.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _sessionId;
  String? _userId = 'user_12345';
  final List<Map<String, String>> _messages = [];
  bool _showSessionSelector = false;
  List<SessionInfo> _userSessions = [];
  bool _initialSessionFetched = false;

  @override
  void initState() {
    super.initState();
    context.read<ChatbotSessionBloc>().add(ChatbotGetUserSessionsEvent(_userId!));
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || _sessionId == null) return;
    context.read<ChatbotBloc>().add(
      ChatbotQueryEvent(CementQueryRequest(query: text, sessionId: _sessionId, userId: _userId)),
    );
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _controller.clear();
    });
  }

  void _onSessionSelected(SessionInfo session) {
    setState(() {
      _sessionId = session.sessionId;
      _userId = session.userId;
      _showSessionSelector = false;
      _messages.clear();
    });
    context.read<ChatbotSessionBloc>().add(ChatbotGetChatHistoryEvent(sessionId: _sessionId!, userId: _userId!));
  }

  void _onCreateSession() {
    context.read<ChatbotSessionBloc>().add(ChatbotCreateSessionEvent(userId: _userId));
  }

  Widget _buildSessionSelector() {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text('Select or Create Session', style: GoogleFonts.poppins()),
      content: SizedBox(
        width: 500,
        child: _userSessions.isEmpty
            ? const Text('No sessions found. Create a new session?')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ..._userSessions.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final session = entry.value;
                    final createdAt = DateTime.tryParse(session.createdAt);
                    final formattedDate = createdAt != null
                        ? '${createdAt.month}/${createdAt.day}/${createdAt.year} ${createdAt.hour % 12}:${createdAt.minute.toString().padLeft(2, '0')} ${createdAt.hour >= 12 ? 'PM' : 'AM'}'
                        : session.createdAt;
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.all(8),
                        child: Center(
                          child: Text(
                            '$idx',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      title: Text('Chat Session ID: ${session.sessionId}'),
                      subtitle: Text('Created: $formattedDate'),
                      onTap: () => _onSessionSelected(session),
                    );
                  }),
                ],
              ),
      ),
      actions: [
        SizedBox(
          height: 40,
          child: FilledButton.icon(
            icon: Icon(Icons.add, color: Colors.grey.shade800),
            label:  Text('Create New Session', style: GoogleFonts.poppins(color: Colors.grey.shade800, fontWeight: FontWeight.w600)),
            onPressed: _onCreateSession,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            // child: const Text('Create New Session'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ChatbotSessionBloc, ChatbotSessionState>(
          listener: (context, state) {
            if (state is ChatbotUserSessionsSuccess && !_initialSessionFetched) {
              _initialSessionFetched = true;
              _userSessions = state.response.sessions;
              if (_userSessions.isEmpty) {
                _onCreateSession();
              } else {
                setState(() => _showSessionSelector = true);
              }
            } else if (state is ChatbotSessionSuccess && state.response.sessionInfo != null) {
              setState(() {
                _sessionId = state.response.sessionInfo!.sessionId;
                _userId = state.response.sessionInfo!.userId;
                _showSessionSelector = false;
                _messages.clear();
              });
            } else if (state is ChatbotChatHistorySuccess) {
              setState(() {
                _messages.clear();
                for (final msg in state.response.messages) {
                  _messages.add({'role': msg.role, 'content': msg.message});
                }
              });
            } else if (state is ChatbotUserSessionsSuccess && _showSessionSelector) {
              setState(() {
                _userSessions = state.response.sessions;
              });
            }
          },
        ),
        BlocListener<ChatbotBloc, ChatbotState>(
          listener: (context, state) {
            if (state is ChatbotQuerySuccess) {
              setState(() {
                _sessionId = state.response.sessionId;
                _userId = state.response.userId;
                _messages.add({'role': 'bot', 'content': state.response.finalAnswer ?? 'No answer'});
              });
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cement Operations Chatbot'),
          actions: [
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              tooltip: 'Change Session',
              onPressed: () {
                context.read<ChatbotSessionBloc>().add(ChatbotGetUserSessionsEvent(_userId ?? 'user_12345'));
                setState(() => _showSessionSelector = true);
              },
            ),
            IconButton(icon: const Icon(Icons.add), tooltip: 'Create New Session', onPressed: _onCreateSession),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                if (_sessionId != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Session: $_sessionId', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, idx) {
                      final msg = _messages[idx];
                      final isUser = msg['role'] == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blue[100] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(msg['content'] ?? '', style: TextStyle(color: Colors.black)),
                        ),
                      );
                    },
                  ),
                ),
                BlocBuilder<ChatbotSessionBloc, ChatbotSessionState>(
                  builder: (context, state) {
                    if (state is ChatbotSessionLoading) {
                      return const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator());
                    } else if (state is ChatbotSessionError) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                BlocBuilder<ChatbotBloc, ChatbotState>(
                  builder: (context, state) {
                    if (state is ChatbotLoading) {
                      return const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator());
                    } else if (state is ChatbotError) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Error: ${state.message}', style: TextStyle(color: Colors.red)),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: const InputDecoration(hintText: 'Ask about cement operations...'),
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
                    ],
                  ),
                ),
              ],
            ),
            if (_showSessionSelector)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(child: _buildSessionSelector()),
              ),
          ],
        ),
      ),
    );
  }
}

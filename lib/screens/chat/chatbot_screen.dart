import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
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
  List<SessionInfo> _userSessions = [];
  bool _initialSessionFetched = false;
  // Added: track whether the session selector dialog is currently open
  bool _isSessionDialogOpen = false;
  // When true, after sessions are refreshed we should re-open the selector dialog
  bool _shouldReopenSessionDialogAfterRefresh = false;

  Future<void> _confirmAndCreateSession() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Create New Session?', style: GoogleFonts.poppins()),
        content: const Text('Are you sure you want to create a new chat session?'),
        actions: [
          SizedBox(
            height: 40,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey.shade800, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: FilledButton.icon(
              icon: Icon(Icons.add, color: Colors.grey.shade800),
              label: Text(
                'Create',
                style: GoogleFonts.poppins(color: Colors.grey.shade800, fontWeight: FontWeight.w600),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              // child: const Text('Create'),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      context.read<ChatbotSessionBloc>().add(ChatbotCreateSessionEvent(userId: _userId));
    }
  }

  Future<void> _showSessionSelectorDialog() async {
    _isSessionDialogOpen = true;
    // Capture the ChatbotSessionBloc and the scaffold messenger from the parent context
    final ChatbotSessionBloc sessionBloc = context.read<ChatbotSessionBloc>();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final selected = await showDialog<SessionInfo>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shadowColor: Colors.black,
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
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Center(
                              child: Text(
                                '$idx',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          title: Text('Chat Session ID: ${session.sessionId}'),
                          subtitle: Text('Created: $formattedDate'),
                          // Added: delete button in front (trailing) of each session
                          trailing: SizedBox(
                            height: 40,
                            width: 40,
                            child: FilledButton(
                              onPressed: () async {
                                // Confirm deletion
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => AlertDialog(
                                    title: Text('Delete Session', style: GoogleFonts.poppins()),
                                    content: Text('Delete session ${session.sessionId}?', style: GoogleFonts.poppins()),
                                    actions: [
                                      FilledButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: Text('Cancel', style: GoogleFonts.poppins()),
                                      ),
                                      FilledButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                        child: Text('Delete', style: GoogleFonts.poppins()),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  if (_userId != null) {
                                    // Use the captured bloc and messenger to avoid lookup on the dialog's context
                                    sessionBloc.add(ChatbotDeleteSessionEvent(userId: _userId!, sessionId: session.sessionId));
                                    messenger.showSnackBar(SnackBar(content: Text('Deleting session ${session.sessionId}...')));
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade200,
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Icon(Icons.delete, color: Colors.redAccent, size: 20),
                            ),
                          ),
                          onTap: () => Navigator.of(context).pop(session),
                        );
                      }),
                    ],
                  ),
          ),
          actions: [
            if (_sessionId != null)
              SizedBox(
                height: 40,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'Close',
                    style: GoogleFonts.poppins(color: Colors.grey.shade800, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            SizedBox(
              height: 40,
              child: FilledButton.icon(
                icon: Icon(Icons.add, color: Colors.grey.shade800),
                label: Text(
                  'Create New Session',
                  style: GoogleFonts.poppins(color: Colors.grey.shade800, fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _confirmAndCreateSession();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        );
      },
    );
    _isSessionDialogOpen = false;
    if (selected != null) {
      _onSessionSelected(selected);
    }
  }

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
      _messages.clear();
    });
    context.read<ChatbotSessionBloc>().add(ChatbotGetChatHistoryEvent(sessionId: _sessionId!, userId: _userId!));
  }

  void _onCreateSession() {
    _confirmAndCreateSession();
  }

  // Retry opening the session selector until the previous dialog is closed.
  // Attempts limited to avoid infinite loops.
  void _retryReopenSessionDialog({int attempts = 6, int delayMs = 150}) {
    if (attempts <= 0) return;
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (!mounted) return;
      if (!_isSessionDialogOpen) {
        _showSessionSelectorDialog();
      } else {
        _retryReopenSessionDialog(attempts: attempts - 1, delayMs: delayMs);
      }
    });
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
                _showSessionSelectorDialog();
              }
            } else if (state is ChatbotSessionSuccess && state.response.sessionInfo != null) {
              setState(() {
                _sessionId = state.response.sessionInfo!.sessionId;
                _userId = state.response.sessionInfo!.userId;
                _messages.clear();
              });
            } else if (state is ChatbotChatHistorySuccess) {
              setState(() {
                _messages.clear();
                for (final msg in state.response.messages) {
                  _messages.add({'role': msg.role, 'content': msg.message});
                }
              });
            } else if (state is ChatbotUserSessionsSuccess) {
              // Regular refresh of user sessions. Update list and, if requested, reopen selector dialog.
              setState(() {
                _userSessions = state.response.sessions;
              });
              if (_shouldReopenSessionDialogAfterRefresh) {
                _shouldReopenSessionDialogAfterRefresh = false;
                // Retry reopening the dialog a few times until the previous dialog is closed
                _retryReopenSessionDialog(attempts: 6, delayMs: 150);
              }
            } else if (state is ChatbotDeleteSessionSuccess) {
              // On successful deletion: refresh sessions and close the session selector dialog if open
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Session ${state.sessionId} deleted')));
              // Refresh the sessions list
              if (_userId != null) {
                // Mark that we want to re-open the selector after sessions refresh
                _shouldReopenSessionDialogAfterRefresh = true;
                context.read<ChatbotSessionBloc>().add(ChatbotGetUserSessionsEvent(_userId!));
              }
              // Close the dialog if it is open
              if (_isSessionDialogOpen) {
                Navigator.of(context, rootNavigator: true).pop();
                _isSessionDialogOpen = false;
                // The dialog will be re-opened once the refreshed sessions arrive (see handler above)
              }
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
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Chat', style: GoogleFonts.poppins(fontSize: 54, fontWeight: FontWeight.w400)),
                  ),
                  Spacer(),
                  SizedBox(
                    height: 50,
                    width: 230,
                    child: FilledButton.icon(
                      label: Text('Change Session', style: GoogleFonts.poppins(color: Colors.black, fontSize: 18)),
                      icon: const Icon(Icons.swap_horiz, size: 22),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      onPressed: () {
                        context.read<ChatbotSessionBloc>().add(ChatbotGetUserSessionsEvent(_userId ?? 'user_12345'));
                        _showSessionSelectorDialog();
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  SizedBox(
                    height: 50,
                    width: 230,
                    child: FilledButton.icon(
                      label: Text('New Session', style: GoogleFonts.poppins(color: Colors.black, fontSize: 18)),
                      icon: const Icon(Icons.add, size: 22),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      onPressed: _onCreateSession,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  padding: const EdgeInsets.all(20),
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
                        child: GptMarkdown(msg['content'] ?? '', style: GoogleFonts.jost(fontSize: 18)),
                      ),
                    );
                  },
                ),
              ),
              Center(
                child: BlocBuilder<ChatbotSessionBloc, ChatbotSessionState>(
                  builder: (context, state) {
                    if (state is ChatbotSessionLoading) {
                      return CircularProgressIndicator();
                    } else if (state is ChatbotSessionError) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
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
                        style: GoogleFonts.jost(fontSize: 22),
                        controller: _controller,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          hintText: 'Ask about cement operations...',
                          hintStyle: GoogleFonts.jost(fontSize: 22, color: Colors.grey.shade600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 21, vertical: 23),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendMessage,
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(24),
                        backgroundColor: Colors.grey.shade700,
                        foregroundColor: Colors.white,
                        shape: CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

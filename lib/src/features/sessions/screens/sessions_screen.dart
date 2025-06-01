import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:study/src/features/sessions/providers/session_provider.dart';
import 'package:study/src/features/sessions/widgets/session_list_item.dart';

/// Placeholder screen for Sessions.
class SessionsScreen extends StatelessWidget {
  /// Creates a [SessionsScreen] widget.
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sessions')),
      body: Consumer<SessionProvider>(
        builder: (context, provider, _) {
          return FutureBuilder(
            future: provider.fetchSessions(),
            builder: (context, snapshot) {
              if (provider.sessions.isEmpty) {
                return const Center(
                  child: Text(
                    'No sessions recorded yet.',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }
              return ListView.builder(
                itemCount: provider.sessions.length,
                itemBuilder:
                    (context, index) =>
                        SessionListItem(session: provider.sessions[index]),
              );
            },
          );
        },
      ),
    );
  }
}

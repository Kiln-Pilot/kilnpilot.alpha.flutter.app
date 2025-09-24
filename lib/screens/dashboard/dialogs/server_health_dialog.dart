import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/server_health/server_health_bloc.dart';

class ServerHealthDialog extends StatelessWidget {
  const ServerHealthDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServerHealthBloc, ServerHealthState>(
      builder: (ctx, state) {
        if (state is ServerHealthLoading) {
          return AlertDialog(
            title: Text('Server Health'),
            content: SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
          );
        } else if (state is ServerHealthSuccess) {
          final details = state.data;
          return AlertDialog(
            title: Text('Server Health Details'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status: ${details['status']}'),
                  Text('Version: ${details['version']}'),
                  Text('Uptime: ${details['uptime']?.toStringAsFixed(0)}s'),
                  if (details['details'] != null)
                    ...details['details'].entries.map((e) => Text('${e.key}: ${e.value}')).toList(),
                  if (details['system_info'] != null)
                    ...details['system_info'].entries.map((e) => Text('${e.key}: ${e.value}')).toList(),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('Close')),
            ],
          );
        } else if (state is ServerHealthError) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(state.message),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('Close')),
            ],
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}


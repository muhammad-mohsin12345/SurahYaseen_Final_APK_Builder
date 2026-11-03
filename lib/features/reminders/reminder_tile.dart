import 'package:flutter/material.dart';

import '../../core/constants/strings.dart';
import '../../core/services/notification_service.dart';
import '../../data/local/app_state.dart';
import '../../shared/widgets/watch.dart';

/// Switch + time picker for the daily reading reminder.
class ReminderTile extends StatelessWidget {
  const ReminderTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch(builder: _content);
  }

  Widget _content(BuildContext context) {
    final s = AppState.I.s;
    final time = TimeOfDay(hour: s.hour, minute: s.minute);
    return Column(
      children: [
        SwitchListTile(
          title: Text(tr('reminder')),
          secondary: const Icon(Icons.notifications_active_outlined),
          value: s.reminderOn,
          onChanged: (v) async {
            if (v) {
              final ok = await NotificationService.I.requestPermission();
              if (!ok) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification permission denied')),
                  );
                }
                return;
              }
              AppState.I.update((x) => x.reminderOn = true);
              await NotificationService.I.schedule();
            } else {
              AppState.I.update((x) => x.reminderOn = false);
              await NotificationService.I.cancel();
            }
          },
        ),
        ListTile(
          enabled: s.reminderOn,
          leading: const Icon(Icons.schedule_rounded),
          title: Text(tr('reminderTime')),
          trailing: Text(time.format(context), style: const TextStyle(fontWeight: FontWeight.w700)),
          onTap: !s.reminderOn
              ? null
              : () async {
                  final t = await showTimePicker(context: context, initialTime: time);
                  if (t != null) {
                    AppState.I.update((x) {
                      x.hour = t.hour;
                      x.minute = t.minute;
                    });
                    await NotificationService.I.schedule();
                  }
                },
        ),
      ],
    );
  }
}

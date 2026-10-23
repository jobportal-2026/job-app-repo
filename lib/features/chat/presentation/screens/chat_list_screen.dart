import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class ChatThreadItem {
  final String id;
  final String name;
  final String role;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;

  const ChatThreadItem({
    required this.id,
    required this.name,
    required this.role,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.isOnline = false,
  });
}

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final threads = [
      const ChatThreadItem(
        id: '1',
        name: 'Blue Tokai Coffee Roasters',
        role: 'Employer',
        lastMessage: 'Understood, will be there right on time. Thank you!',
        time: '10:45 AM',
        unreadCount: 0,
        isOnline: true,
      ),
      const ChatThreadItem(
        id: '2',
        name: 'Hasura Events Team',
        role: 'Employer',
        lastMessage: 'Please confirm your slot for the tech conference.',
        time: 'Yesterday',
        unreadCount: 2,
        isOnline: true,
      ),
      const ChatThreadItem(
        id: '3',
        name: 'Priya Sharma (Senior Barista)',
        role: 'Candidate / Student',
        lastMessage: 'I have attached my certification and references.',
        time: 'Oct 07',
        unreadCount: 0,
        isOnline: false,
      ),
      const ChatThreadItem(
        id: '4',
        name: 'Rahul Verma (Event Staff)',
        role: 'Candidate / Student',
        lastMessage: 'Looking forward to working with you!',
        time: 'Oct 05',
        unreadCount: 0,
        isOnline: false,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages & Chats'),
      ),
      body: ListView.separated(
        itemCount: threads.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.cardBorder, indent: 72),
        itemBuilder: (context, index) {
          final thread = threads[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    thread.name.isNotEmpty ? thread.name[0] : 'U',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18),
                  ),
                ),
                if (thread.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    thread.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  thread.time,
                  style: TextStyle(
                    fontSize: 12,
                    color: thread.unreadCount > 0 ? AppColors.primary : AppColors.textMuted,
                    fontWeight: thread.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            subtitle: Row(
              children: [
                Expanded(
                  child: Text(
                    thread.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: thread.unreadCount > 0 ? AppColors.textPrimary : AppColors.textSecondary,
                      fontWeight: thread.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (thread.unreadCount > 0)
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${thread.unreadCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            onTap: () {
              context.push('/chat?name=${Uri.encodeComponent(thread.name)}&role=${Uri.encodeComponent(thread.role)}');
            },
          );
        },
      ),
    );
  }
}

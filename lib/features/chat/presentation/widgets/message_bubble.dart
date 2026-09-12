import 'package:flutter/material.dart';

import '../../domain/entities/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  String _formatTime(DateTime date) {
    final hour =
    date.hour.toString().padLeft(2, '0');

    final minute =
    date.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final blue = const Color(0xFF1468F5);

    return Align(
      alignment: isMe
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth:
          MediaQuery.of(context).size.width * .76,
        ),
        margin: EdgeInsets.only(
          left: isMe ? 60 : 16,
          right: isMe ? 16 : 60,
          top: 4,
          bottom: 4,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? blue
              : const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.only(
            topLeft:
            const Radius.circular(18),
            topRight:
            const Radius.circular(18),
            bottomLeft:
            Radius.circular(isMe ? 18 : 5),
            bottomRight:
            Radius.circular(isMe ? 5 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [

            Text(
              message.text,
              style: TextStyle(
                color: isMe
                    ? Colors.white
                    : const Color(0xFF173E7A),
                fontSize: 15.5,
                height: 1.35,
              ),
            ),

            const SizedBox(height: 4),

            Row(
              mainAxisSize:
              MainAxisSize.min,
              children: [

                Text(
                  _formatTime(
                    message.timestamp,
                  ),
                  style: TextStyle(
                    color: isMe
                        ? Colors.white70
                        : const Color(0xFF7893BA),
                    fontSize: 10.5,
                  ),
                ),

                if (isMe) ...[
                  const SizedBox(width: 4),

                  Icon(
                    message.isRead
                        ? Icons.done_all
                        : Icons.done,
                    size: 15,
                    color: Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
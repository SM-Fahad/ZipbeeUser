import 'package:ZipBee/core/utils/constants/app_colors.dart';
import 'package:ZipBee/features/user/chat/models/message_model.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;

  const ChatBubble({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMe = message.isMe; // ✅ sender বা receiver detect

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start, // right/left
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) _buildTail(isMe), // receiver tail left
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isMe
                    ? AppColors
                          .onboardingIndicatorActive // sender color
                    : Colors.grey[200], // receiver color
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isMe
                      ? const Radius.circular(18)
                      : const Radius.circular(0),
                  bottomRight: isMe
                      ? const Radius.circular(0)
                      : const Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 15,
                      color: isMe ? Colors.black : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment:
                        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      Text(
                        message.time,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isMe ? Colors.black54 : Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.check,
                          size: 14,
                          color: message.isRead
                              ? const Color(0xFF1E88E5)
                              : Colors.black45,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) _buildTail(isMe), // sender tail right
        ],
      ),
    );
  }

  /// Tail for bubble
  Widget _buildTail(bool isMe) {
    return CustomPaint(
      painter: BubbleTailPainter(isMe),
      size: const Size(10, 20),
    );
  }
}

/// Custom Painter for bubble tail
class BubbleTailPainter extends CustomPainter {
  final bool isMe;
  BubbleTailPainter(this.isMe);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isMe ? AppColors.onboardingIndicatorActive : Colors.grey[200]!;

    final path = Path();
    if (isMe) {
      // sender tail right
      path.moveTo(0, 0);
      path.lineTo(size.width, size.height / 2);
      path.lineTo(0, size.height);
    } else {
      // receiver tail left
      path.moveTo(size.width, 0);
      path.lineTo(0, size.height / 2);
      path.lineTo(size.width, size.height);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

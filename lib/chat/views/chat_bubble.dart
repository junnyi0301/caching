import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  const ChatBubble({super.key, required this.message, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: isCurrentUser ? EdgeInsets.only(right: 12, top: 4, bottom: 4, left: 120) : EdgeInsets.only(right: 120, top: 4, bottom: 4, left: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isCurrentUser ? Colors.green : Colors.black12
        ),
        child: Text(message, softWrap: true, style: GoogleFonts.poppins(color: isCurrentUser ? Colors.white : Colors.black, fontSize: 16)),
      ),
    );
  }
}

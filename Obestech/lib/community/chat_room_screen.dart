// 📁 lib/community/chat_room_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:obesetechapp/widgets/chat_bubble.dart';
import 'package:obesetechapp/widgets/chat_input_field.dart';


class ChatRoomScreen extends StatefulWidget {
  final String title;
  const ChatRoomScreen({super.key, required this.title});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final List<Map<String, dynamic>> messages = [];

  void _handleSend(String text) {
    setState(() {
      messages.add({'type': 'text', 'from': 'me', 'text': text});
    });
  }

  void _handleImage(File imageFile) {
    setState(() {
      messages.add({'type': 'image', 'from': 'me', 'file': imageFile});
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _handleImage(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("Paramètres du groupe (notifications, quitter, etc.)"),
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[messages.length - 1 - index];
                return ChatBubble(
                  text: msg['text'],
                  isMe: msg['from'] == 'me',
                  image: msg['type'] == 'image' ? msg['file'] : null,
                );
              },
            ),
          ),
          ChatInputField(onSend: _handleSend, onImagePick: _pickImage),
        ],
      ),
    );
  }
}

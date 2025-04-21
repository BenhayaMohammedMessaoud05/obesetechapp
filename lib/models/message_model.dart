// 📁 lib/models/message_model.dart

class MessageModel {
  final String sender;
  final String content;
  final DateTime timestamp;

  MessageModel({required this.sender, required this.content, required this.timestamp});
}

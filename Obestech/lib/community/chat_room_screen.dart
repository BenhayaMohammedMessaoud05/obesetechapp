import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:obesetechapp/widgets/chat_bubble.dart';
import 'package:obesetechapp/widgets/chat_input_field.dart';
import 'package:obesetechapp/services/api_service.dart';

// Mock theme classes (from previous code)
class AppColors {
  static const primary = Color(0xFF1A3C5A);
  static const accent = Color(0xFF2A5C8A);
  static const cardBackground = Color(0xFFF9FAFB);
  
  static var label;
}

class AppTextStyles {
  static final headline = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );
  static final subhead = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );
  static final label = GoogleFonts.poppins(
    fontSize: 12,
    color: Color(0xFF6B7280),
  );
  static final value = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );
}

class ChatRoomScreen extends StatefulWidget {
  final String token;
  final String title; // Initial channel name
  const ChatRoomScreen({Key? key, required this.token, required this.title}) : super(key: key);

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final List<Map<String, dynamic>> messages = [];
  final List<Map<String, dynamic>> channels = [
    {
      'id': '1',
      'name': 'General Support',
      'description': 'A place for general support and encouragement.',
      'isPrivate': false,
    },
    {
      'id': '2',
      'name': 'Nutrition Tips',
      'description': 'Share and learn about healthy eating.',
      'isPrivate': false,
    },
    {
      'id': 'private_1_2',
      'name': 'Chat with Alice',
      'description': 'Private conversation with Alice',
      'isPrivate': true,
    },
  ];
  final List<Map<String, dynamic>> members = [
    {
      'id': '1',
      'username': 'Alice',
      'avatarUrl': 'https://via.placeholder.com/150',
      'isOnline': true,
    },
    {
      'id': '2',
      'username': 'Bob',
      'avatarUrl': 'https://via.placeholder.com/150',
      'isOnline': false,
    },
    {
      'id': '3',
      'username': 'Charlie',
      'avatarUrl': 'https://via.placeholder.com/150',
      'isOnline': true,
    },
  ];
  String currentChannelId = '1';
  final TextEditingController _salonNameController = TextEditingController();
  final TextEditingController _salonDescController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    messages.addAll([
      {
        'type': 'text',
        'from': 'other',
        'fromId': '1',
        'text': 'Welcome to the General Support group!',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 10)),
        'read': true,
      },
      {
        'type': 'text',
        'from': 'me',
        'fromId': 'me',
        'text': 'Thanks for the warm welcome!',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
        'read': true,
      },
    ]);
    _fetchChannels();
  }

  @override
  void dispose() {
    _salonNameController.dispose();
    _salonDescController.dispose();
    super.dispose();
  }

  Future<void> _fetchChannels() async {
    try {
      // Placeholder for ApiService.getChannels
      // final fetchedChannels = await ApiService.getChannels(widget.token);
      // setState(() {
      //   channels.clear();
      //   channels.addAll(fetchedChannels);
      // });
    } catch (e) {
      print('ChatRoomScreen: Error fetching channels: $e');
    }
  }

  Future<void> _fetchChannelMembers(String channelId) async {
    try {
      // Placeholder for ApiService.getChannelMembers
      // final fetchedMembers = await ApiService.getChannelMembers(widget.token, channelId);
      // setState(() {
      //   members.clear();
      //   members.addAll(fetchedMembers);
      // });
    } catch (e) {
      print('ChatRoomScreen: Error fetching members: $e');
    }
  }

  Future<void> _createChannel(String name, String description, {bool isPrivate = false}) async {
    try {
      // Placeholder for ApiService.createChannel
      // final newChannel = await ApiService.createChannel(widget.token, name, description, isPrivate: isPrivate);
      // setState(() {
      //   channels.add(newChannel);
      //   currentChannelId = newChannel['id'];
      //   messages.clear();
      // });
      setState(() {
        final newChannel = {
          'id': isPrivate ? 'private_${channels.length + 1}' : (channels.length + 1).toString(),
          'name': name,
          'description': description,
          'isPrivate': isPrivate,
        };
        channels.add(newChannel);
        currentChannelId = newChannel['id'] as String;
        messages.clear();
        if (!isPrivate) {
          messages.add({
            'type': 'text',
            'from': 'other',
            'fromId': 'system',
            'text': 'Bienvenue dans $name !',
            'timestamp': DateTime.now(),
            'read': true,
          });
        }
      });
    } catch (e) {
      print('ChatRoomScreen: Error creating channel: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la création du salon: $e')),
      );
    }
  }

  Future<void> _startPrivateChat(String memberId, String memberName) async {
    final privateChannelId = 'private_me_$memberId';
    final existingChannel = channels.firstWhere(
      (channel) => channel['id'] == privateChannelId,
      orElse: () => {},
    );
    if (existingChannel.isNotEmpty) {
      setState(() {
        currentChannelId = privateChannelId;
        messages.clear();
        messages.add({
          'type': 'text',
          'from': 'other',
          'fromId': memberId,
          'text': 'Salut ! Comment ça va ?',
          'timestamp': DateTime.now(),
          'read': true,
        });
      });
    } else {
      await _createChannel(
        'Chat with $memberName',
        'Private conversation with $memberName',
        isPrivate: true,
      );
    }
  }

  void _handleSend(String text) {
    setState(() {
      messages.add({
        'type': 'text',
        'from': 'me',
        'fromId': 'me',
        'text': text,
        'timestamp': DateTime.now(),
        'read': false,
      });
    });
  }

  void _handleImage(File imageFile) {
    setState(() {
      messages.add({
        'type': 'image',
        'from': 'me',
        'fromId': 'me',
        'file': imageFile,
        'timestamp': DateTime.now(),
        'read': false,
      });
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _handleImage(File(pickedFile.path));
    }
  }

  void _showCreateSalonDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Créer un nouveau salon', style: AppTextStyles.headline),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _salonNameController,
              decoration: InputDecoration(
                labelText: 'Nom du salon',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: AppColors.cardBackground,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _salonDescController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: AppColors.cardBackground,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: GoogleFonts.poppins(color: AppColors.primary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_salonNameController.text.isNotEmpty) {
                _createChannel(_salonNameController.text, _salonDescController.text);
                _salonNameController.clear();
                _salonDescController.clear();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Créer', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showMembersSheet(String channelId) {
    _fetchChannelMembers(channelId);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Membres du salon',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(member['avatarUrl']),
                      backgroundColor: AppColors.primary,
                      child: member['avatarUrl'] == null
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    title: Text(member['username'], style: AppTextStyles.subhead),
                    subtitle: Text(
                      member['isOnline'] ? 'En ligne' : 'Hors ligne',
                      style: AppTextStyles.label.copyWith(
                        color: member['isOnline'] ? Colors.green : AppColors.label,
                      ),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _startPrivateChat(member['id'], member['username']);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'Message',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentChannel = channels.firstWhere(
      (channel) => channel['id'] == currentChannelId,
      orElse: () => channels[0],
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    Colors.teal.withOpacity(0.1),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -50,
                    left: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.teal.withOpacity(0.2),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -100,
                    right: -100,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                // Top bar with channel name and controls
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: AppColors.primary),
                        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      ),
                      Expanded(
                        child: Text(
                          currentChannel['name'],
                          style: AppTextStyles.headline,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.group, color: AppColors.primary),
                        onPressed: () => _showMembersSheet(currentChannelId),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: ListView.builder(
                      key: ValueKey(currentChannelId),
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[messages.length - 1 - index];
                        final isMe = msg['from'] == 'me';
                        final sender = isMe
                            ? {'id': 'me', 'username': 'Moi', 'avatarUrl': null}
                            : members.firstWhere(
                                (m) => m['id'] == msg['fromId'],
                                orElse: () => {
                                      'id': msg['fromId'],
                                      'username': 'Unknown',
                                      'avatarUrl': null,
                                    },
                              );
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isMe)
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      sender['avatarUrl'] != null ? NetworkImage(sender['avatarUrl']) : null,
                                  backgroundColor: AppColors.primary,
                                  child: sender['avatarUrl'] == null
                                      ? const Icon(Icons.person, color: Colors.white, size: 20)
                                      : null,
                                ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment:
                                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    if (!isMe)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Text(
                                          sender['username'],
                                          style: AppTextStyles.subhead.copyWith(fontSize: 12),
                                        ),
                                      ),
                                    ChatBubble(
                                      text: msg['text'],
                                      isMe: isMe,
                                      image: msg['type'] == 'image' ? msg['file'] : null,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          DateFormat('HH:mm').format(msg['timestamp'] ?? DateTime.now()),
                                          style: AppTextStyles.label,
                                        ),
                                        if (isMe && msg['read'])
                                          const Icon(
                                            Icons.done_all,
                                            size: 16,
                                            color: AppColors.accent,
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (isMe) const SizedBox(width: 8),
                              if (isMe)
                                const CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.accent,
                                  child: Icon(Icons.person, color: Colors.white, size: 20),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                ChatInputField(
                  onSend: _handleSend,
                  onImagePick: _pickImage,
                ),
              ],
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.primary,
                child: Column(
                  children: [
                    Text(
                      'Salons et Chats',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Communautés et conversations privées',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Salons de groupe',
                        style: AppTextStyles.headline.copyWith(fontSize: 16),
                      ),
                    ),
                    ...channels
                        .where((channel) => !channel['isPrivate'])
                        .map((channel) => ListTile(
                              leading: const Icon(Icons.chat, color: AppColors.primary),
                              title: Text(channel['name'], style: AppTextStyles.subhead),
                              subtitle: Text(
                                channel['description'],
                                style: AppTextStyles.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              selected: channel['id'] == currentChannelId,
                              selectedTileColor: AppColors.cardBackground,
                              onTap: () {
                                setState(() {
                                  currentChannelId = channel['id'];
                                  messages.clear();
                                  messages.add({
                                    'type': 'text',
                                    'from': 'other',
                                    'fromId': 'system',
                                    'text': 'Bienvenue dans ${channel['name']} !',
                                    'timestamp': DateTime.now(),
                                    'read': true,
                                  });
                                });
                                Navigator.pop(context);
                              },
                            )),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Chats privés',
                        style: AppTextStyles.headline.copyWith(fontSize: 16),
                      ),
                    ),
                    ...channels
                        .where((channel) => channel['isPrivate'])
                        .map((channel) => ListTile(
                              leading: const Icon(Icons.lock, color: AppColors.primary),
                              title: Text(channel['name'], style: AppTextStyles.subhead),
                              subtitle: Text(
                                channel['description'],
                                style: AppTextStyles.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              selected: channel['id'] == currentChannelId,
                              selectedTileColor: AppColors.cardBackground,
                              onTap: () {
                                setState(() {
                                  currentChannelId = channel['id'];
                                  messages.clear();
                                  messages.add({
                                    'type': 'text',
                                    'from': 'other',
                                    'fromId': channel['id'].split('_').last,
                                    'text': 'Salut ! Comment ça va ?',
                                    'timestamp': DateTime.now(),
                                    'read': true,
                                  });
                                });
                                Navigator.pop(context);
                              },
                            )),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add, color: AppColors.primary),
                title: Text('Créer un salon', style: AppTextStyles.subhead),
                onTap: () {
                  Navigator.pop(context);
                  _showCreateSalonDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.group, color: AppColors.primary),
                title: Text('Voir les membres', style: AppTextStyles.subhead),
                onTap: () {
                  Navigator.pop(context);
                  _showMembersSheet(currentChannelId);
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (_) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.notifications, color: AppColors.primary),
                    title: Text('Gérer les notifications', style: AppTextStyles.subhead),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifications mises à jour')),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.exit_to_app, color: Colors.red),
                    title: Text('Quitter le salon', style: AppTextStyles.subhead.copyWith(color: Colors.red)),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vous avez quitté le salon')),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.settings, color: Colors.white),
      ),
    );
  }
}

// Updated ChatBubble (assumed in widgets/chat_bubble.dart)
class ChatBubble extends StatelessWidget {
  final String? text;
  final bool isMe;
  final File? image;

  const ChatBubble({Key? key, this.text, required this.isMe, this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isMe ? AppColors.accent : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (text != null)
            Text(
              text!,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isMe ? Colors.white : AppColors.primary,
              ),
            ),
          if (image != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                image!,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Updated ChatInputField (assumed in widgets/chat_input_field.dart)
class ChatInputField extends StatelessWidget {
  final Function(String) onSend;
  final VoidCallback onImagePick;

  const ChatInputField({Key? key, required this.onSend, required this.onImagePick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image, color: AppColors.primary),
            onPressed: onImagePick,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Écrire un message...',
                hintStyle: AppTextStyles.label,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.cardBackground,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: AppColors.primary),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onSend(controller.text.trim());
                controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
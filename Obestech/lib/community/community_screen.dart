// 📁 lib/community/community_screen.dart

import 'package:flutter/material.dart';
import 'group_list_screen.dart';
import 'private_chat_list_screen.dart';

//import 'private_chat_list_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Communauté"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Groupes"),
            Tab(text: "Messages privés"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          GroupListScreen(),
          PrivateChatListScreen(),
        ],
      ),
    );
  }
}

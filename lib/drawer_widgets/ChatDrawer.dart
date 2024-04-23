import 'package:flutter/material.dart';
import 'package:flutter_node_auth/models/user.dart';
import 'package:flutter_node_auth/screens/chat_screen.dart';
import 'package:flutter_node_auth/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_node_auth/navigation/drawer.dart'; // Import the drawer screen widget

class ChatDrawer extends StatelessWidget {
  final User currentUser;
  const ChatDrawer({required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return SidebarXExampleApp(
      currentUser: currentUser,
      body:  ChatScreen(databaseId: '',),
    );
  }
}
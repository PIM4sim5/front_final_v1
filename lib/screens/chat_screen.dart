import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatBot Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChatScreen(databaseId: ''),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String databaseId;

  ChatScreen({required this.databaseId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _isConversationLoaded = false;

  void _sendMessage(String databaseId) async {
    String userMessage = _controller.text;
    if (userMessage.isNotEmpty) {
      setState(() {
        _messages.add({"sender": "user", "message": userMessage});
      });
      _controller.clear();

      try {
        var response = await http.post(
          Uri.parse('http://127.0.0.1:5000/chat'),
          body: jsonEncode({
            "user_input": userMessage,
            "file_id": databaseId,
          }),
          headers: {"Content-Type": "application/json"},
        );

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          setState(() {
            _messages.add({"sender": "bot", "message": data['output']});
          });
        } else {
          print('Request failed with status: ${response.statusCode}.');
        }
      } catch (error) {
        print('Error sending message: $error');
      }
    }
  }

  void _getConversationHistory(String databaseId) async {
    try {
      var response = await http.get(
        Uri.parse('http://127.0.0.1:5000/conversations?file_id=$databaseId'),
      );
      if (response.statusCode == 200) {
        List<dynamic> conversationData = jsonDecode(response.body);

        for (var data in conversationData) {
          setState(() {
            _messages.add({
              "_id": data["_id"],
              "sender": "user",
              "message": data["user_input"]
            });
            _messages.add({
              "_id": data["_id"],
              "sender": "bot",
              "message": data["output"]
            });
          });
        }

        setState(() {
          _isConversationLoaded = true;
        });
      } else {
        print('Failed to load conversation history: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error loading conversation history: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatBot'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(_messages),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Enter your message...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(width: 8.0),
            ElevatedButton(
              onPressed: () {
                _getConversationHistory(widget.databaseId);
              },
              child: Text('Load'),
            ),
            SizedBox(width: 8.0),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                _sendMessage(widget.databaseId);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(List<Map<String, dynamic>> messages) {
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: messages[index]["sender"] == "user"
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: messages[index]["sender"] == "user"
                  ? Colors.blue[200]
                  : Colors.grey[300],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    messages[index]["sender"] == "user" ? "You" : "Bot",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4.0),
                  Text(messages[index]["message"]),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

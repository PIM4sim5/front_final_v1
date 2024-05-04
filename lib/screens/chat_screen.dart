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
  List<String> _conversationDates = [];
  bool _isConversationLoaded = false;

  @override
  void initState() {
    super.initState();
    // Appel de _getConversationHistory une seule fois après un délai de 20 secondes
    Future.delayed(Duration(seconds: 20), () {
      _getConversationHistory(widget.databaseId);
    });
  }

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

        // Clear existing messages and dates
        setState(() {
          _messages.clear();
          _conversationDates.clear();
        });

        for (var data in conversationData) {
          // Add messages
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

          // Get conversation date
          String? createdAt = data["created_at"];

          // Check if createdAt is not null
          if (createdAt != null) {
            // Check if the date string is in a valid format
            if (createdAt.length >= 10) { // At least "YYYY-MM-DD" should be present
              String conversationDate = createdAt.substring(0, 10);

              // Check if the date is not already in the list, then add it
              if (!_conversationDates.contains(conversationDate)) {
                setState(() {
                  _conversationDates.add(conversationDate);
                });
              }
            }
          }
        }

        setState(() {
          _isConversationLoaded = true;
        });

        // Print conversation dates
        print('Conversation Dates:');
        _conversationDates.forEach((date) {
          print(date);
        });
      } else {
        print('Failed to load conversation history: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error loading conversation history: $error');
    }
  }

  void _getConversationHistoryByDate(String databaseId, String date) async {
    try {
      // Remplacer "Ap" par "Apr"
      date = date.replaceAll('Ap', 'Apr');

      // Obtention de l'année actuelle
      String currentYear = DateTime.now().year.toString();

      // Formatage de la date au format YYYY-MM-DD
      List<String> dateParts = date.split(' ');

      if (dateParts.length != 3) {
        print('Invalid date format: $date');
        return; // Arrête la fonction si la date n'est pas correctement formatée
      }

      String day = dateParts[1].replaceAll(',', ''); // Récupère le jour en supprimant la virgule
      String month = _getMonthNumber(dateParts[2]); // Récupère le mois
      String formattedDate = '$currentYear-$month-$day'; // Obtient la date au format YYYY-MM-DD
      print('Formatted Date: $formattedDate'); // Affiche la dat
      var response = await http.get(
        Uri.parse('http://127.0.0.1:5000/conversations_by_date?file_id=$databaseId&date=$formattedDate'),
      );
      if (response.statusCode == 200) {
        List<dynamic> conversationData = jsonDecode(response.body);

        // Clear existing messages
        setState(() {
          _messages.clear();
        });

        for (var data in conversationData) {
          // Add messages
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

        // Print conversation messages
        print('Received messages:');
        for (var message in _messages) {
          print('${message["sender"]}: ${message["message"]}');
        }
      } else {
        print('Failed to load conversation history for date $date: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error loading conversation history: $error');
    }
  }




  String _getMonthNumber(String month) {
    switch (month) {
      case 'Jan':
        return '01';
      case 'Feb':
        return '02';
      case 'Mar':
        return '03';
      case 'Apr':
        return '04';
      case 'May':
        return '05';
      case 'Jun':
        return '06';
      case 'Jul':
        return '07';
      case 'Aug':
        return '08';
      case 'Sep':
        return '09';
      case 'Oct':
        return '10';
      case 'Nov':
        return '11';
      case 'Dec':
        return '12';
      default:
        return '';
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatBot'),
      ),
      body: Row(
        children: [
          Expanded(
            child: _buildMessageList(_messages),
          ),
          VerticalDivider(), // Ajouter une barre de séparation verticale
          SizedBox(
            width: 250, // Largeur du Drawer
            child: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Text(
                      'Conversation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  if (_isConversationLoaded)
                    ..._conversationDates.map(
                          (date) => ListTile(
                        title: Text(date),
                        onTap: () {
                          _getConversationHistoryByDate(widget.databaseId, date);
                        },
                      ),
                    ),
                ],
              ),
            ),
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

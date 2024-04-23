import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_node_auth/models/user.dart';
import 'package:provider/provider.dart';
import 'package:flutter_node_auth/services/UploadViewModel.dart';
import 'package:http/http.dart' as http;
import 'chat_screen.dart';

class FileUploadScreen extends StatefulWidget {
  final User currentUser;

  const FileUploadScreen({required this.currentUser});

  @override
  _FileUploadScreenState createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<FileUploadViewModel>(context, listen: false).clearImportedDatabases();
    Provider.of<FileUploadViewModel>(context, listen: false).fetchUploadedDatabases(widget.currentUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
appBar: AppBar(
  title: Center(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Welcome ${widget.currentUser.name}',
          style: GoogleFonts.zenTokyoZoo(
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 20),
          Icon(
          Icons.handshake_sharp, // Choose the waving hand icon from the available icons
          size: 40,
          color: Color.fromARGB(255, 177, 9, 9), // Adjust the color as needed
        ),
      ],
    ),
  ),
  backgroundColor: Colors.transparent,
  elevation: 0, // Remove elevation for a flat look
  flexibleSpace: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromARGB(255, 104, 140, 202),
          Color.fromARGB(255, 159, 203, 75),
        ],
      ),
    ),
  ),
),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPainter(),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  child: GestureDetector(
                    onTap: () {
                      Provider.of<FileUploadViewModel>(context, listen: false).uploadFile(widget.currentUser);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          begin: Alignment.bottomRight,
                          end: Alignment.topLeft,
                          colors: [
                            Color.fromARGB(255, 104, 200, 202),
                            Color.fromARGB(200, 300, 203, 75),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 32, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Upload database',
                              style: TextStyle(fontSize: 14, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Consumer<FileUploadViewModel>(
                    builder: (context, viewModel, child) {
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                        ),
                        itemCount: viewModel.importedDatabases.length,
                        itemBuilder: (context, index) {
                          final database = viewModel.importedDatabases[index];
                          return GestureDetector(
                            onTap: () async {
                              final url = 'http://localhost:3000/python/execute-python-script/${database.id}';
                              try {
                                final response = await http.post(Uri.parse(url));
                                if (response.statusCode == 200) {
                                  // Réponse réussie, vous pouvez ajouter ici le code de gestion de la réponse
                                  print('Requête POST réussie');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(databaseId: database.id),
                                    ),
                                  );
                                } else {
                                  // Gestion des erreurs
                                  print('Erreur lors de la requête POST : ${response.statusCode}');
                                }
                              } catch (error) {
                                // Gestion des erreurs
                                print('Erreur lors de la requête POST : $error');
                              }
                            },
                            child: DatabaseCard(database: database),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DatabaseCard extends StatelessWidget {
  final Database database;

  const DatabaseCard({required this.database});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 20,
      color: Color.fromARGB(255, 182, 189, 203),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 207, 215, 229),
                  border: Border.all(
                    color: Color.fromARGB(255, 1, 1, 1),
                    width: 2.2,
                  ),
                ),
                child: Text(
                  '${database.name}',
                  style: GoogleFonts.newRocker(fontSize: 18, fontWeight: FontWeight.w700, color: Color.fromARGB(255, 0, 0, 0)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 50),
              Container(
                child: Text(
                  'Type: ${_getFileType(database.type)}',
                  style: GoogleFonts.exo(fontSize: 14, color: const Color.fromARGB(255, 11, 9, 9), fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 10),
              Container(
                child: Text(
                  '${_formatDate(database.uploadDate)}',
                  style: GoogleFonts.orbitron(fontSize: 10, color: const Color.fromARGB(255, 22, 18, 18), fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 60),
              Container(
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 132, 18, 18),
                  border: Border.all(
                    color: Color.fromARGB(255, 230, 219, 219),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Uploaded By ${database.uploadedBy}',
                  style: GoogleFonts.eduVicWaNtBeginner(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month}-${dateTime.day} at ${dateTime.hour}:${dateTime.minute}';
  }

  String _getFileType(String type) {
    return type.split('/').last;
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomRight,
        end: Alignment.topLeft,
        colors: [
                            Color.fromARGB(255, 104, 140, 202),
                            Color.fromARGB(255, 159, 203, 75),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 1,
      size.width * 0.5,
      size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.4,
      size.width ,
      size.height * 0.4,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
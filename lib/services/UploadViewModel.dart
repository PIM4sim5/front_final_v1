import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_node_auth/models/user.dart';
import 'package:flutter_node_auth/screens/UploadScreen.dart';

class Database {
  late String id;
  late String name;
  late String type;
  late DateTime uploadDate;
  late String uploadedBy;

  Database({required this.id,required this.name, required this.type, required this.uploadDate, required this.uploadedBy});
}

class FileUploadViewModel extends ChangeNotifier {
  List<Database> _importedDatabases = [];
  List<Database> get importedDatabases => _importedDatabases;


  // Add a method to clear the list of imported databases
  void clearImportedDatabases() {
    _importedDatabases.clear();
  }

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  bool _uploaded = false;
  bool get uploaded => _uploaded;

  String _error = '';
  String get error => _error;
  

  Future<void> uploadFile(User currentUser) async {
    try {
      _uploaded = false; // Reset uploaded status
      _isUploading = true;
      notifyListeners(); // Notify listeners about the change in upload status

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'xls', 'xlsx', 'mdb', 'sqlite', 'sql', 'csv',
          'mongodb', 'json-db', 'xml-db'
        ],
      );

      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.single;

        // Determine content type based on file extension
        String contentType;
        switch (platformFile.extension?.toLowerCase()) {
          case 'xls':
            contentType = 'application/vnd.ms-excel';
            break;
          case 'xlsx':
            contentType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
            break;
          case 'mdb':
            contentType = 'application/x-msaccess';
            break;
          case 'sqlite':
            contentType = 'application/x-sqlite3';
            break;
          case 'sql':
            contentType = 'application/sql';
            break;
          case 'mongodb':
            contentType = 'application/mongodb';
            break;
          case 'csv':
            contentType = 'text/csv';
            break;
          default:
            contentType = 'application/octet-stream';
            break;
        }

        String authToken = await _getAuthToken();

        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://localhost:3000/files/upload'),
        );

        request.headers['x-auth-token'] = authToken;

        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            platformFile.bytes!,
            filename: platformFile.name,
            contentType: MediaType.parse(contentType),
          ),
        );

        var response = await http.Response.fromStream(await request.send());

        if (response.statusCode == 201) {
          // Handle success
          _uploaded = true;
          _isUploading = false;
          notifyListeners();
          print('File uploaded successfully');

          await fetchUploadedDatabases(currentUser);
        } else {
          // Handle error
          print('Error uploading file: ${response.body}');
        }
      } else {
        print('User canceled file selection');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

Future<void> fetchUploadedDatabases(User user) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('user_id', user.id);
      String authToken = await _getAuthToken();

    // Log authentication token and user ID for debugging
    print('Auth Token: $authToken');
    print('User ID: ${prefs.getString('user_id')}');

      var response = await http.get(
        Uri.parse('http://localhost:3000/files/databases'),
        headers: {'x-auth-token': authToken},
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

      _importedDatabases = data
        .where((databaseJson) => databaseJson['uploadedBy']['_id'] == user.id)
        .map((databaseJson) => Database(
          id: databaseJson['_id'].toString(),
          name: databaseJson['filename'],
          type: databaseJson['contentType'],
          uploadDate: DateTime.parse(databaseJson['createdAt']),
          uploadedBy: databaseJson['uploadedBy']['name'],
        ))
        .toList();
        notifyListeners(); // Update UI after fetching data
      } else {
        print('Failed to fetch uploaded databases: ${response.body}');
      }
    } catch (e) {
      print('Exception while fetching uploaded databases: $e');
    }
  }




  Future<String> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('x-auth-token') ?? '';
    return authToken;
  }
}
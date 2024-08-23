import 'package:chungbuk_ict/BookMark.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InformationScreen extends StatefulWidget {
  final String pillCode;
  final String pillName;
  final String confidence;
  final String extractedText;
  final String userId;  // Required parameter

  const InformationScreen({
    Key? key,
    required this.pillCode,
    required this.pillName,
    required this.confidence,
    required this.extractedText,
    required this.userId,  // Required parameter
  }) : super(key: key);

  @override
  _InformationScreenState createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  bool isFavorite = false;

  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });

    if (isFavorite) {
      addToFavorites(widget.pillCode, widget.pillName, widget.userId);
    } else {
      removeFromFavorites(widget.pillCode, widget.userId);
    }
  }

  Future<void> addToFavorites(String pillCode, String pillName, String userId) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/favorites/add/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'pill_code': pillCode,
        'pill_name': pillName,
        'user_id': userId,  // Required parameter
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('Favorite added successfully');
    } else {
      print('Failed to add favorite');
    }
  }

  Future<void> removeFromFavorites(String pillCode, String userId) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/favorites/remove/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'pill_code': pillCode,
        'user_id': userId,  // Required parameter
      }),
    );

    if (response.statusCode == 200) {
      print('Favorite removed successfully');
    } else {
      print('Failed to remove favorite');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: toggleFavorite,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Icon(
                  Icons.local_hospital,
                  size: 50,
                  color: Colors.purple[300],
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Colors.grey,
                  width: 2.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pill Code: ${widget.pillCode}', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  Text('Pill Name: ${widget.pillName}', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  Text('Confidence: ${widget.confidence}', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  Text('Extracted Text: ${widget.extractedText}', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BookmarkScreen(userId: widget.userId),  // Pass userId
                  ),
                );
              },
              child: Text('View Favorites'),
            ),
          ],
        ),
      ),
    );
  }
}

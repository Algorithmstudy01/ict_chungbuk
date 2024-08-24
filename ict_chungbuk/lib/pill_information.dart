import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:chungbuk_ict/BookMark.dart';

class InformationScreen extends StatefulWidget {
  final String pillCode;
  final String pillName;
  final String confidence;
  final String extractedText;
  final String userId;
  final String usage;
  final String precautionsBeforeUse;
  final String usagePrecautions;
  final String drugFoodInteractions;
  final String sideEffects;
  final String storageInstructions;
  final String efficacy;
  final String manufacturer;

  const InformationScreen({
    Key? key,
    required this.pillCode,
    required this.pillName,
    required this.confidence,
    required this.extractedText,
    required this.userId,
    required this.usage,
    required this.precautionsBeforeUse,
    required this.usagePrecautions,
    required this.drugFoodInteractions,
    required this.sideEffects,
    required this.storageInstructions,
    required this.efficacy,
    required this.manufacturer,
  }) : super(key: key);

  @override
  _InformationScreenState createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  bool isFavorite = false;
  late FlutterTts flutterTts;  // Initialize FlutterTts

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
  }

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
        'user_id': userId,
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
        'user_id': userId,
      }),
    );

    if (response.statusCode == 200) {
      print('Favorite removed successfully');
    } else {
      print('Failed to remove favorite');
    }
  }

  void speak(String text) async {
    await flutterTts.speak(text);
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
      body: SingleChildScrollView(
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
                  if (widget.pillCode.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: Text('품목기준코드: ${widget.pillCode}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('품목기준코드: ${widget.pillCode}'),
                        ),
                      ],
                    ),
                  if (widget.pillName.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: Text('제품명: ${widget.pillName}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('제품명: ${widget.pillName}'),
                        ),
                      ],
                    ),
                  if (widget.confidence.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: Text('예측 확률: ${widget.confidence}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('예측 확률: ${widget.confidence}'),
                        ),
                      ],
                    ),
                  if (widget.efficacy.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: Text('이 약의 효능은 무엇입니까?\n${widget.efficacy}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('이 약의 효능은 무엇입니까? ${widget.efficacy}'),
                        ),
                      ],
                    ),
                  if (widget.manufacturer.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: Text('제조/수입사: ${widget.manufacturer}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('제조/수입사: ${widget.manufacturer}'),
                        ),
                      ],
                    ),
                  if (widget.usage.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: Text('이 약은 어떻게 사용합니까?\n${widget.usage}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('이 약은 어떻게 사용합니까? ${widget.usage}'),
                        ),
                      ],
                    ),
                  if (widget.precautionsBeforeUse.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: Text('이 약을 사용하기 전에 반드시 알아야 할 내용은 무엇입니까?\n${widget.precautionsBeforeUse}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('이 약을 사용하기 전에 반드시 알아야 할 내용은 무엇입니까? ${widget.precautionsBeforeUse}'),
                        ),
                      ],
                    ),
                  if (widget.usagePrecautions.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: Text('이 약의 사용상 주의사항은 무엇입니까?\n${widget.usagePrecautions}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('이 약의 사용상 주의사항은 무엇입니까? ${widget.usagePrecautions}'),
                        ),
                      ],
                    ),
                  if (widget.drugFoodInteractions.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: Text('이 약을 사용하는 동안 주의해야 할 약 또는 음식은 무엇입니까?\n${widget.drugFoodInteractions}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('이 약을 사용하는 동안 주의해야 할 약 또는 음식은 무엇입니까? ${widget.drugFoodInteractions}'),
                        ),
                      ],
                    ),
                  if (widget.sideEffects.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: Text('이 약은 어떤 이상반응이 나타날 수 있습니까?\n${widget.sideEffects}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('이 약은 어떤 이상반응이 나타날 수 있습니까? ${widget.sideEffects}'),
                        ),
                      ],
                    ),
                  if (widget.storageInstructions.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: Text('이 약은 어떻게 보관해야 합니까?\n${widget.storageInstructions}\n', style: TextStyle(fontSize: 16))),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => speak('이 약은 어떻게 보관해야 합니까? ${widget.storageInstructions}'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BookmarkScreen(userId: widget.userId),
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

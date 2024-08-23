import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class BookmarkScreen extends StatefulWidget {
  final String userId;  // Ensure this is defined

  const BookmarkScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _BookmarkScreenState createState() => _BookmarkScreenState();
}

 class _BookmarkScreenState extends State<BookmarkScreen> {
  TextEditingController _searchController = TextEditingController();
  Future<List<Map<String, String>>>? _favoritesFuture;
  List<Map<String, String>> _allFavorites = [];
  List<Map<String, String>> _filteredFavorites = [];

  @override
  void initState() {
    super.initState();
    _favoritesFuture = fetchFavorites(widget.userId);
    _searchController.addListener(_filterFavorites);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Map<String, String>>> fetchFavorites(String userId) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/favorites/$userId/'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<Map<String, String>> favorites = data.map<Map<String, String>>((item) => {
        'pillCode': item['pill_code'] as String,
        'pillName': item['pill_name'] as String,
      }).toList();
      setState(() {
        _allFavorites = favorites;
        _filteredFavorites = favorites;
      });
      return favorites;
    } else {
      throw Exception('Failed to load favorites');
    }
  }

  void _filterFavorites() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFavorites = _allFavorites.where((item) {
        final pillName = item['pillName']!.toLowerCase();
        return pillName.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('즐겨찾기 목록'),
        backgroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        foregroundColor: Colors.black,
        shadowColor: Colors.grey.withOpacity(0.5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Map<String, String>>>(
                future: _favoritesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No favorites added yet.'));
                  } else {
                    return ListView.builder(
                      itemCount: _filteredFavorites.length,
                      itemBuilder: (context, index) {
                        final favorite = _filteredFavorites[index];
                        return _buildBookmarkItem(
                          favorite['pillCode']!,
                          favorite['pillName']!,
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.black),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.black),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '검색',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    _filterFavorites();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookmarkItem(String pillCode, String pillName) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.purple[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/img/pill.png',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Text(
                    '알약 이름 : $pillName',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('성분 :', style: TextStyle(fontSize: 14)),
                      SizedBox(height: 4),
                      Text('효과 :', style: TextStyle(fontSize: 14)),
                    ],
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

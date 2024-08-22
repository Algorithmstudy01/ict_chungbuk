import 'package:flutter/material.dart';

class InformationScreen extends StatelessWidget {
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
                  Text('제품명:', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  Text('성분, 함량:', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  Text('효능:', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  Text('사용법:', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  Text('주의사항:', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  Text('보관방법:', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
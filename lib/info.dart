import 'package:burada/colors.dart';
import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hakkında'),
        backgroundColor: darkest,
        foregroundColor: Colors.white,
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Burada App',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              SizedBox(height: 16),
              Text(
                'Burada App, Bluetooth teknolojisiyle yoklama süreçlerini kolaylaştıran bir uygulamadır. Öğrenci ve öğretmenlerin zamandan tasarruf etmesini sağlar.'
                ,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              SizedBox(height: 25),
              Text(
                'Nasıl Kullanılır?',
                style: TextStyle(
                    fontSize: 25, fontWeight: FontWeight.bold, color: darkest),
              ),
              Text(
                '* lorem ipsum',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

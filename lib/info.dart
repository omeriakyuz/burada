import 'package:burada/colors.dart';
import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About the App'),
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
                'Bluetooth-Based Attendance System',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              SizedBox(height: 16),
              Text(
                'Welcome to the Bluetooth Attendance System app. This app provides a seamless experience for both students and teachers to manage attendance in classrooms using Bluetooth technology.',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              SizedBox(height: 25),
              Text(
                'How to Use:',
                style: TextStyle(
                    fontSize: 25, fontWeight: FontWeight.bold, color: darkest),
              ),
              Text(
                '* Choose your role on the initial page: Student or Teacher.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                '* Students will go through phone number authentication and login with fingerprint before accessing the dashboard.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                '* Teachers log in through their college email and can start/stop classes, check attendance, and make modifications.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                '* Students will have to check if they are marked present by the system, and in case of errors, they can contact their teachers to make necessary modifications to the database.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

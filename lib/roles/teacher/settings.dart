import 'package:burada/colors.dart';
import 'package:burada/roles/teacher/home.dart';
import 'package:flutter/material.dart';
import 'package:burada/info.dart';
import 'package:burada/animation.dart';

class TeacherSettingsPage extends StatefulWidget {
  const TeacherSettingsPage({super.key});

  @override
  _TeacherSettingsPageState createState() => _TeacherSettingsPageState();
}

class _TeacherSettingsPageState extends State<TeacherSettingsPage> {
  bool notificationSwitchValue = true;
  double volumeSliderValue = 50.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: darkest,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.info_outlined,
              color: lightest,
              size: 30,
            ),
            onPressed: () {
              Navigator.of(context).push(
                PageTransitionAnimation(
                  page: InfoPage(),
                ),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: const Text('Receive Notifications'),
              activeColor: secondDark,
              value: notificationSwitchValue,
              onChanged: (value) {
                setState(() {
                  notificationSwitchValue = value;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Volume',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: volumeSliderValue,
              onChanged: (value) {
                setState(() {
                  volumeSliderValue = value;
                });
              },
              min: 0,
              max: 100,
              divisions: 10,
              label: volumeSliderValue.round().toString(),
              activeColor: secondDark,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  PageTransitionAnimation(
                    page: TeacherHomePage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: middle,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.only(
                  left: 50,
                  right: 50,
                  top: 15,
                  bottom: 15,
                ),
              ),
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

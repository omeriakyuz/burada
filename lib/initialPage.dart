import 'package:burada/perspectives/student/login.dart';
import 'package:burada/perspectives/student/phone_auth.dart';
import 'package:burada/perspectives/teacher/email_auth.dart';
import 'package:burada/perspectives/teacher/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:burada/colors.dart';

class ChooseRolePage extends StatefulWidget {
  const ChooseRolePage({super.key});

  @override
  _ChooseRolePageState createState() => _ChooseRolePageState();
}

class _ChooseRolePageState extends State<ChooseRolePage> {
  FirebaseAuth auth = FirebaseAuth.instance;

  // @override
  // void initState() {
  //   super.initState();
  //   Future.microtask(() => checkLoggedIn());
  // }

  // void checkLoggedIn() async {
  //   FirebaseAuth auth = FirebaseAuth.instance;
  //   User? user = await auth.authStateChanges().first;
  //   if (user != null) {
  //     if (user.phoneNumber != null) {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => StudentLoginPage()),
  //       );
  //     } else {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => TeacherHomePage()),
  //       );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Select your position",
              style: TextStyle(
                  fontSize: 30, color: darkest, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 30),
            const SizedBox(
                width: 250,
                child: Text(
                  'Choose your role and login with your credentials to continue to the app.',
                  textAlign: TextAlign.center,
                )),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const StudentPhoneAuth()),
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
              child: const Text(
                'Student',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TeacherEmailAuth()),
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
              child: const Text(
                'Teacher',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

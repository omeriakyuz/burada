import 'package:burada/colors.dart';
import 'package:burada/roles/teacher/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:burada/info.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:burada/animation.dart';

String currentTeacher = '';

class TeacherEmailAuth extends StatefulWidget {
  const TeacherEmailAuth({super.key});

  @override
  State<TeacherEmailAuth> createState() => _TeacherEmailAuthState();
}

class _TeacherEmailAuthState extends State<TeacherEmailAuth> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      await fetchTeacherDocument(userCredential.user!.email!);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const TeacherHomePage()),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('Bu e-postaya sahip kullanıcı bulunamadı.');
      } else if (e.code == 'wrong-password') {
        print('Girmiş olduğunuz şifre hatalı.');
      }
    }
  }

  Future<void> fetchTeacherDocument(String email) async {
    try {
      CollectionReference teachers = FirebaseFirestore.instance.collection('teachers');
      QuerySnapshot querySnapshot = await teachers.where('email', isEqualTo: email).get();

      if (querySnapshot.docs.isNotEmpty) {
        var teacherData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        currentTeacher = teacherData['name'];
        print('Öğretmen bilgisi alındı: $teacherData');
      } else {
        print('Öğretmen bulunamadı');
      }
    } catch (e) {
      print('Veri tabanından bilgi alırken hata oluştu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.nunitoTextTheme(),
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: darkest,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
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
                })
          ],
          title: const Text(
            'E-Posta Doğrulama',
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 120),
              Padding(
                padding: const EdgeInsets.all(
                  20,
                ),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'E-Posta',
                    labelText: 'E-Posta',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: InputDecoration(
                    hintText: 'Şifre',
                    labelText: 'Şifre',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  signInWithEmailAndPassword();
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.only(
                      left: 40,
                      right: 40,
                      top: 15,
                      bottom: 15,
                    ),
                    backgroundColor: secondDark,
                    foregroundColor: Colors.white),
                child: const Text('Üye Ol'),
              ),
              SizedBox(height: 120),
            ],
          ),
          // keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        ),
      ),
    );
  }
}
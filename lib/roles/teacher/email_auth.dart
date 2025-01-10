import 'package:flutter/material.dart';
import 'package:burada/colors.dart';
import 'package:burada/roles/teacher/home.dart';
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
      print("***HATA***: ${e.code} - ${e.message}");  // Hata mesajını da loglamak faydalı olur

      switch (e.code) {
        case 'user-not-found':
          _showSnackbar('Bu e-posta adresiyle kayıtlı bir hesap bulunamadı.');

        case 'wrong-password':
          _showSnackbar('Girdiğiniz şifre hatalı. Lütfen kontrol edip tekrar deneyin.');

        case 'invalid-credential':
          _showSnackbar('E-posta veya şifre hatalı. Lütfen bilgilerinizi kontrol edin.');

        case 'invalid-email':
          _showSnackbar('Geçersiz e-posta formatı. Lütfen kontrol edin.');

        case 'user-disabled':
          _showSnackbar('Bu hesap devre dışı bırakılmış. Lütfen yöneticinizle iletişime geçin.');

        case 'too-many-requests':
          _showSnackbar('Çok fazla başarısız giriş denemesi. Lütfen daha sonra tekrar deneyin.');

        case 'channel-error':
          _showSnackbar('Bağlantı hatası. Lütfen internet bağlantınızı kontrol edip tekrar deneyin.');

        case 'network-request-failed':
          _showSnackbar('İnternet bağlantısı yok veya zayıf. Lütfen bağlantınızı kontrol edin.');

        case 'operation-not-allowed':
          _showSnackbar('E-posta/şifre ile giriş bu uygulama için devre dışı bırakılmış.');

        default:
          _showSnackbar('Giriş yapılırken bir hata oluştu. (Hata kodu: ${e.code})');
      }
    } on Exception catch (e) {
      // FirebaseAuthException dışındaki hataları yakalar
      print("***GENEL HATA***: $e");
      _showSnackbar('Beklenmeyen bir hata oluştu. Lütfen daha sonra tekrar deneyin.');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 3)),
    );
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
    return Theme(
      data: ThemeData(
        textTheme: GoogleFonts.nunitoTextTheme(),
        primarySwatch: Colors.blue,
      ),
        child: Scaffold(
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
            'Öğretmen Girişi',
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 100,
              ),
              const Text(
                'Kurumunuzun sistemine kayıtlı bilgileri kullanarak giriş yapabilirsiniz.',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),              Padding(
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
                child: const Text('Giriş Yap'),
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
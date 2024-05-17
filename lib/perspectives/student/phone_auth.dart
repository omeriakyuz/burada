//import 'package:ble_advertiser/login.dart';
import 'package:burada/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:burada/perspectives/student/login.dart';
import 'package:burada/perspectives/student/home.dart';
import 'package:burada/info.dart';
import 'package:burada/animation.dart';

String rollNumberOfStudent = '';

class StudentPhoneAuth extends StatefulWidget {
  const StudentPhoneAuth({super.key});

  @override
  State<StudentPhoneAuth> createState() => _StudentPhoneAuthState();
}

class _StudentPhoneAuthState extends State<StudentPhoneAuth> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController rollNoController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController semesterController = TextEditingController();
  String userNumber = '';
  var otpFieldVisibility = false;
  var receivedID = '';

  void verifyUserPhoneNumber() {
    auth.verifyPhoneNumber(
      phoneNumber: userNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential).then(
              (value) => print('Giriş başarılı.'),
            );
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e.message);
      },
      codeSent: (String verificationId, int? resendToken) {
        receivedID = verificationId;
        setState(() {
          otpFieldVisibility = true;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print('TimeOut');
      },
    );
  }

  Future<void> verifyOTPCode() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: receivedID,
      smsCode: otpController.text,
    );
    await auth
        .signInWithCredential(credential)
        .then((value) => createUserDocument(value.user!));
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const StudentHomePage()),
          (route) => false,
    );
  }

  // Function to create a user document in Firestore
  Future<void> createUserDocument(User user) async {
    try {
      // Reference to the 'users' collection in Firestore
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      // Create a new document with the user's UID
      await users.doc(rollNoController.text).set({
        'rollNo': rollNoController.text,
        'name': nameController.text,
        'semester': semesterController.text,
        'phoneNo': phoneController.text,
        'present': false
      });

      print('User document created in Firestore successfully.');
    } catch (e) {
      print('Failed to create user document in Firestore: $e');
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
            'Doğrulama',
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: rollNoController,
                  onChanged: (value) {
                    rollNumberOfStudent =
                        value; // Update the global value when text changes
                  },
                  decoration: InputDecoration(
                    hintText: '077bei001',
                    labelText: 'Öğrenci Numarası',
                    // labelStyle: TextStyle(color: darkest),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    //  focusedBorder: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(15),
                    //   borderSide: BorderSide(color: darkest),
                    // )
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'John Doe',
                    labelText: 'İsim',
                    // labelStyle: TextStyle(color: darkest),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    //  focusedBorder: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(15),
                    //   borderSide: BorderSide(color: darkest),
                    // )
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: semesterController,
                  decoration: InputDecoration(
                    hintText: 'III/II',
                    labelText: 'Dönem',
                    // labelStyle: TextStyle(color: darkest),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    //  focusedBorder: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(15),
                    //   borderSide: BorderSide(color: darkest),
                    // )
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: IntlPhoneField(
                  showDropdownIcon: false,
                  controller: phoneController,
                  countries: const [
                    Country(
                      name: "Türkiye",
                      nameTranslations: {},
                      flag: "🇹🇷",
                      code: "TR",
                      dialCode: "90",
                      minLength: 10,
                      maxLength: 10,
                    )
                  ], // Restrict to Nepal
                  decoration: InputDecoration(
                    hintText: 'xxxxxxxxxx',
                    labelText: 'Telefon Numarası',
                    // labelStyle: TextStyle(color: darkest),
                    border: OutlineInputBorder(
                      // borderSide: BorderSide(color: darkest),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    // focusedBorder: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(15),
                    //   borderSide: BorderSide(color: darkest),
                    // )
                  ),
                  onChanged: (val) {
                    userNumber = val.completeNumber;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Visibility(
                  visible: otpFieldVisibility,
                  child: TextField(
                    controller: otpController,
                    decoration: InputDecoration(
                      hintText: 'Doğrulama Kodu',
                      labelText: 'Kod',
                      // labelStyle: TextStyle(color: darkest),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: darkest),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      //    focusedBorder: OutlineInputBorder(
                      //   borderRadius: BorderRadius.circular(15),
                      //   borderSide: BorderSide(color: darkest),
                      // )
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (otpFieldVisibility) {
                    verifyOTPCode();
                  } else {
                    verifyUserPhoneNumber();
                  }
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
                child: const Text('Doğrula'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

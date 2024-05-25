import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'package:burada/colors.dart';
import 'package:burada/info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:burada/initialPage.dart';
import 'package:burada/roles/student/check_attendance.dart';
import 'package:burada/roles/student/home.dart';
import 'package:burada/roles/student/login.dart';
import 'package:burada/roles/student/phone_auth.dart';
import 'package:burada/roles/teacher/addclass.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:burada/roles/teacher/check_attendance.dart';
import 'package:burada/roles/teacher/home.dart';
import 'package:burada/roles/teacher/email_auth.dart';
import 'package:burada/roles/student/phone_auth.dart';

import 'package:firebase_core/firebase_core.dart';
//import 'package:burada/login.dart';

import 'firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:burada/animation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '': (context) => const ChooseRolePage(),
        '/student_phoneauth': (context) => const StudentPhoneAuth(),
        '/student_login': (context) => const StudentLoginPage(),
        '/student_home': (context) => const StudentHomePage(),
        '/student_checkattendance': (context) => const StudentAttendancePage(),
        '/teacher_emailauth': (context) => const TeacherEmailAuth(),
        '/teacher_home': (context) => const TeacherHomePage(),
        '/teacher_checkattendance': (context) => const TeacherAttendancePage(),
        '/teacher_addclass': (context) => const AddClass(),
      },
      debugShowCheckedModeBanner: true,
      title: 'Burada',
      theme: ThemeData(
        textTheme: GoogleFonts.nunitoTextTheme(),
        primarySwatch: Colors.blue,
      ),
      home: const ChooseRolePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isAdvertising = false;
  Timer? advertiseTime;
  // String uniqueUUID = const Uuid().v4();
  String rollNumber = rollNumberOfStudent;
  // String rollNumberOfStudent = "";
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    advertiseTime?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Dersin Yoklamasına Katıl'),
          backgroundColor: darkest,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: true,
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
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'ÖĞRENCİ NUMARAN: \n $rollNumber',
                style: const TextStyle(
                    fontSize: 30, color: darkest, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  if (isAdvertising) {
                    stopAdvertising();
                  } else {
                    startAdvertising();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.only(
                    top: 15,
                    bottom: 15,
                    right: 50,
                    left: 50,
                  ),
                ),
                child:
                Text(isAdvertising ? 'Yoklamayı Durdur' : 'Yoklamayı Başlat'),
              ),
              if (isAdvertising)
                const SizedBox(
                    height: 50,
                    child: Center(
                      child: Text('Dersin yoklamasına katılıyorsun...',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.green,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold)),
                    ))
            ],
          ),
        ));
  }

  Future<void> startAdvertising() async {
    String serviceUUID = '21122064-63dd-4788-9fb3-424fa29f2148';
    List<int> manufactData = utf8.encode(rollNumber);
    print("ManufacturerData:$manufactData");
    print("ManufacturerData(decode):" + utf8.decode(manufactData));
    AdvertiseData advertiseData = AdvertiseData(
      serviceUuid: serviceUUID,
      manufacturerId: 0xFFFF,
      manufacturerData: Uint8List.fromList(manufactData),
    );

    AdvertiseSetParameters advertiseSetParameters = AdvertiseSetParameters();
    advertiseTime = Timer.periodic(Duration(seconds: 2), (timer) {
      try {
        FlutterBlePeripheral().start(
            advertiseData: advertiseData,
            advertiseSetParameters: advertiseSetParameters);
        setState(() {
          isAdvertising = true;
        });
      } catch (e) {
        print('Advertising esnasında oluşan hata: $e');
      }
    });
  }

  Future<void> stopAdvertising() async {
    try {
      await FlutterBlePeripheral().stop();
      setState(() {
        isAdvertising = false;
        advertiseTime?.cancel();
      });
    } catch (e) {
      print('Advertising durdururken oluşan hata: $e');
    }
  }


}

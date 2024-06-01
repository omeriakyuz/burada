import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:burada/roles/teacher/email_auth.dart';
import 'package:burada/roles/teacher/teacher_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:burada/colors.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';


class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({Key? key});

  @override
  _TeacherHomePageState createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentPageIndex = 0;
  List<String> buttonTexts = [];
  Map<String, bool> classStartedStates = {};
  String teacherName = currentTeacher;
  List<ScanResult> _scanResults = [];
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;
  bool _isScanning = false;


  @override
  Widget build(BuildContext context) {
    return TeacherBasePage(
      title: 'Kontrol Paneli',
      currentPageIndex: _currentPageIndex,
      buildBody: (context) =>
          StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('subjects')
                  .where('teacherName', isEqualTo: teacherName)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Hata: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final List<DocumentSnapshot> documents = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final subjectName = documents[index]['subject'] as String;
                    bool isClassStarted = classStartedStates[subjectName] ??
                        false; // Get state from map

                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Card(
                        color: lightest,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                      ),
                        child: ListTile(
                          title: Text(subjectName, style: TextStyle(fontSize: 20)),
                          trailing: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                classStartedStates[subjectName] =
                                !isClassStarted;
                              });
                        
                              if (isClassStarted) {
                                stopBLEScan();
                              } else {
                                startBLEScan();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: middle,
                              textStyle: GoogleFonts.nunito(
                                  fontSize: 15, color: Colors.black),
                            ),
                            child: Text(
                                isClassStarted ? 'Yoklamayı Durdur' : 'Yoklamayı Başlat',
                                style: const TextStyle(
                                color: Colors.black
                                ),
                              ),

                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
    );
  }

  Future<void> startBLEScan() async {
    List<BluetoothDevice> devices = [];
    devices.clear();
    print('tarama başladı.');

    await FlutterBluePlus.startScan(
      //withServices:[Guid("21122064-63dd-4788-9fb3-424fa29f2148")]
    );


    FlutterBluePlus.scanResults.listen((results) async {
      final studentsCollection = FirebaseFirestore.instance.collection('users');

      for (ScanResult r in results) {
        if (devices.contains(r.device)) {
          continue; // işlenen cihazı atla
        }
        devices.add(r.device); // listeyye cihaz ekle (yoksa)

        final manufacturerData = r.advertisementData.manufacturerData;
        if (manufacturerData != null && manufacturerData.isNotEmpty ) {
          r.advertisementData.manufacturerData.forEach((manufacturerId, listData) async {  // manufacturer data ( öğrenci ID'sini bluetooth formatından stringe çevir
            if (manufacturerId == 65535) {      // manufacturerId (company id) 0xFFFF olanları işleme al (uygulamamızdaki bluetooth bağlantısında kullanılan)
              var manufacturerDataString = String.fromCharCodes(listData);
              print('listData: $manufacturerDataString');
              try {
                final studentDoc = await studentsCollection.doc(manufacturerDataString).get();
                if (studentDoc.exists) {
                  await studentDoc.reference.update({'present': true});    // Öğrenci ID'si alınan öğrencinin present durumunu true olarak değiştir.
                  print('Öğrenci ($manufacturerDataString) yoklamaya alındı!');
                } else {
                  print('Öğrenci ($manufacturerDataString) veritabanında bulunamadı.');
                }
              } catch (e) {
                print('Firebase hatası (Öğrenci ID: $manufacturerDataString): $e');
              }
            }
          });
        }
      }
    });

  }


  Future<void> stopBLEScan() async {
    print('tarama durdu.');
    await FlutterBluePlus.stopScan();

  }
}

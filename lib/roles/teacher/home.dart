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
    devices.clear(); // Yeni tarama öncesi listeyi temizle
    print('tarama başladı.');

    try {
      await FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
    } catch (e) {
      print('Tarama hatası: $e');
    }

    FlutterBluePlus.scanResults.listen((results) async {
      final studentsCollection = FirebaseFirestore.instance.collection('students');

      for (ScanResult r in results) {
        if (devices.contains(r.device)) {
          continue; // Bu cihaz zaten işlendi, atla
        }
        devices.add(r.device); // Yeni cihazı listeye ekle

        final manufacturerData = r.advertisementData.manufacturerData;
        if (manufacturerData != null && manufacturerData.isNotEmpty) {
          final studentIdBytes = manufacturerData.values.first;
          final studentId = utf8.decode(studentIdBytes);
          print("Cihaz ;) = ${r.device.remoteId}");
          print("Manufacturer datake = ${r.advertisementData.manufacturerData}");


        }
      }
    });
  }


  Future<void> stopBLEScan() async {
    print('tarama durdu.');
    await FlutterBluePlus.stopScan();

  }
}

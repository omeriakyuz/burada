import 'package:burada/roles/teacher/email_auth.dart';
import 'package:burada/roles/teacher/teacher_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:burada/colors.dart';
import 'package:google_fonts/google_fonts.dart';

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

  void startBLEScan() {
    print('tarama başladı.');

  }

  void stopBLEScan() {
    print('tarama durdu.');

  }
}

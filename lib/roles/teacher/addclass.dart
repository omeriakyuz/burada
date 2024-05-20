import 'package:burada/roles/teacher/teacher_base.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:burada/roles/teacher/home.dart';
import 'package:burada/colors.dart';

import 'package:burada/roles/teacher/check_attendance.dart';
import 'package:burada/info.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AddClass extends StatefulWidget {
  const AddClass({super.key});

  @override
  _AddClassState createState() => _AddClassState();
}

class _AddClassState extends State<AddClass> {
  String? selectedSubject;
  String? selectedFaculty;
  String? selectedSemester;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController customSubjectController = TextEditingController();

  List<String> subjects = [
    'Nesneye Yönelik Programlama',
    'Algoritmalar',
    'Veritabanı',
    'Fizik II',
    'Python Programlamaya Giriş',
    'Ayrık Matematik',
  ];

  List<String> faculties = [
    'Bilgisayar Mühendisliği',
    'A',
    'B',
    'C',
    'E',
  ];

  List<String> semesters = [
    'I/I',
    'I/II',
    'II/I',
    'II/II',
    'III/I',
    'III/II',
    'IV/I',
    'IV/II'
  ];

  Future<void> addSubject() async {
    try {
      User? currentTeacher = FirebaseAuth.instance.currentUser;

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('teachers')
          .doc(currentTeacher?.uid)
          .get();

      String teacherName = userSnapshot['name'];


      await FirebaseFirestore.instance.collection('subjects').add({
        'subject': customSubjectController.text,
        'faculty': selectedFaculty,
        'semester': selectedSemester,
        'teacherName': teacherName,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check, color: Colors.white),
              SizedBox(width: 8),
              Text('Ders başarıyla eklendi.'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Clear input fields after successful addition
      setState(() {
        customSubjectController.clear();
        selectedSubject = null;
        selectedFaculty = faculties.first;
        selectedSemester = semesters.length >= 6 ? semesters[5] : null;
      });
      print('Ders eklendi.');
    } catch (e) {
      print('Ders ekleme hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return TeacherBasePage(
        title: 'Ders ekleme',
        key: _scaffoldKey,
        currentPageIndex: 1,
        buildBody: (context) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                TypeAheadField<String>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: customSubjectController,
                    decoration: InputDecoration(
                      labelText: 'Ders',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  suggestionsCallback: (pattern) {
                    return subjects.where((subject) => subject
                        .toLowerCase()
                        .startsWith(pattern.toLowerCase()));
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    customSubjectController.text = suggestion;
                    setState(() {
                      selectedSubject = suggestion;
                    });
                  },
                  noItemsFoundBuilder: (context) {
                    return Text('Ders başarıyla eklendi.');
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedFaculty,
                  // ?? faculties.first,
                  onChanged: (newValue) {
                    setState(() {
                      selectedFaculty = newValue;
                    });
                  },
                  items: faculties.map((faculty) {
                    return DropdownMenuItem<String>(
                      value: faculty,
                      child: Text(faculty),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Fakülte',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedSemester,
                  // ??
                  //     (semesters.length >= 6 ? semesters[5] : null),
                  onChanged: (newValue) {
                    setState(() {
                      selectedSemester = newValue;
                    });
                  },
                  items: semesters.map((semester) {
                    return DropdownMenuItem<String>(
                      value: semester,
                      child: Text(semester),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Dönem',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondDark,
                    foregroundColor: darkest,
                    padding: const EdgeInsets.only(
                      left: 50,
                      right: 50,
                      top: 15,
                      bottom: 15,
                    ),
                  ),
                  onPressed: () {
                    addSubject();
                  },
                  child: const Text(
                    'Gönder',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }); //Base Page
  }
}

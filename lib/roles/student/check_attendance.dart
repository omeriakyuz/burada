import 'package:burada/roles/student/phone_auth.dart';
import 'package:burada/roles/student/student_base.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:burada/colors.dart';
import 'package:burada/info.dart';

class StudentAttendancePage extends StatefulWidget {
  const StudentAttendancePage({super.key});

  @override
  _StudentAttendancePageState createState() => _StudentAttendancePageState();
}

class _StudentAttendancePageState extends State<StudentAttendancePage> {
  int _currentPageIndex =
      1;
  List<bool> isExpandedList = List<bool>.generate(10, (index) => false);

  @override
  Widget build(BuildContext context) {
    return StudentBasePage(
      title: 'Yoklama',
      currentPageIndex: _currentPageIndex,
      buildBody: (context) => FutureBuilder(
        future: getSubjectsForCurrentSemester(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(
              color: Colors.white,
            );
          }
          if (snapshot.hasError) {
            return Text('Hata: ${snapshot.error}');
          }
          final subjects = snapshot.data!.docs;
          return ListView.builder(
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              String subjectName = subjects[index]['subject'];
              return Padding(
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 8,
                  right: 10,
                  left: 10,
                ),
                child: SubjectCard(subjectName: subjectName),
              );
            },
          );
        },
      ),
    );
  }

  Future<QuerySnapshot> getSubjectsForCurrentSemester() async {
    // Firestore'dan dönem bilgisi çek
    String currentUserSemester =
        'III/II'; // Değiştirilecek

    // Güncel kullanıcının dönem sorgusu
    return FirebaseFirestore.instance
        .collection('subjects')
        .where('semester', isEqualTo: currentUserSemester)
        .get();
  }
}

class SubjectCard extends StatefulWidget {
  final String subjectName;

  const SubjectCard({Key? key, required this.subjectName}) : super(key: key);

  @override
  _SubjectCardState createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard> {
  bool isExpanded = false;
  bool isPresent = false;

  @override
  void initState() {
    super.initState();
    fetchAttendanceStatus();
  }

  void fetchAttendanceStatus() async {

    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(rollNumberOfStudent)
        .get();
    setState(() {
      isPresent = userSnapshot['present'] ??
          false; // Mevcut olma durumunu set et
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: lightest,
      child: Column(
        children: [
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    widget.subjectName,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            trailing: GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Icon(
                isExpanded ? Icons.visibility_off : Icons.visibility,
                color: darkest,
              ),
            ),
          ),
          Visibility(
            visible: isExpanded,
            child: SizedBox(
              height: 50,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Text(
                  'Yoklama Durumun: ${isPresent ? 'Mevcut' : 'Yok'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

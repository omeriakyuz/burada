import 'package:burada/roles/teacher/teacher_base.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:burada/colors.dart';
import 'package:burada/roles/teacher/email_auth.dart';
import 'package:intl/intl.dart';

class TeacherAttendancePage extends StatefulWidget {
  const TeacherAttendancePage({Key? key}) : super(key: key);

  @override
  _TeacherAttendancePageState createState() => _TeacherAttendancePageState();
}

class _TeacherAttendancePageState extends State<TeacherAttendancePage> {
  String? selectedSubject;
  List<String> teacherSubjects = [];

  @override
  void initState() {
    super.initState();
    loadTeacherSubjects();
  }

  Future<void> loadTeacherSubjects() async {
    final QuerySnapshot subjectsSnapshot = await FirebaseFirestore.instance
        .collection('subjects')
        .where('teacherName', isEqualTo: currentTeacher)
        .get();

    setState(() {
      teacherSubjects = subjectsSnapshot.docs
          .map((doc) => doc['subject'] as String)
          .toList();
      if (teacherSubjects.isNotEmpty) {
        selectedSubject = teacherSubjects.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TeacherBasePage(
      title: 'Yoklama Kayıtları',
      currentPageIndex: 1,
      buildBody: (context) => Column(
        children: [
          if (teacherSubjects.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: lightest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<String>(
                  value: selectedSubject,
                  isExpanded: true,
                  dropdownColor: lightest,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  items: teacherSubjects.map((String subject) {
                    return DropdownMenuItem<String>(
                      value: subject,
                      child: Text(subject),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSubject = newValue;
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('attendanceRecords')
                    .where('subjectName', isEqualTo: selectedSubject)
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Hata: ${snapshot.error}',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'Bu ders için yoklama kaydı bulunmamaktadır.',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final record = snapshot.data!.docs[index];
                      final data = record.data() as Map<String, dynamic>;
                      return AttendanceRecord(
                        date: data['date'] as String,
                        studentList: Map<String, bool>.from(data['studentList'] as Map),
                      );
                    },
                  );
                },
              ),
            ),
          ] else
            Center(
              child: Text(
                'Henüz ders atamanız bulunmamaktadır.',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

class AttendanceRecord extends StatefulWidget {
  final String date;
  final Map<String, bool> studentList;

  const AttendanceRecord({
    Key? key,
    required this.date,
    required this.studentList,
  }) : super(key: key);

  @override
  _AttendanceRecordState createState() => _AttendanceRecordState();
}

class _AttendanceRecordState extends State<AttendanceRecord> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    int presentCount = widget.studentList.values.where((present) => present).length;
    int totalCount = widget.studentList.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: lightest,
        elevation: 4,
        child: ExpansionTile(
          title: Text(
            widget.date,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          subtitle: Text(
            'Katılım: $presentCount/$totalCount',
            style: TextStyle(
              color: Colors.black87,
            ),
          ),
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Öğrenci Ara...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Öğrenci Listesi:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  ...widget.studentList.entries.map((entry) {
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(entry.key)
                          .get(),
                      builder: (context, studentSnapshot) {
                        if (!studentSnapshot.hasData) {
                          return SizedBox.shrink();
                        }

                        final studentData = studentSnapshot.data!.data() as Map<String, dynamic>;
                        final studentName = studentData['name'] as String;

                        if (searchQuery.isNotEmpty &&
                            !studentName.toLowerCase().contains(searchQuery) &&
                            !entry.key.toLowerCase().contains(searchQuery)) {
                          return SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Icon(
                                entry.value ? Icons.check_circle : Icons.cancel,
                                color: entry.value ? Colors.green : Colors.red,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '$studentName (${entry.key})',
                                  style: TextStyle(
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

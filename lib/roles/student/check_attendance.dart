import 'package:burada/roles/student/student_base.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:burada/colors.dart';
import 'package:burada/info.dart';
import 'package:intl/intl.dart';
import 'package:burada/roles/student/phone_auth.dart';


class StudentAttendancePage extends StatefulWidget {
  const StudentAttendancePage({super.key});

  @override
  _StudentAttendancePageState createState() => _StudentAttendancePageState();
}

class _StudentAttendancePageState extends State<StudentAttendancePage> {
  int _currentPageIndex = 1;

  @override
  Widget build(BuildContext context) {
    return StudentBasePage(
      title: 'Yoklama Kayıtları',
      currentPageIndex: _currentPageIndex,
      buildBody: (context) => StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('subjects')
            .where('studentList', arrayContains: rollNumberOfStudent)
            .snapshots(),
        builder: (context, subjectsSnapshot) {
          if (subjectsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }

          if (subjectsSnapshot.hasError) {
            return Center(
              child: Text(
                'Hata: ${subjectsSnapshot.error}',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          if (!subjectsSnapshot.hasData || subjectsSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Henüz kayıtlı olduğunuz ders bulunmamaktadır.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            itemCount: subjectsSnapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final subject = subjectsSnapshot.data!.docs[index];
              final subjectName = subject['subject'] as String;

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
                      subjectName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('attendanceRecords')
                          .where('subjectName', isEqualTo: subjectName)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Text(
                            'Yükleniyor...',
                            style: TextStyle(color: Colors.black54),
                          );
                        }

                        int totalClasses = snapshot.data!.docs.length;
                        int attendedClasses = 0;

                        for (var doc in snapshot.data!.docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          final studentList = Map<String, bool>.from(data['studentList'] as Map);
                          if (studentList[rollNumberOfStudent] == true) {
                            attendedClasses++;
                          }
                        }

                        return Text(
                          'Katılım: $attendedClasses/$totalClasses',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('attendanceRecords')
                            .where('subjectName', isEqualTo: subjectName)
                            .orderBy('date', descending: true)
                            .snapshots(),
                        builder: (context, recordsSnapshot) {
                          if (recordsSnapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (!recordsSnapshot.hasData || recordsSnapshot.data!.docs.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Bu ders için yoklama kaydı bulunmamaktadır.',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: recordsSnapshot.data!.docs.length,
                            itemBuilder: (context, recordIndex) {
                              final record = recordsSnapshot.data!.docs[recordIndex];
                              final data = record.data() as Map<String, dynamic>;
                              final date = data['date'] as String;
                              final studentList = Map<String, bool>.from(data['studentList'] as Map);
                              final isPresent = studentList[rollNumberOfStudent] ?? false;

                              return ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                                title: Text(
                                  date,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                trailing: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isPresent ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    isPresent ? 'Katıldı' : 'Katılmadı',
                                    style: TextStyle(
                                      color: isPresent ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:burada/roles/teacher/attendance.dart';
import 'package:burada/roles/teacher/email_auth.dart';
import 'package:burada/roles/teacher/teacher_base.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:burada/colors.dart';
import 'package:burada/roles/teacher/home.dart';
import 'package:burada/info.dart';
import 'package:burada/animation.dart';

class TeacherAttendancePage extends StatelessWidget {
  const TeacherAttendancePage({Key? key});

  @override
  Widget build(BuildContext context) {
    return TeacherBasePage(
      title: 'Yoklama Kayıtları',
      currentPageIndex: 2,
      buildBody: (context) => StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('subjects').snapshots(),
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
              final Map<String, dynamic> data =
                  documents[index].data() as Map<String, dynamic>;
              final String subjectName = data['subject'];
              final String teacherName = data['teacherName'];
              return FutureBuilder<bool>(
                future: isTeacherAssociatedWithSubject(teacherName),
                builder: (context, teacherAssociatedSnapshot) {
                  if (teacherAssociatedSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator(color: Colors.white);
                  }

                  if (teacherAssociatedSnapshot.hasError) {
                    return Text('Hata: ${teacherAssociatedSnapshot.error}');
                  }

                  final bool isTeacherAssociated =
                      teacherAssociatedSnapshot.data ?? false;

                  if (isTeacherAssociated) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        top: 8,
                        bottom: 8,
                        right: 10,
                        left: 10,
                      ),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 3,
                        color: lightest,
                        child: ListTile(
                          title: Text(
                            subjectName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          trailing: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                PageTransitionAnimation(
                                  page: AttendanceTable(),
                                ),
                              ); // Handle onTap
                            },
                            child: const Icon(Icons.edit, color: Colors.black),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox(); // Return an empty container if the teacher is not associated with the subject
                  }
                },
              );
            },
          );
        },
      ),
    ); //Base Page
  }

  Future<bool> isTeacherAssociatedWithSubject(String teacherName) async {
    return teacherName == currentTeacher;
  }
}

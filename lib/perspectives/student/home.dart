import 'package:burada/perspectives/student/settings.dart';
import 'package:burada/perspectives/student/student_base.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:burada/colors.dart';
import 'package:burada/main.dart';
// import 'package:student/check_attendance.dart';
import 'package:burada/info.dart';
import 'package:burada/animation.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({Key? key}) : super(key: key);

  @override
  _StudentHomePageState createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return StudentBasePage(
      title: 'Dashboard',
      currentPageIndex: _currentPageIndex,
      buildBody: (context) => FutureBuilder(
        future: getSubjectsForCurrentSemester(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(
              color: Colors.white,
            );
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          final subjects = snapshot.data!.docs;
          return ListView.builder(
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                String subjectName = subjects[index]['subject'];
                String teacherName = subjects[index]['teacherName'];
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
                    color: lightest,
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              '$subjectName',
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              '$teacherName',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                          )
                        ],
                      ),
                      trailing: SizedBox(
                        width: 100,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                PageTransitionAnimation(
                                  page: MyHomePage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: middle,
                              textStyle: const TextStyle(fontSize: 15),
                            ),
                            child: const Text(
                              'Attend',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              });
        },
      ),
    );
  }

  Future<QuerySnapshot> getSubjectsForCurrentSemester() async {
    // Get the current user's semester from Firestore or any other source
    String currentUserSemester =
        'III/II'; // Example value, replace it with your logic

    // Query subjects where the 'semester' field matches the current user's semester
    return FirebaseFirestore.instance
        .collection('subjects')
        .where('semester', isEqualTo: currentUserSemester)
        .get();
  }
}

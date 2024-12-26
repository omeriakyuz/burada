import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AttendanceReportPage extends StatefulWidget {
  final String subjectName;

  const AttendanceReportPage({Key? key, required this.subjectName}) : super(key: key);

  @override
  _AttendanceReportPageState createState() => _AttendanceReportPageState();
}

class _AttendanceReportPageState extends State<AttendanceReportPage> {
  String searchQuery = '';
  List<MapEntry<String, bool>> presentStudents = [];
  List<MapEntry<String, bool>> absentStudents = [];
  Map<String, Map<String, dynamic>> studentDataMap = {};
  bool isReportSaved = false;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    var snapshot = await FirebaseFirestore.instance.collection('subjects').doc(widget.subjectName).get();
    if (snapshot.exists) {
      var studentList = Map<String, bool>.from(snapshot.data()!['studentList'] as Map);
      var studentsCollection = FirebaseFirestore.instance.collection('users');

      for (var student in studentList.entries) {
        var studentDoc = await studentsCollection.doc(student.key).get();
        if (studentDoc.exists) {
          studentDataMap[student.key] = studentDoc.data() as Map<String, dynamic>;
        }
      }

      setState(() {
        presentStudents = studentList.entries.where((entry) => entry.value).toList();
        absentStudents = studentList.entries.where((entry) => !entry.value).toList();
      });
    }
  }

  Future<void> saveReport() async {
    if (isReportSaved) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rapor zaten kaydedildi.')));
      return;
    }

    String date = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now().toUtc().add(Duration(hours: 3)));
    String subjectName = widget.subjectName;
    Map<String, bool> studentList = {
      for (var student in presentStudents) student.key: true,
      for (var student in absentStudents) student.key: false,
    };

    await FirebaseFirestore.instance.collection('attendanceRecords').add({
      'date': date,
      'subjectName': subjectName,
      'studentList': studentList,
    });

    setState(() {
      isReportSaved = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rapor kaydedildi.')));
  }

  @override
  Widget build(BuildContext context) {
    var attendanceRate = (presentStudents.length / (presentStudents.length + absentStudents.length)) * 100;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Yoklama Raporu - ${widget.subjectName}'),
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Katılım Oranı'),
              Tab(text: 'Katılanlar'),
              Tab(text: 'Katılmayanlar'),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Katılım Oranı: ${attendanceRate.toStringAsFixed(2)}%',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    color: Colors.green,
                                    value: presentStudents.length.toDouble(),
                                    title: '${attendanceRate}%',
                                    radius: 50,
                                    titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                  PieChartSectionData(
                                    color: Colors.red,
                                    value: absentStudents.length.toDouble(),
                                    title: '${(100-attendanceRate)}%',
                                    radius: 50,
                                    titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                ],
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Container(width: 16, height: 16, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text('Katılan', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              SizedBox(width: 32),
                              Row(
                                children: [
                                  Container(width: 16, height: 16, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Katılmayan', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  buildStudentList(presentStudents, 'Katılanların Sayısı: ${presentStudents.length}'),
                  buildStudentList(absentStudents, 'Katılmayanların Sayısı: ${absentStudents.length}'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                onPressed: saveReport,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.upload, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Raporu Yükle', style: TextStyle(color: Colors.white, fontSize: 18)),
                  ],
                ),              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStudentList(List<MapEntry<String, bool>> students, String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Ara',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
            SizedBox(height: 8),
            Expanded(
              child: students.isEmpty
                  ? Text('Öğrenci yok', style: TextStyle(color: Colors.black54))
                  : ListView(
                children: students
                    .where((student) => student.key.toLowerCase().contains(searchQuery) || studentDataMap[student.key]!['name'].toLowerCase().contains(searchQuery))
                    .map((student) {
                  var studentData = studentDataMap[student.key]!;
                  String profileImageUrl = studentData['profilePicture'];
                  String studentName = studentData['name'];

                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(profileImageUrl),
                    ),
                    title: Text(studentName, style: TextStyle(color: Colors.black)),
                    subtitle: Text(student.key, style: TextStyle(color: Colors.black54)),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
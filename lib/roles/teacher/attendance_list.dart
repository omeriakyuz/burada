// attendance_list.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:intl/intl.dart';
import 'attendance_report.dart';

class AttendancePage extends StatefulWidget {
  final String subjectName;

  const AttendancePage({Key? key, required this.subjectName}) : super(key: key);

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isClassStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> startBLEScan() async {
    List<BluetoothDevice> devices = [];
    devices.clear();
    print('tarama başladı.');

    await FlutterBluePlus.startScan();

    FlutterBluePlus.scanResults.listen((results) async {
      final studentsCollection = FirebaseFirestore.instance.collection('users');
      final subjectDocRef = FirebaseFirestore.instance.collection('subjects').doc(widget.subjectName);


      for (ScanResult r in results) {
        if (devices.contains(r.device)) {
          continue;
        }
        devices.add(r.device);

        final manufacturerData = r.advertisementData.manufacturerData;
        if (manufacturerData != null && manufacturerData.isNotEmpty) {
          r.advertisementData.manufacturerData.forEach((manufacturerId, listData) async {
            if (manufacturerId == 65535) {
              var manufacturerDataString = String.fromCharCodes(listData);
              print('listData: $manufacturerDataString');
              try {

                final studentDoc = await studentsCollection.doc(manufacturerDataString).get();
                if (studentDoc.exists) {
                  await studentDoc.reference.update({'present': true});
                  await subjectDocRef.update({
                    'studentList.$manufacturerDataString': true,
                  });
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
  void toggleAttendance() {
    if (_isClassStarted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Yoklamayı Durdur'),
            content: Text('Yoklamayı durdurmak istediğinize emin misiniz?'),
            actions: <Widget>[
              TextButton(
                child: Text('Hayır'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Evet'),
                onPressed: () {
                  setState(() {
                    _isClassStarted = false;
                  });
                  stopBLEScan();
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AttendanceReportPage(subjectName: widget.subjectName),
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        _isClassStarted = true;
      });
      startBLEScan();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yoklama Listesi'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${DateFormat('dd/MM/yyyy').format(DateTime.now())} tarihli ${widget.subjectName} dersi için yoklama alınıyor. Öğrenci listesi:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('subjects')
                  .doc(widget.subjectName)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.data!.exists) {
                  return Center(child: Text('Belge bulunamadı.'));
                }

                var studentList = Map<String, bool>.from(snapshot.data!['studentList'] as Map);

                return ListView.builder(
                  itemCount: studentList.length,
                  itemBuilder: (context, index) {
                    String studentId = studentList.keys.elementAt(index);
                    bool isPresent = studentList[studentId] ?? false;

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(studentId).get(),
                      builder: (context, studentSnapshot) {
                        if (studentSnapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (!studentSnapshot.hasData || !studentSnapshot.data!.exists) {
                          return ListTile(
                            title: Text('Öğrenci bulunamadı'),
                          );
                        }

                        var studentData = studentSnapshot.data!.data() as Map<String, dynamic>;
                        String profileImageUrl = studentData['profilePicture'];
                        String studentName = studentData['name'];

                        return Card(
                          color: Colors.blue.shade100,
                          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(profileImageUrl),
                            ),
                            title: Text(
                              studentName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(studentId),
                            trailing: Icon(
                              isPresent ? Icons.check_circle : Icons.cancel,
                              color: isPresent ? Colors.green : Colors.red,
                              size: 30,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Opacity(
                  opacity: _animation.value,
                  child: Text(
                    'Yoklama işlemi sürüyor...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: toggleAttendance,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isClassStarted ? Colors.red : Colors.green,
                padding: EdgeInsets.symmetric(vertical: 12),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: Center(
                child: Text(
                  _isClassStarted ? 'Yoklamayı Durdur' : 'Yoklamayı Başlat',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
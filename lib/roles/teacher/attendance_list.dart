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
  Map<String, bool> attendanceMap = {};

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

    // Dersin öğrenci listesini al
    final subjectDoc = await FirebaseFirestore.instance.collection('subjects').doc(widget.subjectName).get();
    if (!subjectDoc.exists) {
      print('Ders bulunamadı.');
      return;
    }

    // Öğrenci listesini array'den al ve attendance map'i oluştur
    List<String> studentList = List<String>.from(subjectDoc.data()!['studentList'] as List);
    attendanceMap.clear();
    for (String studentId in studentList) {
      attendanceMap[studentId] = false;
    }

    await FlutterBluePlus.startScan();

    FlutterBluePlus.scanResults.listen((results) async {
      final studentsCollection = FirebaseFirestore.instance.collection('users');

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
                // Öğrenci ID'si ders listesinde var mı kontrol et
                if (studentList.contains(manufacturerDataString)) {
                  attendanceMap[manufacturerDataString] = true;
                  setState(() {});
                  print('Öğrenci ($manufacturerDataString) yoklamaya alındı!');
                } else {
                  print('Öğrenci ($manufacturerDataString) bu dersin listesinde değil.');
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
                onPressed: () async {
                  setState(() {
                    _isClassStarted = false;
                  });
                  stopBLEScan();

                  // Yoklama kaydını oluştur
                  String date = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
                  await FirebaseFirestore.instance.collection('attendanceRecords').add({
                    'date': date,
                    'subjectName': widget.subjectName,
                    'studentList': attendanceMap,
                  });

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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (_isClassStarted) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Yoklamayı İptal Et'),
                    content: Text('Şuan çıkmak yoklamayı iptal edecektir. Çıkmak istediğinize emin misiniz?'),
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
                          stopBLEScan();
                          Navigator.of(context).pop(); // Dialog'u kapat
                          Navigator.of(context).pop(); // Sayfadan çık
                        },
                      ),
                    ],
                  );
                },
              );
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
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

                List<String> studentList = List<String>.from(snapshot.data!['studentList'] as List);

                return ListView.builder(
                  itemCount: studentList.length,
                  itemBuilder: (context, index) {
                    String studentId = studentList[index];

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
                              attendanceMap[studentId] == true
                                  ? Icons.check_circle
                                  : _isClassStarted
                                  ? Icons.pending
                                  : Icons.cancel,
                              color: attendanceMap[studentId] == true
                                  ? Colors.green
                                  : _isClassStarted
                                  ? Colors.grey
                                  : Colors.red,
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
            child: _isClassStarted ? AnimatedBuilder(
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
            ) : SizedBox(),
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
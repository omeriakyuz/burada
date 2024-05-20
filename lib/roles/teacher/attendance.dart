import 'package:burada/colors.dart';
import 'package:burada/info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:burada/animation.dart';

class AttendanceTable extends StatefulWidget {
  const AttendanceTable({super.key});

  @override
  State<AttendanceTable> createState() => _AttendanceTableState();
}

class _AttendanceTableState extends State<AttendanceTable> {
  @override
  Widget build(BuildContext context) {
    final databaseReference = FirebaseDatabase.instance.ref().child('CMPE');
    final firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yoklama'),
        backgroundColor: darkest,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.info_outlined,
              color: lightest,
              size: 30,
            ),
            onPressed: () {
              Navigator.of(context).push(
                PageTransitionAnimation(
                  page: InfoPage(),
                ),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: FutureBuilder(
            future: FirebaseFirestore.instance.collection('users').get(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(
                  color: Colors.white,
                );
              }
              if (snapshot.hasError) {
                return Text('Hata: ${snapshot.error}');
              }
              final users = snapshot.data!.docs;
              return SingleChildScrollView(
                child: DataTable(
                  columns: <DataColumn>[
                    DataColumn(
                      label: Text(
                        'Öğr. No',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    const DataColumn(
                      label: Text(
                        'İsim',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        DateFormat('dd-MM-yyyy').format(DateTime.now()),
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    const DataColumn(
                      label: Text(
                        'Telefon No.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                  rows: List<DataRow>.generate(
                    users.length,
                        (index) => DataRow(
                      cells: <DataCell>[
                        DataCell(
                          Text(users[index]['rollNo']),
                        ),
                        DataCell(
                          Text(users[index]['name']),
                        ),
                        DataCell(
                          Row(
                            children: [
                              FutureBuilder(
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(users[index].id)
                                    .get(),
                                builder: (context,
                                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator(
                                        color: Colors.white);
                                  }
                                  if (snapshot.hasError) {
                                    return Text('Hata: ${snapshot.error}');
                                  }
                                  var present = snapshot.data!['present'];
                                  return DropdownButton<String>(
                                    onChanged: (String? newValue) async {
                                      if (newValue != null) {
                                        bool updatedValue =
                                        newValue == 'Mevcut' ? true : false;
                                        // Update the Firestore document with the selected value
                                        await firestore
                                            .collection('users')
                                            .doc(users[index].id)
                                            .update({
                                          'present': updatedValue,
                                        }).then((_) {
                                          setState(() {
                                            present = updatedValue;
                                          });
                                        });
                                      }
                                    },
                                    value: present == true ? 'Mevcut' : 'Yok',
                                    items: <String>['Yok', 'Mevcut']
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Text(users[index]['phoneNo']),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
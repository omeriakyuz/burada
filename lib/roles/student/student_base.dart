import 'package:burada/roles/student/check_attendance.dart';
import 'package:burada/roles/student/home.dart';
import 'package:burada/roles/student/phone_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:burada/colors.dart';
import 'package:burada/info.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:burada/roles/student/settings.dart';
import 'package:burada/animation.dart';


import '../../initialPage.dart';


class StudentBasePage extends StatelessWidget {
  final String title;
  final Widget Function(BuildContext) buildBody;
  final int currentPageIndex;

  const StudentBasePage({
    Key? key,
    required this.title,
    required this.buildBody,
    required this.currentPageIndex,
  }) : super(key: key);

  Future<Map<String, dynamic>> fetchStudentInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    print('User UID: ${user!.uid}');
    print('rollNumberOfStudent: $rollNumberOfStudent');
    print('User: $user');
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(rollNumberOfStudent).get();
      return doc.data() as Map<String, dynamic>;
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: darkest,
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(
              Icons.menu,
              size: 30,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      body: buildBody(context),
      bottomNavigationBar: Container(
        color: darkest,
        height: 60,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 0),
            child: GNav(
              iconSize: 30,
              textSize: 20,
              backgroundColor: darkest,
              color: Colors.white,
              activeColor: Colors.white,
              tabBackgroundColor: middle,
              gap: 10,
              selectedIndex: currentPageIndex,
              onTabChange: (index) {
                if (index == currentPageIndex) return;
                
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) => StudentHomePage(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                } else if (index == 1) {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) => StudentAttendancePage(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                }
              },
              tabs: [
                GButton(
                  icon: Icons.home,
                  text: 'Anasayfa',
                  padding: EdgeInsets.all(10),
                ),
                GButton(
                  icon: Icons.assignment,
                  text: 'Yoklama',
                  padding: EdgeInsets.all(10),
                ),
              ],
            )),
      ),
      drawer: FutureBuilder<Map<String, dynamic>>(
        future: fetchStudentInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Drawer(
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Drawer(
              child: Center(child: Text('Hata: ${snapshot.error}')),
            );
          } else {
            var studentInfo = snapshot.data!;
            return Drawer(
              width: 250,
              child: ListView(
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(studentInfo['name']),
                    accountEmail: Text(studentInfo['rollNo']),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: studentInfo['profilePicture'].isNotEmpty
                          ? NetworkImage(studentInfo['profilePicture'])
                          : AssetImage('assets/images/blank-profile.png') as ImageProvider,
                    ),
                    decoration: BoxDecoration(
                      color: darkest,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Ayarlar'),
                    onTap: () {
                      Navigator.of(context).push(
                        PageTransitionAnimation(
                          page: StudentSettingsPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('Hakkında'),
                    onTap: () {
                      Navigator.of(context).push(
                        PageTransitionAnimation(
                          page: InfoPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Çıkış Yap'),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => ChooseRolePage()),
                      );
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
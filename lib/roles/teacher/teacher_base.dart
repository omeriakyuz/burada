import 'package:burada/roles/teacher/addclass.dart';
import 'package:burada/roles/teacher/check_attendance.dart';
import 'package:burada/roles/teacher/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:burada/colors.dart';
import 'package:burada/info.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:burada/roles/teacher/settings.dart';
import 'package:burada/animation.dart';

import '../../initialPage.dart';

class TeacherBasePage extends StatelessWidget {
  final String title;
  final Widget Function(BuildContext) buildBody;
  final int currentPageIndex;

  const TeacherBasePage({
    Key? key,
    required this.title,
    required this.buildBody,
    required this.currentPageIndex,
  }) : super(key: key);

  Future<Map<String, dynamic>> fetchTeacherInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    print('User UID: ${user!.uid}');
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('teachers').doc(user.uid).get();
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
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
            child: GNav(
              iconSize: 30,
              textSize: 20,
              backgroundColor: darkest,
              color: Colors.white,
              activeColor: Colors.white,
              tabBackgroundColor: middle,
              gap: 10,
              tabs: [
                GButton(
                  icon: Icons.home,
                  text: 'Anasayfa',
                  onPressed: () {
                    Navigator.of(context).push(
                      PageTransitionAnimation(
                        page: TeacherHomePage(),
                      ),
                    );
                  },
                  padding: EdgeInsets.all(10),
                ),
                GButton(
                  icon: Icons.add_circle_outline_outlined,
                  text: 'Sınıf Ekle',
                  onPressed: () {
                    Navigator.of(context).push(
                      PageTransitionAnimation(
                        page: AddClass(),
                      ),
                    );
                  },
                  padding: EdgeInsets.all(10),
                ),
                GButton(
                  icon: Icons.assignment,
                  text: 'Yoklama',
                  onPressed: () {
                    Navigator.of(context).push(
                      PageTransitionAnimation(
                        page: TeacherAttendancePage(),
                      ),
                    );
                  },
                  padding: EdgeInsets.all(10),
                ),
              ],
              selectedIndex: currentPageIndex,
            )),
      ),
      drawer: FutureBuilder<Map<String, dynamic>>(
        future: fetchTeacherInfo(),
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
            var teacherInfo = snapshot.data!;
            return Drawer(
              child: ListView(
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(teacherInfo['name']),
                    accountEmail: Text(teacherInfo['email']),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: teacherInfo['profilePicture'].isNotEmpty
                          ? NetworkImage(teacherInfo['profilePicture'])
                          : AssetImage('assets/images/blank-profile.png') as ImageProvider,
                    ),
                    decoration: BoxDecoration(
                      color: darkest,
                    ),
                  ),
                  ListTile(
                    title: const Text('Ayarlar'),
                    onTap: () {
                      Navigator.of(context).push(
                        PageTransitionAnimation(
                          page: TeacherSettingsPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
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
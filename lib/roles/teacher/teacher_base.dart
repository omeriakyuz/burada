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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: darkest,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
              icon: Icon(
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
              })
        ],
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
              // tabMargin: EdgeInsets.all(1),
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
      drawer: Drawer(
        child: ListView(
          children: [
            Container(
              height: 100,
              child: const DrawerHeader(
                decoration: BoxDecoration(
                  color: darkest,
                ),
                padding: EdgeInsets.all(20),
                child: Text(
                  'Menü',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                  ),
                ),
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
      ),
    );
  }
}

import 'package:burada/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:burada/perspectives/student/home.dart';
import 'package:burada/info.dart';
import 'package:burada/animation.dart';

class StudentLoginPage extends StatefulWidget {
  const StudentLoginPage({super.key});

  @override
  State<StudentLoginPage> createState() => _StudentLoginPageState();
}

class _StudentLoginPageState extends State<StudentLoginPage> {
  late final LocalAuthentication auth;
  bool _supportState = false;

  @override
  void initState() {
    super.initState();
    auth = LocalAuthentication();
    auth.isDeviceSupported().then(
          (bool isSupported) => setState(() {
            _supportState = isSupported;
          }),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkest,
        foregroundColor: Colors.white,
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
              })
        ],
        title: const Text('Login as Student'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Login with Fingerprint',
              style: TextStyle(
                  fontSize: 30, color: darkest, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: 40,
            ),
            const SizedBox(
                width: 350,
                child: Text(
                  'Click on the icon below to authenticate yourself with your fingerprint and continue to the app.',
                  textAlign: TextAlign.center,
                )),
            IconButton(
              onPressed: _authenticate,
              icon: const Icon(Icons.fingerprint_outlined),
              iconSize: 300.0, // Adjust size as needed
              tooltip: 'Authenticate with Biometrics',
              color: secondDark,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _authenticate() async {
    try {
      bool authenticated = await auth.authenticate(
          localizedReason:
              'You must authenticate yourself to continue to the app.',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ));

      print('Authenticated: $authenticated');
      if (authenticated) {
        // Navigate to the main page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const StudentHomePage()),
          (route) => false,
        );
      }
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();

    print("List of available biometrics: $availableBiometrics");

    if (!mounted) {
      return;
    }
  }
}

//import 'package:ble_advertiser/login.dart';
import 'package:burada/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:burada/roles/student/login.dart';
import 'package:burada/roles/student/home.dart';
import 'package:burada/info.dart';
import 'package:burada/animation.dart';
import 'package:flutter/services.dart';

String rollNumberOfStudent = '';

class StudentPhoneAuth extends StatefulWidget {
  const StudentPhoneAuth({super.key});

  @override
  State<StudentPhoneAuth> createState() => _StudentPhoneAuthState();
}

class _StudentPhoneAuthState extends State<StudentPhoneAuth> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  String userNumber = '';
  var otpFieldVisibility = false;
  var receivedID = '';

  void verifyUserPhoneNumber() {
    auth.verifyPhoneNumber(
      phoneNumber: userNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          final userCredential = await auth.signInWithCredential(credential);
          await fetchUserDocument(userCredential.user!.phoneNumber!);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const StudentHomePage()),
                (route) => false,
          );
        } on FirebaseAuthException catch (e) {
          print("***HATA***: ${e.code} - ${e.message}");
          switch (e.code) {
            case 'invalid-verification-code':
              _showSnackbar('Geçersiz doğrulama kodu.');
            case 'invalid-verification-id':
              _showSnackbar('Geçersiz doğrulama ID\'si.');
            case 'session-expired':
              _showSnackbar('Doğrulama süresi doldu. Lütfen tekrar deneyin.');
            case 'network-request-failed':
              _showSnackbar('İnternet bağlantınızı kontrol edip tekrar deneyin.');
            case 'too-many-requests':
              _showSnackbar('Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.');
            default:
              _showSnackbar('Giriş yapılırken bir hata oluştu. (${e.code})');
          }
        } catch (e) {
          print("***GENEL HATA***: $e");
          _showSnackbar('Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.');
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        print("***DOĞRULAMA HATASI***: ${e.code} - ${e.message}");
        switch (e.code) {
          case 'invalid-phone-number':
            _showSnackbar('Geçersiz telefon numarası formatı.');
          case 'invalid-verification-code':
            _showSnackbar('Geçersiz doğrulama kodu.');
          case 'too-many-requests':
            _showSnackbar('Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.');
          case 'operation-not-allowed':
            _showSnackbar('Telefon doğrulaması şu anda kullanılamıyor.');
          case 'quota-exceeded':
            _showSnackbar('SMS kotası aşıldı. Lütfen daha sonra tekrar deneyin.');
          case 'user-disabled':
            _showSnackbar('Bu hesap devre dışı bırakılmış.');
          default:
            _showSnackbar('Doğrulama sırasında hata: ${e.code}');
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        receivedID = verificationId;
        setState(() {
          otpFieldVisibility = true;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _showSnackbar('SMS kodu zaman aşımına uğradı. Lütfen tekrar deneyin.');
      },
    );
  }

  Future<void> verifyOTPCode() async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: receivedID,
        smsCode: otpController.text,
      );

      final userCredential = await auth.signInWithCredential(credential);
      await fetchUserDocument(userCredential.user!.phoneNumber!);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const StudentHomePage()),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      print("***OTP HATASI***: ${e.code} - ${e.message}");
      switch (e.code) {
        case 'invalid-verification-code':
          _showSnackbar('SMS kodu hatalı. Lütfen kontrol edip tekrar deneyin.');
        case 'invalid-verification-id':
          _showSnackbar('Doğrulama oturumu geçersiz. Tekrar kod talep edin.');
        case 'session-expired':
          _showSnackbar('Doğrulama süresi doldu. Yeni kod talep edin.');
        case 'network-request-failed':
          _showSnackbar('İnternet bağlantınızı kontrol edip tekrar deneyin.');
        default:
          _showSnackbar('Doğrulama sırasında hata oluştu. (${e.code})');
      }
    } catch (e) {
      print("***GENEL HATA***: $e");
      _showSnackbar('Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 3)),
    );
  }

  Future<void> fetchUserDocument(String phoneNumber) async {
    try {
      CollectionReference users = FirebaseFirestore.instance.collection('users');
      QuerySnapshot querySnapshot = await users.where('phoneNo', isEqualTo: phoneNumber).get();

      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        rollNumberOfStudent = userData['rollNo'];
        print('Kullanıcı bilgisi alındı: $userData');
      } else {
        print('Kullanıcı bulunamadı');
      }
    } catch (e) {
      print('Veri tabanından bilgi alırken hata oluştu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        textTheme: GoogleFonts.nunitoTextTheme(),
        primarySwatch: Colors.blue,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: darkest,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
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
          title: const Text(
            'Öğrenci Girişi',
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 100,
              ),
              const Text(
                'Sisteme kayıtlı telefon numaranızı kullanarak giriş yapabilirsiniz.',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    prefixText: '+90 ',
                    hintText: 'XXXXXXXXXX',
                    labelText: 'Telefon Numarası',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.phone,
                  onChanged: (val) {
                    userNumber = '+90' + val;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Visibility(
                  visible: otpFieldVisibility,
                  child: TextField(
                    controller: otpController,
                    decoration: InputDecoration(
                      hintText: '111111',
                      labelText: 'SMS Kodu',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    keyboardType: TextInputType.number, // Sadece sayıları kabul et
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // Sadece rakam girişi
                      LengthLimitingTextInputFormatter(6), // Maksimum 6 haneli giriş
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (otpFieldVisibility) {
                    verifyOTPCode();
                  } else {
                    verifyUserPhoneNumber();
                  }
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.only(
                      left: 40,
                      right: 40,
                      top: 15,
                      bottom: 15,
                    ),
                    backgroundColor: secondDark,
                    foregroundColor: Colors.white),
                child: const Text('Doğrula'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

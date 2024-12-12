import 'dart:io';
import 'package:burada/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:image/image.dart' as img;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:camera/camera.dart';

class FaceVerificationPage extends StatefulWidget {
  final String rollNumber;
  FaceVerificationPage({required this.rollNumber});

  @override
  _FaceVerificationPageState createState() => _FaceVerificationPageState();
}

class _FaceVerificationPageState extends State<FaceVerificationPage> {
  CameraController? _cameraController;
  bool isLoading = false;
  final FaceVerificationService _service = FaceVerificationService();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front);
    _cameraController = CameraController(frontCamera, ResolutionPreset.medium);
    await _cameraController!.initialize();
    setState(() {});
  }

  Future<void> _takePicture() async {
    setState(() {
      isLoading = true;
    });
    try {
      final image = await _cameraController!.takePicture();
      final compressedImage = await _compressImage(File(image.path));
      final imageUrl = await _uploadImageToFirebase(compressedImage);
      final result = await _service.verifyFace(widget.rollNumber, imageUrl);
      print('Yüz doğrulama sonucu: ${result['status']}');
      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Yüz Doğrulaması Başarılı.Yoklamaya katılınıyor...')),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Yüz doğrulama başarısız: ${result['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yüz doğrulama başarısız: $e')),
      );
      print('Hata mesajı: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<File> _compressImage(File file) async {
    final image = img.decodeImage(file.readAsBytesSync())!;
    final compressedImage = img.copyResize(image, width: 600);
    final tempDir = await getTemporaryDirectory();
    final compressedImagePath = join(tempDir.path, 'compressed_image.jpg');
    final compressedImageFile = File(compressedImagePath)..writeAsBytesSync(img.encodeJpg(compressedImage, quality: 85));
    return compressedImageFile;
  }

  Future<String> _uploadImageToFirebase(File file) async {
    final storageRef = FirebaseStorage.instance.ref().child('temp_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = storageRef.putFile(file);
    await uploadTask.whenComplete(() => null);
    return await storageRef.getDownloadURL();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: Text('Yüz Doğrulama')),
      body: Stack(
        children: [
          CameraPreview(_cameraController!),
          Center(
            child: CustomPaint(
              painter: FaceMaskPainter(),
              size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _takePicture,
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondDark,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Text('Fotoğraf Çek', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FaceMaskPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.75)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2.2);
    final ovalSize = Size(size.width * 0.8, size.height * 0.75); // Oval boyutunu ayarlayın

    // Bulanık arka planı çiz
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Oval boşluğu çiz (temiz alan)
    final ovalPath = Path()..addOval(Rect.fromCenter(center: center, width: ovalSize.width, height: ovalSize.height));
    final strokePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawPath(ovalPath, strokePaint);
    canvas.drawPath(ovalPath, Paint()..blendMode = BlendMode.clear);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false; // Performansı artırmak için false döndürün, eğer maske değişmiyorsa.
  }
}

class FaceVerificationService {
  final String baseUrl = 'https://burada-app-backend-154404b6ca14.herokuapp.com';

  Future<Map<String, dynamic>> verifyFace(String uid, String imageUrl) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verifyFace'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'uid': uid,
          'image_url': imageUrl,
        }),
      );

      print('API isteği yapıldı: ${response.request}');
      print('API yanıtı: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return {'status': 'success', 'matched': result['matched']};
      } else {
        final errorResult = jsonDecode(response.body);
        return {'status': 'error', 'message': errorResult['message']};
      }
    } catch (e) {
      print('Yüz doğrulama sırasında hata oluştu: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }
}

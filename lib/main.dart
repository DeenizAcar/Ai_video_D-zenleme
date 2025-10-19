// Gerekli paketleri içe aktarıyoruz
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart'; 
import 'package:image_picker/image_picker.dart'; 
import 'dart:io'; 
import 'dart:convert'; 
import 'dart:typed_data'; 
import 'firebase_options.dart';
import 'auth_screen.dart';


// main fonksiyonumuzu 'async' olarak güncelledik
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

// Uygulamanın ana widget'ı. Giriş durumunu kontrol eder.
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Video Düzenleme',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData && snapshot.data != null) {
            return const MyHomePage(title: 'AI Video Oluşturucu');
          } else {
            return const AuthScreen();
          }
        },
      ),
    );
  }
}

// Ana sayfa widget'ımız (fotoğraf yükleme ekranı)
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = false; 
  // XFile? _selectedImage; 
  final TextEditingController _promptController = TextEditingController();
  // final ImagePicker _picker = ImagePicker(); 

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  // Video Oluşturma Fonksiyonu (Yapay Zeka Çağrısı)
  Future<void> _generateVideo() async {
    final user = FirebaseAuth.instance.currentUser;
    // SADECE prompt kontrolü yapılıyor
    if (user == null || _promptController.text.trim().isEmpty) {
      return; 
    }

    setState(() {
      _isLoading = true;
    });

    // callable değişkenini burada tanımlıyoruz
    final callable = FirebaseFunctions.instance.httpsCallable('generateVideoFromImage');

    try {
      // KESİN TEST AMAÇLI GÖMÜLÜ BASE64 KODU
      const String base64Image = 
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII='; 

      final Map<String, dynamic> requestData = {
        'image': base64Image, // <-- KESİN DOLU GÖRSEL VERİSİ
        'prompt': _promptController.text.trim(),
      };

      // ignore: avoid_print
      print('Firebase Cloud Function çağrılıyor: generateVideoFromImage...');

      // Fonksiyonu çağır ve sonucu bekle
      final HttpsCallableResult result = await callable.call(requestData);

      // ignore: avoid_print
      print('Fonksiyon Çağrısı Başarılı!');
      // ignore: avoid_print
      print('Sunucudan Yanıt: ${result.data}');
      
      // NOT: Sunucudan yanıt 200 OK geldiğinde, bu satırların çalışması gerekir.
      // Artık invalid-argument hatası almamalıyız.

    } on FirebaseFunctionsException catch (e) {
      // ignore: avoid_print
      print('Cloud Function Hatası Oluştu:');
      // ignore: avoid_print
      print('Kod: ${e.code}');
      // ignore: avoid_print
      print('Mesaj: ${e.message}');
    } catch (e) {
      // ignore: avoid_print
      print('Bilinmeyen Hata: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
    
  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Fotoğraf seçme mantığı kaldırıldığı için sadece prompt kontrolü yapıyoruz
    final bool isButtonDisabled = _isLoading || _promptController.text.trim().isEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: _signOut,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Hoş geldin mesajı
              if (user != null)
                Text('Hoş geldin, ${user.email ?? 'Kullanıcı'}!'),
              const SizedBox(height: 30),

              // FOTOĞRAF ALANI KALDIRILDIĞI İÇİN BOŞLUK BIRAKIYORUZ
              const SizedBox(height: 150),
              
              // PROMPT ALANI
              TextField(
                controller: _promptController,
                maxLines: 3,
                enabled: !_isLoading, 
                decoration: const InputDecoration(
                  labelText: 'Video için Prompt (İstek) Girin',
                  hintText: 'Örneğin: "Bu fotoğrafı hareketli, çizgi film stilinde bir videoya dönüştür."',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() {}), 
              ),

              const SizedBox(height: 20),

              // VİDEO OLUŞTUR BUTONU
              ElevatedButton.icon(
                // Sadece prompt doluysa butonu etkinleştiriyoruz
                onPressed: isButtonDisabled ? null : _generateVideo, 
                icon: _isLoading 
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.movie_creation),
                label: Text(_isLoading ? 'Oluşturuluyor...' : 'AI Video Oluştur'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
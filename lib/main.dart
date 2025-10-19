// Gerekli paketleri içe aktarıyoruz
import 'package:flutter/material.dart';
// Firebase'i çalıştırmak için 'firebase_core' paketini ekledik
import 'package:firebase_core/firebase_core.dart';
// flutterfire configure'un oluşturduğu anahtar dosyasını ekledik
import 'firebase_options.dart';

// main fonksiyonumuzu 'async' olarak güncelledik
// çünkü Firebase'in başlamasını beklememiz gerekiyor
Future<void> main() async {
  // Flutter uygulamasının donanımla (native kod) konuşmaya
  // hazır olduğundan emin oluyoruz.
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i başlatıyoruz!
  // 'firebase_options.dart' dosyasındaki anahtarları kullanacak.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firebase başladiktan sonra uygulamamızı çalıştırıyoruz
  runApp(const MyApp());
}

// Buradan sonrası, bildiğimiz standart sayaç uygulaması.
// Henüz hiçbir şeyini değiştirmedik.

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
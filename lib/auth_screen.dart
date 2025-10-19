import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Formu yönetmek için bir GlobalKey oluşturuyoruz
  final _formKey = GlobalKey<FormState>();
  // Giriş mi yoksa Kayıt mı modunda olduğumuzu tutacak değişken
  var _isLoginMode = true;
  // Kullanıcının girdiği e-posta ve şifreyi tutacak değişkenler
  var _enteredEmail = '';
  var _enteredPassword = '';
  // Firebase Auth işlemleri sırasında yüklenme durumunu göstermek için
  var _isAuthenticating = false;

  // Form gönderildiğinde çalışacak fonksiyon
  void _submitAuthForm() async {
    // Formdaki validasyonları kontrol et
    final isValid = _formKey.currentState!.validate();

    // Eğer form geçerli değilse veya zaten bir işlem yapılıyorsa, fonksiyondan çık
    if (!isValid || _isAuthenticating) {
      return;
    }

    // Formdaki verileri kaydet (onSaved fonksiyonlarını tetikler)
    _formKey.currentState!.save();

    // Yükleniyor durumunu başlat
    setState(() {
      _isAuthenticating = true;
    });

    try {
      if (_isLoginMode) {
        // Giriş yapma modundaysak
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
        // Giriş başarılı olursa, main.dart'taki StreamBuilder bizi otomatik olarak
        // MyHomePage'e yönlendirecek.
      } else {
        // Kayıt olma modundaysak
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
        // Kayıt başarılı olursa, yine otomatik olarak MyHomePage'e yönlendirileceğiz.
      }
    } on FirebaseAuthException catch (error) {
      // Firebase'den bir hata gelirse
      var errorMessage = 'Kimlik doğrulama başarısız oldu.';
      if (error.message != null) {
        errorMessage = error.message!;
      }
      // Hata mesajını ekranda göster (snackbar ile)
      if (mounted) { // Widget hala ekranda mı diye kontrol et
         ScaffoldMessenger.of(context).clearSnackBars();
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text(errorMessage),
             backgroundColor: Theme.of(context).colorScheme.error,
           ),
         );
      }
       // Yükleniyor durumunu bitir
      setState(() {
         _isAuthenticating = false;
      });

    } catch (error) {
       // Beklenmedik başka bir hata olursa
       print(error); // Hatanın ne olduğunu görmek için konsola yazdır
       if (mounted) {
         ScaffoldMessenger.of(context).clearSnackBars();
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: const Text('Beklenmedik bir hata oluştu.'),
             backgroundColor: Theme.of(context).colorScheme.error,
           ),
         );
       }
       // Yükleniyor durumunu bitir
       setState(() {
         _isAuthenticating = false;
       });
    }

    // Not: Başarılı olursa yükleniyor durumunu bitirmeye gerek yok,
    // çünkü zaten başka bir ekrana yönlenmiş olacağız.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginMode ? 'Giriş Yap' : 'Kayıt Ol'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView( // Klavye açıldığında taşmayı önlemek için
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey, // Form anahtarını bağlıyoruz
            child: Column(
              mainAxisSize: MainAxisSize.min, // İçerik kadar yer kapla
              children: [
                // E-posta giriş alanı
                TextFormField(
                  decoration: const InputDecoration(labelText: 'E-posta'),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty || !value.contains('@')) {
                      return 'Lütfen geçerli bir e-posta adresi girin.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredEmail = value!;
                  },
                ),
                const SizedBox(height: 12),
                // Şifre giriş alanı
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Şifre'),
                  obscureText: true, // Şifreyi gizle
                  validator: (value) {
                    if (value == null || value.trim().length < 6) {
                      return 'Şifre en az 6 karakter olmalıdır.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredPassword = value!;
                  },
                ),
                const SizedBox(height: 20),
                // Yükleniyor göstergesi veya Giriş/Kayıt butonu
                if (_isAuthenticating)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submitAuthForm, // Formu gönder
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Text(_isLoginMode ? 'Giriş Yap' : 'Kayıt Ol'),
                  ),
                const SizedBox(height: 12),
                // Yükleniyor değilse Mod değiştirme butonu
                 if (!_isAuthenticating)
                   TextButton(
                     onPressed: () {
                       setState(() {
                         _isLoginMode = !_isLoginMode; // Modu tersine çevir
                       });
                     },
                     child: Text(
                       _isLoginMode ? 'Yeni hesap oluştur' : 'Zaten hesabım var',
                     ),
                   ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
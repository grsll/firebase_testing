import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase berhasil diinisialisasi!");
  } catch (e) {
    print("❌ Gagal inisialisasi Firebase: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cek Firebase',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Cek Firebase')),
        body: const Center(child: FirebaseCheckWidget()),
      ),
    );
  }
}

class FirebaseCheckWidget extends StatefulWidget {
  const FirebaseCheckWidget({super.key});

  @override
  State<FirebaseCheckWidget> createState() => _FirebaseCheckWidgetState();
}

class _FirebaseCheckWidgetState extends State<FirebaseCheckWidget> {
  String _status = 'Belum dicek';

  Future<void> _cekFirebase() async {
    setState(() => _status = 'Mencoba menulis ke Firestore...');
    try {
      await FirebaseFirestore.instance.collection('cek_firebase').add({
        'waktu': DateTime.now().toIso8601String(),
        'pesan': 'Tes koneksi berhasil',
      });
      setState(() => _status = '✅ Berhasil menulis ke Firestore!');
    } catch (e) {
      setState(() => _status = '❌ Gagal: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_status, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _cekFirebase,
          child: const Text('Cek Firestore'),
        ),
      ],
    );
  }
}

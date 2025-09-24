import 'package:atividade/app/my_app.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAvLaZUP8F8mpi4ihD4GaVL5ZEroA59mUs",
      authDomain: "persistenciadedados-2cfde.firebaseapp.com",
      projectId: "persistenciadedados-2cfde",
      storageBucket: "persistenciadedados-2cfde.firebasestorage.app",
      messagingSenderId: "231725361849",
      appId: "1:231725361849:web:23796d4b388901ddc14968",
      measurementId: "G-9WDR4K7PCB",
    ),
  );
  
  runApp(MyApp());
}
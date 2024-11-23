import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fuelwise/firebase/daoFirestore.dart';
import 'package:fuelwise/firebase/login.dart';
import 'firebase/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  DaoFirestore.inicializa();
  runApp(Login());
}
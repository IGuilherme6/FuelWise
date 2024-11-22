import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fuelwise/firebase_options.dart';

class DaoFirestore {
  static final clientes = <String, String>{"nome": "André", "idade": "20"};
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  static void inicializa() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  static void salvar() {


  }

  static void salvarAutoID() {

  }


}
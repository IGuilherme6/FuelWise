import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fuelwise/firebase/firebase_options.dart';
import 'package:fuelwise/models/abastecimento.dart';
import 'package:fuelwise/models/veiculos.dart';

class DaoFirestore {
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  static final FirebaseAuth auth = FirebaseAuth.instance;

  static void inicializa() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Verifica se tem usuário logado e retorna seu ID
  static String? get currentUserId {
    return auth.currentUser?.uid;
  }

  // Métodos para Veículo
  static Future<void> salvarVeiculo(Veiculo veiculo) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuário não autenticado');

    final Map<String, dynamic> veiculoData = {
      'nome': veiculo.nome,
      'modelo': veiculo.modelo,
      'placa': veiculo.placa,
      'ano': veiculo.ano,
      'km': veiculo.km,
    };

    // Só adiciona mediaConsumo se existir um valor
    if (veiculo.mediaConsumo != null) {
      veiculoData['mediaConsumo'] = veiculo.mediaConsumo;
    }

    await db
        .collection('users')
        .doc(userId)
        .collection('veiculos')
        .add(veiculoData);
  }

  static Future<void> atualizarVeiculo(String veiculoId, Veiculo veiculo) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuário não autenticado');

    await db
        .collection('users')
        .doc(userId)
        .collection('veiculos')
        .doc(veiculoId)
        .update({
      'nome': veiculo.nome,
      'modelo': veiculo.modelo,
      'placa': veiculo.placa,
      'ano': veiculo.ano,
      'km': veiculo.km,
      'mediaConsumo': veiculo.mediaConsumo,
    });
  }

  static Future<void> excluirVeiculo(String veiculoId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuário não autenticado');

    await db
        .collection('users')
        .doc(userId)
        .collection('veiculos')
        .doc(veiculoId)
        .delete();
  }

  static Stream<List<Veiculo>> getVeiculos() {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuário não autenticado');

    return db
        .collection('users')
        .doc(userId)
        .collection('veiculos')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      return Veiculo(
        doc['nome'],
        doc['modelo'],
        doc['placa'],
        doc['ano'],
        doc['km'],
      )..mediaConsumo = doc['mediaConsumo'] ?? 0.0;
    }).toList());
  }

  static Future<Veiculo?> getVeiculo(String veiculoId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuário não autenticado');

    final doc = await db
        .collection('users')
        .doc(userId)
        .collection('veiculos')
        .doc(veiculoId)
        .get();

    if (doc.exists && doc.data() != null) {
      return Veiculo(
        doc['nome'],
        doc['modelo'],
        doc['placa'],
        doc['ano'],
        doc['km'],
      )..mediaConsumo = doc['mediaConsumo'] ?? 0.0;
    }
    return null;
  }

  // Métodos para Abastecimento
  static Future<void> salvarAbastecimento(
      String veiculoId, Abastecimento abastecimento) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuário não autenticado');

    await db.runTransaction((transaction) async {
      final veiculoRef = db
          .collection('users')
          .doc(userId)
          .collection('veiculos')
          .doc(veiculoId);

      final veiculoDoc = await transaction.get(veiculoRef);

      if (veiculoDoc.exists) {
        // Conversões mais seguras com verificação de tipo
        double kmAnterior;
        try {
          kmAnterior = double.parse(veiculoDoc.data()?['km'].toString() ?? '0.0');
        } catch (_) {
          kmAnterior = 0.0;
        }

        double kmAtual;
        try {
          kmAtual = double.parse(abastecimento.quilometragemAtual.toString());
        } catch (_) {
          throw Exception('Quilometragem atual inválida');
        }

        if (kmAtual < kmAnterior) {
          throw Exception('A quilometragem atual não pode ser menor que a anterior');
        }

        double litros;
        try {
          litros = double.parse(abastecimento.litros.toString());
        } catch (_) {
          throw Exception('Quantidade de litros inválida');
        }

        final kmPercorrido = kmAtual - kmAnterior;
        final mediaConsumo = kmPercorrido / litros;

        transaction.update(veiculoRef, {
          'km': kmAtual,
          'mediaConsumo': mediaConsumo,
        });

        final abastecimentoRef = veiculoRef.collection('abastecimentos').doc();
        transaction.set(abastecimentoRef, {
          'data': Timestamp.fromDate(abastecimento.data),
          'quilometragemAtual': kmAtual,
          'litros': litros,
        });
      }
    });
  }

  static Stream<List<Abastecimento>> getAbastecimentos(String veiculoId) {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuário não autenticado');

    return db
        .collection('users')
        .doc(userId)
        .collection('veiculos')
        .doc(veiculoId)
        .collection('abastecimentos')
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      return Abastecimento(
        (doc['data'] as Timestamp).toDate(),
        doc['quilometragemAtual'],
        doc['litros'],
      );
    }).toList());
  }

  static Future<void> excluirAbastecimento(
      String veiculoId, String abastecimentoId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuário não autenticado');

    await db
        .collection('users')
        .doc(userId)
        .collection('veiculos')
        .doc(veiculoId)
        .collection('abastecimentos')
        .doc(abastecimentoId)
        .delete();
  }

  static Future<Abastecimento?> getUltimoAbastecimento(String veiculoId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuário não autenticado');

    final querySnapshot = await db
        .collection('users')
        .doc(userId)
        .collection('veiculos')
        .doc(veiculoId)
        .collection('abastecimentos')
        .orderBy('data', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      return Abastecimento(
        (doc['data'] as Timestamp).toDate(),
        doc['quilometragemAtual'],
        doc['litros'],
      );
    }
    return null;
  }
}
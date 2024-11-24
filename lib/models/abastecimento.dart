import 'package:cloud_firestore/cloud_firestore.dart';

class Abastecimento {
  late DateTime _data;
  late double _quilometragemAtual;
  late double _litros;

  Abastecimento(this._data, this._quilometragemAtual, this._litros);

  set litros(double value) {
    _litros = value;
  }

  set quilometragemAtual(double value) {
    _quilometragemAtual = value;
  }

  set data(DateTime value) {
    _data = value;
  }

  double get litros => _litros;
  double get quilometragemAtual => _quilometragemAtual;
  DateTime get data => _data;

  factory Abastecimento.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Abastecimento(
      (data['data'] as Timestamp).toDate(),
      (data['quilometragemAtual'] as num).toDouble(),
      (data['litros'] as num).toDouble(),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'data': _data,
      'quilometragemAtual': _quilometragemAtual,
      'litros': _litros,
    };
  }
}
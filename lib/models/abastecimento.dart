
import 'dart:ffi';

class Abastecimento {

  late DateTime _data;
  late Double _quilometragemAtual;
  late Double _litros;

  Abastecimento(this._data, this._quilometragemAtual, this._litros);

  set litros(Double value) {
    _litros = value;
  }

  set quilometragemAtual(Double value) {
    _quilometragemAtual = value;
  }

  set data(DateTime value) {
    _data = value;
  }

  Double get litros => _litros;

  Double get quilometragemAtual => _quilometragemAtual;

  DateTime get data => _data;
}
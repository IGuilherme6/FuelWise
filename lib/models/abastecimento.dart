class Abastecimento {
  late DateTime _data;
  late double _quilometragemAtual;  // Mudado de Double para double
  late double _litros;              // Mudado de Double para double

  Abastecimento(this._data, this._quilometragemAtual, this._litros);

  set litros(double value) {        // Mudado de Double para double
    _litros = value;
  }

  set quilometragemAtual(double value) {  // Mudado de Double para double
    _quilometragemAtual = value;
  }

  set data(DateTime value) {
    _data = value;
  }

  double get litros => _litros;             // Mudado de Double para double
  double get quilometragemAtual => _quilometragemAtual;  // Mudado de Double para double
  DateTime get data => _data;
}

class Veiculo {
  late String _nome;
  late String _modelo;
  late String _placa;
  late int _ano;
  late double _km;
  late double _mediaConsumo;


  Veiculo(this._nome, this._modelo, this._placa, this._ano, this._km,[this._mediaConsumo = 0.0]);

  String get nome => _nome;

  String get modelo => _modelo;

  int get ano => _ano;

  String get placa => _placa;

  double get km => _km;

  double get mediaConsumo => _mediaConsumo;

  set ano(int value) {
    _ano = value;
  }

  set placa(String value) {
    _placa = value;
  }

  set modelo(String value) {
    _modelo = value;
  }

  set nome(String value) {
    _nome = value;
  }

  set mediaConsumo(double value) {
    _mediaConsumo = value;
  }

  set km(double value) {
    _km = value;
  }
}
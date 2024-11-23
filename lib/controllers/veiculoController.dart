import 'package:fuelwise/firebase/daoFirestore.dart';
import 'package:fuelwise/models/veiculos.dart';

class VeiculoController {
  // Stream para observar mudanças na lista de veículos
  Stream<List<Veiculo>> get veiculos => DaoFirestore.getVeiculos();

  // Cadastrar novo veículo
  Future<void> cadastrarVeiculo({
    required String nome,
    required String modelo,
    required String placa,
    required int ano,
    required double km,
  }) async {
    try {
      final veiculo = Veiculo(
        nome,
        modelo,
        placa,
        ano,
        km,
      );

      await DaoFirestore.salvarVeiculo(veiculo);
    } catch (e) {
      throw Exception('Erro ao cadastrar veículo: ${e.toString()}');
    }
  }

  // Editar veículo existente
  Future<void> editarVeiculo({
    required String veiculoId,
    required String nome,
    required String modelo,
    required String placa,
    required int ano,
    required double km,
    double mediaConsumo = 0.0,
  }) async {
    try {
      final veiculo = Veiculo(
        nome,
        modelo,
        placa,
        ano,
        km,
      )..mediaConsumo = mediaConsumo;

      await DaoFirestore.atualizarVeiculo(veiculoId, veiculo);
    } catch (e) {
      throw Exception('Erro ao editar veículo: ${e.toString()}');
    }
  }

  // Excluir veículo
  Future<void> excluirVeiculo(String veiculoId) async {
    try {
      await DaoFirestore.excluirVeiculo(veiculoId);
    } catch (e) {
      throw Exception('Erro ao excluir veículo: ${e.toString()}');
    }
  }

  // Buscar veículo específico
  Future<Veiculo?> buscarVeiculo(String veiculoId) async {
    try {
      return await DaoFirestore.getVeiculo(veiculoId);
    } catch (e) {
      throw Exception('Erro ao buscar veículo: ${e.toString()}');
    }
  }

  // Obter último abastecimento do veículo
  Future<double?> obterUltimaQuilometragem(String veiculoId) async {
    try {
      final ultimoAbastecimento = await DaoFirestore.getUltimoAbastecimento(veiculoId);
      if (ultimoAbastecimento?.quilometragemAtual != null) {
        return double.parse(ultimoAbastecimento!.quilometragemAtual.toString());
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao obter última quilometragem: ${e.toString()}');
    }
  }

  // Validar dados do veículo
  void validarDadosVeiculo({
    required String nome,
    required String modelo,
    required String placa,
    required int ano,
    required double km,
  }) {
    if (nome.isEmpty) {
      throw Exception('Nome do veículo é obrigatório');
    }
    if (modelo.isEmpty) {
      throw Exception('Modelo do veículo é obrigatório');
    }
    if (placa.isEmpty) {
      throw Exception('Placa do veículo é obrigatória');
    }
    if (placa.length != 7) {
      throw Exception('Placa deve conter 7 caracteres');
    }
    if (ano < 1900 || ano > DateTime.now().year + 1) {
      throw Exception('Ano inválido');
    }
    if (km < 0) {
      throw Exception('Quilometragem não pode ser negativa');
    }
  }

  // Verificar se placa já existe
  Future<bool> verificarPlacaExistente(String placa) async {
    try {
      final veiculosStream = DaoFirestore.getVeiculos();
      final veiculos = await veiculosStream.first;

      return veiculos.any((veiculo) =>
      veiculo.placa.toLowerCase() == placa.toLowerCase()
      );
    } catch (e) {
      throw Exception('Erro ao verificar placa: ${e.toString()}');
    }
  }

  // Formatar placa para padrão brasileiro (ABC1234 ou ABC1D23)
  String formatarPlaca(String placa) {
    placa = placa.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

    if (placa.length != 7) {
      throw Exception('Placa deve conter 7 caracteres');
    }

    // Validar formato da placa (antiga ou Mercosul)
    if (!RegExp(r'^[A-Z]{3}[0-9]{4}$').hasMatch(placa) && // Formato antigo
        !RegExp(r'^[A-Z]{3}[0-9]{1}[A-Z]{1}[0-9]{2}$').hasMatch(placa)) { // Formato Mercosul
      throw Exception('Formato de placa inválido');
    }

    return placa;
  }
}
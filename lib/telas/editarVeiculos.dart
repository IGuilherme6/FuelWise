import 'package:flutter/material.dart';
import 'package:fuelwise/controllers/veiculoController.dart';
import 'package:fuelwise/models/veiculos.dart';

class EditarVeiculoScreen extends StatefulWidget {
  final String veiculoId;
  final Veiculo veiculo;

  const EditarVeiculoScreen({
    Key? key,
    required this.veiculoId,
    required this.veiculo,
  }) : super(key: key);

  @override
  _EditarVeiculoScreenState createState() => _EditarVeiculoScreenState();
}

class _EditarVeiculoScreenState extends State<EditarVeiculoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto para os campos do formulário
  late TextEditingController _nomeController;
  late TextEditingController _modeloController;
  late TextEditingController _placaController;
  late TextEditingController _anoController;
  late TextEditingController _kmController;
  late TextEditingController _mediaConsumoController;

  @override
  void initState() {
    super.initState();
    // Inicializa os controladores com os dados do veículo
    _nomeController = TextEditingController(text: widget.veiculo.nome);
    _modeloController = TextEditingController(text: widget.veiculo.modelo);
    _placaController = TextEditingController(text: widget.veiculo.placa);
    _anoController = TextEditingController(text: widget.veiculo.ano.toString());
    _kmController = TextEditingController(text: widget.veiculo.km.toString());
    _mediaConsumoController = TextEditingController(
        text: widget.veiculo.mediaConsumo?.toStringAsFixed(1) ?? '0.0');
  }

  @override
  void dispose() {
    // Libera a memória dos controladores quando a tela for descartada
    _nomeController.dispose();
    _modeloController.dispose();
    _placaController.dispose();
    _anoController.dispose();
    _kmController.dispose();
    _mediaConsumoController.dispose();
    super.dispose();
  }

  Future<void> _salvarAlteracoes() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Chama o método do controlador para atualizar o veículo
        await VeiculoController().editarVeiculo(
          veiculoId: widget.veiculoId,
          nome: _nomeController.text.trim(),
          modelo: _modeloController.text.trim(),
          placa: _placaController.text.trim(),
          ano: int.parse(_anoController.text.trim()),
          km: double.parse(_kmController.text.trim()),
          mediaConsumo: double.parse(_mediaConsumoController.text.trim()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veículo atualizado com sucesso!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar veículo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Veículo'),
          centerTitle: true,
          backgroundColor: Colors.blue[800]
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o nome do veículo';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _modeloController,
                decoration: const InputDecoration(labelText: 'Modelo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o modelo do veículo';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _placaController,
                decoration: const InputDecoration(labelText: 'Placa'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a placa do veículo';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _anoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Ano'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o ano do veículo';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Informe um ano válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _kmController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quilometragem'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a quilometragem atual';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Informe um número válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _mediaConsumoController,
                keyboardType: TextInputType.number,
                decoration:
                const InputDecoration(labelText: 'Média de Consumo (km/l)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a média de consumo';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Informe um número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvarAlteracoes,
                child: const Text('Salvar Alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

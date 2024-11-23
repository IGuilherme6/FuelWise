import 'package:flutter/material.dart';
import 'package:fuelwise/firebase/daoFirestore.dart';
import 'package:fuelwise/models/abastecimento.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class NovoAbastecimento extends StatefulWidget {
  final String veiculoId;
  final String veiculoNome;

  const NovoAbastecimento({required this.veiculoId, required this.veiculoNome, Key? key});

  @override
  State<NovoAbastecimento> createState() => _NovoAbastecimentoState();
}

class _NovoAbastecimentoState extends State<NovoAbastecimento> {
  final _formKey = GlobalKey<FormState>();
  final _litrosController = TextEditingController();
  final _kmController = TextEditingController();
  DateTime _dataSelecionada = DateTime.now();

  final _maskFormatter = MaskTextInputFormatter(
    mask: '##.##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    _litrosController.dispose();
    _kmController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dataSelecionada) {
      setState(() {
        _dataSelecionada = picked;
      });
    }
  }

  void _salvarAbastecimento() async {
    if (_formKey.currentState!.validate()) {
      try {
        final abastecimento = Abastecimento(
          _dataSelecionada,
          double.parse(_kmController.text),
          double.parse(_litrosController.text),
        );

        await DaoFirestore.salvarAbastecimento(widget.veiculoId, abastecimento);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Abastecimento registrado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao registrar abastecimento: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novo Abastecimento - ${widget.veiculoNome}'),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data do Abastecimento',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(_dataSelecionada),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _kmController,
                decoration: const InputDecoration(
                  labelText: 'Quilometragem Atual',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.speed),
                  suffixText: 'km',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a quilometragem';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Insira um número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _litrosController,
                decoration: const InputDecoration(
                  labelText: 'Litros Abastecidos',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_gas_station),
                  suffixText: 'L',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [_maskFormatter],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a quantidade de litros';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Insira um número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _salvarAbastecimento,
                icon: const Icon(Icons.save),
                label: const Text('Salvar Abastecimento'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
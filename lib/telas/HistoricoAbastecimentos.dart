import 'package:flutter/material.dart';
import 'package:fuelwise/controllers/veiculoController.dart';
import 'package:fuelwise/firebase/daoFirestore.dart';
import 'package:fuelwise/models/abastecimento.dart';
import 'package:fuelwise/models/veiculos.dart';
import 'package:intl/intl.dart';

class HistoricoAbastecimentosPage extends StatefulWidget {
  @override
  _HistoricoAbastecimentosPageState createState() =>
      _HistoricoAbastecimentosPageState();
}

class _HistoricoAbastecimentosPageState extends State<HistoricoAbastecimentosPage> {
  late Stream<List<Veiculo>> veiculosStream;

  @override
  void initState() {
    super.initState();
    veiculosStream = VeiculoController().veiculos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de Abastecimentos'),
      ),
      body: StreamBuilder<List<Veiculo>>(
        stream: veiculosStream,
        builder: (context, snapshotVeiculos) {
          print('Estado do snapshot veículos: ${snapshotVeiculos.connectionState}');
          print('Tem dados? ${snapshotVeiculos.hasData}');
          print('Tem erro? ${snapshotVeiculos.hasError}');

          if (snapshotVeiculos.hasError) {
            return Center(
              child: Text('Erro ao carregar veículos: ${snapshotVeiculos.error}'),
            );
          }

          if (snapshotVeiculos.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshotVeiculos.hasData || snapshotVeiculos.data!.isEmpty) {
            return Center(child: Text('Nenhum veículo encontrado'));
          }

          print('Número de veículos: ${snapshotVeiculos.data!.length}');

          return SingleChildScrollView(
            child: Column(
              children: snapshotVeiculos.data!.map((veiculo) {
                print('Processando veículo: ${veiculo.placa}');

                return StreamBuilder<List<Abastecimento>>(
                  stream: DaoFirestore.getAbastecimentos(veiculo.placa),
                  builder: (context, snapshotAbastecimentos) {
                    print('Estado do snapshot abastecimentos para ${veiculo.placa}: ${snapshotAbastecimentos.connectionState}');
                    print('Tem dados? ${snapshotAbastecimentos.hasData}');
                    print('Tem erro? ${snapshotAbastecimentos.hasError}');

                    if (snapshotAbastecimentos.hasError) {
                      return Card(
                        margin: EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Erro ao carregar abastecimentos: ${snapshotAbastecimentos.error}'),
                        ),
                      );
                    }

                    if (snapshotAbastecimentos.connectionState == ConnectionState.waiting) {
                      return Card(
                        margin: EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    }

                    final abastecimentos = snapshotAbastecimentos.data ?? [];
                    print('Número de abastecimentos para ${veiculo.placa}: ${abastecimentos.length}');

                    if (abastecimentos.isEmpty) {
                      return Card(
                        margin: EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Nenhum abastecimento para ${veiculo.modelo} - ${veiculo.placa}'),
                        ),
                      );
                    }

                    return Column(
                      children: abastecimentos.map((abastecimento) {
                        return Card(
                          margin: EdgeInsets.all(8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${veiculo.nome} - ${veiculo.modelo}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Placa: ${veiculo.placa}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat('dd/MM/yyyy HH:mm').format(abastecimento.data),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Quilometragem: ${abastecimento.quilometragemAtual.toStringAsFixed(1)} km',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      'Litros: ${abastecimento.litros.toStringAsFixed(2)} L',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
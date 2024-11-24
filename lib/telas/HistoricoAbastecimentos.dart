import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuelwise/controllers/veiculoController.dart';
import 'package:fuelwise/firebase/autenticacaoFirebase.dart';
import 'package:fuelwise/firebase/daoFirestore.dart';
import 'package:fuelwise/firebase/login.dart';
import 'package:fuelwise/models/abastecimento.dart';
import 'package:fuelwise/models/veiculos.dart';
import 'package:fuelwise/telas/CadastroVeiculo.dart';
import 'package:fuelwise/telas/telaPrincipal.dart';
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
    AutenticacaoFirebase auth = AutenticacaoFirebase();
    return Scaffold(
      appBar: AppBar(
        title: const Text("FuelWise"),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue[800],
              ),
              child: FutureBuilder<User?>(
                future: FirebaseAuth.instance.authStateChanges().first,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }
                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data == null) {
                    return const Center(
                      child: Text(
                        'Usuário não encontrado',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    );
                  }

                  final user = snapshot.data!;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person, size: 48, color: Colors.white),
                      const SizedBox(height: 10),
                      Text(
                        user.email ?? 'Email não disponível',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text("Adicionar Veículo"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CadastroVeiculo()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_paste_search),
              title: const Text("Histórico de Abastecimentos",
              style: TextStyle(color: Colors.cyan),),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () async {
                await auth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
            ),
          ],
        ),
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
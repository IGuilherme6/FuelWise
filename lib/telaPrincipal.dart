import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fuelwise/autenticacaoFirebase.dart';
import 'package:fuelwise/login.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

  class _MyHomePageState extends State<MyHomePage> {
  AutenticacaoFirebase auth = new AutenticacaoFirebase();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("FuelWise"),),
        titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold
        ),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
      ),
        drawer: Drawer(
          child: ListView(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.grey),
                child: Column(children: []),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text("Home"),
                onTap: () {
                  // Navegação para tela principal com listagem de veículos
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage())
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.directions_car),
                title: const Text("Meus Veículos"),
                onTap: () {
                  // Navegação para lista de veículos
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => ListaVeiculos()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text("Adicionar Veículo"),
                onTap: () {
                  // Navegação para formulário de cadastro de veículo
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => CadastroVeiculo()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text("Histórico de Abastecimentos"),
                onTap: () {
                  // Navegação para histórico de abastecimentos
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => HistoricoAbastecimentos()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Perfil"),
                onTap: () {
                  // Navegação para tela de perfil
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => TelaPerfil()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Logout"),
                onTap: () async {
                  await auth.signOut();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Login())
                  );
                },
              )
            ],
          ),
        )
    );
  }
  }
  
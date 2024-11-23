
import 'package:flutter/material.dart';
import 'package:fuelwise/firebase/autenticacaoFirebase.dart';
import 'package:fuelwise/telas/telaPrincipal.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tela de Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AutenticacaoFirebase auth = AutenticacaoFirebase();

  @override
  void initState() {
    super.initState();
    _validaLogin();
  }

  void _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    // Chama o método de login e recebe a mensagem de resultado
    String message = await auth.signInWithEmailPassword(email, password);

    // Exibe um Snackbar com a mensagem de resultado
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    _validaLogin();
  }

  Future<void> signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      print("Erro ao fazer logout: $e");
    }
  }

  void _register() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    // Chama o método de registro e recebe a mensagem de resultado
    String message = await auth.registerWithEmailPassword(email, password);

    // Exibe um Snackbar com a mensagem de resultado
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    _validaLogin();
  }


  void _validaLogin() async {
    if (await auth.isUserLoggedIn()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    }
  }

  void _recuperarSenha() async {
    final email = _emailController.text;

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, insira seu email para recuperar a senha.")),
      );
      return;
    }

    try {
      // Chama o método de recuperação de senha no Firebase
      await auth.enviarEmailRecuperacaoSenha(email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email de recuperação enviado para $email.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao enviar email de recuperação: ${e.toString()}")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[200]!, Colors.blue[800]!],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'FuelWise',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      SizedBox(height: 24),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 24),
                      GestureDetector(
                        onTap: () {
                          // Ação ao clicar no texto
                         _recuperarSenha();
                        },
                        child: Text(
                          "Esqueceu a senha?",
                          style: TextStyle(
                            color: Colors.red,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _login,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue[800],
                          minimumSize: Size(double.infinity, 50),
                          side: BorderSide(color: Colors.blue[800]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Entrar',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: _register,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue[800],
                          minimumSize: Size(double.infinity, 50),
                          side: BorderSide(color: Colors.blue[800]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Registrar',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
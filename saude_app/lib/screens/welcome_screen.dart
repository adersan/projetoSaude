
import 'package:flutter/material.dart';
import 'cadastro_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF), // Lavanda claro
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/imagens/logo.png',
                height: 160,
              ),
              SizedBox(height: 24),
              Text(
                'Seja bem-vindo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5A468E),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'à sua vida mais saudável!',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF5A468E),
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (_) => CadastroScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6C4F9E), // Roxo escuro
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                ),
                child: Text(
                  'Criar conta',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (_) => LoginScreen()));
                },
                child: Text.rich(
                  TextSpan(
                    text: 'Já é membro? ',
                    style: TextStyle(color: Colors.black87),
                    children: [
                      TextSpan(
                        text: 'Login',
                        style: TextStyle(
                          color: Color(0xFF5A468E),
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

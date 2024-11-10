import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _errorMessage;

  // Fonction de connexion via Firestore
  Future<void> _login() async {
    final login = _loginController.text;
    final password = _passwordController.text;

    if (login.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "Les champs ne doivent pas être vides.";
      });
      return;
    }

    try {
      // Rechercher l'utilisateur dans Firestore
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(login).get();
      print("TEST $userSnapshot");
      if (userSnapshot.exists) {
        // Utilisateur trouvé, vérifier le mot de passe
        var userData = userSnapshot.data() as Map<String, dynamic>;
        if (userData['password'] == password) {
          // Rediriger vers la page suivante si le mot de passe est correct
          print("CONTEXT $context");
          Navigator.pushReplacementNamed(
            context,
            '/clothing-list',
            arguments: {'login': login},
          );
        } else {
          // Mot de passe incorrect
          setState(() {
            _errorMessage = "Mot de passe incorrect";
          });
        }
      } else {
        // Utilisateur non trouvé
        setState(() {
          _errorMessage = "Utilisateur non trouvé";
        });
      }
    } catch (e) {
      // Afficher les erreurs dans la console
      print("Erreur de connexion: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PROJET VINTED',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _loginController,
              decoration: const InputDecoration(
                labelText: 'Login',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true, // Le texte est obfusqué
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple, // Couleur du bouton
              ),
              child: const Text(
                'Se connecter',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

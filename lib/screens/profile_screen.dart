import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart'; // Page de login pour la déconnexion
import 'package:intl/intl.dart'; // Importer le package intl pour les dates
import 'add_clothing_screen.dart'; // Importer la page d'ajout de vêtement

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>(); // Clé pour le formulaire

  // Champs du profil utilisateur
  TextEditingController loginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController birthdayController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();
  TextEditingController cityController = TextEditingController();

  bool isLoading = false; // Indicateur de chargement

  @override
  void initState() {
    super.initState();
    _getUserData(); // Charger les informations utilisateur depuis Firestore
  }

  // Récupérer les informations utilisateur depuis Firestore
  Future<void> _getUserData() async {
    setState(() {
      isLoading = true;
    });
    try {
      print(widget.userId);
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        print(userDoc.data());
        // Mise à jour des contrôleurs avec les données récupérées
        setState(() {
          loginController.text = widget.userId;
          passwordController.text = userData['password'] ?? '';
          birthdayController.text = userData['birthday']
              .toDate()
              .toString()
              .split(' ')[0]
              .split('-')
              .reversed
              .join('/');
          addressController.text = userData['address'] ?? '';
          postalCodeController.text = userData['postalCode'] ?? '';
          cityController.text = userData['city'] ?? '';
        });
      } else {
        print("Document utilisateur non trouvé.");
      }
    } catch (e) {
      print("Erreur lors du chargement des données utilisateur : $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  // Sauvegarder les modifications utilisateur dans Firestore
  Future<void> _saveProfile() async {
    print(widget.userId);
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .update({
          'password': passwordController.text,
          'birthday': Timestamp.fromDate(
              DateFormat('dd/MM/yyyy').parse(birthdayController.text)),
          'address': addressController.text,
          'postalCode': postalCodeController.text,
          'city': cityController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil mis à jour avec succès !")),
        );
      } catch (e) {
        print("Erreur lors de la mise à jour du profil : $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Erreur lors de la mise à jour du profil !")),
        );
      }
    }
  }

  // Fonction pour déconnecter l'utilisateur
  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mon profil',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        actions: [
          // Bouton "Valider" pour enregistrer les modifications
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Valider',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Loader pendant le chargement des données
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey, // Formulaire pour validation
                child: ListView(
                  children: [
                    // Champ "Login" (readonly)
                    TextFormField(
                      controller: loginController,
                      readOnly: true, // Le login est en lecture seule
                      decoration: const InputDecoration(labelText: 'Login'),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    // Champ "Password" (offusqué)
                    TextFormField(
                      controller: passwordController,
                      obscureText: true, // Masquer le mot de passe
                      decoration: const InputDecoration(labelText: 'Password'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un mot de passe';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Champ "Anniversaire"
                    TextFormField(
                      controller: birthdayController,
                      keyboardType: TextInputType.datetime,
                      textInputAction: TextInputAction.next,
                      decoration:
                          const InputDecoration(labelText: 'Anniversaire'),
                    ),
                    const SizedBox(height: 16),
                    // Champ "Adresse"
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(labelText: 'Adresse'),
                    ),
                    const SizedBox(height: 16),
                    // Champ "Code Postal" (clavier numérique)
                    TextFormField(
                      controller: postalCodeController,
                      keyboardType: TextInputType.number, // Clavier numérique
                      textInputAction: TextInputAction.next,
                      decoration:
                          const InputDecoration(labelText: 'Code Postal'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un code postal';
                        }
                        if (value.length != 5) {
                          return 'Le code postal doit avoir 5 chiffres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Champ "Ville"
                    TextFormField(
                      controller: cityController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(labelText: 'Ville'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Naviguer vers l'écran d'ajout de vêtement
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddClothingScreen(userId: widget.userId),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple),
                      child: const Text(
                        'Ajouter un vêtement',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    const SizedBox(height: 16),
                    // Bouton "Se déconnecter"
                    ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Se déconnecter',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

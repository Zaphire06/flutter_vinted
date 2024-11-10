import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_screen.dart'; // Import de la page du panier
import 'clothing_detail_screen.dart'; // Import de la page de détail
import '../widgets/bottom_navigation.dart';
import 'profile_screen.dart'; // Import de la page profil

class ClothingListScreen extends StatefulWidget {
  const ClothingListScreen({super.key});

  @override
  _ClothingListScreenState createState() => _ClothingListScreenState();
}

class _ClothingListScreenState extends State<ClothingListScreen> {
  int _currentIndex = 0; // Index de la page courante
  String userId = "";
  final List<Widget> _pages = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Récupération des arguments
    final arguments = ModalRoute.of(context)?.settings.arguments as Map?;
    if (arguments != null && arguments.containsKey('login')) {
      userId = arguments['login'];
    } else {
      userId = "defaultUserId"; // Valeur par défaut si 'login' n'est pas fourni
    }

    // Initialiser les pages une seule fois, uniquement si _pages est vide
    if (_pages.isEmpty) {
      _pages.addAll([
        _buildClothingList(), // Page "Acheter"
        CartScreen(userId: userId), // Page "Panier"
        ProfileScreen(userId: userId), // Page "Profil"
      ]);
    }
  }

  // // Liste des pages (Acheter, Panier, Profil)
  // final List<Widget> _pages = [];

  // @override
  // void initState() {
  //   super.initState();
  //   print("VRAIS BONJOUR $userId");
  //   // Initialiser les pages une seule fois
  //   _pages.addAll([
  //     _buildClothingList(), // Page "Acheter"
  //     CartScreen(userId: userId), // Page "Panier"
  //     ProfileScreen(userId: userId), // Page "Profil"
  //   ]);
  // }

  // Changer de page en fonction de l'index
  void _onTabTapped(int index) {
    if (index == _currentIndex) {
      return; // Ne rien faire si la page est déjà active
    }
    setState(() {
      _currentIndex = index;
    });
  }

  // Fonction pour créer la page de liste des vêtements
  Widget _buildClothingList() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Acheter des vêtements',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('clothing').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final clothes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: clothes.length,
            itemBuilder: (context, index) {
              var clothingItem = clothes[index].data() as Map<String, dynamic>;

              final imageUrl = clothingItem['imageUrl'];
              final title = clothingItem['title'];
              final size = clothingItem['size'];
              final price = clothingItem['price'];
              return ListTile(
                leading: SizedBox(
                  width: 50, // Largeur spécifique pour l'image
                  height: 50, // Hauteur spécifique pour l'image
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit
                        .cover, // Ajuste l'image pour qu'elle remplisse le cadre
                  ),
                ),
                title: Text(title),
                subtitle: Text('Taille: $size - Prix: $price €'),
                onTap: () {
                  // Redirection vers la page de détail du vêtement
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClothingDetailScreen(
                        clothingItem: clothingItem,
                        userId: userId, // Passe l'ID utilisateur
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages, // Afficher la page correspondant à l'index courant
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

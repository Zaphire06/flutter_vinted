import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartScreen extends StatefulWidget {
  final String userId; // ID de l'utilisateur connecté

  const CartScreen({super.key, required this.userId});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double total = 0.0; // Stocker le total général

  // Fonction pour récupérer les articles du panier
  Stream<QuerySnapshot> _getCartItems() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId.isNotEmpty ? widget.userId : 'default_user_id')
        .collection('cart')
        .snapshots();
  }

  // Calculer le total des prix des articles
  void _calculateTotal(List<QueryDocumentSnapshot> cartItems) {
    double totalTemp = 0.0;
    for (var item in cartItems) {
      totalTemp += double.tryParse(item['price'].toString()) ?? 0.00;
      totalTemp = double.parse(totalTemp.toStringAsFixed(2));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        total = double.parse(totalTemp.toStringAsFixed(2));
      });
    });
  }

  // Supprimer un article du panier
  Future<void> _removeItem(String itemId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('cart')
        .doc(itemId)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Article supprimé du panier !")),
    );

    // Mettre à jour le panier après suppression
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mon Panier',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getCartItems(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child:
                    CircularProgressIndicator()); // Loader pendant le chargement des données
          }

          final cartItems = snapshot.data!.docs;

          // Calculer le total après avoir récupéré les articles du panier
          _calculateTotal(cartItems);

          if (cartItems.isEmpty) {
            return const Center(
              child: Text('Votre panier est vide'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    var item = cartItems[index].data() as Map<String, dynamic>;
                    String itemId = cartItems[index].id;

                    return ListTile(
                      leading: Image.network(
                        item['imageUrl'],
                        height: 50,
                        width: 50,
                      ),
                      title: Text(item['title']),
                      subtitle: Text(
                          'Taille: ${item['size']} - Prix: ${item['price']} €'),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          _removeItem(itemId); // Supprimer l'article
                        },
                      ),
                    );
                  },
                ),
              ),
              // Afficher le total général
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Total: ${total.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

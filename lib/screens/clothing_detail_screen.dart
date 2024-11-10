import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClothingDetailScreen extends StatefulWidget {
  final Map<String, dynamic>
      clothingItem; // Données du vêtement passées depuis la page précédente
  final String userId; // L'ID de l'utilisateur connecté

  const ClothingDetailScreen(
      {super.key, required this.clothingItem, required this.userId});

  @override
  _ClothingDetailScreenState createState() => _ClothingDetailScreenState();
}

class _ClothingDetailScreenState extends State<ClothingDetailScreen> {
  bool isLoading =
      false; // Ajout d'une variable pour gérer l'état de chargement

  Future<bool> _isItemInCart() async {
    print("SALUTATION $widget.userId");
    try {
      // Cherche dans la sous-collection 'cart' de l'utilisateur pour voir si l'article existe déjà
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users') // Accéder à la collection 'users'
          .doc(widget.userId) // Identifier le document utilisateur
          .collection('cart') // Accéder à la sous-collection 'cart'
          .where('title',
              isEqualTo: widget.clothingItem['title']) // Filtrer par titre
          .where('size',
              isEqualTo: widget.clothingItem['size']) // Filtrer par taille
          .get();

      // Si un document est trouvé, cela signifie que l'article est déjà dans le panier
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print("Erreur lors de la vérification du panier : $e");
      return false; // Retourne 'false' en cas d'erreur
    }
  }

  // Fonction pour ajouter l'article au panier si ce n'est pas déjà fait
  Future<void> _addToCart() async {
    setState(() {
      isLoading = true; // Démarrer le chargement
    });

    try {
      // Vérifier si l'article est déjà dans le panier
      bool isInCart = await _isItemInCart();
      if (isInCart) {
        print("Cet article est déjà dans le panier !");
        // Afficher un message à l'utilisateur si l'article est déjà dans le panier
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Cet article est déjà dans votre panier !")),
        );
      } else {
        // Ajouter l'article au panier si ce n'est pas déjà fait
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('cart')
            .add({
          'title': widget.clothingItem['title'],
          'category': widget.clothingItem['category'],
          'size': widget.clothingItem['size'],
          'brand': widget.clothingItem['brand'],
          'price': widget.clothingItem['price'],
          'imageUrl': widget.clothingItem['imageUrl'],
          'timestamp': FieldValue.serverTimestamp(),
        });

        print("Article ajouté au panier !");
        // Afficher un message de succès à l'utilisateur
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Article ajouté au panier !")),
        );
        print("ITS OKAY");
      }
    } catch (e) {
      print("Erreur lors de l'ajout au panier : $e");
      // Afficher un message d'erreur à l'utilisateur
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de l'ajout au panier !")),
      );
    } finally {
      setState(() {
        isLoading = false; // Fin du chargement
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail du vêtement'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Affichage de l'image
            Center(
              child: Image.network(
                widget.clothingItem['imageUrl'],
                height: 250,
              ),
            ),
            const SizedBox(height: 16),
            // Titre du vêtement
            Text(
              widget.clothingItem['title'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Catégorie
            Text(
              'Catégorie: ${widget.clothingItem['category']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            // Taille
            Text(
              'Taille: ${widget.clothingItem['size']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            // Marque
            Text(
              'Marque: ${widget.clothingItem['brand']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            // Prix
            Text(
              'Prix: ${widget.clothingItem['price']} €',
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            const SizedBox(height: 20),
            // Boutons Retour et Ajouter au panier
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Retour à la liste des vêtements
                  },
                  child: const Text('Retour'),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : _addToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    // Désactiver la couleur du bouton lorsqu'il est désactivé
                    disabledBackgroundColor: Colors.grey,
                  ), // Désactiver le bouton pendant le chargement
                  child: isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'Ajouter au panier',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

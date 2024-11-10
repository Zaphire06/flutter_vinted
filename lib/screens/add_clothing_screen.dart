import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class AddClothingScreen extends StatefulWidget {
  final String userId;

  const AddClothingScreen({super.key, required this.userId});

  @override
  _AddClothingScreenState createState() => _AddClothingScreenState();
}

class _AddClothingScreenState extends State<AddClothingScreen> {
  final _formKey = GlobalKey<FormState>();

  // Champs du formulaire
  TextEditingController imageUrlController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController sizeController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  bool _isCategoryLoading = false;
  bool _isModelLoaded = false; // Indicateur de chargement du modèle

  late Interpreter _interpreter;

  // Déplace le ValueNotifier à cet endroit pour qu'il soit accessible dans tout le widget
  ValueNotifier<String> categoryNotifier = ValueNotifier('Non défini');

  @override
  void initState() {
    super.initState();
    _loadModel(); // Charger le modèle dès l'initialisation
  }

  @override
  void dispose() {
    // Vérification avant de fermer l'interpréteur pour éviter les erreurs
    if (_isModelLoaded) {
      _interpreter.close();
    }
    categoryNotifier.dispose(); // Ne pas oublier de disposer le notifier
    super.dispose();
  }

  // Charger le modèle TFLite
  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('./assets/model.tflite');
      setState(() {
        _isModelLoaded = true;
      });
      print(
          'Dimensions d\'entrée attendues : ${_interpreter.getInputTensor(0).shape}');
      print('Modèle chargé avec succès');
    } catch (e) {
      setState(() {
        _isModelLoaded = false;
      });
      print('Erreur lors du chargement du modèle: $e');
    }
  }

  // Vérifier si l'URL est une image valide
  Future<bool> _isImageUrlValid(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      return response.statusCode == 200 &&
          response.headers['content-type']!.startsWith('image');
    } catch (e) {
      print("Erreur lors de la vérification de l'image: $e");
      return false;
    }
  }

  // Charger et redimensionner l'image pour le modèle
  Future<img.Image?> _loadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Uint8List bytes = response.bodyBytes;
        img.Image? image = img.decodeImage(Uint8List.view(bytes.buffer));
        return img.copyResize(image!, width: 128, height: 128);
      }
    } catch (e) {
      print("Erreur lors du chargement de l'image: $e");
    }
    return null;
  }

  // Préparer l'image pour correspondre aux dimensions [1, 128, 128, 3] (RGB)
  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    List<List<List<List<double>>>> inputImage = List.generate(
        1,
        (_) => List.generate(
            128, (_) => List.generate(128, (_) => List.filled(3, 0.0))));

    for (int x = 0; x < 128; x++) {
      for (int y = 0; y < 128; y++) {
        var pixel = image.getPixel(x, y);
        inputImage[0][x][y][0] = img.getRed(pixel) / 255.0;
        inputImage[0][x][y][1] = img.getGreen(pixel) / 255.0;
        inputImage[0][x][y][2] = img.getBlue(pixel) / 255.0;
      }
    }

    return inputImage;
  }

  // Prédire la catégorie à partir de l'image
  Future<void> _predictCategory(String imageUrl) async {
    if (!_isModelLoaded) {
      print('Modèle non chargé');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur: Modèle non chargé !")),
      );
      return;
    }

    setState(() {
      _isCategoryLoading = true;
    });

    img.Image? image = await _loadImage(imageUrl);
    if (image != null) {
      List<List<List<List<double>>>> inputImage = _preprocessImage(image);

      var output = List.filled(20, 0.0).reshape([1, 20]);

      if (_isModelLoaded) {
        try {
          _interpreter.run(inputImage, output);

          int predictedIndex = output[0].indexWhere((element) {
            return element ==
                output[0].reduce((double a, double b) => a > b ? a : b);
          });

          // Mettre à jour la valeur du categoryNotifier ici
          categoryNotifier.value = _getLabel(predictedIndex);
          print('Catégorie prédite: ${categoryNotifier.value}');
        } catch (e) {
          print("Erreur lors de l'exécution du modèle : $e");
        }
      } else {
        print('Erreur : Modèle non chargé');
      }
    } else {
      categoryNotifier.value = 'Non reconnu';
    }

    setState(() {
      _isCategoryLoading = false;
    });
  }

  // Récupérer l'étiquette correspondant à l'indice prédit
  String _getLabel(int index) {
    List<String> labels = [
      'Tshirts',
      'Shirts',
      'Sweaters',
      'Jackets & Coats',
      'Dresses',
      'Pants & Jeans',
      'Skirts',
      'Footwear',
      'Loungewear',
      'Accessories',
      'Hats & Headgear',
      'Jewelry',
      'Scarves & Stoles',
      'Undergarments',
      'Suits',
      'Makeup',
      'Perfumes',
      'Sports Equipment',
      'Watches',
      'Miscellaneous'
    ];
    return labels[index];
  }

  // Sauvegarder les informations du vêtement dans Firestore
  Future<void> _saveClothing() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('clothing').add({
          'imageUrl': imageUrlController.text,
          'title': titleController.text,
          'size': sizeController.text,
          'brand': brandController.text,
          'price': double.parse(priceController.text).toStringAsFixed(2),
          'userId': widget.userId,
          'category': categoryNotifier.value, // Catégorie prédite
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vêtement ajouté avec succès !")),
        );

        Navigator.pop(context);
      } catch (e) {
        print("Erreur lors de l'ajout du vêtement : $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de l'ajout du vêtement.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un vêtement'),
        backgroundColor: Colors.deepPurple,
        actions: [
          TextButton(
            onPressed: _saveClothing,
            child: const Text(
              'Valider',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: 'URL de l\'image'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer l\'URL de l\'image';
                  }
                  return null;
                },
                onChanged: (value) async {
                  if (value.isNotEmpty) {
                    bool isValidImage = await _isImageUrlValid(value);
                    if (isValidImage) {
                      _predictCategory(value);
                    } else {
                      categoryNotifier.value = 'Non valide';
                    }
                  }
                },
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder(
                valueListenable: categoryNotifier,
                builder: (context, value, child) {
                  return TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Catégorie',
                      suffixIcon: _isCategoryLoading
                          ? const CircularProgressIndicator()
                          : null,
                    ),
                    controller: TextEditingController(text: value),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Titre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: sizeController,
                decoration: const InputDecoration(labelText: 'Taille'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la taille';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: brandController,
                decoration: const InputDecoration(labelText: 'Marque'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la marque';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Prix'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le prix';
                  }
                  try {
                    double.parse(value);
                  } catch (e) {
                    return 'Veuillez entrer un prix valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveClothing,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                child: const Text(
                  'Valider',
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
